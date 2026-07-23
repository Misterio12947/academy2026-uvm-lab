# mux2_registered — Test Plan

**Bloque:** `mux2_registered` (mux2 + register_bank con bus 2*WIDTH)
**Documento de referencia:** RTL and Verification Lab — Synopsys, Octubre 2025
**Verificado bajo:** `academy2026-uvm-lab / uvm_tb / mux2_registered_verification`
**Herramientas:** VCS V-2023.12-SP2-8, UVM-1.2, URG, Verdi
**Version del testplan:** 2.0

## 1. Alcance

Verificacion completa del `mux2_registered` en dos fases:

- **Fase 1 (standalone, v1.0)**: 15 checks, 6 escenarios. Firmada.
- **Fase 2 (UVM, v2.0)**: env UVM replicando el patron del
  mux4_registered_verification, adaptado a bus 2*WIDTH y select de 1 bit.

**Nota**: modulo derivado (no en Lab I) necesario para el top del CPU
(senal `selmux2` del control unit).

## 2. Features del DUT

| ID           | Feature                                                    | Referencia                       |
| ------------ | ---------------------------------------------------------- | -------------------------------- |
| FEAT-M2R-01  | 2 entradas de datos de 2*WIDTH bits                        | Necesidad del top del CPU        |
| FEAT-M2R-02  | Salida registrada de 2*WIDTH bits (sincrona)                | Patron de mux4_registered        |
| FEAT-M2R-03  | Reset asincrono activo alto                                  | Convencion del proyecto          |
| FEAT-M2R-04  | Enable de captura (wr_en)                                    | Consistencia con mux4_registered |
| FEAT-M2R-05  | WIDTH externo parametrizable, bus interno 2*WIDTH            | Composicion parametrica          |
| FEAT-M2R-06  | Interfaz consistente con mux4_registered                     | Convencion del proyecto          |

## 3. Matriz de requerimientos

### 3.1 Requerimientos funcionales

| ID           | Descripcion                                                       | Metodo | Fase 1 | Fase 2 | Status |
| ------------ | ----------------------------------------------------------------- | ------ | ------ | ------ | ------ |
| REQ-M2R-01   | Reset asincrono fuerza out=0                                       | DIR + RND + SCB + COV | ESC 1, 4 | `cg_mux2r.cp_rst.high` | **PASS** |
| REQ-M2R-02   | Con wr_en=1: out = mux2(in1, in2, sel) capturado                  | DIR + RND + SCB + COV | ESC 2, 5 | `cg_mux2r.cx_sel_out` | **PASS** |
| REQ-M2R-03   | Con wr_en=0: out mantiene valor previo                            | DIR + RND + SCB + COV | ESC 3   | `cg_hold_duration` | **PASS** |
| REQ-M2R-04   | Reset domina sobre wr_en                                            | DIR + COV | ESC 4  | `cg_mux2r.cx_wr_en_rst.[high][high]` | **PASS** |
| REQ-M2R-05   | WIDTH externo=8 -> bus interno de 16 bits                          | STR    | Compile | Compile | **PASS** |
| REQ-M2R-06   | Interfaz consistente con mux4_registered                          | REVIEW | Diff | Diff | **PASS** |

### 3.2 Requerimientos de composicion

| ID          | Descripcion                                                       | Metodo | Fase 1 | Fase 2 | Status |
| ----------- | ----------------------------------------------------------------- | ------ | ------ | ------ | ------ |
| REQ-COM-01  | mux2 drivea al register_bank con bus de 2*WIDTH                   | REVIEW | Diseno | Diseno | **PASS** |
| REQ-COM-02  | Cambio de din de entrada seleccionada NO afecta out durante hold  | DIR + CHK | ESC 6 | Multiples writes | **PASS** |
| REQ-COM-03  | Ambos selects son alcanzables y capturables                        | DIR + COV | ESC 5 | `cg_mux2r.cp_sel` (2 bins) | **PASS** |
| REQ-COM-04  | Post-reset con wr_en=1 captura en el siguiente edge               | DIR + CHK | ESC 4 | Sequences reset | **PASS** |
| REQ-COM-05  | Transiciones write/hold/reset ejercitadas                          | COV    | N/A    | `cg_transitions.cp_transitions` (8 bins) | **PASS** |
| REQ-COM-06  | Cada select produce salidas en todos los rangos (16-bit)          | COV    | N/A    | `cg_mux2r.cx_sel_out` (10 bins) | **PASS** |
| REQ-COM-07  | Parametrizacion del bus a 2*WIDTH funciona correctamente          | STR + DIR | Todos los ESC | Toggle 16-bit al 100% | **PASS** |

## 4. Fase 1 — Standalone TB

Ver v1.0 del testplan. 15/15 PASS.

## 5. Fase 2 — Env UVM

### 5.1 Functional coverage

**`cg_mux2r`**:
- `cp_wr_en`, `cp_rst`, `cp_sel` (2 bins c/u)
- `cp_out` (5 bins con umbrales 16-bit: 0, [1:0x1FFF], [0x2000:0xDFFF],
  [0xE000:0xFFFE], 0xFFFF)
- `cx_wr_en_rst` (4 bins): incluye `reset_write`
- `cx_sel_out` (10 bins): cada select con salidas en cada rango

**`cg_transitions`**: identico al mux4_registered (4 + 8 bins).

**`cg_hold_duration`** (4 bins): one/short/medium/long_hold.

### 5.2 Structural coverage

Filtrado a `mux2_registered` + `testbench` con `cm_hier.cfg`.

### 5.3 Waivers

- Watchdog `uvm_fatal` envuelto en pragma.

### 5.4 Sequences

| Sequence                       | Proposito                                | # tx |
| ------------------------------ | ---------------------------------------- | ---- |
| `mux2_registered_seq_rand`     | Aleatorias con reset 5%, wr_en 50/50     | 1000 |
| `mux2_registered_directed_seq` | Casos borde: selects, hold, reset+write  | ~15  |
| `mux2_registered_reset_seq`    | Escenarios especificos de reset          | ~15  |
| `mux2_registered_coverage_seq` | Closure de covergroups                   | ~150 |

### 5.5 Tests

| Test                                | Proposito                                    |
| ----------------------------------- | -------------------------------------------- |
| `mux2_registered_random_test`       | 1000 tx aleatorias                           |
| `mux2_registered_directed_test`     | Casos borde                                  |
| `mux2_registered_reset_test`        | Escenarios de reset asincrono                |
| `mux2_registered_coverage_test`     | Closure de covergroups                       |
| `mux2_registered_regression_test`   | Encadena los 4                                |

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

- `../../mux2_verification/rtl/mux2.sv`
- `../../regbank_verification/rtl/register_bank.sv`
- `../rtl/mux2_registered.sv`

## 8. Referencias

- **Spec:** RTL and Verification Lab — Synopsys, Octubre 2025
- **RTL del DUT:** `rtl/mux2_registered.sv`
- **Standalone TB (Fase 1):** `sim/tb_mux2_registered.sv`
- **Env UVM (Fase 2):** `tb/mux2_registered_*.sv`
- **Envs de submodulos:** `mux2_verification/`, `regbank_verification/`
- **Modulo hermano:** `mux4_registered` (patron replicado aqui)
