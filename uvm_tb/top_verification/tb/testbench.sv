//------------------------------------------------------------------------------
// testbench.sv
//------------------------------------------------------------------------------
module testbench;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import top_pkg::*;
    import top_test_pkg::*;

    logic clk;
    initial clk = 1'b0;
    always #5 clk = ~clk;

    top_if #(.WIDTH(WIDTH)) top_vif (.clk(clk));

    top #(.WIDTH(WIDTH)) dut (
        .clk       (clk),
        .rst       (top_vif.rst),
        .cmd_in    (top_vif.cmd_in),
        .din_1     (top_vif.din_1),
        .din_2     (top_vif.din_2),
        .din_3     (top_vif.din_3),
        .dout_low  (top_vif.dout_low),
        .dout_high (top_vif.dout_high),
        .cpu_rdy   (top_vif.cpu_rdy),
        .zero      (top_vif.zero),
        .error     (top_vif.error)
    );

    initial begin
        uvm_config_db#(virtual top_if)::set(null, "uvm_test_top.env.agent*", "vif", top_vif);
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
