//------------------------------------------------------------------------------
// control_pkg.sv
//------------------------------------------------------------------------------
package control_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "control_transaction.sv"
    `include "control_driver.sv"
    `include "control_monitor.sv"
    `include "control_coverage.sv"
    `include "control_agent.sv"
    `include "control_scoreboard.sv"
    `include "control_env.sv"

endpackage
