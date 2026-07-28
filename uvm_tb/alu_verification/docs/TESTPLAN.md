# Testplan — ALU

**Bloque:** `alu_verification`
**Version:** 1.1 (encoding one-hot per revisor feedback)
**Herramientas:** VCS V-2023.12-SP2-8, UVM-1.2
**Estado:** ✅ SIGNED — Score 100% (line, cond, toggle, branch, groups)
**Change log:**
- v1.0 (2026-05-XX): version inicial con encoding ISA (op[2:0] utiles, op[3] reservado)
- v1.1 (2026-07-28): encoding rediseñado a one-hot per revisor feedback

---

## 1. Alcance

Verificacion funcional y estructural del bloque `ALU` bajo la spec del lab
Synopsys 2025 (RTL and Verification Lab) con el ajuste de encoding one-hot
solicitado por los revisores.

### 1.1 DUT

Modulo `ALU` parametrizado por `WIDTH` (default 8), con:
- **Entradas**: `in1`, `in2` (WIDTH bits c/u), `op[3:0]`, `invalid_data`
- **Salidas**: `out` (2*WIDTH bits), `zero`, `error`
- **Operaciones**: ADD, SUB, MUL, DIV + NOP (ALU pasiva)
- **Encoding del opcode**: one-hot puro (ver seccion 2.1)

### 1.2 Fuera de alcance

- Verificacion del control unit que genera `op` (verificado en `control_verification`)
- Verificacion de codificaciones multi-hot invalidas (default RTL como defensa; envuelto en pragma coverage off)
- Timing dinamico (bloque combinacional puro)

---

## 2. Features del DUT

### 2.1 Encoding del opcode (one-hot per revisor feedback)

Los revisores del lab requirieron que los 4 bits del puerto `op` se usen de
forma significativa. Encoding actualizado a one-hot puro:

| `op[3:0]` | Operacion | Descripcion                                        |
| --------- | --------- | -------------------------------------------------- |
| `4'b0000` | NOP       | ALU pasiva (out=0, zero=1). Enviado por FSM en LOAD/STORE/NOP0/NOP1 |
| `4'b0001` | ADD       | Suma (`op[0]=1`)                                   |
| `4'b0010` | SUB       | Resta (`op[1]=1`)                                  |
| `4'b0100` | MUL       | Multiplicacion (`op[2]=1`)                         |
| `4'b1000` | DIV       | Division (`op[3]=1`)                               |
| otro      | -         | Codificacion invalida (multi-hot). Default: out=-1, error=1 |

### 2.2 Features

| ID           | Feature                                                       | Referencia spec |
| ------------ | ------------------------------------------------------------- | --------------- |
| FEAT-ALU-01  | 4 operaciones aritmeticas (ADD, SUB, MUL, DIV)                | *"addition, subtraction, multiplication and division operations"* |
| FEAT-ALU-02  | Entradas parametrizables (`WIDTH`)                             | *"variable (parameterized) width inputs"* |
| FEAT-ALU-03  | Salida de `2*WIDTH` bits                                       | *"output bus in accordance"* |
| FEAT-ALU-04  | `zero=1` cuando el resultado es 0                              | *"zero[0] asserted when result is 0"* |
| FEAT-ALU-05  | `error=1` en div/0 o `invalid_data=1`                          | *"error[0] asserted when dividing by 0 or input data not valid"* |
| FEAT-ALU-06  | `out=-1` forzado en cualquier error                            | *"On error condition, output must be forced to be -1"* |
| FEAT-ALU-07  | Operaciones descritas con operadores aritmeticos SV            | *"described using Verilog arithmetic operators"* |
| FEAT-ALU-08  | Puerto `op` de 4 bits con encoding one-hot significativo      | *"op input is 4 bits"* + revisor feedback |
| FEAT-ALU-09  | NOP (`op=0000`): ALU pasiva sin efecto sobre datos             | Deducido del encoding one-hot |

---

## 3. Matriz de requerimientos

### 3.1 Requerimientos funcionales por operacion

| ID          | Descripcion                                                       | Metodo               | Cobertura                       | Status |
| ----------- | ----------------------------------------------------------------- | -------------------- | ------------------------------- | ------ |
| REQ-ALU-01  | ADD (`op=0001`): `out = in1 + in2`                                 | DIR + RND + SCB + COV | `cp_op.op_add`                 | **PASS** |
| REQ-ALU-02  | SUB (`op=0010`): `out = in1 - in2`                                 | DIR + RND + SCB + COV | `cp_op.op_sub`                 | **PASS** |
| REQ-ALU-03  | MUL (`op=0100`): `out = in1 * in2` (2*WIDTH bits, sin truncamiento) | DIR + RND + SCB + COV | `cp_op.op_mul` + toggle high  | **PASS** |
| REQ-ALU-04  | DIV (`op=1000`): `out = in1 / in2` cuando `in2 != 0`               | DIR + RND + SCB + COV | `cp_op.op_div`                 | **PASS** |
| REQ-ALU-05  | NOP (`op=0000`): `out=0, zero=1, error=0` (ALU pasiva)              | DIR + RND + SCB + COV | `cp_op.op_nop`                 | **PASS** |

