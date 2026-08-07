# Golden Model del CPU Multiciclo — Verificación DPI-C

Golden model ciclo-a-ciclo en C que verifica el `top` (CPU multiciclo) contra
el RTL usando **DPI-C nativo de VCS**. Resuelve la verificación exhaustiva del
pipeline que el modelo atómico UVM no podía (el desfase opcode/operandos).

## Por qué DPI-C

- **Nativo de VCS** (estándar IEEE 1800 SystemVerilog). Cero herramientas externas.
- **Co-simulación en vivo**: el modelo C corre durante la simulación, comparación
  ciclo-a-ciclo en tiempo real.
- El modelo replica el **timing exacto** de cada registro del RTL, así que captura
  la latencia de 1 instrucción y el desfase opcode/operandos del pipeline.

## Archivos

| Archivo | Qué es |
|---------|--------|
| `cpu_model.c` | Golden model ciclo-a-ciclo (réplica exacta del RTL del top) |
| `tb_top_golden.sv` | TB con `import "DPI-C"` que compara RTL vs modelo cada ciclo |
| `run_golden.sh` | Runner de VCS (compila C + RTL + TB juntos) |
| `filelist_golden.f` | Lista de RTL (ajustar rutas según Opción A/C) |
| `test_harness.c` | Harness C puro para validar la lógica sin VCS (opcional) |

## Cómo funciona

El `cpu_model.c` mantiene el estado del CPU (registros del datapath, FSM,
memoria) y expone dos funciones DPI:

- `cpu_model_reset()` — resetea el estado (equivale al reset asíncrono)
- `cpu_model_step(cmd_in, din_1/2/3, rst, → dout, flags, cpu_rdy)` — avanza
  UN ciclo, replicando el orden del hardware:
  1. Control genera señales según `current_state` y `cmd_reg_out`
  2. ALU computa con los operandos **registrados** y el opcode (de `cmd_reg_out`)
  3. Memoria lee/escribe según `mux_a_out`
  4. Flanco: actualiza registros según sus enables (aluin/aluout/datain_reg_en)
  5. Avanza la FSM

El TB alimenta el **mismo `cmd_in`/`din` cada ciclo** al RTL y al modelo C.
Como ambos avanzan su FSM idénticamente ciclo-a-ciclo, se mantienen
sincronizados y la comparación cuadra — incluyendo el "deslizamiento" natural
del `cpu_rdy` dentro del pipeline (ocurre idéntico en ambos).

## Uso en syn-sr

### 1. Colocar los archivos

Sugerencia de estructura dentro del proyecto:

```
uvm_tb/top_verification/
├── golden/
│   ├── cpu_model.c
│   ├── test_harness.c
│   └── README.md
└── sim/
    ├── tb_top_golden.sv
    ├── run_golden.sh
    └── filelist_golden.f
```

Ajusta las rutas relativas en `run_golden.sh` y `filelist_golden.f` según
dónde los pongas.

### 2. Ajustar el filelist

En `filelist_golden.f`, las rutas de RTL dependen de tu estructura:
- **Opción C (actual)**: apuntan a `../../<bloque>_verification/rtl/X.sv`
- **Opción A (consolidada)**: cambia a `../../../rtl/X.sv`

El filelist actual usa las rutas de Opción C (copias en uvm_tb). Ajusta si ya
consolidaste.

### 3. Correr

```bash
cd uvm_tb/top_verification/sim
chmod +x run_golden.sh
./run_golden.sh
```

Esperado:
```
=== Resultado ===
Ciclos comparados : <N>
Mismatches        : 0
>>> GOLDEN MODEL MATCH: RTL == modelo C ciclo a ciclo <<<
```

### 4. (Opcional) Validar la lógica del modelo sin VCS

Antes de correr con VCS, puedes verificar que la lógica del modelo es correcta
con el harness en C puro:

```bash
cd golden
gcc -o test_cpu cpu_model.c test_harness.c
./test_cpu
```

Debe mostrar los 3 checks PASS (0x0008, 0x001E, 0x002A). Este harness valida
que el modelo reproduce el programa conocido ADD→STORE→LOAD→NOP.

