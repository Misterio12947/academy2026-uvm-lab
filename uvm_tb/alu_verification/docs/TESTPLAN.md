# Testplan — ALU

**Bloque:** `alu_verification`
**Version:** 1.2 (solo 4 operaciones, sin NOP)
**Herramientas:** Questa 2025.3, UVM-1.2  *(rama `questa`; la corrida original en VCS V-2023.12-SP2-8 vive en `main`)*
**Estado:** ✅ SIGNED — Score 100% (statement, branch, toggle, groups)

**Change log:**
- v1.0 (2026-05-XX): version inicial con encoding ISA (op[2:0] utiles, op[3] reservado). Score 99.38%.
- v1.1 (2026-07-28): encoding rediseñado a one-hot con NOP=0000. Score 100%.
- v1.2 (2026-07-29): NOP eliminado per revisor feedback. La ALU tiene exactamente 4 operaciones (ADD, SUB, MUL, DIV). La FSM nunca envia 0000; usa ADD como opcode neutro para instrucciones no-aritmeticas. Score 100%.

---

## 1. Alcance

Verificacion funcional y estructural del bloque `ALU` bajo la spec del lab
Synopsys 2025 (RTL and Verification Lab) con el encoding one-hot y las 4
operaciones estrictas solicitadas por los revisores.

### 1.1 DUT

Modulo `ALU` parametrizado por `WIDTH` (default 8), con:
- **Entradas**: `in1`, `in2` (WIDTH bits c/u), `op[3:0]`, `invalid_data`
- **Salidas**: `out` (2*WIDTH bits), `zero`, `error`
- **Operaciones**: exactamente 4 (ADD, SUB, MUL, DIV)
- **Encoding del opcode**: one-hot puro (ver seccion 2.1)

### 1.2 Fuera de alcance

- Verificacion del control unit que genera `op` (verificado en `control_verification`)
- Verificacion de codificaciones invalidas (0000 o multi-hot). La FSM nunca las envia; el default RTL las maneja como defensa (excluido de coverage, ver §4.3)
- Timing dinamico (bloque combinacional puro)

---

## 2. Features del DUT

### 2.1 Encoding del opcode (one-hot, solo 4 operaciones)

Per spec: *"This ALU has to have addition, subtraction, multiplication and
division operations"*. La ALU tiene EXACTAMENTE 4 operaciones, sin NOP ni
modo pasivo.

| `op[3:0]` | Operacion | Descripcion                |
| --------- | --------- | -------------------------- |
| `4'b0001` | ADD       | Suma (`op[0]=1`)           |
| `4'b0010` | SUB       | Resta (`op[1]=1`)          |
| `4'b0100` | MUL       | Multiplicacion (`op[2]=1`) |
| `4'b1000` | DIV       | Division (`op[3]=1`)       |
| otro      | -         | Codificacion invalida (0000 o multi-hot). Default defensivo: out=-1, error=1. NUNCA ejecutado en operacion normal. |

**La FSM siempre envia uno de los 4 opcodes validos.** Para instrucciones
no-aritmeticas (LOAD/STORE/NOP), la FSM envia ADD (`0001`) como opcode
neutro y el datapath ignora el resultado (`selmux2=1` toma memoria en LOAD,
`aluout_reg_en=0` en STORE). El control del feedback loop se hace via
`invalid_data` (per spec del CPU), no via un opcode nulo.

### 2.2 Features

| ID           | Feature                                                       | Referencia spec |
| ------------ | ------------------------------------------------------------- | --------------- |
| FEAT-ALU-01  | 4 operaciones aritmeticas (ADD, SUB, MUL, DIV)                | *"addition, subtraction, multiplication and division operations"* |
| FEAT-ALU-02  | Entradas parametrizables (`WIDTH`)                             | *"variable (parameterized) width inputs"* |
| FEAT-ALU-03  | Salida de `2*WIDTH` bits                                       | *"output bus in accordance"* |
| FEAT-ALU-04  | `zero=1` cuando el resultado es 0                              | *"zero[0] asserted when result is 0"* |
| FEAT-ALU-05  | `error=1` en div/0 o `invalid_data=1`                          | *"error[0] asserted when dividing by 0 or when input data is not valid"* |
| FEAT-ALU-06  | `out=-1` forzado en cualquier error                            | *"On error condition, output must be forced to be -1"* |
| FEAT-ALU-07  | Operaciones descritas con operadores aritmeticos SV            | *"described using Verilog arithmetic operators"* |
| FEAT-ALU-08  | Puerto `op` de 4 bits con encoding one-hot                    | *"op input is 4 bits"* + revisor feedback |
| FEAT-ALU-09  | La ALU tiene exactamente 4 operaciones (sin NOP ni modo pasivo) | Spec + revisor feedback |

---

## 3. Matriz de requerimientos

### 3.1 Requerimientos funcionales por operacion

