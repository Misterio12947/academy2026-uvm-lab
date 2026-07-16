//------------------------------------------------------------------------------
// tb_memory.sv
// TB standalone para la memoria. 6 escenarios criticos:
//   1. Escritura + lectura en misma direccion
//   2. Escritura en varias direcciones y lectura secuencial
//   3. memoryWrite=0: no debe escribir (retencion)
//   4. memoryRead=0: data_out debe ser 0 (gating de salida)
//   5. Lectura asincrona: cambio de addr refleja en data_out sin esperar clk
//   6. Overwrite: escribir dos veces la misma direccion, ultima gana
//------------------------------------------------------------------------------
`timescale 1ns/1ps

module tb_memory;

    localparam int WIDTH = 8;

    logic                 clk;
    logic                 memoryWrite;
    logic                 memoryRead;
    logic [2*WIDTH-1:0]   memoryWriteData;
    logic [7:0]           memoryAddress;
    logic [2*WIDTH-1:0]   memoryOutData;

    int unsigned checks_total  = 0;
    int unsigned checks_passed = 0;
    int unsigned checks_failed = 0;

    memory #(.WIDTH(WIDTH)) dut (.*);

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic check(input string tag,
                         input logic [2*WIDTH-1:0] expected,
                         input logic [2*WIDTH-1:0] actual);
        checks_total++;
        if (actual === expected) begin
            checks_passed++;
            $display("[PASS] %-45s | esperado=0x%04h  obtenido=0x%04h  @ %0t",
                     tag, expected, actual, $time);
        end
        else begin
            checks_failed++;
            $display("[FAIL] %-45s | esperado=0x%04h  obtenido=0x%04h  @ %0t",
                     tag, expected, actual, $time);
        end
    endtask

    task automatic write_addr(input logic [7:0] addr,
                              input logic [2*WIDTH-1:0] data);
        @(negedge clk);
        memoryAddress   = addr;
        memoryWriteData = data;
        memoryWrite     = 1'b1;
        @(posedge clk);
        @(negedge clk);
        memoryWrite     = 1'b0;
    endtask

    initial begin
        $fsdbDumpfile("memory_standalone.fsdb");
        $fsdbDumpvars(0, tb_memory);
    end

    initial begin
        $display("================================================================");
        $display("  TB standalone: memory (8 palabras x 2*WIDTH bits)");
        $display("================================================================");

        // Init
        memoryWrite = 1'b0;
        memoryRead  = 1'b0;
        memoryAddress = '0;
        memoryWriteData = '0;
        #12;

        //----------------------------------------------------------------------
        // ESC 1: Escritura + lectura en la misma direccion
        //----------------------------------------------------------------------
        $display("\n--- ESC 1: Write y read en misma direccion ---");
        write_addr(8'h00, 16'hCAFE);
        memoryRead    = 1'b1;
        memoryAddress = 8'h00;
        #2;
        check("Read addr[0] tras write CAFE", 16'hCAFE, memoryOutData);

        //----------------------------------------------------------------------
        // ESC 2: Escritura en varias direcciones y lectura secuencial
        //----------------------------------------------------------------------
        $display("\n--- ESC 2: Multiples writes y reads ---");
        memoryRead = 1'b0;
        write_addr(8'h01, 16'h1111);
        write_addr(8'h02, 16'h2222);
        write_addr(8'h03, 16'h3333);
        write_addr(8'h07, 16'h7777);

        memoryRead = 1'b1;
        memoryAddress = 8'h01; #2;
        check("Read addr[1]=1111", 16'h1111, memoryOutData);
        memoryAddress = 8'h02; #2;
        check("Read addr[2]=2222", 16'h2222, memoryOutData);
        memoryAddress = 8'h03; #2;
        check("Read addr[3]=3333", 16'h3333, memoryOutData);
        memoryAddress = 8'h07; #2;
        check("Read addr[7]=7777", 16'h7777, memoryOutData);

        //----------------------------------------------------------------------
        // ESC 3: memoryWrite=0 no debe escribir
        //----------------------------------------------------------------------
        $display("\n--- ESC 3: memoryWrite=0 no escribe ---");
        memoryRead = 1'b0;
        @(negedge clk);
        memoryAddress   = 8'h00;
        memoryWriteData = 16'hDEAD;    // ruido
        memoryWrite     = 1'b0;
        @(posedge clk);
        @(negedge clk);
        memoryRead    = 1'b1;
        memoryAddress = 8'h00;
        #2;
        check("addr[0] retuvo CAFE (no se escribio DEAD)", 16'hCAFE, memoryOutData);

        //----------------------------------------------------------------------
        // ESC 4: memoryRead=0 → data_out=0
        //----------------------------------------------------------------------
        $display("\n--- ESC 4: memoryRead=0 gating de salida ---");
        memoryRead    = 1'b0;
        memoryAddress = 8'h01;
        #2;
        check("Read=0: data_out debe ser 0", 16'h0000, memoryOutData);

        //----------------------------------------------------------------------
        // ESC 5: Lectura asincrona — cambio de addr refleja sin esperar clk
        //----------------------------------------------------------------------
        $display("\n--- ESC 5: Lectura asincrona ---");
        memoryRead = 1'b1;
        memoryAddress = 8'h01; #2;
        check("Async read addr[1]", 16'h1111, memoryOutData);
        memoryAddress = 8'h02; #2;
        check("Async read addr[2] (sin clk)", 16'h2222, memoryOutData);
        memoryAddress = 8'h07; #2;
        check("Async read addr[7] (sin clk)", 16'h7777, memoryOutData);

        //----------------------------------------------------------------------
        // ESC 6: Overwrite — la ultima escritura gana
        //----------------------------------------------------------------------
        $display("\n--- ESC 6: Overwrite en misma direccion ---");
        memoryRead = 1'b0;
        write_addr(8'h05, 16'hAAAA);
        write_addr(8'h05, 16'hBBBB);
        memoryRead = 1'b1;
        memoryAddress = 8'h05; #2;
        check("Overwrite addr[5]=BBBB (no AAAA)", 16'hBBBB, memoryOutData);

        //----------------------------------------------------------------------
        // Reporte final
        //----------------------------------------------------------------------
        $display("\n================================================================");
        $display("  Reporte final:");
        $display("    Checks totales : %0d", checks_total);
        $display("    PASS           : %0d", checks_passed);
        $display("    FAIL           : %0d", checks_failed);
        if (checks_failed == 0)
            $display("  >>> ALL TESTS PASSED <<<");
        else
            $display("  >>> %0d TESTS FAILED <<<", checks_failed);
        $display("================================================================");

        #20 $finish;
    end

    initial begin
        #20us;
        $display("[FATAL] Watchdog: la simulacion excedio 20us");
        $finish;
    end

endmodule
