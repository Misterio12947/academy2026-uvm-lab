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

| ID          | Descripcion                                                    | Metodo    | Escenario TB | Status |
| ----------- | -------------------------------------------------------------- | --------- | ------------ | ------ |
| REQ-CON-01  | Reset mid-instruccion vuelve a RST_ST inmediatamente           | DIR + CHK | ESC 8        | **PASS** |
| REQ-CON-02  | Back-to-back instructions fluyen sin reset intermedio          | DIR + CHK | ESC 9        | **PASS** |
| REQ-CON-03  | p_error=1 sin feedback (muxA/B != 11): nvalid_data=0           | DIR + CHK | ESC 7        | **PASS** |
| REQ-CON-04  | p_error=0 con feedback: nvalid_data=0                          | DIR + CHK | ESC 7        | **PASS** |
| REQ-CON-05  | Ausencia de latches inferidos (always_comb con todos defaults) | REVIEW    | Compile      | **PASS** |
| REQ-CON-06  | Registro de estado usa reset asincrono correctamente           | REVIEW    | Diseno       | **PASS** |
| REQ-CON-07  | Funcion cmd_to_alu_opcode con unique case (deteccion multi-hit) | REVIEW    | Compile      | **PASS** |

## 4. Escenarios del TB standalone

| Escenario | Proposito                                                          | Checks |
| --------- | ------------------------------------------------------------------ | ------ |
| ESC 1     | Reset asincrono lleva a RST_ST                                     | 6      |
| ESC 2     | Ciclo completo ADD (transiciones + outputs + opcode=0001)          | 15     |
| ESC 3     | Ciclo LOAD (memoryRead + selmux2, opcode=0000)                     | 7      |
| ESC 4     | Ciclo STORE (memoryWrite, opcode=0000)                             | 6      |
| ESC 5     | NOP0/NOP1 no acceden memoria, opcode=0000 (2 verificaciones extra) | 7      |
| ESC 6     | cpu_rdy es pulso de 1 ciclo                                        | 5      |
| ESC 7     | nvalid_data con p_error + feedback (4 casos)                       | 4      |
| ESC 8     | Reset mid-instruccion vuelve a RST_ST                              | 4      |
| ESC 9     | Back-to-back instructions ADD -> SUB (opcode cambia 0001 -> 0010)  | 6      |
| **Total** |                                                                    | **60** |

## 5. Criterios de aceptacion

Un run del TB standalone se considera PASS si:
- Todos los checks reportan `[PASS]`
- El reporte final muestra `>>> ALL TESTS PASSED <<<`
- No hay warnings de compilacion en VCS

## 6. Fase siguiente: env UVM

Este bloque va a ser el mas rico para verificacion UVM:
- Coverage: cada estado, cada opcode ALU one-hot, transiciones de estado,
  cross con p_error, cross opcode x estado, traduccion ISA -> one-hot
- Sequences: mezcla aleatoria de opcodes ISA, resets aleatorios, propagacion
  de p_error, casos borde
- Reference model: replica FSM + tabla de traduccion one-hot

## 7. Referencias

- **Spec del lab:** RTL and Verification Lab — Synopsys, Octubre 2025
- **Feedback del revisor:** opcode ALU debe usar los 4 bits en encoding one-hot
- **Diagramas del lab:** 4 imagenes (Reset, Fetch/Decode, Execute, Store)
- **RTL del DUT:** `rtl/control.sv`
- **TB standalone:** `sim/tb_control.sv`
- **RTL relacionado:** `../../alu_verification/rtl/alu.sv` (destino del opcode one-hot)