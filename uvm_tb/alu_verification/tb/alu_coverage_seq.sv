//------------------------------------------------------------------------------
// alu_coverage_seq.sv
// Sequence orientada a cerrar coverage funcional con encoding one-hot.
// Recorre exhaustivamente cada operacion (NOP, ADD, SUB, MUL, DIV) con
// invalid_data en {0,1} y valores especificos para forzar bins de rangos,
// zero_out, y div-by-zero.
//------------------------------------------------------------------------------
class alu_coverage_seq extends uvm_sequence#(alu_transaction);

    `uvm_object_utils(alu_coverage_seq)

    // Encoding one-hot (helpers)
    localparam logic [3:0] OP_NOP = 4'b0000;
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

        // Fase 1: cada opcode con invalid_data=0 y =1 (cierra cp_op, cp_invalid,
        // cx_op_invalid con todos los 5 bins)
        bit [3:0] ops [5] = '{OP_NOP, OP_ADD, OP_SUB, OP_MUL, OP_DIV};
        foreach (ops[i]) begin
            repeat (reps) send_constrained(ops[i], 1'b0);
            repeat (reps) send_constrained(ops[i], 1'b1);
        end

        // Fase 2: DIV con in2==0 para todas las combinaciones de in1
        // Cierra bin div_in2_zero de cx_op_in2_zero
        for (int i = 0; i < 8; i++)
            send_directed(i * 8'h11, 8'h00, OP_DIV, 1'b0);

        // Fase 3: ADD, SUB, MUL con in2==0 para cerrar sus bins en cx_op_in2_zero
        send_directed(8'h55, 8'h00, OP_ADD, 1'b0);
        send_directed(8'hAA, 8'h00, OP_ADD, 1'b0);
        send_directed(8'h55, 8'h00, OP_SUB, 1'b0);
        send_directed(8'hAA, 8'h00, OP_SUB, 1'b0);
        send_directed(8'h55, 8'h00, OP_MUL, 1'b0);
        send_directed(8'hAA, 8'h00, OP_MUL, 1'b0);

        // Fase 4: NOP con in2==0 (bin nop_in2_zero, aunque NOP ignora entradas)
        send_directed(8'h55, 8'h00, OP_NOP, 1'b0);

        // Fase 5: DIV normal para poblar bins de cp_out (rangos)
        for (int i = 0; i < 8; i++)
            send_directed(8'h80, i + 1, OP_DIV, 1'b0);

        // Fase 6: casos con salida cero (zero=1) para cerrar cp_zero.high
        // Requiere out==0 sin invalid_data
        send_directed(8'h00, 8'h00, OP_ADD, 1'b0);  // 0+0=0 -> zero=1
        send_directed(8'h05, 8'h05, OP_SUB, 1'b0);  // 5-5=0 -> zero=1
        send_directed(8'h00, 8'hFF, OP_MUL, 1'b0);  // 0*FF=0 -> zero=1
        send_directed(8'h00, 8'h01, OP_DIV, 1'b0);  // 0/1=0 -> zero=1
        // NOP siempre da out=0 zero=1
        send_directed(8'hAA, 8'hBB, OP_NOP, 1'b0);

        // Fase 7: casos que cierran cp_in1 y cp_in2 en todos los rangos
        // Combinaciones extremas
        send_directed(8'h00, 8'h00, OP_ADD, 1'b0);  // in1=zero, in2=zero
        send_directed(8'hFF, 8'hFF, OP_ADD, 1'b0);  // in1=max,  in2=max
        send_directed(8'h01, 8'hFE, OP_MUL, 1'b0);  // in1=low,  in2=high
        send_directed(8'hE0, 8'h1F, OP_MUL, 1'b0);  // in1=high, in2=low
        send_directed(8'h50, 8'h50, OP_MUL, 1'b0);  // in1=mid,  in2=mid

        // Fase 8: cp_out.high y cp_out.mid (rangos altos de salida)
        // MUL con valores medios/altos genera salidas en rangos altos de 16-bit
        send_directed(8'h80, 8'h80, OP_MUL, 1'b0);  // 128*128=16384 (0x4000, mid)
        send_directed(8'hFE, 8'hFE, OP_MUL, 1'b0);  // 254*254=64516 (0xFC04, high)
        send_directed(8'hC0, 8'hC0, OP_MUL, 1'b0);  // 192*192=36864 (0x9000, mid)

        // Fase 9: cp_out.minus_one (salida -1 solo por error)
        // Se cubre en Fase 1 (invalid_data=1) y Fase 2 (div by zero) - refuerzo:
        send_directed(8'hFF, 8'h00, OP_DIV, 1'b0);  // div/0 -> out=FFFF
        send_directed(8'h55, 8'h33, OP_ADD, 1'b1);  // invalid -> out=FFFF
    endtask

endclass