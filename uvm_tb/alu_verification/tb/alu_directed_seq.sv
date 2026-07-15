//------------------------------------------------------------------------------
// alu_directed_seq.sv
// Sequence directed con casos borde derivados de la spec:
//   - Cada opcode aritmetico basico (ADD, SUB, MUL, DIV)
//   - ADD y SUB que dan zero
//   - DIV por cero -> error, out = -1
//   - invalid_data asertado -> error, out = -1
//   - NOP0, NOP1
//   - LOAD, STORE (pass-through de in2)
//------------------------------------------------------------------------------
class alu_directed_seq extends uvm_sequence#(alu_transaction);

    `uvm_object_utils(alu_directed_seq)

    function new(string name = "alu_directed_seq");
        super.new(name);
    endfunction

    task send(bit [WIDTH-1:0] a, bit [WIDTH-1:0] b, bit [2:0] opc, bit inv);
        alu_transaction req = alu_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {
            in1          == a;
            in2          == b;
            op[2:0]      == opc;
            op[3]        == 1'b0;
            invalid_data == inv;
        })
            `uvm_error("SEQ", "randomize() fallo en directed")
        finish_item(req);
    endtask

    task body();
        // Aritmeticos basicos
        send(8'h05, 8'h03, 3'b000, 1'b0); // ADD 5 + 3
        send(8'h10, 8'h01, 3'b001, 1'b0); // SUB 16 - 1
        send(8'h0F, 8'h0F, 3'b010, 1'b0); // MUL 15 * 15
        send(8'h20, 8'h04, 3'b011, 1'b0); // DIV 32 / 4

        // Casos borde de zero flag
        send(8'h00, 8'h00, 3'b000, 1'b0); // ADD que da zero
        send(8'h05, 8'h05, 3'b001, 1'b0); // SUB que da zero

        // Casos borde de error
        send(8'hAA, 8'h00, 3'b011, 1'b0); // DIV por cero -> error, out=-1
        send(8'h55, 8'hAA, 3'b011, 1'b1); // invalid_data -> error, out=-1

        // NOPs y LOAD/STORE
        send(8'hDE, 8'hAD, 3'b100, 1'b0); // NOP0
        send(8'hDE, 8'hAD, 3'b111, 1'b0); // NOP1
        send(8'h00, 8'h42, 3'b101, 1'b0); // LOAD  -> out = 8'h42
        send(8'h00, 8'h00, 3'b110, 1'b0); // STORE -> out = 0, zero=1

        // Valores maximos y minimos
        send(8'hFF, 8'hFF, 3'b000, 1'b0); // ADD overflow contenido en 2*WIDTH
        send(8'hFF, 8'hFF, 3'b010, 1'b0); // MUL max
        send(8'h00, 8'hFF, 3'b001, 1'b0); // SUB con underflow -> wrap
    endtask

endclass
