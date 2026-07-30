//------------------------------------------------------------------------------
// top_pkg.sv
//------------------------------------------------------------------------------
package top_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    localparam int WIDTH = 8;

    `include "top_transaction.sv"
    `include "top_driver.sv"
    `include "top_monitor.sv"
    `include "top_scoreboard.sv"
    `include "top_agent.sv"
    `include "top_env.sv"

endpackage
