//------------------------------------------------------------------------------
// testbench.sv
//------------------------------------------------------------------------------
module testbench;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import memory_pkg::*;
    import memory_test_pkg::*;

    logic clk;
    initial clk = 1'b0;
    always #5 clk = ~clk;

    memory_if #(.WIDTH(WIDTH)) mem_vif (.clk(clk));

    memory #(.WIDTH(WIDTH)) dut (
        .clk             (clk),
        .memoryWrite     (mem_vif.memoryWrite),
        .memoryRead      (mem_vif.memoryRead),
        .memoryAddress   (mem_vif.memoryAddress),
        .memoryWriteData (mem_vif.memoryWriteData),
        .memoryOutData   (mem_vif.memoryOutData)
    );

    initial begin
        uvm_config_db#(virtual memory_if)::set(null, "uvm_test_top.env.agent*", "vif", mem_vif);
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
