//------------------------------------------------------------------------------
// control_if.sv
// Interface del control. Reset asincrono fuera del clocking block.
// cmd_in y p_error son estimulos; el resto son salidas observadas.
//------------------------------------------------------------------------------
interface control_if (input logic clk);

    logic       rst     = 1'b0;
    logic [6:0] cmd_in  = 7'h00;
    logic       p_error = 1'b0;

    logic       aluin_reg_en;
    logic       datain_reg_en;
    logic       memoryWrite;
    logic       memoryRead;
    logic       selmux2;
    logic       cpu_rdy;
    logic       aluout_reg_en;
    logic       nvalid_data;
    logic [1:0] in_select_a;
    logic [1:0] in_select_b;
    logic [3:0] opcode;

    clocking drv_cb @(posedge clk);
        default input #1step output #1;
        output cmd_in;
        output p_error;
    endclocking

    // Monitor samplea post-edge para observar el estado ya actualizado y las
    // salidas Moore correspondientes al estado presente.
    clocking mon_cb @(posedge clk);
        default input #1;
        input cmd_in;
        input p_error;
        input rst;
        input aluin_reg_en;
        input datain_reg_en;
        input memoryWrite;
        input memoryRead;
        input selmux2;
        input cpu_rdy;
        input aluout_reg_en;
        input nvalid_data;
        input in_select_a;
        input in_select_b;
        input opcode;
    endclocking

    modport DRV (clocking drv_cb, output rst);
    modport MON (clocking mon_cb);

endinterface
