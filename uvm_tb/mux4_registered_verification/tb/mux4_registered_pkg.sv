//------------------------------------------------------------------------------
// mux4_registered_pkg.sv
//------------------------------------------------------------------------------
package mux4_registered_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    localparam int WIDTH = 8;

    `include "mux4_registered_transaction.sv"
    `include "mux4_registered_driver.sv"
    `include "mux4_registered_monitor.sv"
    `include "mux4_registered_coverage.sv"
    `include "mux4_registered_agent.sv"
    `include "mux4_registered_scoreboard.sv"
    `include "mux4_registered_env.sv"

endpackage
