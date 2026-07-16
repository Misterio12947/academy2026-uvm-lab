//------------------------------------------------------------------------------
// tb_register_bank.sv
//
// Testbench standalone para el register_bank (registro D con enable y reset
// asincrono activo alto). Cubre 6 escenarios criticos con checks auto-pass/fail.
//
// Compilar y correr:
//   vcs -sverilog -debug_access+all -kdb tb_register_bank.sv ../rtl/register_bank.sv -o simv
//   ./simv
//
// Verdi (waves):
//   verdi -sv -f filelist.f &
//------------------------------------------------------------------------------
`timescale 1ns/1ps

module tb_register_bank;

    //--------------------------------------------------------------------------
    // Parametros y senales
    //--------------------------------------------------------------------------
    localparam int WIDTH = 8;

    logic              clk;
    logic              rst;
    logic              wr_en;
    logic [WIDTH-1:0]  in;
    logic [WIDTH-1:0]  out;

    // Contadores para reporte final
    int unsigned checks_total  = 0;
    int unsigned checks_passed = 0;
    int unsigned checks_failed = 0;

    //--------------------------------------------------------------------------
    // DUT
    //--------------------------------------------------------------------------
    register_bank #(.WIDTH(WIDTH)) dut (
        .clk   (clk),
        .rst   (rst),
        .wr_en (wr_en),
        .in    (in),
        .out   (out)
    );

    //--------------------------------------------------------------------------
    // Reloj: 100 MHz (periodo 10 ns)
    //--------------------------------------------------------------------------
    initial clk = 1'b0;
    always #5 clk = ~clk;

    //--------------------------------------------------------------------------
    // Task de check con reporte automatico
    //--------------------------------------------------------------------------
    task automatic check(input string tag,
                         input logic [WIDTH-1:0] expected,
                         input logic [WIDTH-1:0] actual);
        checks_total++;
        if (actual === expected) begin
            checks_passed++;
            $display("[PASS] %-40s | esperado=0x%02h  obtenido=0x%02h  @ %0t",
                     tag, expected, actual, $time);
        end
        else begin
            checks_failed++;
            $display("[FAIL] %-40s | esperado=0x%02h  obtenido=0x%02h  @ %0t",
                     tag, expected, actual, $time);
        end
    endtask

    //--------------------------------------------------------------------------
    // Dump para Verdi
    //--------------------------------------------------------------------------
    initial begin
        $fsdbDumpfile("regbank_standalone.fsdb");
        $fsdbDumpvars(0, tb_register_bank);
    end

    //--------------------------------------------------------------------------
    // Escenarios de prueba
    //--------------------------------------------------------------------------
    initial begin
        $display("================================================================");
        $display("  TB standalone: register_bank");
        $display("================================================================");

        //----------------------------------------------------------------------
        // ESCENARIO 1: Reset asincrono al arranque
        //----------------------------------------------------------------------
        // Verifica que rst=1 fuerza out=0 sin depender del flanco de clk.
        $display("\n--- ESC 1: Reset asincrono al arranque ---");
        rst   = 1'b1;
        wr_en = 1'b0;
        in    = 8'hAA;      // ruido en la entrada; no debe capturarlo
        #3;                 // deliberadamente antes del primer posedge (t=5ns)
        check("Reset asincrono fuerza out=0",   8'h00, out);

        // Libera reset alineado a un tiempo estable
        @(negedge clk);
        rst = 1'b0;
        #1;
        check("Post-reset: out se mantiene en 0", 8'h00, out);

        //----------------------------------------------------------------------
        // ESCENARIO 2: Write con wr_en=1
        //----------------------------------------------------------------------
        // Verifica que en posedge clk con wr_en=1, out captura el valor de in.
        $display("\n--- ESC 2: Write con wr_en=1 ---");
        @(negedge clk);
        wr_en = 1'b1;
        in    = 8'h5A;
        @(posedge clk);
        #1;
        check("Write captura in=0x5A en out",     8'h5A, out);

        @(negedge clk);
        in = 8'hC3;
        @(posedge clk);
        #1;
        check("Write captura in=0xC3 en out",     8'hC3, out);

        //----------------------------------------------------------------------
        // ESCENARIO 3: Hold con wr_en=0
        //----------------------------------------------------------------------
        // Verifica que con wr_en=0, out mantiene su valor previo por varios
        // ciclos, ignorando cambios en 'in'.
        $display("\n--- ESC 3: Hold con wr_en=0 ---");
        @(negedge clk);
        wr_en = 1'b0;
        in    = 8'hFF;       // ruido; el DUT debe ignorarlo
        repeat (5) begin
            @(posedge clk);
            #1;
            check("Hold sostenido: out sigue en 0xC3", 8'hC3, out);
        end

        //----------------------------------------------------------------------
        // ESCENARIO 4: Back-to-back writes
        //----------------------------------------------------------------------
        // Verifica que escrituras consecutivas actualizan out cada ciclo.
        $display("\n--- ESC 4: Back-to-back writes ---");
        @(negedge clk);
        wr_en = 1'b1;
        begin
            logic [7:0] pattern [4] = '{8'h11, 8'h22, 8'h33, 8'h44};
            foreach (pattern[i]) begin
                @(negedge clk);
                in = pattern[i];
                @(posedge clk);
                #1;
                check($sformatf("Back-to-back write [%0d]=0x%02h", i, pattern[i]),
                      pattern[i], out);
            end
        end

        //----------------------------------------------------------------------
        // ESCENARIO 5: Reset domina sobre wr_en
        //----------------------------------------------------------------------
        // Verifica que con rst=1 y wr_en=1 simultaneos, el reset gana:
        // out=0, no captura 'in'.
        $display("\n--- ESC 5: Reset domina sobre wr_en ---");
        @(negedge clk);
        wr_en = 1'b1;
        in    = 8'hBE;       // intento de escritura
        rst   = 1'b1;        // reset asincrono simultaneo
        #2;                  // asincrono: no espera posedge
        check("rst=1 + wr_en=1: reset gana, out=0",  8'h00, out);

        // Verifica que el reset se mantiene durante clk edges
        @(posedge clk);
        #1;
        check("rst=1 sostenido durante posedge clk", 8'h00, out);

        @(negedge clk);
        rst = 1'b0;         // libera reset (wr_en sigue en 1, in=0xBE)
        @(posedge clk);
        #1;
        check("Post-reset con wr_en=1: captura 0xBE", 8'hBE, out);

        //----------------------------------------------------------------------
        // ESCENARIO 6: Reset asincrono fuera de flanco de clk
        //----------------------------------------------------------------------
        // Verifica que rst=1 dispara out=0 sin necesidad de posedge clk.
        $display("\n--- ESC 6: Reset asincrono fuera de edge ---");
        @(negedge clk);
        wr_en = 1'b0;       // hold explicito
        in    = 8'h77;
        // Espera hasta un punto entre edges (clk=1, ~2ns despues del posedge)
        @(posedge clk);
        #2;                 // mid-cycle, lejos de cualquier edge
        rst = 1'b1;
        #1;                 // apenas 1ns despues del rst, sin posedge involucrado
        check("Reset asincrono mid-cycle fuerza out=0", 8'h00, out);

        @(negedge clk);
        rst = 1'b0;
        #1;
        check("Libera reset mid-cycle: hold en 0",       8'h00, out);

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

    //--------------------------------------------------------------------------
    // Watchdog
    //--------------------------------------------------------------------------
    initial begin
        #10us;
        $display("[FATAL] Watchdog: la simulacion excedio 10us");
        $finish;
    end

endmodule
