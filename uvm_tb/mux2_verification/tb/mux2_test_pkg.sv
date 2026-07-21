//------------------------------------------------------------------------------
// mux2_test_pkg.sv
//------------------------------------------------------------------------------
package mux2_test_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import mux2_pkg::*;

    `include "mux2_seq_rand.sv"
    `include "mux2_directed_seq.sv"
    `include "mux2_coverage_seq.sv"
    `include "mux2_test.sv"

endpackage
