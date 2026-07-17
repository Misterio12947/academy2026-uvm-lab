//------------------------------------------------------------------------------
// tb_mux4.sv
// TB standalone del mux4. Combinacional, sin clk. 6 escenarios criticos:
//   1. Cada select individual (din1..din4)
//   2. Cambio dinamico de select (verifica combinacional)
//   3. Valores extremos: todos 0, todos FF
//   4. Independencia de entradas: cambio en un din no seleccionado no afecta
//   5. WIDTH parametrizado con distintos patrones por din
//   6. Barrido de todos los selects con patrones distintos
//------------------------------------------------------------------------------
`timescale 1ns/1ps

module tb_mux4;

    localparam int WIDTH = 8;

    logic [WIDTH-1:0] din1, din2, din3, din4;
    logic [1:0]       select;
    logic [WIDTH-1:0] dout;

    int unsigned checks_total  = 0;
    int unsigned checks_passed = 0;
    int unsigned checks_failed = 0;

    mux4 #(.WIDTH(WIDTH)) dut (.*);

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
        $fsdbDumpfile("mux4_standalone.fsdb");
        $fsdbDumpvars(0, tb_mux4);
    end

    initial begin
        $display("================================================================");
        $display("  TB standalone: mux4 (4:1, WIDTH=%0d)", WIDTH);
        $display("================================================================");

        //----------------------------------------------------------------------
        // ESC 1: Cada select individual con valores distintivos por din
        //----------------------------------------------------------------------
        $display("\n--- ESC 1: Selects individuales ---");
        din1 = 8'hAA; din2 = 8'hBB; din3 = 8'hCC; din4 = 8'hDD;

        select = 2'b00; #1;
        check("select=00 -> dout=din1=AA", 8'hAA, dout);
        select = 2'b01; #1;
        check("select=01 -> dout=din2=BB", 8'hBB, dout);
        select = 2'b10; #1;
        check("select=10 -> dout=din3=CC", 8'hCC, dout);
        select = 2'b11; #1;
        check("select=11 -> dout=din4=DD", 8'hDD, dout);

        //----------------------------------------------------------------------
        // ESC 2: Cambio dinamico de select (combinacional, sin clk)
        //----------------------------------------------------------------------
        $display("\n--- ESC 2: Cambio dinamico de select ---");
        din1 = 8'h11; din2 = 8'h22; din3 = 8'h33; din4 = 8'h44;
        select = 2'b00; #1;
        check("Cambio dinamico [00] -> 11",  8'h11, dout);
        select = 2'b11; #1;
        check("Cambio dinamico [11] -> 44",  8'h44, dout);
        select = 2'b01; #1;
        check("Cambio dinamico [01] -> 22",  8'h22, dout);
        select = 2'b10; #1;
        check("Cambio dinamico [10] -> 33",  8'h33, dout);

        //----------------------------------------------------------------------
        // ESC 3: Valores extremos
        //----------------------------------------------------------------------
        $display("\n--- ESC 3: Valores extremos ---");
        din1 = 8'h00; din2 = 8'h00; din3 = 8'h00; din4 = 8'h00;
        select = 2'b00; #1;
        check("Todos zero: dout=0",           8'h00, dout);

        din1 = 8'hFF; din2 = 8'hFF; din3 = 8'hFF; din4 = 8'hFF;
        select = 2'b11; #1;
        check("Todos max: dout=FF",           8'hFF, dout);

        //----------------------------------------------------------------------
        // ESC 4: Independencia entre entradas
        //----------------------------------------------------------------------
        $display("\n--- ESC 4: Independencia entre entradas ---");
        din1 = 8'h55; din2 = 8'h00; din3 = 8'h00; din4 = 8'h00;
        select = 2'b00; #1;
        check("Solo din1 activo",             8'h55, dout);

        // Cambiar din2/3/4 sin cambiar select -> dout no debe cambiar
        din2 = 8'hAA; din3 = 8'hAA; din4 = 8'hAA;
        #1;
        check("Ruido en din2/3/4 no afecta",  8'h55, dout);

        //----------------------------------------------------------------------
        // ESC 5: Barrido de select con patrones alternados
        //----------------------------------------------------------------------
        $display("\n--- ESC 5: Barrido con patrones alternados ---");
        din1 = 8'h5A; din2 = 8'hA5; din3 = 8'h3C; din4 = 8'hC3;

        select = 2'b00; #1;
        check("Barrido select=00 -> 5A",      8'h5A, dout);
        select = 2'b01; #1;
        check("Barrido select=01 -> A5",      8'hA5, dout);
        select = 2'b10; #1;
        check("Barrido select=10 -> 3C",      8'h3C, dout);
        select = 2'b11; #1;
        check("Barrido select=11 -> C3",      8'hC3, dout);

		//----------------------------------------------------------------------
        // ESC 6: Cambios rapidos (stress combinacional)
        //----------------------------------------------------------------------
        $display("\n--- ESC 6: Cambios rapidos ---");
        din1 = 8'h01; din2 = 8'h02; din3 = 8'h04; din4 = 8'h08;
        for (int i = 0; i < 8; i++) begin
            select = i[1:0];
            #1;
        end
        // Ultimo select = 7[1:0] = 11 -> din4 = 08
        check("Ultimo del barrido rapido (i=7 -> select=11)",  8'h08, dout);

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
