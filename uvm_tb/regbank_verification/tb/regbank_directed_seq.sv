//------------------------------------------------------------------------------
// regbank_directed_seq.sv
// Sequence directed. Cubre los mismos 6 escenarios criticos del standalone TB
// mas escenarios adicionales de transiciones y valores extremos.
//------------------------------------------------------------------------------
class regbank_directed_seq extends uvm_sequence#(regbank_transaction);

    `uvm_object_utils(regbank_directed_seq)

    function new(string name = "regbank_directed_seq");
        super.new(name);
    endfunction

    // Envia una tx de escritura directed
    task send_write(bit [WIDTH-1:0] value, bit enable);
        regbank_transaction req = regbank_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {
            wr_en        == enable;
            in           == value;
            assert_reset == 1'b0;
        })
            `uvm_error("SEQ", "randomize() fallo en directed write")
        finish_item(req);
    endtask

    // Envia una tx de reset
    task send_reset();
        regbank_transaction req = regbank_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with { assert_reset == 1'b1; })
            `uvm_error("SEQ", "randomize() fallo en directed reset")
        finish_item(req);
    endtask

    task body();
        // Bloque 1: writes con valores extremos
        send_write(8'h00, 1'b1);   // escribe 0
        send_write(8'hFF, 1'b1);   // escribe max
        send_write(8'h55, 1'b1);   // patron alternado
        send_write(8'hAA, 1'b1);   // patron alternado inverso

        // Bloque 2: hold sostenido (5 ciclos con wr_en=0)
        repeat (5) send_write(8'hDE, 1'b0);   // in=ruido, no debe capturarse

        // Bloque 3: back-to-back writes con patron
        send_write(8'h11, 1'b1);
        send_write(8'h22, 1'b1);
        send_write(8'h33, 1'b1);
        send_write(8'h44, 1'b1);

        // Bloque 4: reset y verificacion post-reset
        send_reset();
        send_write(8'hBE, 1'b1);   // primera escritura despues del reset

        // Bloque 5: toggle write / hold
        send_write(8'h01, 1'b1);
        send_write(8'hFF, 1'b0);   // hold
        send_write(8'h02, 1'b1);
        send_write(8'hFF, 1'b0);   // hold
        send_write(8'h04, 1'b1);
    endtask

endclass
