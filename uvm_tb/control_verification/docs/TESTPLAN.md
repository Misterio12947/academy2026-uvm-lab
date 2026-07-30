# control — Test Plan (Standalone TB)

**Bloque:** `control` (unidad de control del CPU multiciclo, FSM Moore 4 estados)
**Documento de referencia:** RTL and Verification Lab — Synopsys, Octubre 2025
**Verificado bajo:** `academy2026-uvm-lab / uvm_tb / control_verification`
**Herramientas:** VCS V-2023.12-SP2-8
**Version del testplan:** 1.1 (encoding opcode one-hot per revisor feedback)

**Change log:**
- v1.0 (2026-06-XX): version inicial con encoding ISA (opcode = {1'b0, cmd_in[2:0]}). 56/56 PASS.
- v1.1 (2026-07-28): encoding opcode ALU rediseñado a one-hot per revisor feedback. 60/60 PASS.

## 1. Alcance

Validacion standalone del `control`, el modulo mas complejo del Lab III.
Implementa una FSM Moore de 4 estados que orquesta el CPU multiciclo:

- **RST_ST**: captura primer cmd_in del master ("avoid losing one cycle")
- **FETCH_DECODE**: decodifica cmd_in, captura operandos en registros A y B
- **EXECUTE**: ALU computa (y opcionalmente memoryRead para LOAD)
- **STORE**: pulso cpu_rdy, captura siguiente cmd_in, y opcionalmente
  memoryWrite si la instruccion es STORE

## 2. Features del DUT (segun spec e imagenes del laboratorio)

| ID          | Feature                                        | Referencia                  |
| ----------- | ---------------------------------------------- | --------------------------- |
| FEAT-CTL-01 | FSM Moore de 4 estados                         | Diagramas del lab (4 fases) |
| FEAT-CTL-02 | Reset asincrono activo alto lleva a RST_ST     | Convencion del proyecto     |
| FEAT-CTL-03 | Decodificacion de cmd_in [6:5]/[4:3]/[2:0]     | Spec: ISA cmd_in structure  |
| FEAT-CTL-04 | Enables de registro por etapa                  | Spec: "enable stages only when applicable" |
| FEAT-CTL-05 | cpu_rdy pulso de 1 ciclo en STORE              | Spec: "ready when instruction finishes" |
| FEAT-CTL-06 | opcode de 4 bits hacia la ALU (one-hot)        | Spec: *"op input is 4 bits"* + revisor feedback |
| FEAT-CTL-07 | Acceso a memoria segun opcode: LOAD lee en EXECUTE, STORE escribe en STORE | Imagenes 3 y 4 |
| FEAT-CTL-08 | nvalid_data = p_error && feedback              | Spec: "invalid_data when data from feedback loop and previous result was not valid" |
| FEAT-CTL-09 | Interfaz mandatoria del lab                     | Spec: "mandatory interface" |
| FEAT-CTL-10 | Traduccion cmd_in ISA (3 bits) -> opcode ALU one-hot (4 bits) | Revisor feedback |

## 2.1 Encoding del opcode ALU (one-hot per revisor feedback)

El control traduce el ISA de 3 bits (`cmd_in[2:0]`) al encoding one-hot
de 4 bits requerido por la ALU:

| cmd_in[2:0] | ISA       | opcode ALU (one-hot) | Descripcion                     |
| ----------- | --------- | -------------------- | ------------------------------- |
| 3'b000      | ADD       | `4'b0001`            | op[0]=1                         |
| 3'b001      | SUB       | `4'b0010`            | op[1]=1                         |
| 3'b010      | MUL       | `4'b0100`            | op[2]=1                         |
| 3'b011      | DIV       | `4'b1000`            | op[3]=1                         |
| 3'b100      | NOP0      | `4'b0000`            | ALU pasiva                      |
| 3'b101      | LOAD      | `4'b0000`            | ALU pasiva (LOAD usa memoria)   |
| 3'b110      | STORE     | `4'b0000`            | ALU pasiva (STORE usa memoria)  |
| 3'b111      | NOP1      | `4'b0000`            | ALU pasiva                      |

Implementado en el RTL via funcion `cmd_to_alu_opcode` con `unique case`.

## 3. Matriz de requerimientos

### 3.1 Requerimientos funcionales

| ID          | Descripcion                                                       | Metodo    | Escenario TB | Status |
| ----------- | ----------------------------------------------------------------- | --------- | ------------ | ------ |
| REQ-CTL-01  | Reset asincrono lleva a RST_ST                                    | DIR + CHK | ESC 1        | **PASS** |
| REQ-CTL-02  | RST_ST: datain_reg_en=1, resto=0                                  | DIR + CHK | ESC 1        | **PASS** |
| REQ-CTL-03  | FSM transiciona RST_ST -> FETCH_DECODE -> EXECUTE -> STORE       | DIR + CHK | ESC 2        | **PASS** |
| REQ-CTL-04  | FETCH_DECODE: aluin_reg_en=1                                      | DIR + CHK | ESC 2, 6     | **PASS** |
| REQ-CTL-05  | EXECUTE: aluout_reg_en=1                                          | DIR + CHK | ESC 2, 6, 9  | **PASS** |
| REQ-CTL-06  | STORE: cpu_rdy=1, datain_reg_en=1                                 | DIR + CHK | ESC 2, 6, 9  | **PASS** |
| REQ-CTL-07  | cpu_rdy es pulso de 1 ciclo (solo activo en STORE)                | DIR + CHK | ESC 6        | **PASS** |
| REQ-CTL-08  | opcode ALU one-hot: ADD=0001 en EXECUTE                           | DIR + CHK | ESC 2, 9     | **PASS** |
| REQ-CTL-09  | opcode ALU one-hot: SUB=0010 en EXECUTE                           | DIR + CHK | ESC 9        | **PASS** |
| REQ-CTL-10  | in_select_a = cmd_in[6:5], in_select_b = cmd_in[4:3]              | DIR + CHK | ESC 2        | **PASS** |
| REQ-CTL-11  | LOAD: memoryRead=1 y selmux2=1 en EXECUTE, opcode=0000            | DIR + CHK | ESC 3        | **PASS** |
| REQ-CTL-12  | STORE: memoryWrite=1 en STORE (fase final), opcode=0000            | DIR + CHK | ESC 4        | **PASS** |
| REQ-CTL-13  | NOP0/NOP1: no accede memoria, opcode=0000                          | DIR + CHK | ESC 5        | **PASS** |
| REQ-CTL-14  | ADD/SUB/MUL/DIV: no accede memoria                                 | DIR + CHK | ESC 2, 9     | **PASS** |
| REQ-CTL-15  | nvalid_data = p_error AND (muxA==11 OR muxB==11) en EXECUTE       | DIR + CHK | ESC 7        | **PASS** |
| REQ-CTL-16  | Interfaz cumple spec mandatorio                                    | REVIEW    | Diff con spec | **PASS** |
| REQ-CTL-17  | Traduccion ISA -> opcode ALU one-hot en tabla completa (seccion 2.1) | DIR + CHK | ESC 2, 3, 4, 5, 9 | **PASS** |

### 3.2 Requerimientos de consistencia

# control — Test Plan

**Bloque:** `control` (unidad de control del CPU multiciclo, FSM Moore 4 estados)
**Documento de referencia:** RTL and Verification Lab — Synopsys, Octubre 2025
**Verificado bajo:** `academy2026-uvm-lab / uvm_tb / control_verification`
**Herramientas:** VCS V-2023.12-SP2-8, UVM-1.2, URG, Verdi
**Version del testplan:** 2.0 (fase 1 standalone + fase 2 env UVM)

**Change log:**
- v1.0 (2026-06-XX): version inicial con encoding ISA (opcode = {1'b0, cmd_in[2:0]}). 56/56 PASS.
- v1.1 (2026-07-28): encoding opcode ALU rediseñado a one-hot. LOAD/STORE/NOP -> 0000. 60/60 PASS.
- v1.2 (2026-07-29): (a) ALU sin NOP -> LOAD/STORE/NOP mapean a ADD neutro (0001), no 0000, porque la FSM nunca envia 0000. (b) STORE preserva registro de salida (aluout_reg_en=0) para escribir a memoria el dato previo. (c) NOP mantiene estado (aluout_reg_en=0). 63/63 PASS.
- v2.0 (2026-07-30): agregada fase 2 (env UVM completo con reference model, 5 covergroups, regression). Groups 100%, FSM 100%.

---

## 1. Alcance

Verificacion completa del `control`, el modulo mas complejo del Lab III, en
dos fases:

- **Fase 1 (standalone, v1.x)**: TB self-checking en SV puro. 63/63 checks PASS.
- **Fase 2 (UVM, v2.0)**: env UVM con reference model exacto de la logica Moore,
  5 covergroups y regression suite.

El control implementa una FSM Moore de 4 estados que orquesta el CPU multiciclo:

- **RST_ST**: captura primer cmd_in del master ("avoid losing one cycle")
- **FETCH_DECODE**: decodifica cmd_in, captura operandos en registros A y B
- **EXECUTE**: ALU computa (y opcionalmente memoryRead para LOAD)
- **STORE**: pulso cpu_rdy, captura siguiente cmd_in, y opcionalmente
  memoryWrite si la instruccion es STORE

---

## 2. Features del DUT

| ID          | Feature                                        | Referencia                  |
| ----------- | ---------------------------------------------- | --------------------------- |
| FEAT-CTL-01 | FSM Moore de 4 estados                         | Diagramas del lab (4 fases) |
| FEAT-CTL-02 | Reset asincrono activo alto lleva a RST_ST     | Convencion del proyecto     |
| FEAT-CTL-03 | Decodificacion de cmd_in [6:5]/[4:3]/[2:0]     | Spec: ISA cmd_in structure  |
| FEAT-CTL-04 | Enables de registro por etapa                  | Spec: "enable stages only when applicable" |
| FEAT-CTL-05 | cpu_rdy pulso de 1 ciclo en STORE              | Spec: "ready when instruction finishes" |
| FEAT-CTL-06 | opcode de 4 bits hacia la ALU (one-hot)        | Spec: *"op input is 4 bits"* + revisor feedback |
| FEAT-CTL-07 | Acceso a memoria segun opcode: LOAD lee en EXECUTE, STORE escribe en STORE | Imagenes 3 y 4 |
| FEAT-CTL-08 | nvalid_data = p_error && feedback              | Spec: "invalid_data when data from feedback loop and previous result was not valid" |
| FEAT-CTL-09 | Interfaz mandatoria del lab                     | Spec: "mandatory interface" |
| FEAT-CTL-10 | Traduccion cmd_in ISA (3 bits) -> opcode ALU one-hot (4 bits) | Revisor feedback |
| FEAT-CTL-11 | STORE preserva registro de salida para escritura a memoria | Spec: "if store instruction, occurs in this cycle" + interpretacion 1 |
| FEAT-CTL-12 | NOP mantiene el estado (no altera dout ni flags) | Revisor feedback |

### 2.1 Encoding del opcode ALU (one-hot, con ADD neutro)

La ALU tiene exactamente 4 operaciones (ADD/SUB/MUL/DIV). El control traduce
el ISA de 3 bits (`cmd_in[2:0]`) al encoding one-hot de 4 bits. **La FSM
nunca envia 0000**: las instrucciones no-aritmeticas (NOP/LOAD/STORE) envian
ADD (0001) como opcode NEUTRO, y el datapath ignora el resultado.

| cmd_in[2:0] | ISA       | opcode ALU (one-hot) | Resultado usado? |
| ----------- | --------- | -------------------- | ---------------- |
| 3'b000      | ADD       | `4'b0001`            | Si               |
| 3'b001      | SUB       | `4'b0010`            | Si               |
| 3'b010      | MUL       | `4'b0100`            | Si               |
| 3'b011      | DIV       | `4'b1000`            | Si               |
| 3'b100      | NOP0      | `4'b0001` (neutro)   | No (mantiene estado) |
| 3'b101      | LOAD      | `4'b0001` (neutro)   | No (selmux2 toma memoria) |
| 3'b110      | STORE     | `4'b0001` (neutro)   | No (aluout_reg_en=0) |
| 3'b111      | NOP1      | `4'b0001` (neutro)   | No (mantiene estado) |

Implementado en el RTL via funcion `cmd_to_alu_opcode` con `unique case`.

### 2.2 Captura en el registro de salida (aluout_reg_en en EXECUTE)

Tabla del comportamiento de `aluout_reg_en`, que determina que instrucciones
capturan en el registro de salida `{dout_high, dout_low}`:

| ISA op          | aluout_reg_en | Que captura / Por que                          |
| --------------- | ------------- | ---------------------------------------------- |
| ADD/SUB/MUL/DIV | 1             | Captura el resultado de la ALU                 |
| LOAD            | 1             | Captura el dato de memoria (selmux2=1)          |
| STORE           | 0             | Preserva el dato previo para escribirlo a memoria |
| NOP0/NOP1       | 0             | Mantiene el estado (no altera la salida)        |

---

## 3. Matriz de requerimientos

### 3.1 Requerimientos funcionales

| ID          | Descripcion                                                       | Metodo    | Fase 1 (ESC) | Fase 2 (cobertura) | Status |
| ----------- | ----------------------------------------------------------------- | --------- | ------------ | ------------------ | ------ |
| REQ-CTL-01  | Reset asincrono lleva a RST_ST                                    | DIR + CHK + SCB | ESC 1  | Monitor reset handling | **PASS** |
| REQ-CTL-02  | RST_ST: datain_reg_en=1, resto=0                                  | DIR + CHK + SCB | ESC 1  | `cg_control.cp_state.rst_st` | **PASS** |
| REQ-CTL-03  | FSM transiciona RST_ST -> FETCH_DECODE -> EXECUTE -> STORE       | DIR + CHK + COV | ESC 2  | `cg_transitions` (4 bins) | **PASS** |
| REQ-CTL-04  | FETCH_DECODE: aluin_reg_en=1                                      | DIR + CHK + SCB | ESC 2, 6 | `cg_control.cp_state.fetch_decode` | **PASS** |
| REQ-CTL-05  | EXECUTE: aluout_reg_en=1 (operaciones aritmeticas y LOAD)         | DIR + CHK + SCB + COV | ESC 2, 6, 9 | `cg_reg_enables.*_capture` | **PASS** |
| REQ-CTL-06  | STORE: cpu_rdy=1, datain_reg_en=1                                 | DIR + CHK + SCB | ESC 2, 6, 9 | `cg_control.cp_state.store` | **PASS** |
| REQ-CTL-07  | cpu_rdy es pulso de 1 ciclo (solo activo en STORE)                | DIR + CHK | ESC 6 | Scoreboard (por estado) | **PASS** |
| REQ-CTL-08  | opcode ALU one-hot: ADD=0001 en EXECUTE                           | DIR + CHK + COV | ESC 2, 9 | `cg_control.cp_alu_opcode.op_add` | **PASS** |
| REQ-CTL-09  | opcode ALU one-hot: SUB=0010, MUL=0100, DIV=1000                  | DIR + CHK + COV | ESC 9 | `cg_control.cp_alu_opcode` (4 bins) | **PASS** |
| REQ-CTL-10  | in_select_a = cmd_in[6:5], in_select_b = cmd_in[4:3]              | DIR + CHK + SCB | ESC 2 | `cg_control.cp_muxA/cp_muxB` | **PASS** |
| REQ-CTL-11  | LOAD: memoryRead=1 y selmux2=1 en EXECUTE, opcode=0001 (neutro)   | DIR + CHK + SCB | ESC 3 | Scoreboard (LOAD en EXECUTE) | **PASS** |
| REQ-CTL-12  | STORE: memoryWrite=1 en STORE, opcode=0001 (neutro)               | DIR + CHK + SCB | ESC 4 | Scoreboard (STORE state) | **PASS** |
| REQ-CTL-13  | NOP0/NOP1: no accede memoria, opcode=0001 (neutro)                | DIR + CHK + SCB | ESC 5 | Scoreboard (NOP en EXECUTE) | **PASS** |
| REQ-CTL-14  | ADD/SUB/MUL/DIV: no accede memoria                                 | DIR + CHK + SCB | ESC 2, 9 | Scoreboard (memW/memR=0) | **PASS** |
| REQ-CTL-15  | nvalid_data = p_error AND (muxA==11 OR muxB==11) en EXECUTE       | DIR + CHK + COV | ESC 7 | `cg_error_propagation` | **PASS** |
| REQ-CTL-16  | Interfaz cumple spec mandatorio                                    | REVIEW    | Diff con spec | Diff | **PASS** |
| REQ-CTL-17  | Traduccion ISA -> opcode ALU one-hot en tabla completa (sec 2.1)  | DIR + CHK + COV | ESC 2-5, 9 | `cg_alu_opcode_map` (8 mappings) | **PASS** |
| REQ-CTL-18  | STORE preserva registro de salida (aluout_reg_en=0)              | DIR + CHK + COV | ESC 4 | `cg_reg_enables.store_hold` | **PASS** |
| REQ-CTL-19  | NOP0/NOP1 mantienen estado (aluout_reg_en=0)                     | DIR + CHK + COV | ESC 5 | `cg_reg_enables.nop0_hold/nop1_hold` | **PASS** |

### 3.2 Requerimientos de consistencia

| ID          | Descripcion                                                    | Metodo    | Fase 1 (ESC) | Fase 2 | Status |
| ----------- | -------------------------------------------------------------- | --------- | ------------ | ------ | ------ |
| REQ-CON-01  | Reset mid-instruccion vuelve a RST_ST inmediatamente           | DIR + CHK + COV | ESC 8 | `control_reset_seq` + monitor | **PASS** |
| REQ-CON-02  | Back-to-back instructions fluyen sin reset intermedio          | DIR + CHK | ESC 9 | Sequences | **PASS** |
| REQ-CON-03  | p_error=1 sin feedback (muxA/B != 11): nvalid_data=0           | DIR + CHK + COV | ESC 7 | `cg_error_propagation` illegal_bins | **PASS** |
| REQ-CON-04  | p_error=0 con feedback: nvalid_data=0                          | DIR + CHK + COV | ESC 7 | `cg_error_propagation` illegal_bins | **PASS** |
| REQ-CON-05  | Ausencia de latches inferidos (always_comb con defaults)       | REVIEW    | Compile | Compile | **PASS** |
| REQ-CON-06  | Registro de estado usa reset asincrono correctamente           | REVIEW    | Diseno | Monitor reset handling | **PASS** |
| REQ-CON-07  | Funcion cmd_to_alu_opcode con unique case (deteccion multi-hit) | REVIEW   | Compile | Compile | **PASS** |
| REQ-CON-08  | Transiciones de FSM: solo las 4 validas ocurren                | COV       | N/A   | `cg_transitions` illegal_bins (8) | **PASS** |

---

## 4. Fase 1 — Standalone TB

### 4.1 Escenarios

| Escenario | Proposito                                                          | Checks |
| --------- | ------------------------------------------------------------------ | ------ |
| ESC 1     | Reset asincrono lleva a RST_ST                                     | 6      |
| ESC 2     | Ciclo completo ADD (transiciones + outputs + opcode=0001)          | 15     |
| ESC 3     | Ciclo LOAD (memoryRead + selmux2, opcode=0001 neutro)             | 7      |
| ESC 4     | Ciclo STORE (memoryWrite, opcode=0001 neutro, aluout_reg_en=0)    | 7      |
| ESC 5     | NOP0/NOP1 no acceden memoria, opcode=0001, aluout_reg_en=0        | 9      |
| ESC 6     | cpu_rdy es pulso de 1 ciclo                                        | 5      |
| ESC 7     | nvalid_data con p_error + feedback (4 casos)                       | 4      |
| ESC 8     | Reset mid-instruccion vuelve a RST_ST                              | 4      |
| ESC 9     | Back-to-back instructions ADD -> SUB (opcode cambia 0001 -> 0010)  | 6      |
| **Total** |                                                                    | **63** |

### 4.2 Criterio de sign-off (Fase 1)

- Todos los checks `[PASS]`, reporte `>>> ALL TESTS PASSED <<<`
- Sin warnings de compilacion

**Resultado: 63/63 PASS.**

---

## 5. Fase 2 — Env UVM

### 5.1 Reference model

Replica EXACTA de la logica Moore del `control.sv`. Para cada transaccion,
dado `(state_observed, cmd_in, p_error)`, predice las 11 salidas
(aluin_reg_en, datain_reg_en, memoryWrite, memoryRead, selmux2, cpu_rdy,
aluout_reg_en, nvalid_data, in_select_a, in_select_b, opcode) y las compara
con el DUT.

El `state_observed` lo reconstruye el monitor replicando la FSM, porque
`current_state` es interno al RTL (no observable por puerto). Ver README para
el manejo del reset y el riesgo de desincronizacion.

### 5.2 Functional coverage (5 covergroups)

| Covergroup             | Cobertura                                                    |
| ---------------------- | ----------------------------------------------------------- |
| `cg_control`           | `cp_state` (4), `cp_isa_op` (8), `cp_alu_opcode` (4 one-hot), `cp_muxA` (4), `cp_muxB` (4), `cp_p_error` (2), cross `cx_state_isa` (32) |
| `cg_transitions`       | 4 transiciones FSM validas + `illegal_bins` (8 inalcanzables). Sample manual para no contar transiciones a traves de reset |
| `cg_alu_opcode_map`    | Cross ISA op x ALU opcode: verifica la tabla de traduccion completa (8 mappings validos) |
| `cg_error_propagation` | Cross `p_error` x feedback x `nvalid_data` + `illegal_bins` (nvalid=1 requiere p_error && feedback) |
| `cg_reg_enables`       | `aluout_reg_en` por opcode en EXECUTE (8 bins nombrados + `illegal_bins`). Verifica que STORE/NOP0/NOP1 dan 0, resto da 1 |

### 5.3 Structural coverage

Filtrado a `control` + `testbench` con `cm_hier.cfg`. Incluye FSM coverage.

**Meta**: 100% score en `testbench` (incluyendo FSM).

### 5.4 Waivers

- `rtl/control.sv`: defaults del `cmd_to_alu_opcode` y de las transiciones
  (envueltos en pragma coverage off, unreachable-by-design)
- `tb/testbench.sv`: watchdog `uvm_fatal` (pragma)

### 5.5 Sequences

| Sequence                     | Proposito                                | # tx |
| ---------------------------- | ---------------------------------------- | ---- |
| `control_seq_rand`           | Aleatorias (cmd_in, p_error, reset dist) | 1000 |
| `control_directed_seq`       | Cada opcode end-to-end + p_error/feedback | ~60  |
| `control_opcode_sweep_seq`   | Barrido opcode x muxA x muxB              | ~500 |
| `control_reset_seq`          | Resets mid-instruccion en cada estado    | ~30  |
| `control_coverage_seq`       | Closure exhaustivo de los 5 covergroups  | ~150 |

### 5.6 Tests

| Test                          | Proposito                                    |
| ----------------------------- | -------------------------------------------- |
| `control_random_test`         | 1000 tx aleatorias                           |
| `control_directed_test`       | Cada opcode end-to-end + p_error/feedback    |
| `control_opcode_sweep_test`   | Barrido opcode x muxA x muxB                  |
| `control_reset_test`          | Resets mid-instruccion en cada estado        |
| `control_coverage_test`       | Closure exhaustivo                            |
| `control_regression_test`     | Encadena los 5                                |

### 5.7 Criterio de sign-off (Fase 2)

- [x] Scoreboard: 0 errores
- [x] Functional coverage: 100% en los 5 covergroups
- [x] Structural coverage: score `testbench` >= 99% (incluyendo FSM)
- [x] Todos los REQ en PASS

### Comando de sign-off

```bash
cd sim/
make clean
make regress
cat cov_report/dashboard.txt
```

---

## 6. Resultados actuales

**Fase 1:** 63/63 checks PASS.

**Fase 2** (ejecucion 2026-07-30):
- Regresion: 5 tests, **0 errores**, 3510+ transacciones verificadas
- Los 5 covergroups: **100%**
- Structural: **100%** en line, cond, toggle, **FSM**, branch
- Score total: 90.48% (uvm_pkg cosmetico, excluido)

---

## 7. Nota de diseño: reconstruccion del estado en el monitor

El `current_state` de la FSM es interno al `control.sv` (no sale por puerto).
El monitor lo reconstruye replicando la maquina de estados. Existe un riesgo
teorico de desincronizacion monitor-DUT, critico ante el reset asincrono,
mitigado con: deteccion de reset por muestra, re-sincronizacion post-reset, y
el flag `first_after_reset` para no contar transiciones que cruzan un reset.
Ver README del bloque para el detalle completo.

---

## 8. Historico de cambios

| Version | Fecha       | Cambios principales                                                                 |
| ------- | ----------- | ----------------------------------------------------------------------------------- |
| 1.0     | 2026-06-XX  | Version inicial. Encoding ISA (opcode = {1'b0, cmd_in[2:0]}). 56/56 PASS.           |
| 1.1     | 2026-07-28  | Encoding opcode ALU one-hot. LOAD/STORE/NOP -> 0000. 60/60 PASS.                    |
| 1.2     | 2026-07-29  | ALU sin NOP: LOAD/STORE/NOP -> ADD neutro (0001). STORE preserva registro. NOP mantiene estado. 63/63 PASS. |
| **2.0** | **2026-07-30** | **Fase 2 (env UVM): reference model exacto, 5 covergroups, regression. Groups 100%, FSM 100%.** |

---

## 9. Referencias

- **Spec del lab:** RTL and Verification Lab — Synopsys, Octubre 2025
- **Feedback del revisor:** (1) opcode ALU one-hot; (2) ALU solo 4 operaciones, FSM nunca envia 0000, usa ADD neutro; (3) STORE preserva registro para memoria; (4) NOP mantiene estado
- **Diagramas del lab:** 4 imagenes (Reset, Fetch/Decode, Execute, Store)
- **RTL del DUT:** `rtl/control.sv`
- **TB standalone (Fase 1):** `sim/tb_control.sv`
- **Env UVM (Fase 2):** `tb/control_*.sv`
- **RTL relacionado:** `../../alu_verification/rtl/alu.sv` (destino del opcode one-hot)