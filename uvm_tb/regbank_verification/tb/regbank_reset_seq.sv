//------------------------------------------------------------------------------
// regbank_reset_seq.sv
// Sequence enfocada en escenarios de reset asincrono. Ejercita:
//   - Reset consecutivos (2+ resets seguidos)
//   - Reset intercalado con writes
//   - Reset justo despues de un write (verifica que rst domina)
//   - Escritura inmediata post-reset
//------------------------------------------------------------------------------
class regbank_reset_seq extends uvm_sequence#(regbank_transaction);

    `uvm_object_utils(regbank_reset_seq)

    function new(string name = "regbank_reset_seq");
        super.new(name);
    endfunction

    task send_write(bit [WIDTH-1:0] value, bit enable);
        regbank_transaction req = regbank_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {
            wr_en        == enable;
            in           == value;
            assert_reset == 1'b0;
        })
            `uvm_error("SEQ", "randomize() fallo")
        finish_item(req);
    endtask

    task send_reset();
        regbank_transaction req = regbank_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with { assert_reset == 1'b1; })
            `uvm_error("SEQ", "randomize() fallo en reset")
        finish_item(req);
    endtask

    task body();
        // Escenario A: reset simple + write + reset + write
        send_write(8'hAB, 1'b1);
        send_reset();
        send_write(8'hCD, 1'b1);
        send_reset();
        send_write(8'hEF, 1'b1);

        // Escenario B: dos resets consecutivos
        send_reset();
        send_reset();

        // Escenario C: write, hold, reset (verifica que reset no depende del
        // estado previo del wr_en)
        send_write(8'h77, 1'b1);
        send_write(8'hFF, 1'b0);   // hold
        send_write(8'hFF, 1'b0);   // hold
        send_reset();

        // Escenario D: reset seguido de hold (verifica que post-reset se
        // mantiene en 0)
        send_reset();
        repeat (3) send_write(8'hFF, 1'b0);   // hold en 0

        // Escenario E: rafaga de writes despues de reset (verifica que el
        // registro se recupera correctamente)
        send_reset();
        send_write(8'h10, 1'b1);
        send_write(8'h20, 1'b1);
        send_write(8'h30, 1'b1);
    endtask

endclass
