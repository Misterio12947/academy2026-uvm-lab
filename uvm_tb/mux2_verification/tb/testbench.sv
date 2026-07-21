//------------------------------------------------------------------------------
// testbench.sv
//------------------------------------------------------------------------------
module testbench;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import mux2_pkg::*;
    import mux2_test_pkg::*;

    logic clk;
    initial clk = 1'b0;
    always #5 clk = ~clk;

    mux2_if #(.WIDTH(WIDTH)) mux2_vif (.clk(clk));

    mux2 #(.WIDTH(WIDTH)) dut (
        .din1   (mux2_vif.din1),
        .din2   (mux2_vif.din2),
        .select (mux2_vif.select),
        .dout   (mux2_vif.dout)
    );

    initial begin
        uvm_config_db#(virtual mux2_if)::set(null, "uvm_test_top.env.agent*", "vif", mux2_vif);
        run_test();
    end

    initial begin
        $fsdbDumpfile("waves.fsdb");
        $fsdbDumpvars(0, testbench);
    end

    // VCS coverage off
    initial begin
        #500us;
        `uvm_fatal("TB", "Watchdog: la simulacion excedio 500us")
    end
    // VCS coverage on

endmodule
