//------------------------------------------------------------------------------
// alu_directed_seq.sv
// Directed cases: cada operacion con valores extremos, div-by-zero,
// invalid_data en cada op. Encoding one-hot, 4 operaciones (sin NOP).
//------------------------------------------------------------------------------
class alu_directed_seq extends uvm_sequence#(alu_transaction);

    `uvm_object_utils(alu_directed_seq)

    localparam logic [3:0] OP_ADD = 4'b0001;
    localparam logic [3:0] OP_SUB = 4'b0010;
    localparam logic [3:0] OP_MUL = 4'b0100;
    localparam logic [3:0] OP_DIV = 4'b1000;

    function new(string name = "alu_directed_seq");
        super.new(name);
    endfunction

    task send(bit [WIDTH-1:0] i1, i2,
              bit [3:0]       op_val,
              bit             inv);
        alu_transaction req = alu_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {
            in1          == i1;
            in2          == i2;
            op           == op_val;
            invalid_data == inv;
        })
            `uvm_error("SEQ", "randomize() fallo en directed")
        finish_item(req);
    endtask

    task body();
        // === ADD: valores canonicos y bordes ===
        send(8'h05, 8'h03, OP_ADD, 1'b0);   // 5+3=8
        send(8'h00, 8'h00, OP_ADD, 1'b0);   // 0+0=0 (zero=1)
        send(8'hFF, 8'h01, OP_ADD, 1'b0);   // 255+1=256 (verifica 2*WIDTH)
        send(8'hFF, 8'hFF, OP_ADD, 1'b0);   // 255+255=510

        // === SUB ===
        send(8'h10, 8'h01, OP_SUB, 1'b0);   // 16-1=15
        send(8'h05, 8'h05, OP_SUB, 1'b0);   // 5-5=0 (zero=1)
        send(8'h00, 8'h01, OP_SUB, 1'b0);   // 0-1 (underflow)

        // === MUL: bordes de 2*WIDTH ===
        send(8'h10, 8'h10, OP_MUL, 1'b0);   // 16*16=256
        send(8'hFF, 8'hFF, OP_MUL, 1'b0);   // 255*255=65025
        send(8'h00, 8'hFF, OP_MUL, 1'b0);   // 0*x=0 (zero=1)
        send(8'h01, 8'hFF, OP_MUL, 1'b0);   // 1*255=255

        // === DIV: normales y por cero ===
        send(8'h20, 8'h04, OP_DIV, 1'b0);   // 32/4=8
        send(8'hFF, 8'h01, OP_DIV, 1'b0);   // 255/1=255
        send(8'h00, 8'h01, OP_DIV, 1'b0);   // 0/1=0 (zero=1)
        send(8'hAA, 8'h00, OP_DIV, 1'b0);   // div por cero -> error, out=-1
        send(8'hFF, 8'h00, OP_DIV, 1'b0);   // div por cero

        // === invalid_data=1 en cada operacion: fuerza error/-1 ===
        send(8'h05, 8'h03, OP_ADD, 1'b1);   // ADD con invalid
        send(8'h10, 8'h01, OP_SUB, 1'b1);   // SUB con invalid
        send(8'h10, 8'h10, OP_MUL, 1'b1);   // MUL con invalid
        send(8'h20, 8'h04, OP_DIV, 1'b1);   // DIV con invalid
    endtask

endclass