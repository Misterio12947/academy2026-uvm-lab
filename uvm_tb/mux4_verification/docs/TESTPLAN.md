# mux4 — Test Plan

**Bloque:** `mux4` (multiplexor 4:1 parametrizado, combinacional)
**Documento de referencia:** RTL and Verification Lab — Synopsys, Octubre 2025
**Verificado bajo:** `academy2026-uvm-lab / uvm_tb / mux4_verification`
**Herramientas:** VCS V-2023.12-SP2-8, UVM-1.2, URG, Verdi
**Version del testplan:** 2.0

## 1. Alcance

Verificacion completa del mux4 en dos fases:

- **Fase 1 (standalone, v1.0)**: TB self-checking en SV puro para validacion
  inicial del RTL. Firmada con 17/17 checks PASS.
- **Fase 2 (UVM, v2.0)**: env UVM completo con functional coverage,
  structural coverage y regression suite.

## 2. Features del DUT (segun spec)

| ID           | Feature                                        | Referencia spec                  |
| ------------ | ---------------------------------------------- | -------------------------------- |
| FEAT-MUX4-01 | 4 entradas de datos                            | `input [WIDTH-1:0] din1..din4`   |
| FEAT-MUX4-02 | Salida = una de las 4 entradas segun select    | *"4-input multiplexer (mux)"*    |
| FEAT-MUX4-03 | Ancho parametrizable (default WIDTH=8)         | *"variable width"*               |
| FEAT-MUX4-04 | Combinacional (sin registro de salida)         | Spec pide mux4_registered aparte |
| FEAT-MUX4-05 | Interfaz mandatoria                            | *"mandatory"*                    |

## 3. Matriz de requerimientos

### 3.1 Requerimientos funcionales

| ID           | Descripcion                                          | Metodo    | Fase 1 | Fase 2 | Status |
| ------------ | ---------------------------------------------------- | --------- | ------ | ------ | ------ |
| REQ-MUX4-01  | select=2'b00 -> dout = din1                          | DIR + RND + SCB + COV | ESC 1, 2, 3, 5 | `cg_mux4.cp_select.sel_din1`, `alu_directed_seq` | **PASS** |
| REQ-MUX4-02  | select=2'b01 -> dout = din2                          | DIR + RND + SCB + COV | ESC 1, 2, 5    | `cg_mux4.cp_select.sel_din2` | **PASS** |
| REQ-MUX4-03  | select=2'b10 -> dout = din3                          | DIR + RND + SCB + COV | ESC 1, 2, 5    | `cg_mux4.cp_select.sel_din3` | **PASS** |
| REQ-MUX4-04  | select=2'b11 -> dout = din4                          | DIR + RND + SCB + COV | ESC 1, 2, 3, 5 | `cg_mux4.cp_select.sel_din4` | **PASS** |
| REQ-MUX4-05  | WIDTH parametrizable (probado con WIDTH=8)           | STR       | Compile OK    | Compile OK   | **PASS** |
| REQ-MUX4-06  | Salida combinacional (cambio de select refleja sin clk) | DIR + CHK | ESC 2, 6      | Multiples samples/tx | **PASS** |
| REQ-MUX4-07  | Interfaz cumple spec mandatorio                       | REVIEW    | Diff con spec | Diff con spec | **PASS** |

### 3.2 Requerimientos de consistencia

| ID          | Descripcion                                                    | Metodo    | Fase 1 | Fase 2 | Status |
| ----------- | -------------------------------------------------------------- | --------- | ------ | ------ | ------ |
| REQ-CON-01  | Ausencia de latches inferidos                                  | REVIEW    | Compile | Compile | **PASS** |
| REQ-CON-02  | Independencia entre entradas                                    | DIR + CHK | ESC 4  | `cx_select_dout` en todos los rangos | **PASS** |
| REQ-CON-03  | Robustez frente a cambios rapidos de select                    | DIR + CHK | ESC 6  | 500 tx random | **PASS** |
| REQ-CON-04  | Valores extremos (all-zero, all-one) se propagan correctamente | DIR + CHK | ESC 3  | `cg_edge_cases` | **PASS** |
| REQ-CON-05  | Cada select produce salidas en todos los rangos                | COV       | N/A    | `cg_mux4.cx_select_dout` | **PASS** |
| REQ-CON-06  | Cada select propaga din=0x00 y din=0xFF                        | COV       | N/A    | `cg_edge_cases` (8 bins) | **PASS** |

