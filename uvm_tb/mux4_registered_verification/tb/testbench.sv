//------------------------------------------------------------------------------
// testbench.sv
//------------------------------------------------------------------------------
module testbench;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import mux4_registered_pkg::*;
    import mux4_registered_test_pkg::*;

    logic clk;
    initial clk = 1'b0;
    always #5 clk = ~clk;

    mux4_registered_if #(.WIDTH(WIDTH)) mux4r_vif (.clk(clk));

    mux4_registered #(.WIDTH(WIDTH)) dut (
        .clk   (clk),
        .rst   (mux4r_vif.rst),
        .wr_en (mux4r_vif.wr_en),
        .sel   (mux4r_vif.sel),
        .in1   (mux4r_vif.in1),
        .in2   (mux4r_vif.in2),
        .in3   (mux4r_vif.in3),
        .in4   (mux4r_vif.in4),
        .out   (mux4r_vif.out)
    );

    initial begin
        uvm_config_db#(virtual mux4_registered_if)::set(null, "uvm_test_top.env.agent*", "vif", mux4r_vif);
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
