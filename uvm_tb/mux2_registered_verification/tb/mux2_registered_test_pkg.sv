//------------------------------------------------------------------------------
// mux2_registered_test_pkg.sv
//------------------------------------------------------------------------------
package mux2_registered_test_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import mux2_registered_pkg::*;

    `include "mux2_registered_seq_rand.sv"
    `include "mux2_registered_directed_seq.sv"
    `include "mux2_registered_reset_seq.sv"
    `include "mux2_registered_coverage_seq.sv"
    `include "mux2_registered_test.sv"

endpackage
