//------------------------------------------------------------------------------
// testbench.sv
// Top-level del testbench del mux4.
//------------------------------------------------------------------------------
module testbench;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import mux4_pkg::*;
    import mux4_test_pkg::*;

    // Clock del TB (100 MHz)
    logic clk;
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Interface
    mux4_if #(.WIDTH(WIDTH)) mux4_vif (.clk(clk));

    // DUT
    mux4 #(.WIDTH(WIDTH)) dut (
        .din1   (mux4_vif.din1),
        .din2   (mux4_vif.din2),
        .din3   (mux4_vif.din3),
        .din4   (mux4_vif.din4),
        .select (mux4_vif.select),
        .dout   (mux4_vif.dout)
    );

    // Publicar vif y arrancar UVM
    initial begin
        uvm_config_db#(virtual mux4_if)::set(null, "uvm_test_top.env.agent*", "vif", mux4_vif);
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
