//------------------------------------------------------------------------------
// testbench.sv
//------------------------------------------------------------------------------
module testbench;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import mux2_registered_pkg::*;
    import mux2_registered_test_pkg::*;

    logic clk;
    initial clk = 1'b0;
    always #5 clk = ~clk;

    mux2_registered_if #(.WIDTH(WIDTH)) mux2r_vif (.clk(clk));

    mux2_registered #(.WIDTH(WIDTH)) dut (
        .clk   (clk),
        .rst   (mux2r_vif.rst),
        .sel   (mux2r_vif.sel),
        .wr_en (mux2r_vif.wr_en),
        .in1   (mux2r_vif.in1),
        .in2   (mux2r_vif.in2),
        .out   (mux2r_vif.out)
    );

    initial begin
        uvm_config_db#(virtual mux2_registered_if)::set(null, "uvm_test_top.env.agent*", "vif", mux2r_vif);
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