### 3.2 Requerimientos de error

| ID          | Descripcion                                                       | Metodo               | Cobertura                            | Status |
| ----------- | ----------------------------------------------------------------- | -------------------- | ------------------------------------ | ------ |
| REQ-ALU-06  | DIV con `in2=0`: `error=1, out=-1`                                 | DIR + SCB + COV      | `cx_op_in2_zero.div_in2_zero`       | **PASS** |
| REQ-ALU-07  | `invalid_data=1` fuerza `error=1, out=-1` independiente de `op`    | DIR + SCB + COV      | `cx_op_invalid.*_invalid` (5 bins)  | **PASS** |
| REQ-ALU-08  | `out=-1` (MINUS_ONE, `2*WIDTH` all-ones) en toda condicion de error | DIR + SCB + COV     | `cp_out.minus_one`                  | **PASS** |

### 3.3 Requerimientos de flags

| ID          | Descripcion                                                       | Metodo               | Cobertura                       | Status |
| ----------- | ----------------------------------------------------------------- | -------------------- | ------------------------------- | ------ |
| REQ-ALU-09  | `zero=1` cuando `out=0` en operaciones aritmeticas y NOP          | DIR + SCB + COV      | `cp_zero.high`                 | **PASS** |
| REQ-ALU-10  | `zero=0` cuando `out != 0`                                         | RND + SCB + COV      | `cp_zero.low`                  | **PASS** |
| REQ-ALU-11  | `error=1` solo en div/0 o `invalid_data`                           | DIR + RND + SCB      | `cp_error.high` + scoreboard  | **PASS** |
| REQ-ALU-12  | `error=0` en operaciones validas sin `invalid_data`                | RND + SCB            | `cp_error.low`                 | **PASS** |

### 3.4 Requerimientos estructurales

| ID          | Descripcion                                                       | Metodo               | Cobertura                       | Status |
| ----------- | ----------------------------------------------------------------- | -------------------- | ------------------------------- | ------ |
| REQ-ALU-13  | `WIDTH` parametrizable (default 8)                                | STR                  | Compile OK                     | **PASS** |
| REQ-ALU-14  | Encoding one-hot: cada operacion en un bit unico                  | REVIEW + COV         | RTL + `cp_op` (5 bins)         | **PASS** |
| REQ-ALU-15  | Uso de operadores aritmeticos SV (`+`, `-`, `*`, `/`)              | REVIEW               | Diff con spec                  | **PASS** |
| REQ-ALU-16  | Sin latches inferidos (defaults en `always_comb`)                  | REVIEW + LINT        | Compile OK                     | **PASS** |

---

## 4. Coverage

### 4.1 Functional coverage — `alu_coverage.sv`

**`cg_alu`** — un unico covergroup con 7 coverpoints + 2 crosses.

#### Coverpoints

| Coverpoint          | Bins                                                               |
| ------------------- | ------------------------------------------------------------------ |
| `cp_op` (5 bins)    | `op_nop` (0000), `op_add` (0001), `op_sub` (0010), `op_mul` (0100), `op_div` (1000) |
| `cp_in1` (5 bins)   | `zero` (0), `low` ([1:0x1F]), `mid` ([0x20:0xDF]), `high` ([0xE0:0xFE]), `max_val` (0xFF) |
| `cp_in2` (5 bins)   | Mismos rangos que `cp_in1`                                         |
| `cp_out` (5 bins)   | `zero` (0), `low` ([1:0x1FFF]), `mid` ([0x2000:0xDFFF]), `high` ([0xE000:0xFFFE]), `minus_one` (0xFFFF) |
| `cp_invalid_data`   | `low` (0), `high` (1)                                              |
| `cp_zero`           | `low` (0), `high` (1)                                              |
| `cp_error`          | `low` (0), `high` (1)                                              |

#### Crosses criticos

**`cx_op_in2_zero`** — cada operacion con `in2=0` (verifica div-by-zero y bordes)

| Bin              | Cubre                                            |
| ---------------- | ------------------------------------------------ |
| `nop_in2_zero`   | NOP con in2=0 (ALU pasiva, in2 ignorado)         |
| `add_in2_zero`   | ADD con in2=0 (out=in1, no error)                |
| `sub_in2_zero`   | SUB con in2=0 (out=in1, no error)                |
| `mul_in2_zero`   | MUL con in2=0 (out=0, no error)                  |
| `div_in2_zero`   | DIV con in2=0 (out=-1, error=1) — critico       |
| `ignore_bins`    | Descarta bins donde `in2 != 0`                   |

**`cx_op_invalid`** — cada operacion con `invalid_data=1` (verifica error propagado)

