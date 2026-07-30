# ==========================================================================
# compile.tcl - Compilacion y reportes
# ==========================================================================

# --- Pre-compile ---
source ../scripts/constraints.sdc

report_port -verbose         > reports/ports.rpt
check_timing                 > reports/check_timing_pre.rpt

# Paralelismo (ajusta -max_cores segun servidor y licencia)
set_host_options -max_cores 8

# --- Compile (Ultra Effort, preservando jerarquia) ---
echo "=== compile_ultra ==="
compile_ultra -no_autoungroup

# --- Post-compile: verificacion del diseño ---
check_design > reports/check_design_post.rpt

# --- Reportes de sign-off ---
report_qor                              > reports/QoRpos.rpt
report_timing -max_paths 10 -delay_type max > reports/timing_setup.rpt
report_timing -max_paths 10 -delay_type min > reports/timing_hold.rpt
report_area   -hierarchy                > reports/area.rpt
report_power  -hierarchy                > reports/power.rpt
report_constraint -all_violators        > reports/violations.rpt
report_reference  -hierarchy            > reports/references.rpt

# --- Check de sintesis adicional (si el script existe en el server) ---
# Descomenta si tienes este script en tu flujo:
# source ../scripts/DesignCompiler_checksynthesis.tcl

# --- Guardar diseño ---
echo "=== Escribiendo netlist ==="
write_file -format verilog -hier -output outputs/mapped.v
write_file -format ddc     -hier -output outputs/mapped.ddc
write_sdc outputs/mapped.sdc

echo "=== Synthesis completo. Netlist en outputs/, reportes en reports/ ==="