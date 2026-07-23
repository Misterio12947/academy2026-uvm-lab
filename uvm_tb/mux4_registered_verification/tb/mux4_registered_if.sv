//------------------------------------------------------------------------------
// mux4_registered_if.sv
// Interface del mux4_registered. Reset asincrono FUERA del clocking block
// (no puede sincronizarse). Senales sincronas (sel, in1..in4, wr_en) dentro.
//------------------------------------------------------------------------------
interface mux4_registered_if #(parameter WIDTH = 8) (input logic clk);

    // Reset asincrono (activo alto). Fuera de clocking block.
    logic                 rst    = 1'b0;

    // Senales sincronas
    logic                 wr_en  = 1'b0;
    logic [1:0]           sel    = 2'b00;
    logic [WIDTH-1:0]     in1    = '0;
    logic [WIDTH-1:0]     in2    = '0;
    logic [WIDTH-1:0]     in3    = '0;
    logic [WIDTH-1:0]     in4    = '0;
    logic [WIDTH-1:0]     out;

    // Driver: escribe estimulos sincronos con skew #1 post-edge
    clocking drv_cb @(posedge clk);
        default input #1step output #1;
        output wr_en;
        output sel;
        output in1;
        output in2;
        output in3;
        output in4;
    endclocking

    // Monitor: samplea 1 tick POST-edge para observar el resultado del DUT
    // ya actualizado (el registro cambia en delta despues del posedge).
    clocking mon_cb @(posedge clk);
        default input #1;
        input wr_en;
        input sel;
        input in1;
        input in2;
        input in3;
        input in4;
        input rst;
        input out;
    endclocking

    modport DRV (clocking drv_cb, output rst);
    modport MON (clocking mon_cb);

endinterface
