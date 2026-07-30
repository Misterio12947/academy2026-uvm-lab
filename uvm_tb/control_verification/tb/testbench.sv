//------------------------------------------------------------------------------
// testbench.sv
//------------------------------------------------------------------------------
module testbench;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import control_pkg::*;
    import control_test_pkg::*;

    logic clk;
    initial clk = 1'b0;
    always #5 clk = ~clk;

    control_if ctrl_vif (.clk(clk));

    control dut (
        .clk           (clk),
        .rst           (ctrl_vif.rst),
        .cmd_in        (ctrl_vif.cmd_in),
        .p_error       (ctrl_vif.p_error),
        .aluin_reg_en  (ctrl_vif.aluin_reg_en),
        .datain_reg_en (ctrl_vif.datain_reg_en),
        .memoryWrite   (ctrl_vif.memoryWrite),
        .memoryRead    (ctrl_vif.memoryRead),
        .selmux2       (ctrl_vif.selmux2),
        .cpu_rdy       (ctrl_vif.cpu_rdy),
        .aluout_reg_en (ctrl_vif.aluout_reg_en),
        .nvalid_data   (ctrl_vif.nvalid_data),
        .in_select_a   (ctrl_vif.in_select_a),
        .in_select_b   (ctrl_vif.in_select_b),
        .opcode        (ctrl_vif.opcode)
    );

    initial begin
        uvm_config_db#(virtual control_if)::set(null, "uvm_test_top.env.agent*", "vif", ctrl_vif);
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
