# ==========================================================================
# fm.tcl - Equivalencia Logica (LEC) con Formality
# CPU multiciclo (top): RTL vs netlist sintetizado por Design Compiler
# Target: SKY130 sky130_fd_sc_hd
# ==========================================================================
# EJECUCION (desde lec/):
#   fm_shell -f scripts/fm.tcl | tee formality.log
# ==========================================================================

# --- Rutas ---
set RTL_DIR      "../rtl"
set NETLIST      "../syn/work/outputs/mapped.v"
set SVF_FILE     "../syn/work/default.svf"
set LIB_DIR      "../libs"
set DESIGN_NAME  "top"

# --- Auto setup mode ---
set synopsys_auto_setup true

# --- SVF: guia de DC ---
set_svf $SVF_FILE

# ==========================================================================
# REFERENCE: el RTL (golden). -r lee al contenedor de referencia (r:/WORK)
# ==========================================================================
read_sverilog -r -libname WORK "
    $RTL_DIR/alu.sv
    $RTL_DIR/register_bank.sv
    $RTL_DIR/mux4.sv
    $RTL_DIR/mux2.sv
    $RTL_DIR/mux4_registered.sv
    $RTL_DIR/mux2_registered.sv
    $RTL_DIR/memory.sv
    $RTL_DIR/control.sv
    $RTL_DIR/top.sv
"
set_top r:/WORK/$DESIGN_NAME

# ==========================================================================
# IMPLEMENTATION: el netlist. -i lee al contenedor de implementacion (i:/WORK)
# ==========================================================================
# Ambas librerias SKY130 (igual que el link_library de synthesis)
read_db $LIB_DIR/sky130_fd_sc_hd__ss_100C_1v40.db
read_db $LIB_DIR/sky130_fd_sc_hd__ff_100C_1v95.db

read_verilog -i -libname WORK -netlist $NETLIST
set_top i:/WORK/$DESIGN_NAME

# ==========================================================================
# MATCH + VERIFY
# ==========================================================================
match
report_unmatched_points > reports/unmatched.rpt

verify

# ==========================================================================
# REPORTES
# ==========================================================================
report_status         > reports/status.rpt
report_passing_points > reports/passing.rpt
report_failing_points > reports/failing.rpt

echo "=== LEC completo. Ver reports/status.rpt ==="