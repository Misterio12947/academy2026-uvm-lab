# control Verification

Verificacion completa del `control`, la unidad de control del CPU multiciclo
(FSM Moore de 4 estados). Cubre dos fases: TB standalone en SV puro y env UVM
completo con reference model, 5 covergroups y regression suite.

## Estructura
```
control_verification/
├── README.md
├── docs/
│ └── TESTPLAN.md
├── rtl/
│ └── control.sv
├── sim/
│ ├── tb_control.sv # Fase 1: standalone (63 checks)
│ ├── run.sh # Fase 1
│ ├── Makefile # Fase 2
│ ├── filelist.f
│ └── cm_hier.cfg
└── tb/
├── control_agent.sv
├── control_coverage.sv
├── control_coverage_seq.sv
├── control_directed_seq.sv
├── control_driver.sv
├── control_env.sv
├── control_if.sv
├── control_monitor.sv
├── control_opcode_sweep_seq.sv
├── control_pkg.sv
├── control_reset_seq.sv
├── control_scoreboard.sv
├── control_seq_rand.sv
├── control_test.sv
├── control_test_pkg.sv
├── control_transaction.sv
└── testbench.sv
```

## Fase 1 — Standalone TB

**63/63 checks PASS.** 9 escenarios: reset, ciclo completo por opcode,
LOAD/STORE/NOP con acceso a memoria, cpu_rdy pulso, nvalid_data, reset
mid-instruccion, back-to-back.

```bash
cd sim/
./run.sh
```

## Fase 2 — Env UVM

```bash
cd sim/
make regress
```

### Tests disponibles

| Test                          | Proposito                                    |
| ----------------------------- | -------------------------------------------- |
| `control_random_test`         | 1000 tx aleatorias                           |
| `control_directed_test`       | Cada opcode end-to-end + p_error/feedback    |
| `control_opcode_sweep_test`   | Barrido opcode x muxA x muxB                  |
| `control_reset_test`          | Resets mid-instruccion en cada estado        |
| `control_coverage_test`       | Closure exhaustivo                            |
| `control_regression_test`     | Encadena los 5                                |

### Coverage (5 covergroups)

- **`cg_control`**: `cp_state` (4), `cp_isa_op` (8), `cp_alu_opcode` (4 one-hot),
  `cp_muxA` (4), `cp_muxB` (4), `cp_p_error` (2), cross `cx_state_isa`
- **`cg_transitions`**: 4 transiciones FSM validas + `illegal_bins` para las 8 inalcanzables
- **`cg_alu_opcode_map`**: cross ISA op x ALU opcode — verifica la tabla de
  traduccion completa (ADD/SUB/MUL/DIV one-hot; NOP0/LOAD/STORE/NOP1 -> ADD)
- **`cg_error_propagation`**: cross p_error x feedback x nvalid_data con
  `illegal_bins` (nvalid=1 requiere p_error=1 && feedback)
- **`cg_reg_enables`**: cross ISA op x aluout_reg_en en EXECUTE — verifica que
  STORE/NOP0/NOP1 dan aluout_reg_en=0 y el resto da 1 (cubre los fixes del
  encoding one-hot)

### Criterio de sign-off

- Scoreboard: 0 errores
- Functional coverage: 100% en los 5 covergroups
- Structural coverage: score `testbench` >= 99%

## Nota de diseño: reconstruccion del estado en el monitor

**Importante para quien mantenga este env.**

El `current_state` de la FSM es una senal **interna** del `control.sv` — no
sale por ningun puerto del modulo (el RTL esta firmado y no se modifico solo
para verificacion). Por eso, el monitor **reconstruye el estado** replicando
la maquina de estados: mantiene un `model_state` que avanza con cada flanco
de reloj siguiendo la misma logica de transiciones que el RTL
(RST_ST -> FETCH_DECODE -> EXECUTE -> STORE -> FETCH_DECODE).

### Riesgo: desincronizacion monitor-DUT

Como el estado se infiere en vez de observarse directamente, existe un riesgo
teorico de **desincronizacion** entre el `model_state` del monitor y el
`current_state` real del DUT. Esto podria producir falsos MISMATCH en el
scoreboard si ambos se desalinean.

**Punto critico: el reset asincrono.** El `rst` puede caer en cualquier
momento (es asincrono), forzando el DUT a RST_ST fuera del flujo normal de la
FSM. Si el monitor no detectara ese reset, quedaria corrido.

### Mitigacion implementada

El monitor maneja el reset de forma robusta:

1. **Deteccion de reset por muestra**: en cada flanco, el monitor lee `rst`
   del clocking block. Si `rst=1`, resetea `model_state = RST_ST`
   inmediatamente y marca `first_after_reset`, sin emitir transaccion (los
   valores durante reset activo no se verifican como operacion normal).

2. **Re-sincronizacion post-reset**: tras soltar el reset, tanto el DUT como
   el monitor estan en RST_ST, y ambos avanzan sincronizados con el mismo
   reloj. La coherencia se restablece automaticamente.

3. **Verificacion explicita en `control_reset_seq`**: la sequence de reset
   inyecta resets en cada punto de la FSM (FETCH_DECODE, EXECUTE, STORE) y
   luego corre instrucciones completas. Si hubiera desincronizacion, el
   scoreboard lo detectaria como MISMATCH masivo tras el reset. Que el env
   cierre a 0 errores confirma que la re-sincronizacion funciona.

### Alternativa no adoptada

Se podria exponer `current_state` como puerto de debug del RTL (ej.
`output [1:0] dbg_state`) para que el monitor lo lea directamente, eliminando
el riesgo. **No se adopto** para mantener el RTL intacto (ya firmado, 63/63
en standalone). La reconstruccion con manejo robusto de reset es suficiente,
y es una tecnica estandar en verificacion cuando no se quiere instrumentar
el DUT.

## Nota didactica: el env mas complejo del proyecto

Este env integra todo lo aprendido en bloques anteriores:
- **FSM**: coverage de estados y transiciones (con `illegal_bins`)
- **Reference model complejo**: replica exacta de la logica Moore del RTL
- **Reconstruccion de estado**: patron para DUTs con estado interno no observable
- **Coverage de la tabla de traduccion**: `cg_alu_opcode_map` documenta y
  verifica el encoding one-hot pedido por los revisores
- **Coverage de los fixes**: `cg_reg_enables` verifica el comportamiento de
  STORE y NOP (que no capturan en el registro de salida)

## Fase siguiente

Con control firmado, solo queda `top` (integracion end-to-end del CPU
multiciclo) para completar los 9 envs UVM del proyecto.