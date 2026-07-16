//------------------------------------------------------------------------------
// testbench.sv
// Top-level del testbench del register_bank.
//------------------------------------------------------------------------------
module testbench;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import regbank_pkg::*;
    import regbank_test_pkg::*;

    // Clock 100 MHz
    logic clk;
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Interface
    regbank_if #(.WIDTH(WIDTH)) rb_vif (.clk(clk));

    // DUT
    register_bank #(.WIDTH(WIDTH)) dut (
        .clk   (clk),
        .rst   (rb_vif.rst),
        .wr_en (rb_vif.wr_en),
        .in    (rb_vif.in),
        .out   (rb_vif.out)
    );

    initial begin
        uvm_config_db#(virtual regbank_if)::set(null, "uvm_test_top.env.agent*", "vif", rb_vif);
        run_test();
    end

    // Dump para Verdi
    initial begin
        $fsdbDumpfile("waves.fsdb");
        $fsdbDumpvars(0, testbench);
    end

    // Watchdog
    // VCS coverage off
    initial begin
        #500us;
        `uvm_fatal("TB", "Watchdog: la simulacion excedio 500us")
    end
    // VCS coverage on

endmodule
