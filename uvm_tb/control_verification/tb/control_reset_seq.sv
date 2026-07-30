//------------------------------------------------------------------------------
// control_reset_seq.sv
// Resets mid-instruccion en cada punto de la FSM. Verifica que el control
// vuelve a RST_ST y que el monitor se re-sincroniza.
//------------------------------------------------------------------------------
class control_reset_seq extends uvm_sequence#(control_transaction);

    `uvm_object_utils(control_reset_seq)

    function new(string name = "control_reset_seq");
        super.new(name);
    endfunction

    task send(bit [1:0] mA, bit [1:0] mB, bit [2:0] op);
        control_transaction req = control_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {
            muxA         == mA;
            muxB         == mB;
            isa_op       == op;
            p_error      == 1'b0;
            assert_reset == 1'b0;
        })
            `uvm_error("SEQ", "randomize() fallo")
        finish_item(req);
    endtask

    task send_reset();
        control_transaction req = control_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with { assert_reset == 1'b1; })
            `uvm_error("SEQ", "randomize() fallo en reset")
        finish_item(req);
    endtask

    task body();
        // Reset tras 1 ciclo (en FETCH_DECODE)
        send(2'b00, 2'b01, 3'b000);
        send_reset();

        // Reset tras 2 ciclos (en EXECUTE)
        send(2'b00, 2'b01, 3'b001);
        send(2'b00, 2'b01, 3'b001);
        send_reset();

        // Reset tras 3 ciclos (en STORE)
        send(2'b00, 2'b01, 3'b010);
        send(2'b00, 2'b01, 3'b010);
        send(2'b00, 2'b01, 3'b010);
        send_reset();

        // Instruccion completa despues del reset (verifica re-sincronizacion)
        repeat (4) send(2'b01, 2'b10, 3'b011);

        // Resets consecutivos
        send_reset();
        send_reset();

        // Reset y arranque limpio
        repeat (4) send(2'b00, 2'b00, 3'b101);  // LOAD completo
    endtask

endclass
