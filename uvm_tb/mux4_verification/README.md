# mux4 Verification

Verificacion completa del multiplexor 4:1 parametrizado del laboratorio
Synopsys. Cubre dos fases: TB standalone en SV puro (validacion inicial) y
env UVM completo (fase avanzada con coverage funcional y estructural).

## Estructura
```
mux4_verification/
├── README.md
├── docs/
│ └── TESTPLAN.md # Testplan v2.0 (fase 1 + fase 2)
├── rtl/
│ └── mux4.sv # DUT: mux 4:1 parametrizado combinacional
├── sim/
│ ├── tb_mux4.sv # Fase 1: TB standalone (17 checks)
│ ├── run.sh # Fase 1: compile + sim
│ ├── Makefile # Fase 2: flujo UVM
│ ├── filelist.f # Fase 2: filelist para VCS + UVM
│ └── cm_hier.cfg # Fase 2: filtro de coverage estructural
└── tb/
├── mux4_agent.sv # Fase 2: agent (drv + mon + sqr)
├── mux4_coverage.sv # Fase 2: covergroups funcionales
├── mux4_coverage_seq.sv # Fase 2: sequence de closure
├── mux4_directed_seq.sv # Fase 2: sequence directed
├── mux4_driver.sv # Fase 2: driver via clocking block
├── mux4_env.sv # Fase 2: environment
├── mux4_if.sv # Fase 2: interface con clocking blocks
├── mux4_monitor.sv # Fase 2: monitor con filtro $isunknown
├── mux4_pkg.sv # Fase 2: paquete de infraestructura
├── mux4_scoreboard.sv # Fase 2: scoreboard con reference model
├── mux4_seq_rand.sv # Fase 2: sequence random (500 tx)
├── mux4_test.sv # Fase 2: tests (random, directed, cov, regression)
├── mux4_test_pkg.sv # Fase 2: paquete de tests
├── mux4_transaction.sv # Fase 2: sequence item
└── testbench.sv # Fase 2: top-level del TB UVM
```

## Fase 1 — Standalone TB

TB self-checking en SV puro para validacion inicial del RTL.

### Uso

```bash
cd sim/
./run.sh
```

### Escenarios cubiertos

1. Cada select individual (2'b00, 01, 10, 11)
2. Cambio dinamico de select (verifica combinacional)
3. Valores extremos (all-zero, all-one)
4. Independencia de entradas no seleccionadas
5. Barrido con patrones alternados por din
6. Cambios rapidos (stress combinacional)

### Criterio de sign-off

**17/17 checks PASS**.

## Fase 2 — Env UVM

Env UVM completo con functional coverage, structural coverage, scoreboard
con reference model, y regression suite.

### Uso

```bash
cd sim/

# Regresion completa: los 3 tests + reporte
make regress

# Test individual
make compile
make sim TEST=mux4_directed_test
make cov
```

### Tests disponibles

| Test                   | Proposito                                 |
| ---------------------- | ----------------------------------------- |
| `mux4_random_test`     | 500 transacciones aleatorias              |
| `mux4_directed_test`   | 16 casos borde derivados de la spec       |
| `mux4_coverage_test`   | Closure exhaustivo de covergroups         |
| `mux4_regression_test` | Encadena los 3 en una sola simulacion     |

### Coverage

**Funcional** (2 covergroups en `mux4_coverage.sv`):
- `cg_mux4`: `cp_select` (4 bins), `cp_din1..cp_din4` (5 bins c/u),
  `cp_dout` (5 bins), `cx_select_dout` (20 bins)
- `cg_edge_cases`: `cp_select_din_zero` y `cp_select_din_max` (8 bins)

**Estructural** (VCS `-cm`): line + cond + fsm + tgl + branch + assert.
Filtrado a `mux4` + `testbench` con `sim/cm_hier.cfg`.

### Waivers

- `rtl/mux4.sv`: default del `unique case` (unreachable, envuelto en pragma)
- `tb/testbench.sv`: watchdog `uvm_fatal` (envuelto en pragma)

### Criterio de sign-off

- **Scoreboard:** 0 errores
- **Functional coverage:** `cg_mux4` y `cg_edge_cases` == 100.00%
- **Structural coverage:** score `testbench` >= 99%

### Resultados actuales

- Regresion: 3 tests, **0 errores**
- Groups: **100%**
- Line, cond, toggle, branch: **100%**
- Score total: **100%**

## Nota didactica

El mux4 es uno de los bloques mas simples del lab. Aun asi, se verifica con
dos fases completas y el mismo rigor que los modulos complejos:

- **Fase 1** demuestra que incluso los modulos "triviales" merecen testplan
  formal, checks self-verifying y criterios de aceptacion medibles.
- **Fase 2** demuestra que el patron UVM (interface + agent + scoreboard +
  coverage) escala uniformemente desde bloques simples hasta bloques
  complejos. Este env sirve como plantilla mas ligera para estudiantes
  antes de estudiar envs mas ricos como el de la ALU o el register_bank.

Ambas fases conviven en el mismo bloque, ilustrando la evolucion natural
de una verificacion: validacion rapida (fase 1) -> cierre formal con
coverage (fase 2).

## Fase siguiente

Con el mux4 firmado en fase 2, el patron esta calibrado para replicar en
los envs UVM restantes (mux2, mux4_registered, mux2_registered, memory,
control, top).
