# ALU UVM Verification — Questa / UVM 1.2

Entorno UVM para verificar el ALU del laboratorio RTL & Verification (Synopsys, Oct 2025).

> **Rama `questa`.** Este README documenta el flujo sobre **Questa / Questa One con
> UVM 1.2**. La versión con **VCS + Verdi** vive en la rama `main`. El RTL, el env
> UVM y el testplan son fuente única compartida; solo cambia el harness de `sim/`.

## Estructura del proyecto

```
alu_verification/
├── rtl/
│   └── alu.sv                  # DUT: ALU parametrizada per lab spec
├── tb/
│   ├── alu_if.sv               # Interface con clocking blocks
│   ├── alu_transaction.sv      # Sequence item
│   ├── alu_driver.sv           # Driver
│   ├── alu_monitor.sv          # Monitor
│   ├── alu_coverage.sv         # Componente de coverage funcional
│   ├── alu_agent.sv            # Agent (driver + monitor + sequencer)
│   ├── alu_scoreboard.sv       # Scoreboard con reference model
│   ├── alu_env.sv              # Environment
│   ├── alu_pkg.sv              # Paquete de infraestructura
│   ├── alu_seq_rand.sv         # Sequence aleatoria
│   ├── alu_directed_seq.sv     # Sequence directed (casos borde de la spec)
│   ├── alu_coverage_seq.sv     # Sequence para cerrar coverage
│   ├── alu_test.sv             # Tests (base, random, directed, coverage, regression)
│   ├── alu_test_pkg.sv         # Paquete de tests
│   └── testbench.sv            # Top-level del TB (dump FSDB bajo `ifdef VCS)
└── sim/
    ├── Makefile                # Flujo Questa (comp / opt / sim / cov / regress)
    ├── filelist.f              # Lista de archivos para vlog
    ├── run.do                  # Script de simulacion (ondas + coverage save)
    └── cov_exclude.do          # Exclusiones de coverage (viewcov)
```

## Uso

Flujo clásico de 3 pasos: `vlib` → `vlog` → `vopt` → `vsim`.

```bash
cd sim/

# Regresion completa: random + directed + coverage + reporte con exclusiones
make comp && make opt && make regress

# Test individual
make comp
make opt
make sim TEST=alu_directed_test
make cov

# Debug con ondas
make opt sim WAVE=wlf      TEST=alu_directed_test   # WLF clasico (vsim -view vsim.wlf)
make opt sim WAVE=qwavedb  TEST=alu_directed_test   # Visualizer (make visualizer)
```

Variables: `TEST`, `SEED`, `UVM_VERB`, `WAVE` (`none`|`wlf`|`qwavedb`),
`UVM_VER` (`uvm-1.2` por defecto). Ver `make help`.

## Tests disponibles

| Test                  | Proposito                                                        |
| --------------------- | ---------------------------------------------------------------- |
| `alu_random_test`     | Transacciones aleatorias                                         |
| `alu_directed_test`   | Casos borde derivados de la spec                                 |
| `alu_coverage_test`   | Recorrido exhaustivo para cerrar covergroups                     |
| `alu_regression_test` | Encadena directed + coverage_seq + random en una sola simulacion |

## Resultados de coverage

Última corrida en Questa (`make regress`: random + directed + coverage, 3 tests
acumulados en `merged_excl.ucdb`):

| Metrica            | Valor       | Notas                                              |
| ------------------ | ----------- | -------------------------------------------------- |
| Errores            | 0           | Todos los checks del scoreboard pasan              |
| `cg_alu`           | **100.00%** | Opcodes ISA, invalid_data, zero, error, ranges (33/33 bins) |

### Coverage de código (`+cover=sbcft`, acotado a `ALU` + `testbench`)

Instrumentación acotada a los módulos del diseño y el TB-top (equivalente al
`-cm_hier` de VCS): la UVM precompilada y las clases del TB quedan fuera.

| Instancia            | Statements | Branches | Toggles |
| -------------------- | ---------- | -------- | ------- |
| `ALU` (dut)          | 100% (15/15) | 100% (7/7) | 100% (36/36) |
| `testbench`          | 100% (5/5)   | —          | 100% (2/2)   |
| `alu_if` (vif)       | 100% (9/9)   | —          | 100% (78/78) |

`Cond`: sin bins (los `if` del ALU son de un término → cuentan como branches).
`FSM` / `Assert`: no aplican (ALU combinacional, sin SVA).

## Coverage holes conocidos (unreachable-by-design)

Los siguientes holes son **inalcanzables por construccion del diseno**, no por
gaps del testbench. Se documentan aqui para transparencia y se excluyen via
`cov_exclude.do` (siguiente seccion).

### 1. `rtl/alu.sv` — Default del `unique case`

```systemverilog
default: begin
    out   = MINUS_ONE;
    zero  = 1'b0;
    error = 1'b1;
