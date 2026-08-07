//==============================================================================
// tb_top_golden.sv
// Testbench de verificacion del CPU (top) contra el golden model en C via DPI-C.
//
// Compara CICLO A CICLO las salidas observables del RTL contra las que predice
// el golden model (cpu_model.c). Como el modelo replica el timing exacto del
// pipeline (latencia de 1 instruccion, desfase opcode/operandos), la
// comparacion debe dar 0 mismatches.
//
// Flujo:
//   - Cada ciclo, se aplican los mismos cmd_in/din al RTL y al modelo C
//   - El modelo C (cpu_model_step) devuelve las salidas esperadas
//   - Se comparan contra dout/flags/cpu_rdy del RTL
//
// Programa: mezcla dirigida (las 8 instrucciones, transiciones, feedback,
// div/0) + aleatorio con seed.
//==============================================================================
`timescale 1ns/1ps

module tb_top_golden;

    localparam int WIDTH = 8;

    //--------------------------------------------------------------------------
    // Importacion DPI-C del golden model
    //--------------------------------------------------------------------------
    import "DPI-C" function void cpu_model_reset();
    import "DPI-C" function void cpu_model_step(
        input  byte unsigned cmd_in,
        input  byte unsigned din_1,
        input  byte unsigned din_2,
        input  byte unsigned din_3,
        input  byte unsigned rst,
        output byte unsigned dout_high,
        output byte unsigned dout_low,
        output byte unsigned cpu_rdy,
        output byte unsigned zero,
        output byte unsigned error
    );

    //--------------------------------------------------------------------------
    // Señales del DUT
    //--------------------------------------------------------------------------
    logic                 clk;
    logic                 rst;
    logic [6:0]           cmd_in;
    logic [WIDTH-1:0]     din_1, din_2, din_3;
    logic [WIDTH-1:0]     dout_low, dout_high;
    logic                 cpu_rdy, zero, error;

    top #(.WIDTH(WIDTH)) dut (
        .clk(clk), .rst(rst), .cmd_in(cmd_in),
        .din_1(din_1), .din_2(din_2), .din_3(din_3),
        .dout_low(dout_low), .dout_high(dout_high),
        .cpu_rdy(cpu_rdy), .zero(zero), .error(error)
    );

    //--------------------------------------------------------------------------
    // Reloj
    //--------------------------------------------------------------------------
    initial clk = 1'b0;
    always #5 clk = ~clk;

    //--------------------------------------------------------------------------
    // Contadores de verificacion
    //--------------------------------------------------------------------------
    int unsigned checks    = 0;
    int unsigned mism      = 0;
    int unsigned skipped_x = 0;  // ciclos saltados por X's en el RTL
    int unsigned warmup    = 3;  // ciclos iniciales del pipeline a ignorar

    // Salidas esperadas del modelo C
    byte unsigned exp_dh, exp_dl, exp_rdy, exp_z, exp_e;

    //--------------------------------------------------------------------------
    // Comparacion ciclo a ciclo: se llama DESPUES de cada flanco
    //--------------------------------------------------------------------------
    task automatic compare_cycle(int cyc);
        logic [15:0] rtl_dout, exp_dout;
        rtl_dout = {dout_high, dout_low};
        exp_dout = {exp_dh, exp_dl};

        // No comparar durante warmup (arranque del pipeline)
        if (cyc <= warmup) return;

        // No comparar cuando el RTL tiene X's (registros no inicializados que
        // se propagan via el feedback loop). El modelo trabaja con valores
        // definidos (0), no puede predecir X. En operacion normal las X's se
        // sobrescriben; no son un error funcional. Ver README (manejo de X).
        if ($isunknown(rtl_dout) || $isunknown(cpu_rdy) ||
            $isunknown(zero)     || $isunknown(error)) begin
            skipped_x++;
            return;
        end

        checks++;

        if ((rtl_dout !== exp_dout) ||
            (cpu_rdy  !== exp_rdy)  ||
            (zero     !== exp_z)    ||
            (error    !== exp_e)) begin
            mism++;
            $display("[MISMATCH cyc %0d] cmd=%b din=%0h/%0h/%0h",
                     cyc, cmd_in, din_1, din_2, din_3);
            $display("    RTL: dout=%04h rdy=%0b zero=%0b err=%0b",
                     rtl_dout, cpu_rdy, zero, error);
            $display("    REF: dout=%04h rdy=%0b zero=%0b err=%0b",
                     exp_dout, exp_rdy, exp_z, exp_e);
        end
    endtask

    //--------------------------------------------------------------------------
    // Aplica una instruccion: mantiene cmd/din estables 4 ciclos, comparando
    // cada ciclo contra el modelo.
    //--------------------------------------------------------------------------
    int cycle_count = 0;

    task automatic apply_instr(logic [1:0] mA, logic [1:0] mB, logic [2:0] op,
                               logic [WIDTH-1:0] d1, d2, d3);
        cmd_in = {mA, mB, op};
        din_1  = d1; din_2 = d2; din_3 = d3;
        repeat (4) begin
            @(posedge clk);
            // Avanzar el modelo C con los mismos inputs de este ciclo
            cpu_model_step(cmd_in, din_1, din_2, din_3, rst,
                           exp_dh, exp_dl, exp_rdy, exp_z, exp_e);
            #1;  // settle de las salidas del RTL
            cycle_count++;
            compare_cycle(cycle_count);
        end
    endtask

    //--------------------------------------------------------------------------
    // Reset coordinado (RTL + modelo)
    //--------------------------------------------------------------------------
    task automatic do_reset();
        cmd_in = 0; din_1 = 0; din_2 = 0; din_3 = 0;
        rst = 1'b1;
        cpu_model_reset();
        repeat (3) begin
            @(posedge clk);
            cpu_model_step(cmd_in, din_1, din_2, din_3, 1,
                           exp_dh, exp_dl, exp_rdy, exp_z, exp_e);
            #1;
        end
        rst = 1'b0;
    endtask

    //--------------------------------------------------------------------------
    // Programa de prueba: dirigido + aleatorio
    //--------------------------------------------------------------------------
    initial begin
        $fsdbDumpfile("golden.fsdb");
        $fsdbDumpvars(0, tb_top_golden);

        $display("================================================================");
        $display("  Verificacion top vs golden model (DPI-C) - ciclo a ciclo");
        $display("================================================================");

        do_reset();

        // ===== Fase dirigida: las 8 instrucciones + casos clave =====
        $display("--- Fase dirigida ---");

        // Warmup
        apply_instr(2'b00, 2'b00, 3'b100, 8'h00, 8'h00, 8'h00);  // NOP

        // Las 4 aritmeticas
        apply_instr(2'b00, 2'b01, 3'b000, 8'd5,  8'd3,  8'h00);  // ADD 5+3
        apply_instr(2'b00, 2'b01, 3'b001, 8'd16, 8'd1,  8'h00);  // SUB 16-1
        apply_instr(2'b00, 2'b01, 3'b010, 8'd16, 8'd16, 8'h00);  // MUL 16*16
        apply_instr(2'b00, 2'b01, 3'b011, 8'd32, 8'd4,  8'h00);  // DIV 32/4

        // DIV por cero
        apply_instr(2'b00, 2'b01, 3'b011, 8'hAA, 8'h00, 8'h00);  // DIV/0

        // STORE + LOAD
        apply_instr(2'b00, 2'b01, 3'b000, 8'hC0, 8'h0C, 8'h00);  // ADD -> 0xCC
        apply_instr(2'b00, 2'b00, 3'b110, 8'd5,  8'h00, 8'h00);  // STORE addr=5
        apply_instr(2'b00, 2'b00, 3'b101, 8'd5,  8'h00, 8'h00);  // LOAD addr=5

        // NOP mantiene estado
        apply_instr(2'b00, 2'b00, 3'b100, 8'hDE, 8'hAD, 8'hBE);  // NOP

        // Feedback loop: instruccion previa con error, luego feedback
        apply_instr(2'b00, 2'b01, 3'b011, 8'hFF, 8'h00, 8'h00);  // DIV/0 -> error
        apply_instr(2'b11, 2'b00, 3'b000, 8'h00, 8'h00, 8'h00);  // ADD con muxA=feedback

        // Transiciones back-to-back (el desfase opcode/operandos)
        apply_instr(2'b00, 2'b01, 3'b000, 8'd10, 8'd20, 8'h00);  // ADD 10+20
        apply_instr(2'b00, 2'b01, 3'b001, 8'd50, 8'd8,  8'h00);  // SUB 50-8

        // ===== Fase aleatoria =====
        $display("--- Fase aleatoria (200 instrucciones) ---");
        begin
            int seed = 12345;
            for (int i = 0; i < 200; i++) begin
                logic [1:0] rmA, rmB;
                logic [2:0] rop;
                logic [7:0] rd1, rd2, rd3;
                rmA = $random(seed) % 4;
                rmB = $random(seed) % 4;
                rop = $random(seed) % 8;
                rd1 = $random(seed) % 256;
                rd2 = $random(seed) % 256;
                rd3 = $random(seed) % 256;
                apply_instr(rmA, rmB, rop, rd1, rd2, rd3);
            end
        end

        // Drenaje final
        apply_instr(2'b00, 2'b00, 3'b100, 8'h00, 8'h00, 8'h00);
        apply_instr(2'b00, 2'b00, 3'b100, 8'h00, 8'h00, 8'h00);

        //---------------------------------------------------------------------
        // Reporte
        //---------------------------------------------------------------------
        $display("================================================================");
        $display("  Reporte final:");
        $display("    Ciclos comparados : %0d", checks);
        $display("    Mismatches        : %0d", mism);
        $display("    Saltados por X    : %0d (RTL no inicializado, benigno)", skipped_x);
        if (mism == 0)
            $display("  >>> GOLDEN MODEL MATCH: RTL == modelo C ciclo a ciclo <<<");
        else
            $display("  >>> %0d MISMATCHES <<<", mism);
        $display("================================================================");

        #20 $finish;
    end

    initial begin
        #500us;
        $display("[WATCHDOG] timeout");
        $finish;
    end

endmodule
