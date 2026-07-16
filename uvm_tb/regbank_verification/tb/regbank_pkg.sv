//------------------------------------------------------------------------------
// regbank_pkg.sv
// Paquete de infraestructura UVM del register_bank.
//------------------------------------------------------------------------------
package regbank_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    localparam int WIDTH = 8;

    `include "regbank_transaction.sv"
    `include "regbank_driver.sv"
    `include "regbank_monitor.sv"
    `include "regbank_coverage.sv"
    `include "regbank_agent.sv"
    `include "regbank_scoreboard.sv"
    `include "regbank_env.sv"

endpackage
