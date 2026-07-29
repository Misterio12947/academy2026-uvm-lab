//------------------------------------------------------------------------------
// tb_control.sv
// TB standalone del control unit. Verifica la FSM de 4 estados, la
// decodificacion de cmd_in por opcode, y la propagacion de p_error.
//
// Encoding del opcode ALU (one-hot per revisor feedback):
//   ADD  -> 4'b0001
//   SUB  -> 4'b0010
//   MUL  -> 4'b0100
//   DIV  -> 4'b1000
//   NOP0/LOAD/STORE/NOP1 -> 4'b0000 (ALU pasiva)
//
// 9 escenarios:
//   1. Reset asincrono lleva a RST_ST con outputs correctos
//   2. Transicion RST -> FETCH_DECODE -> EXECUTE -> STORE (ciclo completo ADD)
//   3. Ciclo LOAD (memoryRead=1 y selmux2=1 en EXECUTE, opcode=0000)
//   4. Ciclo STORE (memoryWrite=1 en STORE, opcode=0000)
//   5. Ciclos NOP0 y NOP1 (no acceden memoria, opcode=0000)
//   6. cpu_rdy solo activo en STORE (verificacion de pulso)
//   7. nvalid_data: p_error + feedback (muxA=11 o muxB=11)
//   8. Reset mid-instruccion vuelve a RST_ST inmediatamente
//   9. Back-to-back instructions (ADD -> SUB)
//------------------------------------------------------------------------------
`timescale 1ns/1ps

module tb_control;

    logic       clk;
    logic       rst;
    logic [6:0] cmd_in;
    logic       p_error;

    logic       aluin_reg_en;
    logic       datain_reg_en;
    logic       memoryWrite;
    logic       memoryRead;
    logic       selmux2;
    logic       cpu_rdy;
    logic       aluout_reg_en;
    logic       nvalid_data;
    logic [1:0] in_select_a;
    logic [1:0] in_select_b;
    logic [3:0] opcode;

    int unsigned checks_total  = 0;
    int unsigned checks_passed = 0;
    int unsigned checks_failed = 0;

    control dut (.*);

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic check_bit(input string tag,
                             input logic expected,
                             input logic actual);
        checks_total++;
        if (actual === expected) begin
            checks_passed++;
            $display("[PASS] %-55s | esperado=%0b  obtenido=%0b  @ %0t",
                     tag, expected, actual, $time);
        end
        else begin
            checks_failed++;
            $display("[FAIL] %-55s | esperado=%0b  obtenido=%0b  @ %0t",
                     tag, expected, actual, $time);
        end
    endtask

    task automatic check_val(input string tag,
                             input logic [3:0] expected,
                             input logic [3:0] actual);
        checks_total++;
        if (actual === expected) begin
            checks_passed++;
            $display("[PASS] %-55s | esperado=0x%0h  obtenido=0x%0h  @ %0t",
                     tag, expected, actual, $time);
        end
        else begin
            checks_failed++;
            $display("[FAIL] %-55s | esperado=0x%0h  obtenido=0x%0h  @ %0t",
                     tag, expected, actual, $time);
        end
    endtask

    initial begin
        $fsdbDumpfile("control_standalone.fsdb");
        $fsdbDumpvars(0, tb_control);
    end

    task automatic do_reset();
        @(negedge clk);
        rst = 1'b1;
        @(negedge clk);
        @(negedge clk);
        rst = 1'b0;
    endtask

    function automatic logic [6:0] mk_cmd(input logic [1:0] mA,
                                          input logic [1:0] mB,
                                          input logic [2:0] op);
        return {mA, mB, op};
    endfunction

    initial begin
        $display("================================================================");
        $display("  TB standalone: control (FSM 4 estados, opcode ALU one-hot)");
        $display("================================================================");

        cmd_in  = 7'h00;
        p_error = 1'b0;
        rst     = 1'b0;

        //----------------------------------------------------------------------
        // ESC 1: Reset asincrono lleva a RST_ST
        //----------------------------------------------------------------------
        $display("\n--- ESC 1: Reset asincrono lleva a RST_ST ---");
        do_reset();
        #1;
        check_bit("RST_ST: datain_reg_en=1",         1'b1, datain_reg_en);
        check_bit("RST_ST: cpu_rdy=0",               1'b0, cpu_rdy);
        check_bit("RST_ST: aluin_reg_en=0",          1'b0, aluin_reg_en);
        check_bit("RST_ST: aluout_reg_en=0",         1'b0, aluout_reg_en);
        check_bit("RST_ST: memoryWrite=0",           1'b0, memoryWrite);
        check_bit("RST_ST: memoryRead=0",            1'b0, memoryRead);

        //----------------------------------------------------------------------
        // ESC 2: Ciclo completo ADD (RST -> FETCH -> EXEC -> STORE)
        // opcode ADD = 4'b0001 (one-hot: op[0]=1)
        //----------------------------------------------------------------------
        $display("\n--- ESC 2: Ciclo completo ADD (opcode one-hot) ---");
        cmd_in = mk_cmd(2'b01, 2'b10, 3'b000);   // ADD

        @(posedge clk); #1;   // FETCH_DECODE
        check_bit("FETCH_DECODE: aluin_reg_en=1",    1'b1, aluin_reg_en);
        check_bit("FETCH_DECODE: datain_reg_en=0",   1'b0, datain_reg_en);
        check_bit("FETCH_DECODE: cpu_rdy=0",         1'b0, cpu_rdy);
        check_val("FETCH_DECODE: in_select_a=01",    4'b0001, {2'b00, in_select_a});
        check_val("FETCH_DECODE: in_select_b=10",    4'b0010, {2'b00, in_select_b});

        @(posedge clk); #1;   // EXECUTE
        check_bit("EXECUTE: aluout_reg_en=1",        1'b1, aluout_reg_en);
        check_bit("EXECUTE: aluin_reg_en=0",         1'b0, aluin_reg_en);
        check_bit("EXECUTE ADD: memoryRead=0",       1'b0, memoryRead);
        check_bit("EXECUTE ADD: memoryWrite=0",      1'b0, memoryWrite);
        check_val("EXECUTE: opcode=0001 (ADD one-hot)", 4'b0001, opcode);

        @(posedge clk); #1;   // STORE
        check_bit("STORE: cpu_rdy=1 (pulso)",        1'b1, cpu_rdy);
        check_bit("STORE: datain_reg_en=1",          1'b1, datain_reg_en);
        check_bit("STORE ADD: memoryWrite=0",        1'b0, memoryWrite);
        check_bit("STORE: aluout_reg_en=0",          1'b0, aluout_reg_en);

        //----------------------------------------------------------------------
        // ESC 3: Ciclo LOAD (memoryRead + selmux2 en EXECUTE)
        // opcode LOAD = 4'b0000 (ALU pasiva)
        //----------------------------------------------------------------------
        $display("\n--- ESC 3: Ciclo LOAD (opcode 0000 - ALU pasiva) ---");
        do_reset();
        cmd_in = mk_cmd(2'b00, 2'b00, 3'b101);   // LOAD

        @(posedge clk); #1;   // FETCH_DECODE
        @(posedge clk); #1;   // EXECUTE
        check_bit("EXECUTE LOAD: memoryRead=1",      1'b1, memoryRead);
        check_bit("EXECUTE LOAD: selmux2=1",         1'b1, selmux2);
        check_bit("EXECUTE LOAD: memoryWrite=0",     1'b0, memoryWrite);
        check_val("EXECUTE LOAD: opcode=0001 (ADD neutro)", 4'b0001, opcode);

        @(posedge clk); #1;   // STORE
        check_bit("STORE LOAD: cpu_rdy=1",           1'b1, cpu_rdy);
        check_bit("STORE LOAD: memoryWrite=0",       1'b0, memoryWrite);

        //----------------------------------------------------------------------
        // ESC 4: Ciclo STORE (memoryWrite en STORE)
        // opcode STORE = 4'b0000 (ALU pasiva)
        //----------------------------------------------------------------------
        $display("\n--- ESC 4: Ciclo STORE (opcode 0000 - ALU pasiva) ---");
        do_reset();
        cmd_in = mk_cmd(2'b00, 2'b00, 3'b110);   // STORE

        @(posedge clk); #1;   // FETCH_DECODE
        @(posedge clk); #1;   // EXECUTE
        check_bit("EXECUTE STORE: memoryWrite=0",    1'b0, memoryWrite);
        check_bit("EXECUTE STORE: memoryRead=0",     1'b0, memoryRead);
        check_val("EXECUTE STORE: opcode=0001 (ADD neutro)", 4'b0001, opcode);
        check_bit("EXECUTE STORE: aluout_reg_en=0 (preserva dato para memoria)", 1'b0, aluout_reg_en);

        @(posedge clk); #1;   // STORE
        check_bit("STORE STORE: memoryWrite=1",      1'b1, memoryWrite);
        check_bit("STORE STORE: cpu_rdy=1",          1'b1, cpu_rdy);
        check_bit("STORE STORE: memoryRead=0",       1'b0, memoryRead);

        //----------------------------------------------------------------------
        // ESC 5: NOP0 y NOP1 no acceden memoria, opcode=0000
        //----------------------------------------------------------------------
        $display("\n--- ESC 5: NOP no accede memoria (opcode 0000) ---");
        do_reset();
        cmd_in = mk_cmd(2'b00, 2'b00, 3'b100);   // NOP0

        @(posedge clk); #1;   // FETCH_DECODE
        @(posedge clk); #1;   // EXECUTE
        check_bit("EXECUTE NOP0: memoryRead=0",      1'b0, memoryRead);
        check_bit("EXECUTE NOP0: memoryWrite=0",     1'b0, memoryWrite);
        check_val("EXECUTE NOP0: opcode=0001 (ADD neutro)", 4'b0001, opcode);
		check_bit("EXECUTE NOP0: aluout_reg_en=0 (mantiene estado)", 1'b0, aluout_reg_en);
		
        @(posedge clk); #1;   // STORE
        check_bit("STORE NOP0: memoryWrite=0",       1'b0, memoryWrite);
        check_bit("STORE NOP0: cpu_rdy=1",           1'b1, cpu_rdy);

        do_reset();
        cmd_in = mk_cmd(2'b00, 2'b00, 3'b111);   // NOP1

        @(posedge clk); #1;   // FETCH_DECODE
        @(posedge clk); #1;   // EXECUTE
        check_bit("EXECUTE NOP1: memoryRead=0",      1'b0, memoryRead);
        check_val("EXECUTE NOP1: opcode=0001 (ADD neutro)", 4'b0001, opcode);
		check_bit("EXECUTE NOP1: aluout_reg_en=0 (mantiene estado)", 1'b0, aluout_reg_en);
        @(posedge clk); #1;   // STORE
        check_bit("STORE NOP1: memoryWrite=0",       1'b0, memoryWrite);

        //----------------------------------------------------------------------
        // ESC 6: cpu_rdy solo en STORE (pulso de 1 ciclo)
        //----------------------------------------------------------------------
        $display("\n--- ESC 6: cpu_rdy es pulso de 1 ciclo ---");
        do_reset();
        cmd_in = mk_cmd(2'b00, 2'b00, 3'b000);   // ADD

        #1;
        check_bit("RST_ST: cpu_rdy=0",               1'b0, cpu_rdy);

        @(posedge clk); #1;   // FETCH_DECODE
        check_bit("FETCH_DECODE: cpu_rdy=0",         1'b0, cpu_rdy);

        @(posedge clk); #1;   // EXECUTE
        check_bit("EXECUTE: cpu_rdy=0",              1'b0, cpu_rdy);

        @(posedge clk); #1;   // STORE
        check_bit("STORE: cpu_rdy=1 (pulso ON)",     1'b1, cpu_rdy);

        @(posedge clk); #1;   // Next FETCH_DECODE
        check_bit("Next FETCH_DECODE: cpu_rdy=0",    1'b0, cpu_rdy);

        //----------------------------------------------------------------------
        // ESC 7: nvalid_data = p_error && feedback (muxA=11 o muxB=11)
        //----------------------------------------------------------------------
        $display("\n--- ESC 7: nvalid_data con p_error + feedback ---");
        do_reset();

        cmd_in  = mk_cmd(2'b11, 2'b00, 3'b000);
        p_error = 1'b1;

        @(posedge clk); #1;   // FETCH_DECODE
        @(posedge clk); #1;   // EXECUTE
        check_bit("p_error=1 + muxA=11: nvalid_data=1", 1'b1, nvalid_data);

        do_reset();
        cmd_in  = mk_cmd(2'b00, 2'b11, 3'b000);
        p_error = 1'b1;
        @(posedge clk); #1;   // FETCH_DECODE
        @(posedge clk); #1;   // EXECUTE
        check_bit("p_error=1 + muxB=11: nvalid_data=1", 1'b1, nvalid_data);

        do_reset();
        cmd_in  = mk_cmd(2'b01, 2'b10, 3'b000);
        p_error = 1'b1;
        @(posedge clk); #1;   // FETCH_DECODE
        @(posedge clk); #1;   // EXECUTE
        check_bit("p_error=1 sin feedback: nvalid_data=0", 1'b0, nvalid_data);

        do_reset();
        cmd_in  = mk_cmd(2'b11, 2'b11, 3'b000);
        p_error = 1'b0;
        @(posedge clk); #1;   // FETCH_DECODE
        @(posedge clk); #1;   // EXECUTE
        check_bit("p_error=0 con feedback: nvalid_data=0", 1'b0, nvalid_data);

        p_error = 1'b0;

        //----------------------------------------------------------------------
        // ESC 8: Reset mid-instruccion
        //----------------------------------------------------------------------
        $display("\n--- ESC 8: Reset mid-instruccion ---");
        do_reset();
        cmd_in = mk_cmd(2'b00, 2'b00, 3'b000);   // ADD

        @(posedge clk); #1;   // FETCH_DECODE
        @(posedge clk); #1;   // EXECUTE
        rst = 1'b1;
        #2;
        check_bit("Reset mid-EXECUTE: aluin_reg_en=0", 1'b0, aluin_reg_en);
        check_bit("Reset mid-EXECUTE: aluout_reg_en=0", 1'b0, aluout_reg_en);
        check_bit("Reset mid-EXECUTE: datain_reg_en=1 (RST_ST)", 1'b1, datain_reg_en);
        check_bit("Reset mid-EXECUTE: cpu_rdy=0",     1'b0, cpu_rdy);
        rst = 1'b0;

        //----------------------------------------------------------------------
        // ESC 9: Back-to-back instructions (ADD -> SUB)
        // Verifica que el opcode cambia entre instrucciones (0001 -> 0010)
        //----------------------------------------------------------------------
        $display("\n--- ESC 9: Back-to-back instructions (ADD -> SUB) ---");
        do_reset();
        cmd_in = mk_cmd(2'b00, 2'b00, 3'b000);   // ADD 1

        @(posedge clk); #1;   // FETCH_DECODE
        @(posedge clk); #1;   // EXECUTE
        check_val("Instr 1 EXECUTE: opcode=0001 (ADD)", 4'b0001, opcode);
        @(posedge clk); #1;   // STORE (cpu_rdy=1)
        check_bit("Instr 1 STORE: cpu_rdy=1",        1'b1, cpu_rdy);

        cmd_in = mk_cmd(2'b01, 2'b01, 3'b001);   // SUB

        @(posedge clk); #1;   // FETCH_DECODE (instr 2)
        check_bit("Instr 2 FETCH: aluin_reg_en=1",   1'b1, aluin_reg_en);
        check_bit("Instr 2 FETCH: cpu_rdy=0",        1'b0, cpu_rdy);

        @(posedge clk); #1;   // EXECUTE (instr 2)
        check_val("Instr 2 EXECUTE: opcode=0010 (SUB)", 4'b0010, opcode);
        check_bit("Instr 2 EXECUTE: aluout_reg_en=1", 1'b1, aluout_reg_en);

        @(posedge clk); #1;   // STORE (instr 2)
        check_bit("Instr 2 STORE: cpu_rdy=1",        1'b1, cpu_rdy);

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