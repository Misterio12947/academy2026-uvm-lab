# mux2 — Test Plan

**Bloque:** `mux2` (multiplexor 2:1 parametrizado, combinacional)
**Documento de referencia:** RTL and Verification Lab — Synopsys, Octubre 2025
**Verificado bajo:** `academy2026-uvm-lab / uvm_tb / mux2_verification`
**Herramientas:** VCS V-2023.12-SP2-8, UVM-1.2, URG, Verdi
**Version del testplan:** 2.0

## 1. Alcance

Verificacion completa del mux2 en dos fases:

- **Fase 1 (standalone, v1.0)**: TB self-checking en SV puro. Firmada con
  16/16 checks PASS.
- **Fase 2 (UVM, v2.0)**: env UVM completo con functional coverage,
  structural coverage y regression suite.

**Nota**: el mux2 es un modulo derivado (no listado en Lab I) necesario
para el top del CPU (senal `selmux2` del control unit).

## 2. Features del DUT

| ID          | Feature                                        | Referencia                       |
| ----------- | ---------------------------------------------- | -------------------------------- |
| FEAT-MUX2-01 | 2 entradas de datos                            | `input [WIDTH-1:0] din1, din2`   |
| FEAT-MUX2-02 | Salida = una de las 2 entradas segun select    | Derivado del patron de mux4      |
| FEAT-MUX2-03 | Ancho parametrizable (default WIDTH=8)         | Consistencia con mux4/regbank    |
| FEAT-MUX2-04 | Combinacional (sin registro de salida)         | Sera envuelto en mux2_registered |
| FEAT-MUX2-05 | Interfaz consistente con convenciones del proyecto | Alineado con mux4            |

## 3. Matriz de requerimientos

### 3.1 Requerimientos funcionales

| ID           | Descripcion                                          | Metodo    | Fase 1 | Fase 2 | Status |
| ------------ | ---------------------------------------------------- | --------- | ------ | ------ | ------ |
| REQ-MUX2-01  | select=1'b0 -> dout = din1                           | DIR + RND + SCB + COV | ESC 1, 2, 3, 5 | `cg_mux2.cp_select.sel_din1` | **PASS** |
| REQ-MUX2-02  | select=1'b1 -> dout = din2                           | DIR + RND + SCB + COV | ESC 1, 2, 3, 5 | `cg_mux2.cp_select.sel_din2` | **PASS** |
| REQ-MUX2-03  | WIDTH parametrizable (probado con WIDTH=8)           | STR       | Compile OK | Compile OK | **PASS** |
| REQ-MUX2-04  | Salida combinacional (cambio de select refleja sin clk) | DIR + CHK | ESC 2, 6 | Multiples samples/tx | **PASS** |
| REQ-MUX2-05  | Interfaz consistente con mux4                        | REVIEW    | Convencion | Convencion | **PASS** |

### 3.2 Requerimientos de consistencia

| ID          | Descripcion                                                    | Metodo    | Fase 1 | Fase 2 | Status |
| ----------- | -------------------------------------------------------------- | --------- | ------ | ------ | ------ |
| REQ-CON-01  | Ausencia de latches inferidos                                  | REVIEW    | Compile | Compile | **PASS** |
| REQ-CON-02  | Independencia entre entradas                                    | DIR + CHK | ESC 4  | `cx_select_dout` | **PASS** |
| REQ-CON-03  | Robustez frente a toggle rapido de select                     | DIR + CHK | ESC 6  | 500 tx random | **PASS** |
| REQ-CON-04  | Valores extremos (all-zero, all-one) se propagan correctamente | DIR + CHK | ESC 3  | `cg_edge_cases` | **PASS** |
| REQ-CON-05  | Cada select produce salidas en todos los rangos                | COV       | N/A    | `cg_mux2.cx_select_dout` | **PASS** |
| REQ-CON-06  | Cada select propaga din=0x00 y din=0xFF                        | COV       | N/A    | `cg_edge_cases` (4 bins) | **PASS** |

## 4. Fase 1 — Standalone TB

Ver seccion 4 del testplan v1.0 (16 checks, 6 escenarios). Sign-off:
16/16 PASS.

## 5. Fase 2 — Env UVM

### 5.1 Functional coverage — `mux2_coverage.sv`

**`cg_mux2`**:
- `cp_select` (2 bins): un bin por cada valor de select
- `cp_din1`, `cp_din2` (5 bins c/u): rangos zero/low/mid/high/max
- `cp_dout` (5 bins)
- `cx_select_dout` (10 bins): cross para verificar que cada select produce
  salidas en todos los rangos

**`cg_edge_cases`**:
- `cp_select_din_zero` (2 bins): cada select con din seleccionado en 0x00
- `cp_select_din_max` (2 bins): cada select con din seleccionado en 0xFF

**Meta:** 100% en ambos covergroups.

### 5.2 Structural coverage — VCS `-cm`

Metricas: `line + cond + fsm + tgl + branch + assert`.
Filtrado a DUT + testbench con `sim/cm_hier.cfg`.

**Meta:** >= 99% score en `testbench`.

### 5.3 Waivers

- **`rtl/mux2.sv`**: default del `unique case` envuelto en pragma
- **`tb/testbench.sv`**: watchdog `uvm_fatal` envuelto en pragma

### 5.4 Sequences

| Sequence              | Proposito                                      | # transacciones |
| --------------------- | ---------------------------------------------- | --------------- |
| `mux2_seq_rand`       | Aleatorias con din y select uniformes          | 500             |
| `mux2_directed_seq`   | Casos borde derivados del standalone TB        | 10              |
| `mux2_coverage_seq`   | Closure exhaustivo de covergroups              | ~90             |

### 5.5 Tests

| Test                   | Proposito                                          |
| ---------------------- | -------------------------------------------------- |
| `mux2_random_test`     | 500 transacciones aleatorias                       |
| `mux2_directed_test`   | Casos borde                                        |
| `mux2_coverage_test`   | Closure de covergroups                             |
| `mux2_regression_test` | Encadena los 3 en una sola simulacion              |

## 6. Criterios de aceptacion (Fase 2)

- [ ] **Scoreboard:** 0 errores
- [ ] **Functional coverage:** `cg_mux2` y `cg_edge_cases` == 100.00%
- [ ] **Structural coverage:** score `testbench` >= 99%
- [ ] **Tests individuales:** `UVM_ERROR: 0` y `UVM_FATAL: 0`
- [ ] **Trazabilidad:** todos los REQ en PASS
- [ ] **Waivers:** cada hole con justificacion en seccion 5.3

### Comando de sign-off (Fase 2)

```bash
cd sim/
make clean
make regress
```

## 7. Referencias

- **Spec del lab:** RTL and Verification Lab — Synopsys, Octubre 2025
- **RTL del DUT:** `rtl/mux2.sv`
- **Standalone TB (Fase 1):** `sim/tb_mux2.sv`, `sim/run.sh`
- **Env UVM (Fase 2):** `tb/mux2_*.sv`, `sim/Makefile`
- **Modulo hermano:** `mux4` (verificado en `mux4_verification/`, patron replicado aqui)
