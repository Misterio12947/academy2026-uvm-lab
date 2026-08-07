# academy2026-uvm-lab — CPU Multiciclo (Synopsys Academy 2026)

CPU multiciclo de 3 etapas (FETCH_DECODE → EXECUTE → STORE), verificado con
UVM y un golden model ciclo-a-ciclo, sintetizado con Design Compiler para
SKY130 y validado con equivalencia logica (Formality).

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
├── rtl/ # RTL canonico (fuente para synthesis)
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
│ ├── rtl/ # RTL del bloque (ver NOTA de duplicacion)
│ ├── tb/ # Env UVM
│ ├── sim/ # Makefile, filelist, standalone TB
│ └── docs/ # Testplan
│ └── top_verification/
│ └── golden/ # Golden model ciclo-a-ciclo en C (DPI-C)
├── docs/ # Documentacion general
└── scripts/ # Scripts auxiliares
```
## NOTA IMPORTANTE: duplicacion de RTL (pendiente de consolidar)

**Estado actual (Opcion C - temporal):**
Los RTL existen en DOS lugares:
1. `rtl/` — copia canonica usada por synthesis y LEC
2. `uvm_tb/<bloque>_verification/rtl/` — copias usadas por verificacion

Esto es una duplicacion temporal para desbloquear synthesis rapido. **Riesgo:
si editas un RTL, debes actualizar AMBAS copias** o divergiran.

**Pendiente (Opcion A - consolidacion):**
Migrar a fuente unica: mover todos los RTL a `rtl/`, borrar los
`uvm_tb/*/rtl/`, y actualizar los `filelist.f` de cada env UVM para apuntar
a `../../../rtl/<archivo>.sv`. Esto restablece "single source of truth".

### Checklist para la consolidacion (Opcion A) - PENDIENTE

- [ ] Verificar que `rtl/` tiene la version mas reciente de cada RTL
      (los ultimos fixes: encoding one-hot, ALU 4 ops, STORE, NOP)
- [ ] Actualizar los 9 `filelist.f` en `uvm_tb/*_verification/sim/`:
      cambiar `../../<bloque>_verification/rtl/X.sv` -> `../../../rtl/X.sv`
- [ ] Actualizar el `filelist.f` del top (referencia varios submodulos)
- [ ] Actualizar `filelist_golden.f` del golden model (mismas rutas de RTL)
- [ ] Correr `make regress` en cada env para confirmar que la verificacion
      sigue funcionando tras el cambio de rutas
- [ ] Borrar los directorios `uvm_tb/*/rtl/`
- [ ] Actualizar esta seccion del README

**IMPORTANTE:** mientras la Opcion C este activa, si haces un fix a un RTL,
COPIALO tambien a `uvm_tb/<bloque>_verification/rtl/` para no perder la
sincronizacion con verificacion. Nota: el flujo actual (synthesis + LEC) uso
la copia de `rtl/`, que esta sincronizada con verificacion a la fecha del
tag v3.0-synthesis-lec.

## Flujos

### Verificacion (UVM)
```bash
cd uvm_tb/<bloque>_verification/sim
make regress              # env UVM completo
./run.sh                  # TB standalone (fase 1)
```

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
- **Consolidacion RTL** (Opcion A, checklist arriba)
- **P&R (ICC2) + Signoff (PrimeTime)** si se continua el flujo hasta layout

## Tags

| Tag                     | Hito                                              |
| ----------------------- | ------------------------------------------------- |
| `v1.0-rtl-complete`     | RTL de los 9 bloques + TBs standalone             |
| `v2.0-uvm-verification` | Verificacion funcional UVM (8 bloques 100% + top) |
| `v3.0-synthesis-lec`    | Flujo ASIC front-end: synthesis + LEC             |
| `v4.0-golden-model`     | Verificacion del top: golden model ciclo-a-ciclo  |