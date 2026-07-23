//------------------------------------------------------------------------------
// mux2_registered_pkg.sv
//------------------------------------------------------------------------------
package mux2_registered_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    localparam int WIDTH = 8;

    `include "mux2_registered_transaction.sv"
    `include "mux2_registered_driver.sv"
    `include "mux2_registered_monitor.sv"
    `include "mux2_registered_coverage.sv"
    `include "mux2_registered_agent.sv"
    `include "mux2_registered_scoreboard.sv"
    `include "mux2_registered_env.sv"

endpackage
