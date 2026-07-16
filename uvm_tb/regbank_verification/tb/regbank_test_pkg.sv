//------------------------------------------------------------------------------
// regbank_test_pkg.sv
//------------------------------------------------------------------------------
package regbank_test_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import regbank_pkg::*;

    `include "regbank_seq_rand.sv"
    `include "regbank_directed_seq.sv"
    `include "regbank_reset_seq.sv"
    `include "regbank_coverage_seq.sv"
    `include "regbank_test.sv"

endpackage
