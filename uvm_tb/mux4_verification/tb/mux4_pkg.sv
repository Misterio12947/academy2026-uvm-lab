//------------------------------------------------------------------------------
// mux4_pkg.sv
// Paquete de infraestructura UVM del mux4.
//------------------------------------------------------------------------------
package mux4_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    localparam int WIDTH = 8;

    `include "mux4_transaction.sv"
    `include "mux4_driver.sv"
    `include "mux4_monitor.sv"
    `include "mux4_coverage.sv"
    `include "mux4_agent.sv"
    `include "mux4_scoreboard.sv"
    `include "mux4_env.sv"

endpackage
