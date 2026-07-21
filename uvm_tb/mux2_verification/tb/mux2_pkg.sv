//------------------------------------------------------------------------------
// mux2_pkg.sv
//------------------------------------------------------------------------------
package mux2_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    localparam int WIDTH = 8;

    `include "mux2_transaction.sv"
    `include "mux2_driver.sv"
    `include "mux2_monitor.sv"
    `include "mux2_coverage.sv"
    `include "mux2_agent.sv"
    `include "mux2_scoreboard.sv"
    `include "mux2_env.sv"

endpackage