| ID          | Descripcion                                                       | Metodo                | Cobertura              | Status |
| ----------- | ----------------------------------------------------------------- | --------------------- | ---------------------- | ------ |
| REQ-ALU-01  | ADD (`op=0001`): `out = in1 + in2`                                 | DIR + RND + SCB + COV | `cp_op.op_add`         | **PASS** |
| REQ-ALU-02  | SUB (`op=0010`): `out = in1 - in2`                                 | DIR + RND + SCB + COV | `cp_op.op_sub`         | **PASS** |
| REQ-ALU-03  | MUL (`op=0100`): `out = in1 * in2` (2*WIDTH, sin truncamiento)    | DIR + RND + SCB + COV | `cp_op.op_mul` + toggle high | **PASS** |
| REQ-ALU-04  | DIV (`op=1000`): `out = in1 / in2` cuando `in2 != 0`              | DIR + RND + SCB + COV | `cp_op.op_div`         | **PASS** |

### 3.2 Requerimientos de error

| ID          | Descripcion                                                       | Metodo          | Cobertura                            | Status |
| ----------- | ----------------------------------------------------------------- | --------------- | ------------------------------------ | ------ |
| REQ-ALU-05  | DIV con `in2=0`: `error=1, out=-1`                                 | DIR + SCB + COV | `cx_op_in2_zero.div_in2_zero`       | **PASS** |
| REQ-ALU-06  | `invalid_data=1` fuerza `error=1, out=-1` independiente de `op`    | DIR + SCB + COV | `cx_op_invalid.*_invalid` (4 bins)  | **PASS** |
| REQ-ALU-07  | `out=-1` (MINUS_ONE, `2*WIDTH` all-ones) en toda condicion de error | DIR + SCB + COV | `cp_out.minus_one`                | **PASS** |

### 3.3 Requerimientos de flags

| ID          | Descripcion                                                       | Metodo          | Cobertura              | Status |
| ----------- | ----------------------------------------------------------------- | --------------- | ---------------------- | ------ |
| REQ-ALU-08  | `zero=1` cuando `out=0` en operaciones aritmeticas                | DIR + SCB + COV | `cp_zero.high`         | **PASS** |
| REQ-ALU-09  | `zero=0` cuando `out != 0`                                         | RND + SCB + COV | `cp_zero.low`          | **PASS** |
| REQ-ALU-10  | `error=1` solo en div/0 o `invalid_data`                           | DIR + RND + SCB | `cp_error.high` + scoreboard | **PASS** |
| REQ-ALU-11  | `error=0` en operaciones validas sin `invalid_data`                | RND + SCB + COV | `cp_error.low`         | **PASS** |

### 3.4 Requerimientos estructurales

| ID          | Descripcion                                                       | Metodo          | Cobertura              | Status |
| ----------- | ----------------------------------------------------------------- | --------------- | ---------------------- | ------ |
| REQ-ALU-12  | `WIDTH` parametrizable (default 8)                                | STR             | Compile OK             | **PASS** |
| REQ-ALU-13  | Encoding one-hot: solo 4 operaciones enumeradas (sin NOP)         | REVIEW + COV    | RTL + `cp_op` (4 bins) | **PASS** |
| REQ-ALU-14  | Uso de operadores aritmeticos SV (`+`, `-`, `*`, `/`)              | REVIEW          | Diff con spec          | **PASS** |
| REQ-ALU-15  | Sin latches inferidos (defaults en `always_comb` + default case)  | REVIEW + LINT   | Compile OK             | **PASS** |

---

## 4. Coverage

### 4.1 Functional coverage — `alu_coverage.sv`

**`cg_alu`** — un unico covergroup con 7 coverpoints + 2 crosses.

#### Coverpoints

| Coverpoint          | Bins                                                               |
| ------------------- | ------------------------------------------------------------------ |
| `cp_op` (4 bins)    | `op_add` (0001), `op_sub` (0010), `op_mul` (0100), `op_div` (1000) |
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
| `add_in2_zero`   | ADD con in2=0 (out=in1, no error)                |
| `sub_in2_zero`   | SUB con in2=0 (out=in1, no error)                |
| `mul_in2_zero`   | MUL con in2=0 (out=0, no error)                  |
| `div_in2_zero`   | DIV con in2=0 (out=-1, error=1) — critico        |
| `ignore_bins`    | Descarta bins donde `in2 != 0`                   |

**`cx_op_invalid`** — cada operacion con `invalid_data=1` (verifica error propagado)

| Bin              | Cubre                                            |
| ---------------- | ------------------------------------------------ |
| `add_invalid`    | ADD con invalid_data=1 (out=-1, error=1)         |
| `sub_invalid`    | SUB con invalid_data=1                            |
| `mul_invalid`    | MUL con invalid_data=1                            |
| `div_invalid`    | DIV con invalid_data=1                            |
| `ignore_bins`    | Descarta bins donde `invalid_data=0`             |

### 4.2 Structural coverage — Questa `+cover`