| Bin              | Cubre                                            |
| ---------------- | ------------------------------------------------ |
| `nop_invalid`    | NOP con invalid_data=1 (out=-1, error=1)         |
| `add_invalid`    | ADD con invalid_data=1                            |
| `sub_invalid`    | SUB con invalid_data=1                            |
| `mul_invalid`    | MUL con invalid_data=1                            |
| `div_invalid`    | DIV con invalid_data=1                            |
| `ignore_bins`    | Descarta bins donde `invalid_data=0`             |

### 4.2 Structural coverage — VCS `-cm`

Metricas habilitadas: `line + cond + fsm + tgl + branch + assert`.
Filtrado con `sim/cm_hier.cfg` a solo `ALU` + `testbench`.

**Meta**: 100% en score `testbench` y `ALU`.

**Resultado actual**: **100% en LINE, COND, TOGGLE, BRANCH** (FSM y ASSERT no aplican en ALU combinacional).

### 4.3 Waivers

| Archivo         | Ubicacion                     | Justificacion                                    |
| --------------- | ----------------------------- | ------------------------------------------------ |
| `rtl/alu.sv`    | `default` del `unique case`   | Unreachable-by-design en operacion normal (FSM nunca envia op multi-hot). Existe como defensa contra corrupcion de X. Envuelto en `// VCS coverage off/on`. |
| `tb/testbench.sv` | Watchdog `uvm_fatal`         | Timeout defensivo. Envuelto en pragma.           |

---

## 5. Sequences y tests

### 5.1 Sequences

| Sequence           | Proposito                                              | # transacciones |
| ------------------ | ------------------------------------------------------ | --------------- |
| `alu_seq_rand`     | Aleatorias con distribucion balanceada de op          | 500             |
| `alu_directed_seq` | Casos borde: cada op con valores extremos + div/0 + invalid_data | ~25    |
| `alu_coverage_seq` | Closure exhaustivo: 9 fases cubriendo todos los bins  | ~450            |

### 5.2 Tests

| Test                   | Proposito                                          |
| ---------------------- | -------------------------------------------------- |
| `alu_random_test`      | 500 transacciones aleatorias                       |
| `alu_directed_test`    | Casos borde derivados de la spec                   |
| `alu_coverage_test`    | Closure exhaustivo de covergroups                  |
| `alu_regression_test`  | Encadena directed + coverage + random               |

---

## 6. Criterios de aceptacion

Un run del `alu_regression_test` (o del `make regress`) se considera PASS solo si:

- [x] **Scoreboard**: `num_errors == 0`
- [x] **Functional coverage**: `cg_alu` == 100%
- [x] **Structural coverage**: score `testbench` == 100% en LINE, COND, TOGGLE, BRANCH
- [x] **Tests individuales**: `UVM_ERROR: 0` y `UVM_FATAL: 0`
- [x] **Trazabilidad**: todos los REQ de la seccion 3 en PASS
- [x] **Waivers**: cada hole con justificacion en la seccion 4.3

### Comando de sign-off

```bash
cd sim/
make clean
make regress
grep "UVM_ERROR" sim_alu_regression_test.log
cat cov_report/dashboard.txt
```

---

## 7. Resultados actuales

**Ejecucion:** 2026-07-28

- Regresion: 3 tests, **0 errores**, 1058+ transacciones verificadas
- Groups: **100%**
- Line, cond, toggle, branch: **100%**
- Score total: **100%**

**Mejora respecto al 99.38% previo (encoding ISA)**: el encoding one-hot
reduce el espacio de bins de `cp_op` de 8 opcodes ISA (con LOAD, STORE,
NOP0, NOP1 como opcodes de ALU) a 5 bins ALU utiles (NOP, ADD, SUB, MUL,
DIV). Eliminados los huecos por opcodes no-ALU que antes quedaban
parcialmente cubiertos.

---

## 8. Historico de cambios

| Version | Fecha       | Cambios principales                                    |
| ------- | ----------- | ------------------------------------------------------ |
| 1.0     | 2026-05-XX  | Version inicial. Encoding ISA (`op[2:0]` utiles, `op[3]` reservado). Score 99.38%. |
| **1.1** | **2026-07-28** | **Encoding rediseñado a one-hot per revisor feedback. Score 100%. Bins de `cp_op` reducidos de 8 a 5 (NOP + 4 aritmeticas). Nuevos REQ-ALU-08, REQ-ALU-14 para documentar encoding.** |

---

## 9. Referencias

- **Spec del lab:** RTL and Verification Lab — Synopsys, Octubre 2025
- **Feedback del revisor:** Encoding del opcode debe usar los 4 bits de forma significativa (no zero-padding)
- **RTL del DUT:** `rtl/alu.sv`
- **Env UVM:** `tb/alu_*.sv`
- **Waivers:** pragmas en `rtl/alu.sv` y `tb/testbench.sv`