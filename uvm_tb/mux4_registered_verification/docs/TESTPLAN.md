# mux4_registered — Test Plan

**Bloque:** `mux4_registered` (mux4 + register_bank, compuesto secuencial)
**Documento de referencia:** RTL and Verification Lab — Synopsys, Octubre 2025
**Verificado bajo:** `academy2026-uvm-lab / uvm_tb / mux4_registered_verification`
**Herramientas:** VCS V-2023.12-SP2-8, UVM-1.2, URG, Verdi
**Version del testplan:** 2.0

## 1. Alcance

Verificacion completa del `mux4_registered` en dos fases:

- **Fase 1 (standalone, v1.0)**: 17 checks, 6 escenarios. Firmada.
- **Fase 2 (UVM, v2.0)**: env UVM completo replicando el patron secuencial
  del regbank_verification (reset asincrono, scoreboard con estado interno,
  covergroups de transiciones).

**Enfoque**: el bloque compone dos submodulos ya firmados (mux4 y
register_bank). El env NO re-verifica los submodulos por separado; se enfoca
en la composicion.

## 2. Features del DUT

| ID           | Feature                                                    | Referencia |
| ------------ | ---------------------------------------------------------- | ---------- |
| FEAT-MUXR-01 | 4 entradas + select de 2 bits                              | Lab I      |
| FEAT-MUXR-02 | Salida registrada (sincrona)                                | Lab I      |
| FEAT-MUXR-03 | Reset asincrono activo alto                                 | Convencion |
| FEAT-MUXR-04 | Enable de captura (wr_en)                                    | Lab I      |
| FEAT-MUXR-05 | WIDTH parametrizable                                          | Lab I      |
| FEAT-MUXR-06 | Interfaz mandatoria                                           | Lab I      |

## 3. Matriz de requerimientos

### 3.1 Requerimientos funcionales

| ID           | Descripcion                                                       | Metodo | Fase 1 | Fase 2 | Status |
| ------------ | ----------------------------------------------------------------- | ------ | ------ | ------ | ------ |
| REQ-MUXR-01  | Reset asincrono fuerza out=0                                       | DIR + RND + SCB + COV | ESC 1, 4 | `cg_mux4r.cp_rst.high` | **PASS** |
| REQ-MUXR-02  | Con wr_en=1: out = mux4(in1..in4, sel) capturado                  | DIR + RND + SCB + COV | ESC 2, 5 | `cg_mux4r.cx_sel_out` | **PASS** |
| REQ-MUXR-03  | Con wr_en=0: out mantiene valor previo (hold)                     | DIR + RND + SCB + COV | ESC 3   | `cg_hold_duration` | **PASS** |
| REQ-MUXR-04  | Reset domina sobre wr_en                                            | DIR + COV | ESC 4  | `cg_mux4r.cx_wr_en_rst.[high][high]` | **PASS** |
| REQ-MUXR-05  | WIDTH parametrizable                                                | STR    | Compile | Compile | **PASS** |
| REQ-MUXR-06  | Interfaz mandatoria                                                  | REVIEW | Diff   | Diff   | **PASS** |

### 3.2 Requerimientos de composicion

| ID          | Descripcion                                                    | Metodo | Fase 1 | Fase 2 | Status |
| ----------- | -------------------------------------------------------------- | ------ | ------ | ------ | ------ |
| REQ-COM-01  | mux4 drivea al register_bank correctamente                     | REVIEW | Diseno | Diseno | **PASS** |
| REQ-COM-02  | Cambio de din de entrada seleccionada NO afecta out en hold    | DIR + CHK | ESC 6 | Multiples writes con distinto din | **PASS** |
| REQ-COM-03  | Los 4 selects son alcanzables y capturables                   | DIR + COV | ESC 5 | `cg_mux4r.cp_sel` (4 bins) | **PASS** |
| REQ-COM-04  | Post-reset con wr_en=1 captura en el siguiente edge           | DIR + CHK | ESC 4 | Sequences reset | **PASS** |
| REQ-COM-05  | Transiciones write/hold/reset ejercitadas                     | COV    | N/A    | `cg_transitions.cp_transitions` (8 bins) | **PASS** |
| REQ-COM-06  | Cada select produce salidas en todos los rangos               | COV    | N/A    | `cg_mux4r.cx_sel_out` (20 bins) | **PASS** |

## 4. Fase 1 — Standalone TB

Ver v1.0 del testplan. 17/17 PASS.

## 5. Fase 2 — Env UVM

### 5.1 Functional coverage

**`cg_mux4r`**:
- `cp_wr_en`, `cp_rst` (2 bins c/u)
- `cp_sel` (4 bins)
- `cp_out` (5 bins: zero/low/mid/high/max)
- `cx_wr_en_rst` (4 bins): incluye `reset_write` como en el regbank
- `cx_sel_out` (20 bins): cada select con salidas en cada rango

**`cg_transitions`**:
- `cp_action` (4 bins), `cp_transitions` (8 bins) — mismo patron que regbank

**`cg_hold_duration`** (4 bins): one/short/medium/long_hold

### 5.2 Structural coverage

Filtrado a `mux4_registered` + `testbench` con `cm_hier.cfg`.
No re-cubre `mux4` ni `register_bank` (ya verificados en sus envs).

### 5.3 Waivers

- `rtl/mux4_registered.sv`: no tiene defaults con pragmas (bloque compuesto)
- `tb/testbench.sv`: watchdog envuelto en pragma

### 5.4 Sequences

| Sequence                       | Proposito                                | # tx |
| ------------------------------ | ---------------------------------------- | ---- |
| `mux4_registered_seq_rand`     | Aleatorias con reset 5%, wr_en 50/50     | 1000 |
| `mux4_registered_directed_seq` | Casos borde: selects, hold, reset+write  | ~20  |
| `mux4_registered_reset_seq`    | Escenarios especificos de reset          | ~20  |
| `mux4_registered_coverage_seq` | Closure de covergroups                   | ~200 |

### 5.5 Tests

| Test                                | Proposito                                    |
| ----------------------------------- | -------------------------------------------- |
| `mux4_registered_random_test`       | 1000 tx aleatorias                           |
| `mux4_registered_directed_test`     | Casos borde                                  |
| `mux4_registered_reset_test`        | Escenarios de reset asincrono                |
| `mux4_registered_coverage_test`     | Closure de covergroups                       |
| `mux4_registered_regression_test`   | Encadena los 4 en una sola simulacion        |

## 6. Criterios de aceptacion (Fase 2)

- [ ] Scoreboard: 0 errores
- [ ] Functional coverage: 100% en los 3 covergroups
- [ ] Structural coverage: score `testbench` >= 99%
- [ ] Todos los REQ en PASS

### Comando de sign-off

```bash
cd sim/
make clean
make regress
```

## 7. Dependencias RTL

Este bloque referencia (single source of truth via filelist.f):
- `../../mux4_verification/rtl/mux4.sv`
- `../../regbank_verification/rtl/register_bank.sv`
- `../rtl/mux4_registered.sv`

## 8. Referencias

- **Spec:** RTL and Verification Lab — Synopsys, Octubre 2025
- **RTL del DUT:** `rtl/mux4_registered.sv`
- **Standalone TB (Fase 1):** `sim/tb_mux4_registered.sv`
- **Env UVM (Fase 2):** `tb/mux4_registered_*.sv`
- **Envs de submodulos:** `mux4_verification/`, `regbank_verification/`
