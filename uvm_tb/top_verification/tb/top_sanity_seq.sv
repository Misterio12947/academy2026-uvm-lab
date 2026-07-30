//------------------------------------------------------------------------------
// top_sanity_seq.sv
// Programa conocido para validar el reference model:
//   ADD (5+3=8) -> STORE addr=5 -> LOAD addr=5 -> NOP
// Mismo programa que la corrida de exploracion. Resultados esperados
// conocidos, faciles de verificar a mano.
//------------------------------------------------------------------------------
class top_sanity_seq extends uvm_sequence#(top_transaction);

    `uvm_object_utils(top_sanity_seq)

    function new(string name = "top_sanity_seq");
        super.new(name);
    endfunction

    task send(bit [1:0] mA, bit [1:0] mB, bit [2:0] op,
              bit [WIDTH-1:0] d1, d2, d3);
        top_transaction req = top_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {
            muxA         == mA;
            muxB         == mB;
            isa_op       == op;
            din_1        == d1;
            din_2        == d2;
            din_3        == d3;
            assert_reset == 1'b0;
        })
            `uvm_error("SEQ", "randomize() fallo en sanity")
        finish_item(req);
    endtask

    task body();
        // Instruccion 0: NOP inicial (para arrancar el pipeline limpio)
        send(2'b00, 2'b00, 3'b100, 8'h00, 8'h00, 8'h00);

        // Instr 1: ADD din_1=5 + din_2=3 = 8 (muxA=din_1, muxB=din_2)
        send(2'b00, 2'b01, 3'b000, 8'd5, 8'd3, 8'h00);

        // Instr 2: STORE addr=din_1=5, escribe dout previo (0x0008) a mem[5]
        send(2'b00, 2'b00, 3'b110, 8'd5, 8'h00, 8'h00);

        // Instr 3: LOAD addr=din_1=5, lee mem[5] = 0x0008
        send(2'b00, 2'b00, 3'b101, 8'd5, 8'h00, 8'h00);

        // Instr 4: NOP mantiene estado (dout = 0x0008 del LOAD)
        send(2'b00, 2'b00, 3'b100, 8'hDE, 8'hAD, 8'hBE);

        // Instr 5-6: mas ADDs para verificar el pipeline continua
        send(2'b00, 2'b01, 3'b000, 8'd10, 8'd20, 8'h00);  // 10+20=30
        send(2'b00, 2'b01, 3'b001, 8'd50, 8'd8,  8'h00);  // SUB 50-8=42

        // Instrucciones de drenaje para observar los ultimos resultados
        send(2'b00, 2'b00, 3'b100, 8'h00, 8'h00, 8'h00);  // NOP
        send(2'b00, 2'b00, 3'b100, 8'h00, 8'h00, 8'h00);  // NOP
    endtask

endclass
