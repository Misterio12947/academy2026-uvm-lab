//------------------------------------------------------------------------------
// control_directed_seq.sv
// Cada opcode ISA ejercitado end-to-end + p_error con feedback.
//------------------------------------------------------------------------------
class control_directed_seq extends uvm_sequence#(control_transaction);

    `uvm_object_utils(control_directed_seq)

    function new(string name = "control_directed_seq");
        super.new(name);
    endfunction

    task send(bit [1:0] mA, bit [1:0] mB, bit [2:0] op, bit perr);
        control_transaction req = control_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {
            muxA         == mA;
            muxB         == mB;
            isa_op       == op;
            p_error      == perr;
            assert_reset == 1'b0;
        })
            `uvm_error("SEQ", "randomize() fallo en directed")
        finish_item(req);
    endtask

    task body();
        // Cada opcode ISA una instruccion completa (4 ciclos c/u)
        // ADD, SUB, MUL, DIV
        repeat (4) send(2'b00, 2'b01, 3'b000, 1'b0);  // ADD
        repeat (4) send(2'b00, 2'b01, 3'b001, 1'b0);  // SUB
        repeat (4) send(2'b00, 2'b01, 3'b010, 1'b0);  // MUL
        repeat (4) send(2'b00, 2'b01, 3'b011, 1'b0);  // DIV

        // NOP0, LOAD, STORE, NOP1
        repeat (4) send(2'b00, 2'b00, 3'b100, 1'b0);  // NOP0
        repeat (4) send(2'b00, 2'b00, 3'b101, 1'b0);  // LOAD
        repeat (4) send(2'b00, 2'b00, 3'b110, 1'b0);  // STORE
        repeat (4) send(2'b00, 2'b00, 3'b111, 1'b0);  // NOP1

        // p_error con feedback muxA=11
        repeat (4) send(2'b11, 2'b00, 3'b000, 1'b1);  // ADD con muxA feedback + error
        // p_error con feedback muxB=11
        repeat (4) send(2'b00, 2'b11, 3'b000, 1'b1);  // ADD con muxB feedback + error
        // p_error con ambos feedback
        repeat (4) send(2'b11, 2'b11, 3'b000, 1'b1);
        // p_error sin feedback (nvalid debe seguir 0)
        repeat (4) send(2'b01, 2'b10, 3'b000, 1'b1);
        // feedback sin p_error (nvalid debe seguir 0)
        repeat (4) send(2'b11, 2'b11, 3'b000, 1'b0);
    endtask

endclass
