//------------------------------------------------------------------------------
// tb_mux2_registered.sv
// TB standalone del mux2_registered. Verifica la composicion mux2 + regbank
// con bus de 2*WIDTH bits.
//
// 6 escenarios criticos:
//   1. Reset asincrono al arranque fuerza out=0
//   2. Captura de cada select (0, 1) con wr_en=1
//   3. Hold con wr_en=0: cambios de sel no afectan out
//   4. Reset mid-operacion domina sobre wr_en
//   5. Back-to-back writes alternando selects
//   6. Cambio de din de la entrada seleccionada durante hold
//------------------------------------------------------------------------------
`timescale 1ns/1ps

module tb_mux2_registered;

    localparam int WIDTH = 8;   // bus interno sera 2*WIDTH = 16 bits

    logic                     clk;
    logic                     rst;
    logic                     sel;
    logic                     wr_en;
    logic [2*WIDTH-1:0]       in1, in2;
    logic [2*WIDTH-1:0]       out;

    int unsigned checks_total  = 0;
    int unsigned checks_passed = 0;
    int unsigned checks_failed = 0;

    mux2_registered #(.WIDTH(WIDTH)) dut (.*);

    // Clock 100 MHz
    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic check(input string tag,
                         input logic [2*WIDTH-1:0] expected,
                         input logic [2*WIDTH-1:0] actual);
        checks_total++;
        if (actual === expected) begin
            checks_passed++;
            $display("[PASS] %-50s | esperado=0x%04h  obtenido=0x%04h  @ %0t",
                     tag, expected, actual, $time);
        end
        else begin
            checks_failed++;
            $display("[FAIL] %-50s | esperado=0x%04h  obtenido=0x%04h  @ %0t",
                     tag, expected, actual, $time);
        end
    endtask

    // Task para capturar valor via mux2_registered
    task automatic capture(input logic s);
        @(negedge clk);
        sel   = s;
        wr_en = 1'b1;
        @(posedge clk);
        @(negedge clk);
        wr_en = 1'b0;
    endtask

    initial begin
        $fsdbDumpfile("mux2_registered_standalone.fsdb");
        $fsdbDumpvars(0, tb_mux2_registered);
    end

    initial begin
        $display("================================================================");
        $display("  TB standalone: mux2_registered (bus 2*WIDTH = %0d bits)", 2*WIDTH);
        $display("================================================================");

        // Estado inicial + reset asincrono
        rst   = 1'b1;
        wr_en = 1'b0;
        sel   = 1'b0;
        in1   = 16'hAAAA;
        in2   = 16'hBBBB;
        #3;

        //----------------------------------------------------------------------
        // ESC 1: Reset asincrono al arranque
        //----------------------------------------------------------------------
        $display("\n--- ESC 1: Reset asincrono al arranque ---");
        check("Reset asincrono fuerza out=0",             16'h0000, out);

        @(negedge clk);
        rst = 1'b0;
        #1;
        check("Post-reset: out se mantiene en 0",         16'h0000, out);

        //----------------------------------------------------------------------
        // ESC 2: Captura de cada select con wr_en=1
        //----------------------------------------------------------------------
        $display("\n--- ESC 2: Captura de cada select ---");
        capture(1'b0); #1;
        check("sel=0 + wr_en=1 -> out=in1=AAAA",          16'hAAAA, out);

        capture(1'b1); #1;
        check("sel=1 + wr_en=1 -> out=in2=BBBB",          16'hBBBB, out);

        //----------------------------------------------------------------------
        // ESC 3: Hold con wr_en=0
        //----------------------------------------------------------------------
        $display("\n--- ESC 3: Hold con wr_en=0 ---");
        // out actualmente = BBBB. wr_en=0.
        @(negedge clk);
        sel = 1'b0;                 // cambio de sel a in1 (AAAA)
        @(posedge clk);
        #1;
        check("wr_en=0 + sel cambia a 0: out sigue BBBB", 16'hBBBB, out);

        @(negedge clk);
        sel = 1'b1;                 // cambio a in2 (BBBB, mismo pero refuerza hold)
        @(posedge clk);
        #1;
        check("wr_en=0 + sel cambia a 1: out sigue BBBB", 16'hBBBB, out);

        //----------------------------------------------------------------------
        // ESC 4: Reset mid-operacion domina sobre wr_en
        //----------------------------------------------------------------------
        $display("\n--- ESC 4: Reset domina sobre wr_en ---");
        @(negedge clk);
        wr_en = 1'b1;
        sel   = 1'b0;               // in1=AAAA (intento de captura)
        rst   = 1'b1;               // reset asincrono simultaneo
        #2;
        check("rst=1 + wr_en=1: reset gana, out=0",       16'h0000, out);

        @(posedge clk);
        #1;
        check("rst sostenido durante posedge: out=0",     16'h0000, out);

        @(negedge clk);
        rst = 1'b0;
        // wr_en aun 1, sel=0, in1=AAAA -> proximo posedge captura
        @(posedge clk);
        #1;
        check("Post-reset con wr_en=1: captura in1=AAAA", 16'hAAAA, out);

        //----------------------------------------------------------------------
        // ESC 5: Back-to-back writes alternando selects
        //----------------------------------------------------------------------
        $display("\n--- ESC 5: Back-to-back writes alternando selects ---");
        in1 = 16'h1111;
        in2 = 16'h2222;

        @(negedge clk);
        wr_en = 1'b1;
        sel   = 1'b0; @(posedge clk); #1;
        check("B2B write sel=0 -> 1111",                  16'h1111, out);
        sel   = 1'b1; @(posedge clk); #1;
        check("B2B write sel=1 -> 2222",                  16'h2222, out);
        sel   = 1'b0; @(posedge clk); #1;
        check("B2B write sel=0 -> 1111 (vuelta)",         16'h1111, out);
        sel   = 1'b1; @(posedge clk); #1;
        check("B2B write sel=1 -> 2222 (vuelta)",         16'h2222, out);
        @(negedge clk);
        wr_en = 1'b0;

        //----------------------------------------------------------------------
        // ESC 6: Cambio de din durante hold vs con wr_en=1
        //----------------------------------------------------------------------
        $display("\n--- ESC 6: Cambio de din durante hold ---");
        // out actualmente = 2222 (in2 del ESC 5, sel=1). Cambia in2 sin wr_en.
        @(negedge clk);
        in2 = 16'hCAFE;             // cambia din de la entrada seleccionada
        // wr_en aun 0
        @(posedge clk);
        #1;
        check("Cambio de in2 con wr_en=0: out sigue 2222", 16'h2222, out);

        // Ahora activamos wr_en, debe capturar el nuevo valor CAFE
        @(negedge clk);
        wr_en = 1'b1;
        @(posedge clk);
        #1;
        check("wr_en=1 tras cambio de in2: out=CAFE",     16'hCAFE, out);

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
        #10us;
        $display("[FATAL] Watchdog: la simulacion excedio 10us");
        $finish;
    end

endmodule
