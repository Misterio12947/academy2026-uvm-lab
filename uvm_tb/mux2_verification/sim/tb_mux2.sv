//------------------------------------------------------------------------------
// tb_mux2.sv
// TB standalone del mux2. Combinacional, sin clk. 6 escenarios criticos:
//   1. Cada select individual (din1, din2)
//   2. Cambio dinamico de select (verifica combinacional)
//   3. Valores extremos: todos 0, todos FF
//   4. Independencia de entradas: cambio en din no seleccionado no afecta
//   5. Barrido con patrones alternados
//   6. Toggle rapido de select (stress combinacional)
//------------------------------------------------------------------------------
`timescale 1ns/1ps

module tb_mux2;

    localparam int WIDTH = 8;

    logic [WIDTH-1:0] din1, din2;
    logic             select;
    logic [WIDTH-1:0] dout;

    int unsigned checks_total  = 0;
    int unsigned checks_passed = 0;
    int unsigned checks_failed = 0;

    mux2 #(.WIDTH(WIDTH)) dut (.*);

    task automatic check(input string tag,
                         input logic [WIDTH-1:0] expected,
                         input logic [WIDTH-1:0] actual);
        checks_total++;
        if (actual === expected) begin
            checks_passed++;
            $display("[PASS] %-45s | esperado=0x%02h  obtenido=0x%02h",
                     tag, expected, actual);
        end
        else begin
            checks_failed++;
            $display("[FAIL] %-45s | esperado=0x%02h  obtenido=0x%02h",
                     tag, expected, actual);
        end
    endtask

    initial begin
        $fsdbDumpfile("mux2_standalone.fsdb");
        $fsdbDumpvars(0, tb_mux2);
    end

    initial begin
        $display("================================================================");
        $display("  TB standalone: mux2 (2:1, WIDTH=%0d)", WIDTH);
        $display("================================================================");

        //----------------------------------------------------------------------
        // ESC 1: Cada select individual con valores distintivos por din
        //----------------------------------------------------------------------
        $display("\n--- ESC 1: Selects individuales ---");
        din1 = 8'hAA; din2 = 8'hBB;

        select = 1'b0; #1;
        check("select=0 -> dout=din1=AA",             8'hAA, dout);
        select = 1'b1; #1;
        check("select=1 -> dout=din2=BB",             8'hBB, dout);

        //----------------------------------------------------------------------
        // ESC 2: Cambio dinamico de select
        //----------------------------------------------------------------------
        $display("\n--- ESC 2: Cambio dinamico de select ---");
        din1 = 8'h11; din2 = 8'h22;
        select = 1'b0; #1;
        check("Cambio dinamico [0] -> 11",            8'h11, dout);
        select = 1'b1; #1;
        check("Cambio dinamico [1] -> 22",            8'h22, dout);
        select = 1'b0; #1;
        check("Cambio dinamico [0] -> 11 (vuelta)",   8'h11, dout);

        //----------------------------------------------------------------------
        // ESC 3: Valores extremos
        //----------------------------------------------------------------------
        $display("\n--- ESC 3: Valores extremos ---");
        din1 = 8'h00; din2 = 8'h00;
        select = 1'b0; #1;
        check("Todos zero: dout=0",                    8'h00, dout);

        din1 = 8'hFF; din2 = 8'hFF;
        select = 1'b1; #1;
        check("Todos max: dout=FF",                    8'hFF, dout);

        //----------------------------------------------------------------------
        // ESC 4: Independencia entre entradas
        //----------------------------------------------------------------------
        $display("\n--- ESC 4: Independencia entre entradas ---");
        din1 = 8'h55; din2 = 8'h00;
        select = 1'b0; #1;
        check("Solo din1 activo",                      8'h55, dout);

        din2 = 8'hAA;   // cambiar din2 sin cambiar select
        #1;
        check("Ruido en din2 no afecta cuando sel=0",  8'h55, dout);

        select = 1'b1; #1;
        check("Cambio a sel=1: refleja din2=AA",       8'hAA, dout);

        din1 = 8'h33;   // cambiar din1 sin cambiar select
        #1;
        check("Ruido en din1 no afecta cuando sel=1",  8'hAA, dout);

        //----------------------------------------------------------------------
        // ESC 5: Barrido con patrones alternados
        //----------------------------------------------------------------------
        $display("\n--- ESC 5: Barrido con patrones alternados ---");
        din1 = 8'h5A; din2 = 8'hA5;

        select = 1'b0; #1;
        check("Barrido select=0 -> 5A",                8'h5A, dout);
        select = 1'b1; #1;
        check("Barrido select=1 -> A5",                8'hA5, dout);

        din1 = 8'h3C; din2 = 8'hC3;
        select = 1'b0; #1;
        check("Barrido nuevo patron select=0 -> 3C",   8'h3C, dout);
        select = 1'b1; #1;
        check("Barrido nuevo patron select=1 -> C3",   8'hC3, dout);

        //----------------------------------------------------------------------
        // ESC 6: Toggle rapido de select
        //----------------------------------------------------------------------
        $display("\n--- ESC 6: Toggle rapido de select ---");
        din1 = 8'h01; din2 = 8'h02;
        for (int i = 0; i < 10; i++) begin
            select = i[0];   // alterna 0, 1, 0, 1, ...
            #1;
        end
        // Ultimo select = 9[0] = 1 -> din2 = 02
        check("Ultimo del toggle (i=9 -> sel=1)",      8'h02, dout);

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

        #5 $finish;
    end

endmodule
