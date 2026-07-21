# mux2 Verification

Verificacion completa del multiplexor 2:1 parametrizado. Modulo derivado
(no listado en Lab I) necesario para el top del CPU (senal `selmux2` del
control unit). Cubre dos fases: TB standalone en SV puro y env UVM completo.

## Estructura
```
mux2_verification/
├── README.md
├── docs/
│ └── TESTPLAN.md # Testplan v2.0 (fase 1 + fase 2)
├── rtl/
│ └── mux2.sv # DUT: mux 2:1 parametrizado combinacional
├── sim/
│ ├── tb_mux2.sv # Fase 1: TB standalone (16 checks)
│ ├── run.sh # Fase 1: compile + sim
│ ├── Makefile # Fase 2: flujo UVM
│ ├── filelist.f # Fase 2: filelist para VCS + UVM
│ └── cm_hier.cfg # Fase 2: filtro de coverage estructural
└── tb/
├── mux2_agent.sv # Fase 2: agent (drv + mon + sqr)
├── mux2_coverage.sv # Fase 2: covergroups funcionales
├── mux2_coverage_seq.sv # Fase 2: sequence de closure
├── mux2_directed_seq.sv # Fase 2: sequence directed
├── mux2_driver.sv # Fase 2: driver via clocking block
├── mux2_env.sv # Fase 2: environment
├── mux2_if.sv # Fase 2: interface con clocking blocks
├── mux2_monitor.sv # Fase 2: monitor con filtro $isunknown
├── mux2_pkg.sv # Fase 2: paquete de infraestructura
├── mux2_scoreboard.sv # Fase 2: scoreboard con reference model
├── mux2_seq_rand.sv # Fase 2: sequence random (500 tx)
├── mux2_test.sv # Fase 2: tests
├── mux2_test_pkg.sv # Fase 2: paquete de tests
├── mux2_transaction.sv # Fase 2: sequence item
└── testbench.sv # Fase 2: top-level del TB UVM
```

## Fase 1 — Standalone TB

TB self-checking en SV puro para validacion inicial del RTL.

### Uso

```bash
cd sim/
./run.sh
```

### Criterio de sign-off

**16/16 checks PASS**.

## Fase 2 — Env UVM

Env UVM completo replicando el patron firmado del mux4.

### Uso

```bash
cd sim/

# Regresion completa
make regress

# Test individual
make compile
make sim TEST=mux2_directed_test
make cov
```

### Tests disponibles

| Test                   | Proposito                                 |
| ---------------------- | ----------------------------------------- |
| `mux2_random_test`     | 500 transacciones aleatorias              |
| `mux2_directed_test`   | 10 casos borde                             |
| `mux2_coverage_test`   | Closure exhaustivo de covergroups         |
| `mux2_regression_test` | Encadena los 3 en una sola simulacion     |

### Coverage

**Funcional** (2 covergroups):
- `cg_mux2`: `cp_select` (2 bins), `cp_din1`/`cp_din2` (5 bins c/u),
  `cp_dout` (5 bins), `cx_select_dout` (10 bins)
- `cg_edge_cases`: `cp_select_din_zero` y `cp_select_din_max` (4 bins)

**Estructural** (VCS `-cm`): filtrado a `mux2` + `testbench`.

### Waivers

- `rtl/mux2.sv`: default del `unique case` (unreachable, envuelto en pragma)
- `tb/testbench.sv`: watchdog `uvm_fatal` (envuelto en pragma)

### Criterio de sign-off

- **Scoreboard:** 0 errores
- **Functional coverage:** `cg_mux2` y `cg_edge_cases` == 100.00%
- **Structural coverage:** score `testbench` >= 99%

## Nota didactica

El mux2 es esencialmente una version reducida del mux4 (1 bit de select
en vez de 2, 2 entradas en vez de 4). El env UVM aqui es literalmente el
del mux4 con menos coverpoints, ilustrando como el mismo patron escala
inversamente: cuando el DUT es mas simple, el env es proporcionalmente
mas ligero pero mantiene la misma estructura.

## Fase siguiente

Con el mux2 firmado, seguimos con `mux4_registered` (composicion mux4 +
regbank, primer env UVM que ejercita dependencias RTL entre bloques).
