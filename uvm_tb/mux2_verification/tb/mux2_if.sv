//------------------------------------------------------------------------------
// mux2_if.sv
// Interface del mux2. El DUT es combinacional, pero usamos clk en el harness
// para sincronizar driver/monitor y evitar race conditions.
//------------------------------------------------------------------------------
interface mux2_if #(parameter WIDTH = 8) (input logic clk);

    logic [WIDTH-1:0]     din1   = '0;
    logic [WIDTH-1:0]     din2   = '0;
    logic                 select = 1'b0;
    logic [WIDTH-1:0]     dout;

    clocking drv_cb @(posedge clk);
        default input #1step output #1;
        output din1;
        output din2;
        output select;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1step;
        input din1;
        input din2;
        input select;
        input dout;
    endclocking

    modport DRV (clocking drv_cb);
    modport MON (clocking mon_cb);

endinterface
