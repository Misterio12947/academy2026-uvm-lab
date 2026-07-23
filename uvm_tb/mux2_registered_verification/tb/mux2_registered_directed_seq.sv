//------------------------------------------------------------------------------
// mux2_registered_directed_seq.sv
// Casos borde: cada select capturado, hold sostenido, reset intercalado.
//------------------------------------------------------------------------------
class mux2_registered_directed_seq extends uvm_sequence#(mux2_registered_transaction);

    `uvm_object_utils(mux2_registered_directed_seq)

    function new(string name = "mux2_registered_directed_seq");
        super.new(name);
    endfunction

    task send_write(bit s, bit [2*WIDTH-1:0] d1, d2, bit enable);
        mux2_registered_transaction req = mux2_registered_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {
            sel          == s;
            in1          == d1;
            in2          == d2;
            wr_en        == enable;
            assert_reset == 1'b0;
        })
            `uvm_error("SEQ", "randomize() fallo en directed write")
        finish_item(req);
    endtask

    task send_reset();
        mux2_registered_transaction req = mux2_registered_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with { assert_reset == 1'b1; })
            `uvm_error("SEQ", "randomize() fallo en directed reset")
        finish_item(req);
    endtask

    task body();
        // Bloque 1: cada select capturado con valores distintivos
        send_write(1'b0, 16'hAAAA, 16'hBBBB, 1'b1);
        send_write(1'b1, 16'hAAAA, 16'hBBBB, 1'b1);

        // Bloque 2: hold sostenido
        repeat (5) send_write(1'b0, 16'hFFFF, 16'hFFFF, 1'b0);

        // Bloque 3: back-to-back writes alternando selects
        send_write(1'b0, 16'h1111, 16'h2222, 1'b1);
        send_write(1'b1, 16'h1111, 16'h2222, 1'b1);
        send_write(1'b0, 16'h1111, 16'h2222, 1'b1);
        send_write(1'b1, 16'h1111, 16'h2222, 1'b1);

        // Bloque 4: reset y write inmediato
        send_reset();
        send_write(1'b0, 16'hBEEF, 16'h0000, 1'b1);

        // Bloque 5: valores extremos (0 y max)
        send_write(1'b0, 16'h0000, 16'hFFFF, 1'b1);
        send_write(1'b1, 16'h0000, 16'hFFFF, 1'b1);

        // Bloque 6: toggle write/hold
        send_write(1'b0, 16'h0100, 16'h0200, 1'b1);
        send_write(1'b0, 16'hFFFF, 16'hFFFF, 1'b0);
        send_write(1'b1, 16'hCAFE, 16'hDEAD, 1'b1);
    endtask

endclass
