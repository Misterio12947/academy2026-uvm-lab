//------------------------------------------------------------------------------
// control_coverage_seq.sv
// Closure exhaustivo: todos los opcodes, todos los muxes, p_error con y sin
// feedback, para cerrar los 5 covergroups.
//------------------------------------------------------------------------------
class control_coverage_seq extends uvm_sequence#(control_transaction);

    `uvm_object_utils(control_coverage_seq)

    function new(string name = "control_coverage_seq");
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
            `uvm_error("SEQ", "randomize() fallo en coverage")
        finish_item(req);
    endtask

    task body();
        // Fase 1: cada opcode ISA por los 4 estados (cierra cx_state_isa,
        // cp_isa_op, cp_alu_opcode, cg_alu_opcode_map, cg_reg_enables)
        for (int op = 0; op < 8; op++) begin
            repeat (8) send(2'b00, 2'b01, op[2:0], 1'b0);
        end

        // Fase 2: cada muxA y muxB en todos sus valores (cierra cp_muxA/cp_muxB)
        for (int a = 0; a < 4; a++)
            for (int b = 0; b < 4; b++)
                repeat (4) send(a[1:0], b[1:0], 3'b000, 1'b0);

        // Fase 3: p_error x feedback (cierra cg_error_propagation)
        // p_error=1 con cada combinacion de feedback
        repeat (4) send(2'b11, 2'b00, 3'b000, 1'b1);  // muxA feedback
        repeat (4) send(2'b00, 2'b11, 3'b000, 1'b1);  // muxB feedback
        repeat (4) send(2'b11, 2'b11, 3'b000, 1'b1);  // ambos
        repeat (4) send(2'b01, 2'b10, 3'b000, 1'b1);  // p_error sin feedback
        // p_error=0 con feedback (nvalid debe ser 0)
        repeat (4) send(2'b11, 2'b11, 3'b000, 1'b0);
        repeat (4) send(2'b11, 2'b00, 3'b000, 1'b0);
        repeat (4) send(2'b00, 2'b11, 3'b000, 1'b0);
        // p_error=0 sin feedback
        repeat (4) send(2'b00, 2'b00, 3'b000, 1'b0);

        // Fase 4: STORE y NOP con p_error/feedback para cerrar cg_reg_enables
        // en todas las combinaciones
        repeat (4) send(2'b00, 2'b00, 3'b110, 1'b0);  // STORE
        repeat (4) send(2'b00, 2'b00, 3'b100, 1'b0);  // NOP0
        repeat (4) send(2'b00, 2'b00, 3'b111, 1'b0);  // NOP1
        repeat (4) send(2'b00, 2'b00, 3'b101, 1'b0);  // LOAD
    endtask

endclass
