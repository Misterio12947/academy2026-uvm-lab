//------------------------------------------------------------------------------
// regbank_if.sv
// Interface del register_bank. El reset es asincrono y por eso vive FUERA
// del clocking block: solo las senales sincronas (wr_en, in, out) usan cb.
// El driver maneja rst directamente sin sincronizarlo al clk.
//------------------------------------------------------------------------------
interface regbank_if #(parameter WIDTH = 8) (input logic clk);

    // Reset asincrono (activo alto). Fuera de clocking block por definicion.
    logic              rst          = 1'b0;

    // Senales sincronas
    logic              wr_en        = 1'b0;
    logic [WIDTH-1:0]  in           = '0;
    logic [WIDTH-1:0]  out;

    // Driver: escribe estimulos sincronos con skew #1 post-edge
    clocking drv_cb @(posedge clk);
        default input #1step output #1;
        output wr_en;
        output in;
    endclocking

    // Monitor: samplea 1 tick POST-edge para observar el resultado del DUT
    // ya actualizado (el registro cambia en delta despues del posedge).
    clocking mon_cb @(posedge clk);
        default input #1;
        input wr_en;
        input in;
        input rst;
        input out;
    endclocking

    modport DRV (clocking drv_cb, output rst);
    modport MON (clocking mon_cb);

endinterface
