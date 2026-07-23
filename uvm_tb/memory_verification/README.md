# memory Verification

Verificacion completa del bloque `memory` (8 palabras de 2*WIDTH bits) del
Lab I. Cubre dos fases: TB standalone en SV puro y env UVM completo con
reference model (array asociativo) y coverage exhaustivo de address space.

## Estructura
```
memory_verification/
├── README.md
├── docs/
│ └── TESTPLAN.md # Testplan v2.0 (fase 1 + fase 2)
├── rtl/
│ └── memory.sv # DUT: 8 palabras, write sinc / read asinc
├── sim/
│ ├── tb_memory.sv # Fase 1: TB standalone (11 checks)
│ ├── run.sh # Fase 1: compile + sim
│ ├── Makefile # Fase 2: flujo UVM
│ ├── filelist.f # Fase 2: filelist
│ └── cm_hier.cfg # Filtro de coverage estructural
└── tb/
├── memory_agent.sv
├── memory_coverage.sv
├── memory_coverage_seq.sv
├── memory_directed_seq.sv
├── memory_driver.sv
├── memory_env.sv
├── memory_if.sv
├── memory_monitor.sv
├── memory_pkg.sv
├── memory_scoreboard.sv # Con array asociativo y written_mask
├── memory_seq_rand.sv
├── memory_test.sv
├── memory_test_pkg.sv
├── memory_transaction.sv
├── memory_write_all_seq.sv # Setup de direcciones antes de reads
└── testbench.sv
```

## Fase 1 — Standalone TB

```bash
cd sim/
./run.sh
```

**11/11 checks PASS.**

## Fase 2 — Env UVM

```bash
cd sim/
make regress
```

### Tests disponibles

| Test                     | Proposito                                    |
| ------------------------ | -------------------------------------------- |
| `memory_random_test`     | write_all + 1000 tx aleatorias               |
| `memory_directed_test`   | Casos borde                                  |
| `memory_coverage_test`   | Closure de covergroups                       |
| `memory_regression_test` | Encadena los 4                                |

### Coverage

**Funcional** (3 covergroups):
- `cg_memory`: `cp_addr` (8 bins individuales), `cp_wr_en`/`cp_rd_en`,
  `cp_write_data`/`cp_read_data` (5 rangos c/u con `iff`),
  `cx_addr_wr_en` y `cx_addr_rd_en` (16 bins c/u)
- `cg_access_patterns`: idle/read_only/write_only/write_read (4 bins)
- `cg_transitions`: write-then-read por cada direccion (8 bins)

**Estructural**: filtrado a `memory` + `testbench`.

### Waivers

- Watchdog `uvm_fatal` en testbench envuelto en pragma.

### Criterio de sign-off

- Scoreboard: 0 errores
- Functional coverage: 100% en los 3 covergroups
- Structural coverage: score `testbench` >= 99%

## Nota didactica: address space + scoreboard con modelo persistente

Este env introduce un patron nuevo en el proyecto: **scoreboard con
reference model persistente** (array asociativo `model_mem[0:7]`). A
diferencia de los muxes/regbank donde el scoreboard mantiene un solo
`model_reg`, aqui el modelo es un mapa direccion -> dato.

Elementos clave del patron:
- `written_mask` filtra reads a direcciones no escritas (uninit)
- Verificacion del gating: cuando `memoryRead=0`, el DUT debe forzar
  `data_out=0` (verificado en cada tx, no solo cuando hay read valido)
- `memory_write_all_seq` popula las 8 direcciones antes de que los tests
  aleatorios generen reads — evita reportar false positives por reads a
  direcciones nunca escritas

## Fase siguiente

Con memory firmada, quedan por verificar `control` (FSM, coverage por
estado y opcode) y `top` (integracion completa del CPU).
