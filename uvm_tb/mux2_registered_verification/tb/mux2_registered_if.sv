//------------------------------------------------------------------------------
// mux2_registered_if.sv
// Interface del mux2_registered. Reset asincrono fuera del clocking block.
// Bus de datos de 2*WIDTH bits (16 con WIDTH=8) para in1, in2, out.
//------------------------------------------------------------------------------
interface mux2_registered_if #(parameter WIDTH = 8) (input logic clk);

    // Reset asincrono (activo alto)
    logic                     rst    = 1'b0;

    // Senales sincronas
    logic                     wr_en  = 1'b0;
    logic                     sel    = 1'b0;
    logic [2*WIDTH-1:0]       in1    = '0;
    logic [2*WIDTH-1:0]       in2    = '0;
    logic [2*WIDTH-1:0]       out;

    clocking drv_cb @(posedge clk);
        default input #1step output #1;
        output wr_en;
        output sel;
        output in1;
        output in2;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1;
        input wr_en;
        input sel;
        input in1;
        input in2;
        input rst;
        input out;
    endclocking

    modport DRV (clocking drv_cb, output rst);
    modport MON (clocking mon_cb);

endinterface
