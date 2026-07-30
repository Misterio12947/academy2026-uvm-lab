# ==========================================================================
# setup.tcl - Setup de librerias y variables (CPU multiciclo, SKY130)
# ==========================================================================
# EJECUCION: dc_shell se corre DESDE syn/work/. Rutas relativas parten de ahi.
#   scripts -> ../scripts | rtl -> ../../rtl | libs -> ../../libs
#   salidas (reports, outputs, logs) quedan en el cwd (work/).
# ==========================================================================

# Search path: cwd, RTL local, y libs locales del proyecto.
# (Si quieres usar el PDK compartido, agrega:
#  /home/SHARE-DATA/technology/pdksy/sky130/lib/sky130_fd_sc_hd/db_nldm/ )
set_app_var search_path "$search_path . ../../rtl ../../libs"

# Librerias SKY130 (locales en project/libs)
#   ss_100C_1v40 : slow corner (worst case setup) -> target de compile
#   ff_100C_1v95 : fast corner (best case)        -> analisis de hold
set_app_var target_library "sky130_fd_sc_hd__ss_100C_1v40.db"
set_app_var link_library    "* sky130_fd_sc_hd__ss_100C_1v40.db sky130_fd_sc_hd__ff_100C_1v95.db"

set DESIGN_NAME "top"

# Directorios de salida (dentro de work/)
file mkdir reports
file mkdir outputs
file mkdir logs

# Libreria de trabajo de DC (analyze/elaborate) dentro de work/
define_design_lib WORK -path ./dc_work

echo "=== Setup completo ==="
echo "  CWD        : [pwd]"
echo "  DESIGN     : $DESIGN_NAME"
echo "  target_lib : sky130_fd_sc_hd__ss_100C_1v40.db"