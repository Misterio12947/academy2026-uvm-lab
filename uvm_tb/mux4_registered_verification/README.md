# mux4_registered Verification

Verificacion completa del bloque compuesto `mux4_registered` = mux4 +
register_bank. Cubre dos fases: TB standalone en SV puro (validacion de la
composicion) y env UVM completo (coverage secuencial con reset asincrono).

## Estructura
```
mux4_registered_verification/
├── README.md
├── docs/
│ └── TESTPLAN.md # Testplan v2.0 (fase 1 + fase 2)
├── rtl/
│ └── mux4_registered.sv # DUT compuesto
├── sim/
│ ├── tb_mux4_registered.sv # Fase 1: TB standalone (17 checks)
│ ├── run.sh # Fase 1: compile + sim
│ ├── Makefile # Fase 2: flujo UVM
│ ├── filelist.f # Dependencias RTL sin duplicacion
│ └── cm_hier.cfg # Filtro de coverage
└── tb/
  ├── mux4_registered_agent.sv
  ├── mux4_registered_coverage.sv
  ├── mux4_registered_coverage_seq.sv
  ├── mux4_registered_directed_seq.sv
  ├── mux4_registered_driver.sv
  ├── mux4_registered_env.sv
  ├── mux4_registered_if.sv
  ├── mux4_registered_monitor.sv
  ├── mux4_registered_pkg.sv
  ├── mux4_registered_reset_seq.sv
  ├── mux4_registered_scoreboard.sv
  ├── mux4_registered_seq_rand.sv
  ├── mux4_registered_test.sv
  ├── mux4_registered_test_pkg.sv
  ├── mux4_registered_transaction.sv
  └── testbench.sv
```

## Dependencias RTL (single source of truth)

Este bloque **NO duplica** los RTLs de sus submodulos:

../../mux4_verification/rtl/mux4.sv # ya verificado
../../regbank_verification/rtl/register_bank.sv # ya verificado
../rtl/mux4_registered.sv # RTL de este bloque


## Fase 1 — Standalone TB

TB self-checking para validacion de la composicion. **17/17 checks PASS.**

```bash
cd sim/
./run.sh
```

## Fase 2 — Env UVM

Env UVM completo replicando el patron secuencial del regbank_verification:

```bash
cd sim/
make regress
```

### Tests disponibles

| Test                                | Proposito                                    |
| ----------------------------------- | -------------------------------------------- |
| `mux4_registered_random_test`       | 1000 tx aleatorias                           |
| `mux4_registered_directed_test`     | Casos borde                                  |
| `mux4_registered_reset_test`        | Escenarios de reset asincrono                |
| `mux4_registered_coverage_test`     | Closure de covergroups                       |
| `mux4_registered_regression_test`   | Encadena los 4                                |

### Coverage

**Funcional** (3 covergroups):
- `cg_mux4r`: `cp_wr_en`, `cp_rst`, `cp_sel` (4 bins), `cp_out`,
  `cx_wr_en_rst` (4 bins), `cx_sel_out` (20 bins)
- `cg_transitions`: `cp_action` (4 bins), `cp_transitions` (8 bins)
- `cg_hold_duration`: 4 bins de duracion de hold

**Estructural**: filtrado a `mux4_registered` + `testbench`. No re-cubre
`mux4` ni `register_bank` (ya verificados en sus envs).

### Waivers

- Watchdog `uvm_fatal` en testbench envuelto en pragma.

### Criterio de sign-off

- Scoreboard: 0 errores
- Functional coverage: 100% en los 3 covergroups
- Structural coverage: score `testbench` >= 99%

## Nota didactica: composicion + patron secuencial

Este env ilustra dos conceptos avanzados combinados:

1. **Composicion sin duplicacion**: usa `filelist.f` para referenciar
   submodulos ya verificados. El testplan explicitamente NO re-verifica
   mux4 ni register_bank; solo la composicion.

2. **Patron secuencial**: hereda del regbank_verification todo el manejo
   de reset asincrono, scoreboard con estado interno (opcion A), monitor
   post-edge, dirty/clean reset modes para cerrar `reset_write`.

Es el env mas complejo hasta ahora, pero por composicion de patrones ya
probados en otros bloques.

## Fase siguiente

Con este bloque firmado, sigue `mux2_registered` (mismo patron con bus
2*WIDTH), luego `memory` (introduce address space), `control` (FSM), y
finalmente `top` (integracion completa).
