# ==========================================================================
# read_design.tcl - Lectura de RTL y elaboracion
# ==========================================================================

set rtl_dir "../../rtl"

# --- Automatizacion de lectura de RTL ---
set rtl_files [glob -nocomplain $rtl_dir/*.v $rtl_dir/*.sv]
if {[llength $rtl_files] == 0} {
    echo "ERROR: No se encontraron archivos Verilog en $rtl_dir"
    exit
}

echo "=== Archivos RTL encontrados ==="
foreach f $rtl_files { echo "  $f" }

# analyze de todos juntos; DC resuelve dependencias en el elaborate.
analyze -format sverilog $rtl_files

echo "=== Elaborando: $DESIGN_NAME ==="
elaborate $DESIGN_NAME
current_design $DESIGN_NAME
link

# Chequeo de diseño (referencias resueltas, sin modulos faltantes)
check_design > reports/check_design.rpt

# Jerarquia (confirmar que los 8 submodulos se instanciaron)
report_hierarchy > reports/hierarchy.rpt

echo "=== Lectura y elaboracion completas ==="