## 4. Fase 1 — Standalone TB

Ver seccion 4 del testplan v1.0 (17 checks, 6 escenarios). Sign-off:
17/17 PASS.

## 5. Fase 2 — Env UVM

### 5.1 Functional coverage — `mux4_coverage.sv`

**`cg_mux4`** — cobertura del comportamiento normal:
- `cp_select` (4 bins): un bin por cada valor de select
- `cp_din1..cp_din4` (5 bins c/u): rangos zero/low/mid/high/max
- `cp_dout` (5 bins): rangos de la salida
- `cx_select_dout` (20 bins): cross que verifica que cada select produce
  salidas en todos los rangos

**`cg_edge_cases`** — cobertura de casos borde:
- `cp_select_din_zero` (4 bins): cada select con din seleccionado en 0x00
- `cp_select_din_max` (4 bins): cada select con din seleccionado en 0xFF

**Meta:** 100% en ambos covergroups.

### 5.2 Structural coverage — VCS `-cm`

Metricas: `line + cond + fsm + tgl + branch + assert`.
Filtrado a DUT + testbench con `sim/cm_hier.cfg`.

**Meta:** >= 99% score en `testbench`.

### 5.3 Waivers

- **`rtl/mux4.sv:23-26`** (default del `unique case`): unreachable-by-design
  (select 2-bit enumerado completo). Envuelto en pragma `// VCS coverage off`.
- **`tb/testbench.sv` watchdog**: `uvm_fatal` defensivo. Envuelto en pragma.

### 5.4 Sequences

| Sequence              | Proposito                                      | # transacciones |
| --------------------- | ---------------------------------------------- | --------------- |
| `mux4_seq_rand`       | Aleatorias con din y select uniformes          | 500             |
| `mux4_directed_seq`   | Casos borde derivados del standalone TB        | 16              |
| `mux4_coverage_seq`   | Closure exhaustivo de covergroups              | ~130            |

### 5.5 Tests

| Test                   | Proposito                                          |
| ---------------------- | -------------------------------------------------- |
| `mux4_random_test`     | 500 transacciones aleatorias                       |
| `mux4_directed_test`   | Casos borde                                        |
| `mux4_coverage_test`   | Closure de covergroups                             |
| `mux4_regression_test` | Encadena los 3 en una sola simulacion              |

## 6. Criterios de aceptacion (Fase 2)

Un run del **`mux4_regression_test`** se considera PASS solo si:

- [ ] **Scoreboard:** `num_errors == 0` en todos los tests
- [ ] **Functional coverage:** `cg_mux4` y `cg_edge_cases` == 100.00%
- [ ] **Structural coverage:** score `testbench` >= 99%
- [ ] **Tests individuales:** `UVM_ERROR: 0` y `UVM_FATAL: 0`
- [ ] **Trazabilidad:** todos los REQ de las secciones 3.1 y 3.2 en PASS
- [ ] **Waivers:** cada hole tiene entrada en la seccion 5.3 con justificacion

### Comando de sign-off (Fase 2)

```bash
cd sim/
make clean
make regress
```

## 7. Referencias

- **Spec del lab:** RTL and Verification Lab — Synopsys, Octubre 2025
- **RTL del DUT:** `rtl/mux4.sv`
- **Standalone TB (Fase 1):** `sim/tb_mux4.sv`, `sim/run.sh`
- **Env UVM (Fase 2):** `tb/mux4_*.sv`, `sim/Makefile`
- **Waivers:** pragmas en `rtl/mux4.sv` y `tb/testbench.sv`
