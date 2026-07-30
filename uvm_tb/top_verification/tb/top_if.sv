//------------------------------------------------------------------------------
// top_if.sv
// Interface del CPU completo. Reset async fuera del clocking block.
// Estimulos: cmd_in, din_1/2/3. Observados: dout, flags, cpu_rdy.
//------------------------------------------------------------------------------
interface top_if #(parameter WIDTH = 8) (input logic clk);

    logic                 rst     = 1'b0;
    logic [6:0]           cmd_in  = 7'h00;
    logic [WIDTH-1:0]     din_1   = '0;
    logic [WIDTH-1:0]     din_2   = '0;
    logic [WIDTH-1:0]     din_3   = '0;

    logic [WIDTH-1:0]     dout_low;
    logic [WIDTH-1:0]     dout_high;
    logic                 cpu_rdy;
    logic                 zero;
    logic                 error;

    clocking drv_cb @(posedge clk);
        default input #1step output #1;
        output cmd_in;
        output din_1;
        output din_2;
        output din_3;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1;
        input cmd_in;
        input din_1;
        input din_2;
        input din_3;
        input rst;
        input dout_low;
        input dout_high;
        input cpu_rdy;
        input zero;
        input error;
    endclocking

    modport DRV (clocking drv_cb, output rst);
    modport MON (clocking mon_cb);

endinterface
