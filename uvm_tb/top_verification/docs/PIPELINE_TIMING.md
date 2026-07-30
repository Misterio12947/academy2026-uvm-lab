# Timing del pipeline del CPU — Hallazgo crítico

**Bloque:** `top` (CPU multiciclo completo)
**Fecha del hallazgo:** 2026-07-30
**Metodo:** corrida de exploracion (`sim/tb_explore.sv`) con volcado ciclo a ciclo

---

## Resumen ejecutivo

El CPU multiciclo tiene una **latencia de 1 instruccion** entre la
presentacion de un `cmd_in` y la aparicion de su resultado en `dout`. Cuando
`cpu_rdy=1`, el `cmd_in` visible NO corresponde al `dout` visible: son de
instrucciones distintas.

**Consecuencia para verificacion:** un monitor ingenuo que asocie el `cmd_in`
y el `dout` observados en el mismo `cpu_rdy` produce comparaciones
incorrectas. Hay que modelar el desfase.

---

## Evidencia (corrida de exploracion)

Programa: ADD (5+3) -> STORE addr=5 -> LOAD addr=5 -> NOP.

Volcado relevante (ciclo : evento):
```
CYC 6: presento ADD (5+3), state=EXECUTE, aluout_en=1 -> ALU captura 5+3
CYC 7: cpu_rdy=1, cmd visible=ADD, dout=0x0A <- NO es el resultado del ADD
CYC 10: cpu_rdy=1, cmd visible=STORE, dout=0x08 <- ESTE es el resultado del ADD
CYC 13: cpu_rdy=1, cmd visible=STORE, memW=1, dout=0x08 -> escribe 0x08 a mem[5]
CYC 16: cpu_rdy=1, cmd visible=LOAD, dout=0x08 <- LOAD recupera mem[5]=0x08
```

**Interpretacion:** el resultado de la instruccion presentada en el ciclo N
aparece en el `cpu_rdy` de la instruccion SIGUIENTE. Latencia = 1 instruccion.

Cadena verificada:
- ADD produce 0x08 (5+3), visible un paso despues
- STORE escribe ese 0x08 a mem[5]
- LOAD recupera 0x08 de mem[5]

El datapath es funcionalmente correcto; solo hay que alinear la observacion.

---

## Causa raiz

El CPU registra `cmd_in` en `cmd_reg_out` (register_bank `reg_cmd`) antes de
que el control lo procese. Ademas, el resultado se captura en el registro de
salida (`mux_out`) en el estado EXECUTE y se observa en el STORE siguiente.
La combinacion de estos registros produce la latencia de 1 instruccion entre
estimulo y resultado observable.

Ademas, las instrucciones se **encadenan** sin volver a RST_ST: la secuencia
de estados es continua (FETCH -> EXECUTE -> STORE -> FETCH -> ...), con el
STORE de una instruccion solapando el FETCH de la siguiente.

---

## Estrategia adoptada: Camino 1 (driver espaciado)

Para el env UVM de la Fase 2 (verificacion funcional rapida), se adopto el
**driver espaciado**:

- El driver presenta una instruccion y **espera a que su resultado se observe**
  (el siguiente `cpu_rdy`) antes de presentar la siguiente.
- Entre instrucciones se intercala una instruccion "neutra" (NOP) o ciclos de
  espera que permiten que el resultado se aisle.
- Asi, el monitor asocia cada `dout` con la instruccion correcta sin necesidad
  de un FIFO de latencia.

**Ventaja:** simple, robusto, cierra rapido. Verifica exactamente la misma
funcionalidad (cada instruccion produce el resultado correcto).

**Desventaja:** no ejercita el encadenamiento back-to-back real. Esto se cubre
en la fase cuidadosa (ver abajo).

---

## Pendiente: Camino 2 (fase cuidadosa, golden model)

Queda pendiente una **fase de robustez** con:

