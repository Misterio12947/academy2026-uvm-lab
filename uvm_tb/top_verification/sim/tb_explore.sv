//------------------------------------------------------------------------------
// tb_explore.sv
// TB de EXPLORACION (temporal, no es parte del env final).
// Dispara 4 instrucciones conocidas y vuelca cada ciclo para entender el
// timing del pipeline: cuando cpu_rdy pulsa, que cmd_in y que dout se ven.
//
// Programa:
//   Instr 1: ADD  con din_1=5, din_2=3, muxA=0(din_1), muxB=1(din_2) -> 5+3=8
//   Instr 2: STORE addr=din_1=5, escribe dout previo (0x0008) a mem[5]
//   Instr 3: LOAD  addr=din_1=5, lee mem[5] -> deberia dar 0x0008
//   Instr 4: NOP   mantiene estado (dout previo)
//------------------------------------------------------------------------------
`timescale 1ns/1ps

module tb_explore;

    localparam int WIDTH = 8;

    logic                 clk;
    logic                 rst;
    logic [6:0]           cmd_in;
    logic [WIDTH-1:0]     din_1, din_2, din_3;
    logic [WIDTH-1:0]     dout_low, dout_high;
    logic                 cpu_rdy, zero, error;

    top #(.WIDTH(WIDTH)) dut (
        .clk       (clk),
        .rst       (rst),
        .cmd_in    (cmd_in),
        .din_1     (din_1),
        .din_2     (din_2),
        .din_3     (din_3),
        .dout_low  (dout_low),
        .dout_high (dout_high),
        .cpu_rdy   (cpu_rdy),
        .zero      (zero),
        .error     (error)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Volcado de CADA ciclo: estado interno + observables
    int cycle_num = 0;
    always @(posedge clk) begin
        #1;  // settle
        cycle_num++;
        $display("[CYC %3d] rst=%b cmd_in=%b (mux %b/%b op %b) | state=%0d | dout={%02h,%02h} cpu_rdy=%b zero=%b err=%b | aluout_en=%b datain_en=%b memW=%b memR=%b",
                 cycle_num, rst, cmd_in,
                 cmd_in[6:5], cmd_in[4:3], cmd_in[2:0],
                 dut.u_control.current_state,
                 dout_high, dout_low, cpu_rdy, zero, error,
                 dut.aluout_reg_en, dut.datain_reg_en,
                 dut.memoryWrite, dut.memoryRead);
    end

    // Marca cada vez que cpu_rdy pulsa
    always @(posedge clk) begin
        #1;
        if (cpu_rdy)
            $display("        >>> CPU_RDY: cmd_in visible=%b (op=%b) dout={%02h,%02h} zero=%b err=%b",
                     cmd_in, cmd_in[2:0], dout_high, dout_low, zero, error);
    end

    function automatic logic [6:0] mk(input logic [1:0] mA, input logic [1:0] mB,
                                       input logic [2:0] op);
        return {mA, mB, op};
    endfunction

    initial begin
        // Init
        cmd_in = 7'h00; din_1 = 0; din_2 = 0; din_3 = 0; rst = 0;

        // Reset
        @(negedge clk); rst = 1'b1;
        repeat (3) @(negedge clk);
        rst = 1'b0;
        @(negedge clk);

        $display("\n===== INSTR 1: ADD din_1=5 + din_2=3 (muxA=0, muxB=1) =====");
        cmd_in = mk(2'b00, 2'b01, 3'b000);  // ADD, muxA=din_1, muxB=din_2
        din_1  = 8'd5;
        din_2  = 8'd3;
        repeat (4) @(negedge clk);

        $display("\n===== INSTR 2: STORE addr=din_1=5 (escribe dout previo) =====");
        cmd_in = mk(2'b00, 2'b00, 3'b110);  // STORE, muxA=din_1 (addr=5)
        din_1  = 8'd5;
        repeat (4) @(negedge clk);

        $display("\n===== INSTR 3: LOAD addr=din_1=5 (lee mem[5]) =====");
        cmd_in = mk(2'b00, 2'b00, 3'b101);  // LOAD, muxA=din_1 (addr=5)
        din_1  = 8'd5;
        repeat (4) @(negedge clk);

        $display("\n===== INSTR 4: NOP (mantiene estado) =====");
        cmd_in = mk(2'b00, 2'b00, 3'b100);  // NOP0
        din_1  = 8'hDE;
        din_2  = 8'hAD;
        repeat (4) @(negedge clk);

        $display("\n===== FIN =====");
        #20 $finish;
    end

    initial begin
        #5us;
        $display("[WATCHDOG]");
        $finish;
    end

endmodule
