# academy2026-uvm-lab — CPU Multiciclo (Synopsys Academy 2026)

CPU multiciclo de 3 etapas verificado con UVM y sintetizado con Design
Compiler para SKY130.

## Estructura del proyecto
```
project/
├── rtl/ # RTL canonico (fuente para synthesis)
├── libs/ # Librerias SKY130 (.db)
├── syn/ # Flujo de synthesis (Design Compiler)
│ ├── scripts/ # Scripts Tcl del flujo
│ └── work/ # Salidas: netlist, reportes, logs
├── uvm_tb/ # Verificacion UVM (9 bloques)
│ └── <bloque>_verification/
│ ├── rtl/ # RTL del bloque (ver NOTA de duplicacion)
│ ├── tb/ # Env UVM
│ ├── sim/ # Makefile, filelist, standalone TB
│ └── docs/ # Testplan
├── docs/ # Documentacion general
└── scripts/ # Scripts auxiliares
```
## NOTA IMPORTANTE: duplicacion de RTL (pendiente de consolidar)

**Estado actual (Opcion C - temporal):**
Los RTL existen en DOS lugares:
1. `rtl/` — copia canonica usada por synthesis
2. `uvm_tb/<bloque>_verification/rtl/` — copias usadas por verificacion

Esto es una duplicacion temporal para desbloquear synthesis rapido. **Riesgo:
si editas un RTL, debes actualizar AMBAS copias** o divergiran.

**Pendiente (Opcion A - consolidacion):**
Migrar a fuente unica: mover todos los RTL a `rtl/`, borrar los
`uvm_tb/*/rtl/`, y actualizar los `filelist.f` de cada env UVM para apuntar
a `../../../rtl/<archivo>.sv`. Esto restablece "single source of truth".

### Checklist para la consolidacion (Opcion A) - PENDIENTE

- [ ] Verificar que `rtl/` tiene la version mas reciente de cada RTL
- [ ] Actualizar los 9 `filelist.f` en `uvm_tb/*/verification/sim/`:
      cambiar `../../<bloque>_verification/rtl/X.sv` -> `../../../rtl/X.sv`
- [ ] Actualizar el `filelist.f` del top (referencia varios submodulos)
- [ ] Correr `make regress` en cada env para confirmar que la verificacion
      sigue funcionando tras el cambio de rutas
- [ ] Borrar los directorios `uvm_tb/*/rtl/`
- [ ] Actualizar esta seccion del README

**IMPORTANTE:** mientras la Opcion C este activa, si haces un fix a un RTL
durante synthesis (ej. un cambio para timing), COPIALO tambien a
`uvm_tb/<bloque>_verification/rtl/` para no perder la sincronizacion con
verificacion.

## Flujos

### Verificacion (UVM)
```bash
cd uvm_tb/<bloque>_verification/sim
make regress
```

### Synthesis (Design Compiler)
```bash
cd syn
dc_shell -f scripts/run_syn.tcl | tee work/logs/synthesis.log
```

## Estado del proyecto

Ver tag `v2.0-uvm-verification` para el hito de verificacion funcional.

- 8 bloques con env UVM al 100% de coverage funcional
- top validado end-to-end por standalone (31/31)
- Pendiente: golden model ciclo-a-ciclo para el env exhaustivo del top
  (ver `uvm_tb/top_verification/docs/PIPELINE_TIMING.md`)
- En curso: synthesis del top para SKY130
