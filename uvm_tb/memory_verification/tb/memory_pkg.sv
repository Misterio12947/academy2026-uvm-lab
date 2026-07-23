//------------------------------------------------------------------------------
// memory_pkg.sv
//------------------------------------------------------------------------------
package memory_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    localparam int WIDTH = 8;

    `include "memory_transaction.sv"
    `include "memory_driver.sv"
    `include "memory_monitor.sv"
    `include "memory_coverage.sv"
    `include "memory_agent.sv"
    `include "memory_scoreboard.sv"
    `include "memory_env.sv"

endpackage