Metricas habilitadas: `+cover=sbcft` (s=statement, b=branch, c=condition,
f=fsm, t=toggle), instrumentado en `vopt`. Instrumentacion acotada a
`ALU` + `testbench` (equivalente al `-cm_hier` de VCS); la UVM precompilada
y el codigo de las clases del TB (`alu_pkg`, `alu_test_pkg`) quedan fuera.

**Meta**: 100% en `ALU` y `testbench`.

**Resultado actual** (`merged_excl.ucdb`):

| Instancia      | Statement | Branch | Toggle |
| -------------- | --------- | ------ | ------ |
| `ALU` (dut)    | 100%      | 100%   | 100%   |
| `testbench`    | 100%      | —      | 100%   |
| `alu_if` (vif) | 100%      | —      | 100%   |

`COND`: sin bins (los `if` del ALU son de un termino → cuentan como branches).
`FSM` / `ASSERT`: no aplican (ALU combinacional, sin SVA).

### 4.3 Waivers / exclusiones

En Questa las exclusiones se aplican con `coverage exclude` desde
`sim/cov_exclude.do`, en report-time sobre el UCDB fusionado (modo `viewcov`,
equivalente a `urg -elfile`):

| Ubicacion                       | Justificacion                                    |
| ------------------------------- | ------------------------------------------------ |
| `rtl/alu.sv`, `default` del `unique case` (líneas 74-78) | Puramente defensivo. La FSM siempre envia uno de los 4 opcodes one-hot validos (nunca 0000 ni multi-hot). Existe solo para evitar latches inferidos y como defensa contra corrupcion de X. No se ejecuta en operacion normal. |
| `tb/testbench.sv`, watchdog `uvm_fatal` (líneas 55-58)   | Timeout defensivo; solo dispara si la sim se cuelga. |

> Los pragmas `// VCS coverage off/on` siguen en el RTL compartido (`rtl/alu.sv`)
> para la rama `main`/VCS; Questa los ignora (son comentarios). La exclusion
> efectiva en esta rama la hace `cov_exclude.do`. Los numeros de linea
> corresponden al commit actual; si el RTL/TB cambia, ajustar el `.do`.

---

## 5. Sequences y tests

### 5.1 Sequences

| Sequence           | Proposito                                              | # transacciones |
| ------------------ | ------------------------------------------------------ | --------------- |
| `alu_seq_rand`     | Aleatorias con 4 opcodes validos (25% c/u)            | 500             |
| `alu_directed_seq` | Casos borde: cada op con valores extremos + div/0 + invalid_data | ~20    |
| `alu_coverage_seq` | Closure exhaustivo: 8 fases cubriendo todos los bins  | ~430            |

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
- [x] **Structural coverage**: `ALU` + `testbench` == 100% en STATEMENT, BRANCH, TOGGLE (COND sin bins)
- [x] **Tests individuales**: `UVM_ERROR: 0` y `UVM_FATAL: 0`
- [x] **Trazabilidad**: todos los REQ de la seccion 3 en PASS
- [x] **Exclusiones**: cada hole con justificacion en la seccion 4.3

### Comando de sign-off

```bash
cd sim/
make clean
make comp && make opt && make regress
grep "UVM_ERROR" sim_alu_regression_test.log
cat cov_report.txt
```

---

## 7. Resultados actuales

**Ejecucion:** en Questa 2025.3 (rama `questa`)

- Regresion: 3 tests, **0 errores**
- Groups: **100%** (`cg_alu`, 33/33 bins)
- Statement, branch, toggle en `ALU`/`testbench`: **100%**
- Score total (vista filtrada, post-exclusiones): **100%**

---

## 8. Historico de cambios

| Version | Fecha       | Cambios principales                                    |
| ------- | ----------- | ------------------------------------------------------ |
| 1.0     | 2026-05-XX  | Version inicial. Encoding ISA (`op[2:0]` utiles, `op[3]` reservado). Score 99.38%. |
| 1.1     | 2026-07-28  | Encoding rediseñado a one-hot con NOP=0000. Score 100%. Bins de `cp_op` = 5. |
| **1.2** | **2026-07-29** | **NOP eliminado per revisor feedback. ALU con exactamente 4 operaciones (ADD, SUB, MUL, DIV). La FSM usa ADD (0001) como opcode neutro para instrucciones no-aritmeticas; nunca envia 0000. `cp_op` reducido de 5 a 4 bins. REQ de NOP pasivo eliminado. Score 100%.** |

---

## 9. Referencias

- **Spec del lab:** RTL and Verification Lab — Synopsys, Octubre 2025
- **Feedback del revisor:** (1) opcode ALU debe usar los 4 bits en encoding one-hot; (2) la ALU tiene exactamente 4 operaciones, sin NOP; la FSM nunca envia 0000
- **RTL del DUT:** `rtl/alu.sv`
- **Env UVM:** `tb/alu_*.sv`
- **Exclusiones:** `sim/cov_exclude.do` (`coverage exclude` en viewcov). Los pragmas `// VCS coverage off/on` permanecen en el RTL compartido para la rama `main`.