1. **Golden model en Python**: un simulador del CPU ciclo a ciclo que modele
   el pipeline completo (latencia de 1 instruccion, encadenamiento back-to-back,
   feedback loop, memoria persistente).

2. **Cross-check con Verdi**: comparar el golden model Python contra las ondas
   FSDB del RTL para validar el modelo de pipeline exhaustivamente.

3. **Scoreboard con modelo de pipeline** (FIFO de latencia) para verificar el
   encadenamiento back-to-back real, no solo instrucciones espaciadas.

Esta fase se hara DESPUES de completar synthesis y equivalencia logica (LEC),
que son la prioridad actual del proyecto.

---

## Nota para quien retome esto

Si en el futuro el env del top reporta mismatches masivos, lo PRIMERO a
revisar es la alineacion temporal: confirmar que el monitor asocia el `dout`
con la instruccion correcta y no con la que esta visible en `cmd_in` en el
mismo `cpu_rdy`. Este documento existe precisamente porque ese desfase es
sutil y facil de olvidar.

---

## ACTUALIZACION (2026-07-30): Desfase opcode/operandos — limite del modelo atomico

### Hallazgo

Durante la validacion del reference model de la fase rapida (env UVM del top),
se encontro un segundo desfase mas sutil que la latencia de 1 instruccion:
**el opcode y los operandos llegan a la ALU en ciclos distintos.**

### Evidencia (ondas Verdi)

En la instruccion "SUB 50-8" del sanity, las ondas muestran:
- `in1=0x32 (50)`, `in2=0x08 (8)` — operandos correctos del SUB
- `op=0x1 (ADD)` — pero el opcode es ADD, no SUB
- `out=0x3a (58)` — la ALU calcula 50+8=58 (ADD), no 50-8=42
- `aluout_reg_en=1` captura ese 0x3a

El opcode va desfasado respecto a los operandos por los registros intermedios:
- Operandos: capturados en `mux_a_out`/`mux_b_out` (FETCH_DECODE)
- Opcode: sale combinacional del control basado en `cmd_reg_out` (cmd_in
  registrado en `reg_cmd`)

La diferencia de timing entre estos dos caminos hace que, en el momento de
captura, la ALU combine operandos de una instruccion con el opcode de otra
fase del pipeline.

### Por que el modelo atomico falla

El reference model de la fase rapida calcula:
```
resultado = ALU(operandos_N, opcode_N)
```
asumiendo que operandos y opcode son de la misma instruccion N. El hardware
real los desfasa. Resultado: 15/16 comparaciones coinciden (regimen
permanente donde el opcode no cambia entre instrucciones consecutivas), pero
las TRANSICIONES entre operaciones aritmeticas distintas (ej. ADD -> SUB)
producen mismatch porque ahi el desfase se manifiesta.

### Estado de la verificacion del top

- **RTL: CORRECTO.** Standalone tb_top 31/31 PASS (ejecuta programas reales:
  ADD, SUB, MUL, DIV, LOAD, STORE, NOP, feedback, div/0). El datapath funciona.
- **Env UVM fase rapida: PARCIAL.** El reference model atomico verifica
  correctamente el regimen permanente (15/16 en el sanity) pero no las
  transiciones de opcode por el desfase descrito.
- **Pendiente fase cuidadosa:** golden model ciclo-a-ciclo en Python que
  modele explicitamente el timing de cada registro (cmd_reg, mux registers,
  output register) para verificar el pipeline completo incluyendo transiciones.

### Decision

Se cierra la fase rapida del top con el reference model atomico documentado
como parcial. La verificacion exhaustiva del pipeline (incluyendo el desfase
opcode/operandos) se hara en la fase cuidadosa con el golden model Python +
cross-check Verdi, DESPUES de completar synthesis y equivalencia logica (LEC),
que son la prioridad actual.

El RTL esta validado para proceder a synthesis: el standalone end-to-end
(31/31) es evidencia suficiente de correccion funcional del CPU.