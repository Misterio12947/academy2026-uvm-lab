//------------------------------------------------------------------------------
// mux4_registered_test_pkg.sv
//------------------------------------------------------------------------------
package mux4_registered_test_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import mux4_registered_pkg::*;

    `include "mux4_registered_seq_rand.sv"
    `include "mux4_registered_directed_seq.sv"
    `include "mux4_registered_reset_seq.sv"
    `include "mux4_registered_coverage_seq.sv"
    `include "mux4_registered_test.sv"

endpackage
