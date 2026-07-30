//------------------------------------------------------------------------------
// control_test_pkg.sv
//------------------------------------------------------------------------------
package control_test_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import control_pkg::*;

    `include "control_seq_rand.sv"
    `include "control_directed_seq.sv"
    `include "control_opcode_sweep_seq.sv"
    `include "control_reset_seq.sv"
    `include "control_coverage_seq.sv"
    `include "control_test.sv"

endpackage
