//------------------------------------------------------------------------------
// mux4_if.sv
// Interface del mux4. El DUT es combinacional, pero usamos clk en el harness
// para sincronizar driver/monitor y evitar race conditions.
//------------------------------------------------------------------------------
interface mux4_if #(parameter WIDTH = 8) (input logic clk);

    // Inicializacion a 0 para evitar estado X en t=0 (el DUT es
    // combinacional y muestrearia el default case del case unique).
    logic [WIDTH-1:0]     din1   = '0;
    logic [WIDTH-1:0]     din2   = '0;
    logic [WIDTH-1:0]     din3   = '0;
    logic [WIDTH-1:0]     din4   = '0;
    logic [1:0]           select = '0;
    logic [WIDTH-1:0]     dout;

    // Clocking block para el driver
    clocking drv_cb @(posedge clk);
        default input #1step output #1;
        output din1;
        output din2;
        output din3;
        output din4;
        output select;
    endclocking

    // Clocking block para el monitor
    clocking mon_cb @(posedge clk);
        default input #1step;
        input din1;
        input din2;
        input din3;
        input din4;
        input select;
        input dout;
    endclocking

    modport DRV (clocking drv_cb);
    modport MON (clocking mon_cb);

endinterface
