//------------------------------------------------------------------------------
// alu_coverage_seq.sv
// Sequence orientada a cerrar coverage funcional. Recorre exhaustivamente
// cada opcode de la ISA con multiples combinaciones de operandos e
// invalid_data para maximizar hits en los covergroups.
//------------------------------------------------------------------------------
class alu_coverage_seq extends uvm_sequence#(alu_transaction);

    `uvm_object_utils(alu_coverage_seq)

    function new(string name = "alu_coverage_seq");
        super.new(name);
    endfunction

    task send_constrained(bit [2:0] opc, bit inv);
        alu_transaction req = alu_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {
            op[2:0]      == opc;
            op[3]        == 1'b0;
            invalid_data == inv;
        })
            `uvm_error("SEQ", "randomize() fallo en coverage_seq")
        finish_item(req);
    endtask

    task send_directed(bit [WIDTH-1:0] a, bit [WIDTH-1:0] b,
                       bit [2:0] opc, bit inv);
        alu_transaction req = alu_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {
            in1          == a;
            in2          == b;
            op[2:0]      == opc;
            op[3]        == 1'b0;
            invalid_data == inv;
        })
            `uvm_error("SEQ", "randomize() fallo en coverage_seq directed")
        finish_item(req);
    endtask

    task body();
        int unsigned reps = 40;

        // Loop principal: cada opcode con invalid_data=0 y =1
        // Cubre cp_op, cp_invalid y cx_op_invalid
        for (int opc = 0; opc < 8; opc++) begin
            repeat (reps) send_constrained(opc[2:0], 1'b0);
            repeat (reps) send_constrained(opc[2:0], 1'b1);
        end

        // Casos borde forzados para cerrar cg_edge_cases

        // DIV con in2 == 0 (varias veces con distintos in1)
        for (int i = 0; i < 8; i++)
            send_directed(i * 8'h11, 8'h00, 3'b011, 1'b0);

        // DIV normal (verifica bin div_normal)
        for (int i = 0; i < 8; i++)
            send_directed(8'h80, i + 1, 3'b011, 1'b0);

        // Casos con in1 e in2 en los extremos para cerrar cp_in1 y cp_in2
        send_directed(8'h00, 8'h00, 3'b000, 1'b0);  // zero,   zero
        send_directed(8'hFF, 8'hFF, 3'b000, 1'b0);  // max,    max
        send_directed(8'h01, 8'hFE, 3'b010, 1'b0);  // low,    high
        send_directed(8'hE0, 8'h1F, 3'b010, 1'b0);  // high,   low
        send_directed(8'h50, 8'h50, 3'b010, 1'b0);  // mid,    mid
    endtask

endclass
