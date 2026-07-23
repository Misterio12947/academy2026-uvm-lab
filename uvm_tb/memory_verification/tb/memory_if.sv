//------------------------------------------------------------------------------
// memory_if.sv
// Interface de la memoria. Sin reset (per spec: memoria no tiene reset).
// Writes sincronos (posedge clk), reads asincronos (combinacional).
//------------------------------------------------------------------------------
interface memory_if #(parameter WIDTH = 8) (input logic clk);

    logic                     memoryWrite     = 1'b0;
    logic                     memoryRead      = 1'b0;
    logic [7:0]               memoryAddress   = '0;
    logic [2*WIDTH-1:0]       memoryWriteData = '0;
    logic [2*WIDTH-1:0]       memoryOutData;

    clocking drv_cb @(posedge clk);
        default input #1step output #1;
        output memoryWrite;
        output memoryRead;
        output memoryAddress;
        output memoryWriteData;
    endclocking

    // Nota: memoryOutData es combinacional. Usamos input #1 (preponed) para
    // observar el valor estable en el edge, DESPUES de que address propaga.
    clocking mon_cb @(posedge clk);
        default input #1;
        input memoryWrite;
        input memoryRead;
        input memoryAddress;
        input memoryWriteData;
        input memoryOutData;
    endclocking

    modport DRV (clocking drv_cb);
    modport MON (clocking mon_cb);

endinterface
