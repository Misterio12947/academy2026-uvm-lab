//------------------------------------------------------------------------------
// alu_coverage_seq.sv
// Closure de coverage con 4 operaciones one-hot (sin NOP).
//------------------------------------------------------------------------------
class alu_coverage_seq extends uvm_sequence#(alu_transaction);

    `uvm_object_utils(alu_coverage_seq)

    localparam logic [3:0] OP_ADD = 4'b0001;
    localparam logic [3:0] OP_SUB = 4'b0010;
    localparam logic [3:0] OP_MUL = 4'b0100;
    localparam logic [3:0] OP_DIV = 4'b1000;

    function new(string name = "alu_coverage_seq");
        super.new(name);
    endfunction

    task send_constrained(bit [3:0] op_val, bit inv);
        alu_transaction req = alu_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {
            op           == op_val;
            invalid_data == inv;
        })
            `uvm_error("SEQ", "randomize() fallo en coverage_seq")
        finish_item(req);
    endtask

    task send_directed(bit [WIDTH-1:0] a, bit [WIDTH-1:0] b,
                       bit [3:0] op_val, bit inv);
        alu_transaction req = alu_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {
            in1          == a;
            in2          == b;
            op           == op_val;
            invalid_data == inv;
        })
            `uvm_error("SEQ", "randomize() fallo en coverage_seq directed")
        finish_item(req);
    endtask

    task body();
        int unsigned reps = 40;
        bit [3:0] ops [4] = '{OP_ADD, OP_SUB, OP_MUL, OP_DIV};

        // Fase 1: cada opcode con invalid_data=0 y =1 (cierra cp_op,
        // cp_invalid, cx_op_invalid con los 4 bins)
        foreach (ops[i]) begin
            repeat (reps) send_constrained(ops[i], 1'b0);
            repeat (reps) send_constrained(ops[i], 1'b1);
        end

        // Fase 2: DIV con in2==0 para todas las combinaciones de in1
        for (int i = 0; i < 8; i++)
            send_directed(i * 8'h11, 8'h00, OP_DIV, 1'b0);

        // Fase 3: ADD, SUB, MUL con in2==0 (bins de cx_op_in2_zero)
        send_directed(8'h55, 8'h00, OP_ADD, 1'b0);
        send_directed(8'hAA, 8'h00, OP_ADD, 1'b0);
        send_directed(8'h55, 8'h00, OP_SUB, 1'b0);
        send_directed(8'hAA, 8'h00, OP_SUB, 1'b0);
        send_directed(8'h55, 8'h00, OP_MUL, 1'b0);
        send_directed(8'hAA, 8'h00, OP_MUL, 1'b0);

        // Fase 4: DIV normal para poblar bins de cp_out (rangos)
        for (int i = 0; i < 8; i++)
            send_directed(8'h80, i + 1, OP_DIV, 1'b0);

        // Fase 5: casos con salida cero (zero=1) para cerrar cp_zero.high
        send_directed(8'h00, 8'h00, OP_ADD, 1'b0);  // 0+0=0
        send_directed(8'h05, 8'h05, OP_SUB, 1'b0);  // 5-5=0
        send_directed(8'h00, 8'hFF, OP_MUL, 1'b0);  // 0*FF=0
        send_directed(8'h00, 8'h01, OP_DIV, 1'b0);  // 0/1=0

        // Fase 6: cierra cp_in1 y cp_in2 en todos los rangos
        send_directed(8'h00, 8'h00, OP_ADD, 1'b0);  // zero, zero
        send_directed(8'hFF, 8'hFF, OP_ADD, 1'b0);  // max,  max
        send_directed(8'h01, 8'hFE, OP_MUL, 1'b0);  // low,  high
        send_directed(8'hE0, 8'h1F, OP_MUL, 1'b0);  // high, low
        send_directed(8'h50, 8'h50, OP_MUL, 1'b0);  // mid,  mid

        // Fase 7: cp_out.high y cp_out.mid (rangos altos de salida)
        send_directed(8'h80, 8'h80, OP_MUL, 1'b0);  // 128*128=16384 (0x4000)
        send_directed(8'hFE, 8'hFE, OP_MUL, 1'b0);  // 254*254=64516 (0xFC04)
        send_directed(8'hC0, 8'hC0, OP_MUL, 1'b0);  // 192*192=36864 (0x9000)

        // Fase 8: cp_out.minus_one (salida -1 por error)
        send_directed(8'hFF, 8'h00, OP_DIV, 1'b0);  // div/0 -> FFFF
        send_directed(8'h55, 8'h33, OP_ADD, 1'b1);  // invalid -> FFFF
    endtask

endclass