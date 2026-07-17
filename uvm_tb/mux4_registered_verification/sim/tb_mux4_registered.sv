//------------------------------------------------------------------------------
// tb_mux4_registered.sv
// TB standalone del mux4_registered. Verifica la composicion mux4 + regbank:
//   1. Reset asincrono al arranque fuerza out=0
//   2. Captura de cada select (00, 01, 10, 11) con wr_en=1
//   3. Hold con wr_en=0: cambios de sel no afectan out
//   4. Reset mid-operacion domina sobre wr_en
//   5. Back-to-back writes con distintos selects
//   6. Cambio de din de la entrada seleccionada durante hold
//------------------------------------------------------------------------------
`timescale 1ns/1ps

module tb_mux4_registered;

    localparam int WIDTH = 8;

    logic                 clk;
    logic                 rst;
    logic                 wr_en;
    logic [1:0]           sel;
    logic [WIDTH-1:0]     in1, in2, in3, in4;
    logic [WIDTH-1:0]     out;

    int unsigned checks_total  = 0;
    int unsigned checks_passed = 0;
    int unsigned checks_failed = 0;

    mux4_registered #(.WIDTH(WIDTH)) dut (.*);

    // Clock 100 MHz
    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic check(input string tag,
                         input logic [WIDTH-1:0] expected,
                         input logic [WIDTH-1:0] actual);
        checks_total++;
        if (actual === expected) begin
            checks_passed++;
            $display("[PASS] %-50s | esperado=0x%02h  obtenido=0x%02h  @ %0t",
                     tag, expected, actual, $time);
        end
        else begin
            checks_failed++;
            $display("[FAIL] %-50s | esperado=0x%02h  obtenido=0x%02h  @ %0t",
                     tag, expected, actual, $time);
        end
    endtask

    // Task para capturar valor via mux4_registered: setea sel/wr_en/in
    // y espera al posedge clk para captura.
    task automatic capture(input logic [1:0] s);
        @(negedge clk);
        sel   = s;
        wr_en = 1'b1;
        @(posedge clk);
        @(negedge clk);
        wr_en = 1'b0;
    endtask

    initial begin
        $fsdbDumpfile("mux4_registered_standalone.fsdb");
        $fsdbDumpvars(0, tb_mux4_registered);
    end

    initial begin
        $display("================================================================");
        $display("  TB standalone: mux4_registered (WIDTH=%0d)", WIDTH);
        $display("================================================================");

        // Estado inicial + reset asincrono
        rst   = 1'b1;
        wr_en = 1'b0;
        sel   = 2'b00;
        in1   = 8'hAA; in2 = 8'hBB; in3 = 8'hCC; in4 = 8'hDD;
        #3;

        //----------------------------------------------------------------------
        // ESC 1: Reset asincrono al arranque fuerza out=0
        //----------------------------------------------------------------------
        $display("\n--- ESC 1: Reset asincrono al arranque ---");
        check("Reset asincrono fuerza out=0",           8'h00, out);

        @(negedge clk);
        rst = 1'b0;
        #1;
        check("Post-reset: out se mantiene en 0",       8'h00, out);

        //----------------------------------------------------------------------
        // ESC 2: Captura de cada select con wr_en=1
        //----------------------------------------------------------------------
        $display("\n--- ESC 2: Captura de cada select ---");
        capture(2'b00); #1;
        check("sel=00 + wr_en=1 -> out=in1=AA",         8'hAA, out);

        capture(2'b01); #1;
        check("sel=01 + wr_en=1 -> out=in2=BB",         8'hBB, out);

        capture(2'b10); #1;
        check("sel=10 + wr_en=1 -> out=in3=CC",         8'hCC, out);

        capture(2'b11); #1;
        check("sel=11 + wr_en=1 -> out=in4=DD",         8'hDD, out);

        //----------------------------------------------------------------------
        // ESC 3: Hold con wr_en=0 - cambios de sel no afectan out
        //----------------------------------------------------------------------
        $display("\n--- ESC 3: Hold con wr_en=0 ---");
        // out actualmente = DD (del ESC 2). wr_en=0.
        @(negedge clk);
        sel = 2'b00;   // cambio de sel a in1 (AA)
        @(posedge clk);
        #1;
        check("wr_en=0 + sel cambia a 00: out sigue DD", 8'hDD, out);

        @(negedge clk);
        sel = 2'b10;   // cambio a in3 (CC)
        @(posedge clk);
        #1;
        check("wr_en=0 + sel cambia a 10: out sigue DD", 8'hDD, out);

        //----------------------------------------------------------------------
        // ESC 4: Reset mid-operacion domina sobre wr_en
        //----------------------------------------------------------------------
        $display("\n--- ESC 4: Reset domina sobre wr_en ---");
        @(negedge clk);
        wr_en = 1'b1;
        sel   = 2'b11;   // in4=DD (intento de captura)
        rst   = 1'b1;    // reset asincrono simultaneo
        #2;
        check("rst=1 + wr_en=1: reset gana, out=0",     8'h00, out);

        @(posedge clk);
        #1;
        check("rst sostenido durante posedge: out=0",   8'h00, out);

        @(negedge clk);
        rst = 1'b0;
        // wr_en aun 1, sel=11, in4=DD -> proximo posedge captura
        @(posedge clk);
        #1;
        check("Post-reset con wr_en=1: captura in4=DD", 8'hDD, out);

        //----------------------------------------------------------------------
        // ESC 5: Back-to-back writes con distintos selects
        //----------------------------------------------------------------------
        $display("\n--- ESC 5: Back-to-back writes ---");
        in1 = 8'h11; in2 = 8'h22; in3 = 8'h33; in4 = 8'h44;

        @(negedge clk);
        wr_en = 1'b1;
        sel   = 2'b00; @(posedge clk); #1;
        check("B2B write [00] -> 11",                   8'h11, out);
        sel   = 2'b01; @(posedge clk); #1;
        check("B2B write [01] -> 22",                   8'h22, out);
        sel   = 2'b10; @(posedge clk); #1;
        check("B2B write [10] -> 33",                   8'h33, out);
        sel   = 2'b11; @(posedge clk); #1;
        check("B2B write [11] -> 44",                   8'h44, out);
        @(negedge clk);
        wr_en = 1'b0;

        //----------------------------------------------------------------------
        // ESC 6: Cambio de din de entrada seleccionada durante hold
        //----------------------------------------------------------------------
        // Verifica que 'out' esta registrado: cambiar el din NO cambia out
        // hasta que wr_en=1 y ocurra un posedge.
        $display("\n--- ESC 6: Cambio de din durante hold ---");
        // out actualmente = 44 (in4 del ESC 5). Cambia in4 sin activar wr_en.
        @(negedge clk);
        in4 = 8'hEE;   // cambia din de la entrada seleccionada
        // wr_en aun 0
        @(posedge clk);
        #1;
        check("Cambio de in4 con wr_en=0: out sigue 44", 8'h44, out);

        // Ahora activamos wr_en, debe capturar el nuevo valor EE
        @(negedge clk);
        wr_en = 1'b1;
        @(posedge clk);
        #1;
        check("wr_en=1 tras cambio de in4: out=EE",     8'hEE, out);

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
