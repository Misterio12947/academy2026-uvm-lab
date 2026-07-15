//------------------------------------------------------------------------------
// alu_pkg.sv
// Paquete de infraestructura UVM del ALU. Hace include de transaction,
// driver, monitor, coverage, agent, scoreboard y env en orden de dependencia.
//------------------------------------------------------------------------------
package alu_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // WIDTH global del paquete de verificacion.
    // Si cambia el WIDTH del RTL, ajustar aqui tambien.
    localparam int WIDTH = 8;

    // Orden de dependencia:
    //   transaction -> driver, monitor, coverage
    //   driver + monitor -> agent
    //   transaction -> scoreboard
    //   agent + scoreboard + coverage -> env
    `include "alu_transaction.sv"
    `include "alu_driver.sv"
    `include "alu_monitor.sv"
    `include "alu_coverage.sv"
    `include "alu_agent.sv"
    `include "alu_scoreboard.sv"
    `include "alu_env.sv"

endpackage