end
```

**Motivo**: `op[2:0]` son 3 bits con los 8 patrones enumerados (ADD, SUB, MUL,
DIV, NOP0, LOAD, STORE, NOP1). El `default` existe como buena practica
defensiva pero no puede alcanzarse en simulacion 2-estados con opcode valido.

### 2. `tb/testbench.sv` — Watchdog `uvm_fatal`

```systemverilog
initial begin
    #500us;
    `uvm_fatal("TB", "Watchdog: la simulacion excedio 500us")
end
```

**Motivo**: es codigo defensivo del testbench que solo dispara si la simulacion
se cuelga. Que nunca dispare significa que el env es sano.

### 3. Clases UVM y librería UVM

**Motivo**: la UVM precompilada (`-L uvm-1.2`) no se instrumenta, y el código de
las clases del TB (`alu_pkg`, `alu_test_pkg`) queda fuera del `+cover` al acotar
la instrumentación a `ALU` + `testbench`. No ensucian el reporte.

## Estrategia de exclusiones (waivers)

En Questa los holes documentados se cierran con **`coverage exclude`** en
`sim/cov_exclude.do`, aplicado en **report-time** sobre el UCDB fusionado
(modo `viewcov`), equivalente al `urg -elfile` de VCS:

```tcl
coverage exclude -src ../../../rtl/alu.sv   -line 74 75 76 77 78 -comment "..."
coverage exclude -src ../tb/testbench.sv    -line 55 56 57 58    -comment "..."
```

- **Determinista y versionable**: a diferencia de URG (que rechazaba `.el`
  escritos a mano por checksums/IDs internos y obligaba a Verdi interactivo),
  el `coverage exclude` de Questa es texto plano, apto para revisión y CI.
- **Report-time, no sim-time**: aplicarlas al reportar (no durante la sim)
  preserva el comentario del waiver y refleja el mismo modelo que `urg -elfile`.
- **Pragmas `// VCS coverage off/on`**: siguen presentes en el RTL compartido
  (`rtl/alu.sv`) para la rama `main`/VCS. Questa los ignora (son comentarios),
  así que la exclusión efectiva en esta rama la hace `cov_exclude.do`.

**Nota sobre líneas**: como en cualquier exclude-file por línea, los números
corresponden al commit actual de `alu.sv` / `testbench.sv`. Si esos archivos
cambian, ajustar `cov_exclude.do`.

## Notas de diseno del env

- **DUT combinacional**: el `clk` vive solo en el harness para sincronizar
  driver y monitor via clocking blocks y evitar race conditions.
- **Interface signals inicializados a 0**: evita estado X al arranque de
  simulacion, que llevaria al DUT combinacional al `default` case y a
  mismatches espurios con el scoreboard.
- **Monitor con filtro `$isunknown`**: red de seguridad contra estados X
  transitorios.
- **`WIDTH` fijado a 8** en el paquete UVM (simplifica config_db).
- **`uvm_config_db`** usado en forma directa (`set` con path del agent, `get`
  con contexto local), sin queries anidadas.
- **`alu_pkg`** (infraestructura) y **`alu_test_pkg`** (sequences + tests)
  separados para permitir desarrollo independiente de tests.

## Control de versiones

Estructura de commits sugerida para versionar el env en la rama `questa`:

```bash
# Commit del harness Questa
git add sim/Makefile sim/filelist.f sim/run.do sim/cov_exclude.do tb/testbench.sv
git commit -m "feat(alu): migrar env a Questa - vlib/vlog/vopt/vsim, UVM 1.2, coverage + exclusiones"

# Commit de documentacion
git add README.md docs/TESTPLAN.md
git commit -m "docs(alu): documentar flujo Questa (coverage + exclusiones viewcov)"
```
