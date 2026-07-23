# mux2_registered Verification

Verificacion completa del bloque compuesto `mux2_registered` = mux2 +
register_bank con bus interno de 2*WIDTH bits. Modulo derivado necesario
para el top del CPU. Cubre dos fases: TB standalone y env UVM.

## Estructura
```
mux2_registered_verification/
├── README.md
├── docs/
│ └── TESTPLAN.md # Testplan v2.0 (fase 1 + fase 2)
├── rtl/
│ └── mux2_registered.sv # DUT compuesto con bus 2*WIDTH
├── sim/
│ ├── tb_mux2_registered.sv # Fase 1: TB standalone (15 checks)
│ ├── run.sh # Fase 1: compile + sim
│ ├── Makefile # Fase 2: flujo UVM
│ ├── filelist.f # Dependencias RTL sin duplicacion
│ └── cm_hier.cfg # Filtro de coverage
└── tb/
├── mux2_registered_agent.sv
├── mux2_registered_coverage.sv
├── mux2_registered_coverage_seq.sv
├── mux2_registered_directed_seq.sv
├── mux2_registered_driver.sv
├── mux2_registered_env.sv
├── mux2_registered_if.sv
├── mux2_registered_monitor.sv
├── mux2_registered_pkg.sv
├── mux2_registered_reset_seq.sv
├── mux2_registered_scoreboard.sv
├── mux2_registered_seq_rand.sv
├── mux2_registered_test.sv
├── mux2_registered_test_pkg.sv
├── mux2_registered_transaction.sv
└── testbench.sv
```

## Dependencias RTL

Single source of truth (sin duplicacion):

../../mux2_verification/rtl/mux2.sv # verificado por separado
../../regbank_verification/rtl/register_bank.sv # verificado por separado
../rtl/mux2_registered.sv # RTL de este bloque


Ambos submodulos se instancian con `WIDTH=2*WIDTH_EXTERNO` (bus interno
de 16 bits con WIDTH=8) para acomodar salidas de la ALU y datos hacia
memoria del CPU.

## Fase 1 — Standalone TB

TB self-checking para validacion de la composicion. **15/15 checks PASS.**

```bash
cd sim/
./run.sh
```

## Fase 2 — Env UVM

Env UVM replicando el patron secuencial del mux4_registered_verification,
adaptado a bus 2*WIDTH y select de 1 bit.

```bash
cd sim/
make regress
```

### Tests disponibles

| Test                                | Proposito                                    |
| ----------------------------------- | -------------------------------------------- |
| `mux2_registered_random_test`       | 1000 tx aleatorias                           |
| `mux2_registered_directed_test`     | Casos borde                                  |
| `mux2_registered_reset_test`        | Escenarios de reset asincrono                |
| `mux2_registered_coverage_test`     | Closure de covergroups                       |
| `mux2_registered_regression_test`   | Encadena los 4                                |

### Coverage

**Funcional** (3 covergroups):
- `cg_mux2r`: `cp_wr_en`, `cp_rst`, `cp_sel` (2 bins), `cp_out` (5 bins
  con umbrales 16-bit), `cx_wr_en_rst` (4 bins), `cx_sel_out` (10 bins)
- `cg_transitions`: `cp_action` (4 bins) + `cp_transitions` (8 bins)
- `cg_hold_duration`: 4 bins

**Estructural**: filtrado a `mux2_registered` + `testbench`.

### Waivers

- Watchdog `uvm_fatal` en testbench envuelto en pragma.

### Criterio de sign-off

- Scoreboard: 0 errores
- Functional coverage: 100% en los 3 covergroups
- Structural coverage: score `testbench` >= 99%

## Nota didactica: escalamiento del patron

Este env es esencialmente **mux4_registered adaptado a bus 16-bit**:
mismos covergroups (con menos bins en `cp_sel` y `cx_sel_out`), mismo
scoreboard reactive, mismo driver con dirty/clean reset modes. Ilustra
como un patron UVM bien calibrado se replica limpiamente entre bloques
similares.

Diferencias clave respecto al mux4_registered:
- Bus interno 16-bit (rangos de `cp_out` expandidos a 0x0000..0xFFFF)
- `cp_sel` con 2 bins (no 4)
- `cx_sel_out` con 10 bins (no 20)
- Directed y reset sequences con ~15 casos (no 20)

## Fase siguiente

Con mux2_registered firmado, quedan por verificar: `memory` (introduce
address space), `control` (FSM), y `top` (integracion completa).
