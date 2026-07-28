//------------------------------------------------------------------------------
// tb_top.sv
// TB standalone del CPU multiciclo completo. Verifica integracion end-to-end
// de los 7 submodulos + control.
//
// Modelo de timing:
//   - Cada instruccion toma 3 posedges: FETCH_DECODE, EXECUTE, STORE.
//   - cpu_rdy=1 en STORE (ultimo posedge del ciclo).
//   - cmd_in se captura en el edge que transiciona a FETCH_DECODE (por
//     datain_reg_en=1 en STORE y en RST_ST).
//
// 10 escenarios cubren cada opcode + integracion + feedback + errores.
//------------------------------------------------------------------------------
`timescale 1ns/1ps

module tb_top;

    localparam int WIDTH = 8;

    logic                 clk;
    logic                 rst;
    logic [6:0]           cmd_in;
    logic [WIDTH-1:0]     din_1, din_2, din_3;
    logic [WIDTH-1:0]     dout_low, dout_high;
    logic                 cpu_rdy, zero, error;

    int unsigned checks_total  = 0;
    int unsigned checks_passed = 0;
    int unsigned checks_failed = 0;

    top #(.WIDTH(WIDTH)) dut (.*);

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic check_val(input string tag,
                             input logic [2*WIDTH-1:0] expected,
                             input logic [2*WIDTH-1:0] actual);
        checks_total++;
        if (actual === expected) begin
            checks_passed++;
            $display("[PASS] %-55s | exp=0x%04h  got=0x%04h  @ %0t",
                     tag, expected, actual, $time);
        end else begin
            checks_failed++;
            $display("[FAIL] %-55s | exp=0x%04h  got=0x%04h  @ %0t",
                     tag, expected, actual, $time);
        end
    endtask

    task automatic check_bit(input string tag,
                             input logic expected,
                             input logic actual);
        checks_total++;
        if (actual === expected) begin
            checks_passed++;
            $display("[PASS] %-55s | exp=%0b  got=%0b  @ %0t",
                     tag, expected, actual, $time);
        end else begin
            checks_failed++;
            $display("[FAIL] %-55s | exp=%0b  got=%0b  @ %0t",
                     tag, expected, actual, $time);
        end
    endtask

    function automatic logic [6:0] mk_cmd(input logic [1:0] mA,
                                          input logic [1:0] mB,
                                          input logic [2:0] op);
        return {mA, mB, op};
    endfunction

    // Reset asincrono + presenta primera instruccion + espera cpu_rdy
    task automatic reset_and_run(input logic [6:0] cmd,
                                 input logic [WIDTH-1:0] d1,
                                 input logic [WIDTH-1:0] d2,
                                 input logic [WIDTH-1:0] d3);
        @(negedge clk);
        rst    = 1'b1;
        cmd_in = cmd;
        din_1  = d1;  din_2 = d2;  din_3 = d3;
        @(negedge clk);
        @(negedge clk);
        rst = 1'b0;
        // 3 posedges: RST_ST->FETCH_DECODE->EXECUTE->STORE (cpu_rdy=1)
        repeat (3) @(posedge clk);
        #1;
    endtask

    // Ejecuta siguiente instruccion (asume que acabamos de ver cpu_rdy=1)
    task automatic run_instr(input logic [6:0] cmd,
                             input logic [WIDTH-1:0] d1,
                             input logic [WIDTH-1:0] d2,
                             input logic [WIDTH-1:0] d3);
        @(negedge clk);
        cmd_in = cmd;
        din_1  = d1;  din_2 = d2;  din_3 = d3;
        // 3 posedges hasta el proximo cpu_rdy
        repeat (3) @(posedge clk);
        #1;
    endtask

    initial begin
        $fsdbDumpfile("top_standalone.fsdb");
        $fsdbDumpvars(0, tb_top);
    end

    initial begin
        $display("================================================================");
        $display("  TB standalone: top (CPU multiciclo)");
        $display("================================================================");

        // Init
        cmd_in = '0;
        din_1  = '0;  din_2  = '0;  din_3  = '0;
        rst    = 1'b0;

        //----------------------------------------------------------------------
        // ESC 1: Reset behavior
        //----------------------------------------------------------------------
        $display("\n--- ESC 1: Reset behavior ---");
        rst = 1'b1;
        #3;
        check_bit("Reset: cpu_rdy=0",              1'b0, cpu_rdy);
        check_val("Reset: dout=0",                 16'h0000, {dout_high, dout_low});
        check_bit("Reset: zero=0",                 1'b0, zero);
        check_bit("Reset: error=0",                1'b0, error);
        rst = 1'b0;

        //----------------------------------------------------------------------
        // ESC 2: ADD 5+3=8
        //----------------------------------------------------------------------
        $display("\n--- ESC 2: ADD ---");
        reset_and_run(mk_cmd(2'b00, 2'b01, 3'b000), 8'h05, 8'h03, 8'h00);
        check_bit("ADD 5+3: cpu_rdy=1",            1'b1, cpu_rdy);
        check_val("ADD 5+3: dout=0x0008",          16'h0008, {dout_high, dout_low});
        check_bit("ADD 5+3: zero=0",               1'b0, zero);
        check_bit("ADD 5+3: error=0",              1'b0, error);

        //----------------------------------------------------------------------
        // ESC 3: SUB 16-1=15
        //----------------------------------------------------------------------
        $display("\n--- ESC 3: SUB ---");
        reset_and_run(mk_cmd(2'b00, 2'b01, 3'b001), 8'h10, 8'h01, 8'h00);
        check_bit("SUB 16-1: cpu_rdy=1",           1'b1, cpu_rdy);
        check_val("SUB 16-1: dout=0x000F",         16'h000F, {dout_high, dout_low});
        check_bit("SUB 16-1: zero=0",              1'b0, zero);

        //----------------------------------------------------------------------
        // ESC 4: MUL (verifica dout_high y dout_low)
        //----------------------------------------------------------------------
        $display("\n--- ESC 4: MUL ---");
        reset_and_run(mk_cmd(2'b00, 2'b01, 3'b010), 8'h10, 8'h10, 8'h00);
        // 16 * 16 = 256 = 0x0100
        check_val("MUL 16*16: dout=0x0100",        16'h0100, {dout_high, dout_low});

        reset_and_run(mk_cmd(2'b00, 2'b01, 3'b010), 8'hFF, 8'hFF, 8'h00);
        // 255 * 255 = 65025 = 0xFE01
        check_val("MUL 0xFF*0xFF: dout=0xFE01",    16'hFE01, {dout_high, dout_low});

        //----------------------------------------------------------------------
        // ESC 5: DIV 32/4=8
        //----------------------------------------------------------------------
        $display("\n--- ESC 5: DIV normal ---");
        reset_and_run(mk_cmd(2'b00, 2'b01, 3'b011), 8'h20, 8'h04, 8'h00);
        check_val("DIV 32/4: dout=0x0008",         16'h0008, {dout_high, dout_low});
        check_bit("DIV 32/4: error=0",             1'b0, error);

        //----------------------------------------------------------------------
        // ESC 6: DIV por cero -> error, dout=-1
        //----------------------------------------------------------------------
        $display("\n--- ESC 6: DIV por cero ---");
        reset_and_run(mk_cmd(2'b00, 2'b01, 3'b011), 8'hAA, 8'h00, 8'h00);
        check_val("DIV /0: dout=0xFFFF (-1)",      16'hFFFF, {dout_high, dout_low});
        check_bit("DIV /0: error=1",               1'b1, error);
        check_bit("DIV /0: cpu_rdy=1",             1'b1, cpu_rdy);

        //----------------------------------------------------------------------
        // ESC 7: NOP (out=0, zero=1)
        //----------------------------------------------------------------------
        $display("\n--- ESC 7: NOP ---");
        reset_and_run(mk_cmd(2'b00, 2'b00, 3'b100), 8'hDE, 8'hAD, 8'hBE);
        check_val("NOP: dout=0",                   16'h0000, {dout_high, dout_low});
        check_bit("NOP: zero=1",                   1'b1, zero);
        check_bit("NOP: error=0",                  1'b0, error);
        check_bit("NOP: cpu_rdy=1",                1'b1, cpu_rdy);

		//----------------------------------------------------------------------
        // ESC 8: STORE + LOAD (write-then-read en memoria)
        //
        // Per diagrama del spec: el STORE escribe {dout_high, dout_low} (el
        // resultado de la instruccion PREVIA) a memoria, no un dato fresco.
        // Por eso la secuencia es:
        //   1. Una instruccion que produce el dato (ADD 0xC0 + 0x0C = 0xCC)
        //   2. STORE que escribe ese {dout_high, dout_low}=0x00CC a addr=5
        //   3. LOAD que lee addr=5 y debe recuperar 0x00CC
        //----------------------------------------------------------------------
        $display("\n--- ESC 8: STORE then LOAD ---");

        // Paso 1: ADD para producir 0x00CC en {dout_high, dout_low}
        // 0xC0 + 0x0C = 0xCC
        reset_and_run(mk_cmd(2'b00, 2'b01, 3'b000), 8'hC0, 8'h0C, 8'h00);
        check_val("Setup ADD 0xC0+0x0C: dout=0x00CC", 16'h00CC, {dout_high, dout_low});

        // Paso 2: STORE a addr=5. El address viene de mux_a_out.
        // muxA selecciona din_1=0x05 como direccion. El dato escrito es el
        // {dout_high, dout_low}=0x00CC del ADD anterior.
        run_instr(mk_cmd(2'b00, 2'b00, 3'b110), 8'h05, 8'h00, 8'h00);
        check_bit("STORE: cpu_rdy=1",              1'b1, cpu_rdy);

        // Paso 3: LOAD desde addr=5. Debe recuperar 0x00CC.
        run_instr(mk_cmd(2'b00, 2'b00, 3'b101), 8'h05, 8'h00, 8'h00);
        check_bit("LOAD: cpu_rdy=1",               1'b1, cpu_rdy);
        check_val("LOAD from addr 5: dout=0x00CC", 16'h00CC, {dout_high, dout_low});

        //----------------------------------------------------------------------
        // ESC 9: Feedback loop (muxA=11 usa dout_high, muxB=11 usa dout_low)
        //----------------------------------------------------------------------
        $display("\n--- ESC 9: Feedback loop ---");
        // Instr 1: ADD 5+3=8 -> dout=0x0008 (high=0, low=8)
        reset_and_run(mk_cmd(2'b00, 2'b01, 3'b000), 8'h05, 8'h03, 8'h00);
        check_val("Instr 1 ADD 5+3: dout=0x0008",  16'h0008, {dout_high, dout_low});

        // Instr 2: ADD muxA=11 (dout_high=0), muxB=11 (dout_low=8) -> 0+8=8
        run_instr(mk_cmd(2'b11, 2'b11, 3'b000), 8'h00, 8'h00, 8'h00);
        check_val("Feedback dout_high+dout_low: dout=0x0008", 16'h0008, {dout_high, dout_low});

        //----------------------------------------------------------------------
        // ESC 10: p_error propagation via feedback -> nvalid_data -> ALU error
        //----------------------------------------------------------------------
        $display("\n--- ESC 10: p_error via feedback ---");
        // Instr 1: DIV por 0 -> error=1
        reset_and_run(mk_cmd(2'b00, 2'b01, 3'b011), 8'hAA, 8'h00, 8'h00);
        check_bit("Instr 1 DIV/0: error=1",        1'b1, error);

        // Instr 2: ADD con muxA=11 (feedback) -> nvalid_data=1 -> ALU forza error
        run_instr(mk_cmd(2'b11, 2'b00, 3'b000), 8'h00, 8'h00, 8'h00);
        check_bit("Instr 2 ADD w/ feedback+p_error: error=1", 1'b1, error);
        check_val("Instr 2: dout=0xFFFF (-1)",     16'hFFFF, {dout_high, dout_low});

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
        #50us;
        $display("[FATAL] Watchdog: la simulacion excedio 50us");
        $finish;
    end

endmodule
