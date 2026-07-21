//------------------------------------------------------------------------------
// mux4_test_pkg.sv
//------------------------------------------------------------------------------
package mux4_test_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import mux4_pkg::*;

    `include "mux4_seq_rand.sv"
    `include "mux4_directed_seq.sv"
    `include "mux4_coverage_seq.sv"
    `include "mux4_test.sv"

endpackage