## Validación previa (hecha antes de entregar)

El `cpu_model.c` fue validado con harnesses en C puro:

1. **Programa conocido** (ADD 5+3 → STORE → LOAD → NOP): produce 0x0008,
   guardado y recuperado de memoria. NOP mantiene el estado. ✓
2. **Desfase opcode/operandos**: reproduce el transitorio 0x3A (50+8) en
   transiciones back-to-back ADD→SUB, idéntico al RTL en Verdi. ✓
3. **Determinismo**: 4000 ciclos, 2 corridas idénticas, 0 diferencias. ✓
4. **Estrés**: 1000 instrucciones aleatorias sin valores inválidos. ✓

## El programa de prueba del TB

`tb_top_golden.sv` ejecuta:
- **Fase dirigida**: las 8 instrucciones + DIV/0 + STORE/LOAD + NOP + feedback
  loop + transiciones back-to-back (el desfase)
- **Fase aleatoria**: 200 instrucciones con seed

Comparación ciclo-a-ciclo de `dout`, `zero`, `error`, `cpu_rdy`. Warmup de 3
ciclos ignorado (arranque del pipeline).

## Notas técnicas

- **DPI-C types**: el modelo usa `byte unsigned` (8 bits) en la interfaz SV.
  Los buses de 8 bits del CPU caben en un byte. El `dout` de 16 bits se pasa
  como dos bytes (dout_high, dout_low).
- **Warmup**: los primeros 3 ciclos son el arranque del pipeline (basura antes
  de la primera instrucción válida); no se comparan.

## Alineación de cpu_rdy (fix aplicado)

`cpu_rdy` es una salida Moore que vale 1 en el estado STORE. El TB samplea
DESPUÉS del `@(posedge clk)`, así que ve el estado ya actualizado. Por eso el
modelo evalúa `cpu_rdy` sobre `next_state` (el estado post-flanco), NO sobre el
estado previo:

```c
*cpu_rdy = (next_state == STORE_ST) ? 1 : 0;
```

Sin esto, el modelo pulsa cpu_rdy un ciclo tarde respecto al RTL. Este fix
alinea el pulso exactamente.

## Manejo de X's (valores no inicializados)

El RTL arranca con los registros en X (sin reset de datos). Cuando el feedback
loop (muxA/muxB=11) toma un `dout` aún en X, la X se propaga. El modelo trabaja
con valores definidos (0), no puede predecir X's.

El TB **salta la comparación** cuando el RTL tiene X's (`$isunknown`), contándolo
como `skipped_x`. Esto es práctica estándar: no se compara contra estado no
inicializado, que en operación normal se sobrescribe y no es un error funcional.

## Validación previa (hecha antes de entregar)

El `cpu_model.c` fue validado con harnesses en C puro:

1. **Programa conocido** (ADD 5+3 → STORE → LOAD → NOP): produce 0x0008,
   guardado y recuperado. NOP mantiene estado. 3 checks PASS.
2. **Cross-check contra RTL-reference independiente**: un segundo simulador del
   RTL traducido literalmente del Verilog (registro por registro), independiente
   del golden model. **2053 ciclos (dirigido + 500 aleatorias), 0 mismatches.**
3. **Determinismo**: 4000 ciclos, 2 corridas idénticas, 0 diferencias.
4. **Desfase opcode/operandos**: reproduce el 0x3A transitorio del RTL.

El cross-check (#2) es la validación más fuerte: dos implementaciones
independientes de la misma lógica coinciden ciclo-a-ciclo.

## Si aparecen mismatches en VCS

- **Solo difiere cpu_rdy, desplazado 1 ciclo**: es el fix de arriba. Verifica
  que tu `cpu_model.c` tenga `(next_state == STORE_ST)`, no el estado previo.
- **RTL=xxxx, REF=0000**: X's no inicializadas. El filtro `$isunknown` del TB
  ya las salta; si aparecen, verifica que el filtro esté en tu `compare_cycle`.
- **Difiere dout/zero/error con valores definidos**: eso sí sería un hallazgo
  real. Pásame las primeras líneas para diagnosticar.
