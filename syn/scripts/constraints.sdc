# ==========================================================================
# constraints.tcl - Constraints de timing (CPU multiciclo)
# ==========================================================================

# NOTA: clk_val esta en nanosegundos. 10 ns = 100 MHz.
# El standalone del CPU corre a 10ns. El path critico sintetizado es ~8.5ns,
# asi que hay margen. Para probar mas rapido en el futuro, baja clk_val.
set clk_val 10

# --- Reloj ---
create_clock -period $clk_val [get_ports clk]
set_clock_uncertainty -setup [expr {$clk_val*0.1}]  [get_clocks clk]
set_clock_transition  -max   [expr {$clk_val*0.02}] [get_clocks clk]
set_clock_latency -source -max [expr {$clk_val*0.05}] [get_clocks clk]
set_clock_latency        -max [expr {$clk_val*0.03}] [get_clocks clk]

# --- Delays de I/O ---
set_input_delay  -max [expr {$clk_val*0.4}] -clock clk \
    [remove_from_collection [all_inputs] clk]
set_output_delay -max [expr {$clk_val*0.5}] -clock clk \
    [get_ports [all_outputs]]

# --- Carga y transiciones ---
set_load -max [expr {40.0/1000}] [all_outputs]
set_input_transition -min [expr {$clk_val*0.01}] \
    [remove_from_collection [all_inputs] clk]
set_input_transition -max [expr {$clk_val*0.1}] \
    [remove_from_collection [all_inputs] clk]

# --- Reset asincrono: false path (no restringir con el reloj) ---
set_false_path -from [get_ports rst]

echo "=== Constraints aplicadas (clk = $clk_val ns) ==="