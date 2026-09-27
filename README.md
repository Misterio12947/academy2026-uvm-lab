# academy2026-uvm-lab — CPU Multiciclo (Synopsys Academy 2026)

CPU multiciclo de 3 etapas (FETCH_DECODE → EXECUTE → STORE), verificado con
UVM y un golden model ciclo-a-ciclo, sintetizado con Design Compiler para
SKY130 y validado con equivalencia logica (Formality).

> **Ramas de verificacion**
> Este repo mantiene el mismo entorno UVM sobre dos simuladores, en ramas separadas:
> - **`main`** — flujo original con **VCS + Verdi** (FSDB, URG, `cm_hier`, `.el`).
> - **`questa`** — el mismo TB migrado a **Questa / Questa One con UVM 1.2**
>   (flujo `vlib/vlog/vopt/vsim`, cobertura con `+cover` + UCDB, ondas WLF o Visualizer).
>
> El RTL, los env UVM y los testplan son fuente unica compartida; solo cambia el
> harness de `sim/`. El `testbench.sv` es comun a ambas ramas: el volcado FSDB
> queda bajo `` `ifdef VCS ``, y en Questa las ondas las gestiona `sim/run.do`.

## Flujo ASIC front-end completo

| Etapa                 | Herramienta       | Resultado                          | Tag / Evidencia         |
| --------------------- | ----------------- | ---------------------------------- | ----------------------- |
| Verificacion funcional| VCS + UVM         | 8 bloques 100% + top standalone 31/31 | `v2.0-uvm-verification` |
| Verificacion del top  | VCS + DPI-C       | golden model ciclo-a-ciclo, 0 mismatches | `v4.0-golden-model`  |
| Synthesis             | Design Compiler   | WNS 0.00, path 8.5ns @ 100MHz, 0 DRC | `v3.0-synthesis-lec`    |
| Equivalencia logica   | Formality         | 190/190 SUCCEEDED (19 Port + 171 DFF) | `v3.0-synthesis-lec`    |

## Estructura del proyecto
```
project/
├── rtl/ # RTL - FUENTE UNICA (verificacion, synthesis y LEC)
├── libs/ # Librerias SKY130 (.db) - ignorado en git
├── syn/ # Flujo de synthesis (Design Compiler)
│ ├── scripts/ # setup, read_design, constraints, compile, run_syn
│ └── work/ # Salidas: outputs/, reports/, logs/ (ruido ignorado)
├── lec/ # Equivalencia logica (Formality)
│ ├── scripts/ # fm.tcl
│ ├── run.sh # runner del LEC
│ └── reports/ # equivalence_summary.rpt + status/passing/failing/unmatched
├── uvm_tb/ # Verificacion UVM (9 bloques)
│ └── <bloque>_verification/
│ ├── tb/ # Env UVM
│ ├── sim/ # Makefile, filelist (apunta a ../../../rtl/), standalone TB
│ └── docs/ # Testplan
│ └── top_verification/
│ └── golden/ # Golden model ciclo-a-ciclo en C (DPI-C)
├── docs/ # Documentacion general
└── scripts/ # Scripts auxiliares
```
## Fuente única de RTL (Opción A - consolidada)

Los RTL viven en un solo lugar: `rtl/`. Es la fuente única usada por
verificación, synthesis y LEC.

- **Verificación**: los `filelist.f` de cada env apuntan a `../../../rtl/X.sv`
  (incluyendo `filelist_golden.f` y `filelist_explore.f` del top)
- **Synthesis**: lee de `rtl/` vía `search_path`
- **LEC**: lee de `rtl/` como reference

Un fix a un RTL se hace en un solo archivo y lo ven todos los flujos. No hay
duplicación que sincronizar.

**Histórico:** antes existían copias en `uvm_tb/<bloque>_verification/rtl/`
(Opción C temporal, para desbloquear synthesis rápido). Se consolidaron a
fuente única, validando que los 9 envs siguen compilando y verificando
correctamente desde `rtl/` (8 envs Compilacion OK, alu coverage 100%,
mux4_registered regresión, top golden model 0 mismatches).

## Flujos

### Verificacion (UVM)
```bash
cd uvm_tb/<bloque>_verification/sim
make compile              # compila el env
make regress              # regresion completa (random + directed + coverage)
./run.sh                  # TB standalone (fase 1)
```
### Verificacion (UVM) — flujo Questa / UVM 1.2  *(rama `questa`)*
 
Flujo clasico de 3 pasos (`vlib` -> `vlog` -> `vopt` -> `vsim`) manejado por
`Makefile` + `run.do`. UVM 1.2 precompilada (paridad con el baseline de VCS),
seleccionada apuntando `-L` a la libreria del install.
 
```bash
cd uvm_tb/<bloque>_verification/sim
make comp                 # vlib work + vlog (compila design + TB)
make opt                  # vopt: +cover (instrumentacion) + visibilidad
make sim  TEST=<test>     # vsim en batch; guarda <test>.ucdb
make regress              # random + directed + coverage; fusiona y reporta
make cov                  # (re)genera reportes desde los .ucdb existentes
make clean                # borra artefactos (work/, *.ucdb, covhtml, ...)
```
 
Variables (`make <target> VAR=valor`):
 
| Variable     | Default              | Para que sirve                                             |
| ------------ | -------------------- | ---------------------------------------------------------- |
| `TEST`       | `alu_regression_test`| Test UVM a correr (`+UVM_TESTNAME`)                        |
| `SEED`       | `1`                  | Semilla (`-sv_seed`)                                        |
| `UVM_VERB`   | `UVM_MEDIUM`         | Verbosidad UVM                                             |
| `WAVE`       | `none`               | Ondas: `none` (rapido) \| `wlf` (clasico) \| `qwavedb` (Visualizer) |
| `UVM_VER`    | `uvm-1.2`            | Version de UVM (`uvm-1.2` \| `uvm-1.1d` \| `uvm` 1800.2)   |
| `QUESTA_ROOT`| ruta del install     | Raiz de Questa (ajustar si el install esta en otra ruta)   |
 
**Ondas / debug:**
```bash
make opt sim WAVE=wlf      TEST=alu_directed_test   # genera .wlf -> vsim -view vsim.wlf
make opt sim WAVE=qwavedb  TEST=alu_directed_test   # Visualizer
make visualizer                                     # abre design.bin + qwave.db
```
 
**Cobertura:** se instrumenta en `vopt` con `+cover=sbcft`
(s=statement, b=branch, c=condition, f=fsm, t=toggle), acotada a los modulos
`ALU` + `testbench` — equivalente al `cm_hier.cfg` de VCS. Cada test guarda su
UCDB (`coverage save -onexit`, para que el `$finish` de UVM no se coma el
guardado); `make cov` los fusiona (`vcover merge`), aplica las exclusiones de
`cov_exclude.do` en modo `viewcov` (equivalente a `urg -elfile`) y emite:
 
- `covhtml/index.html` — reporte HTML
- `cov_report.txt` — cobertura de codigo
- `cov_cvg.txt` — cobertura funcional (covergroups)
**Exclusiones** (holes unreachable-by-design): en `sim/cov_exclude.do`,
via `coverage exclude` (traduccion del `alu_cov_excludes.el` de URG).
 
**Equivalencias VCS -> Questa (resumen):**
 
| VCS / Verdi                        | Questa / Questa One                          |
| ---------------------------------- | -------------------------------------------- |
| `vcs -sverilog -ntb_opts uvm-1.2`  | `vlog -sv -L <uvm-1.2>` + `vopt` + `vsim`    |
| `-cm line+cond+fsm+tgl+branch`     | `+cover=sbcft` (en `vopt`)                    |
| `-cm_hier cm_hier.cfg`             | `+cover` acotado a `ALU`/`testbench`          |
| `+ntb_random_seed=`                | `-sv_seed`                                    |
| `$fsdbDumpvars` + Verdi            | `log -r /*` (WLF) o `-qwavedb` (Visualizer)   |
| `urg -elfile alu_cov_excludes.el`  | `coverage exclude` en `viewcov` (`cov_exclude.do`) |

### Verificacion del top con golden model (DPI-C)
```bash
cd uvm_tb/top_verification/sim
./run_golden.sh           # compara RTL vs golden model C ciclo-a-ciclo
```
Compara las salidas del RTL contra el golden model en C (`golden/cpu_model.c`)
en cada ciclo. Modela el pipeline completo, incluyendo el desfase
opcode/operandos. Ver `golden/README.md`.

### Synthesis (Design Compiler)
Se corre DESDE `syn/work/` para confinar el ruido de DC:
```bash
cd syn/work
mkdir -p reports outputs logs
dc_shell -f ../scripts/run_syn.tcl | tee logs/synthesis.log
```
Salidas: `syn/work/outputs/mapped.v` (netlist), `mapped.sdc`, `mapped.ddc`;
reportes en `syn/work/reports/`.

### Equivalencia logica (Formality)
Se corre DESDE `lec/`:
```bash
cd lec
./run.sh                  # fm_shell -f scripts/fm.tcl | tee formality.log
```
Verifica el RTL (`rtl/`) contra el netlist (`syn/work/outputs/mapped.v`)
usando el SVF de DC (`syn/work/default.svf`) y ambas libs SKY130.
Resultado en `lec/reports/`.

## Estado del proyecto

### Completado
- **8 bloques con env UVM al 100%** de coverage funcional (ALU, register_bank,
  mux4, mux2, mux4_registered, mux2_registered, memory, control)
- **top validado end-to-end**: standalone (31/31 PASS) + golden model
  ciclo-a-ciclo (DPI-C, 0 mismatches en 578 ciclos)
- **Synthesis del top** para SKY130: cierra timing a 100 MHz, 0 violaciones
- **Equivalencia logica**: netlist == RTL (190/190 SUCCEEDED)
- **RTL consolidado** a fuente única en `rtl/` (Opción A)

### Verificacion del top: golden model ciclo-a-ciclo
El desfase opcode/operandos del pipeline (documentado en
`uvm_tb/top_verification/docs/PIPELINE_TIMING.md`) se verifico con un golden
model en C via DPI-C nativo de VCS. Modela cada registro con su timing exacto,
capturando el desfase que el modelo atomico UVM no podia. Validado antes con
cross-check contra un RTL-reference independiente (2053 ciclos, 0 mismatches).

### Cambios arquitecturales incorporados (per revisor feedback)
- Opcode ALU one-hot (ADD=0001, SUB=0010, MUL=0100, DIV=1000)
- ALU con exactamente 4 operaciones (sin NOP); FSM usa ADD neutro para
  instrucciones no-aritmeticas
- STORE preserva el registro de salida para escribir a memoria
- NOP mantiene el estado

Todos atravesaron verificacion + synthesis + LEC sin alterar la logica.

### Pendiente (no bloqueante)
- **P&R (ICC2) + Signoff (PrimeTime)** si se continua el flujo hasta layout

## Tags

| Tag                     | Hito                                              |
| ----------------------- | ------------------------------------------------- |
| `v1.0-rtl-complete`     | RTL de los 9 bloques + TBs standalone             |
| `v2.0-uvm-verification` | Verificacion funcional UVM (8 bloques 100% + top) |
| `v3.0-synthesis-lec`    | Flujo ASIC front-end: synthesis + LEC             |
| `v4.0-golden-model`     | Verificacion del top: golden model ciclo-a-ciclo  |
