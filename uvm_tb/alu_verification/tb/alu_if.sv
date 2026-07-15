//------------------------------------------------------------------------------
// alu_if.sv
// Interface del ALU. El DUT es combinacional, pero usamos clk en el harness
// para sincronizar driver/monitor y evitar race conditions.
//------------------------------------------------------------------------------
interface alu_if #(parameter WIDTH = 8) (input logic clk);

    // Inicializacion a 0 para evitar estado X en t=0 (el DUT es
    // combinacional y muestrearia el default case del case unique).
    // El driver luego maneja estas senales via clocking block.
    logic [WIDTH-1:0]     in1          = '0;
    logic [WIDTH-1:0]     in2          = '0;
    logic [3:0]           op           = '0;
    logic                 invalid_data = 1'b0;
    logic [2*WIDTH-1:0]   out;
    logic                 zero;
    logic                 error;

    clocking drv_cb @(posedge clk);
        default input #1step output #1;
        output in1;
        output in2;
        output op;
        output invalid_data;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1step;
        input in1;
        input in2;
        input op;
        input invalid_data;
        input out;
        input zero;
        input error;
    endclocking

    modport DRV (clocking drv_cb);
    modport MON (clocking mon_cb);

endinterface