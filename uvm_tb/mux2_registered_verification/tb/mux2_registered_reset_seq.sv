//------------------------------------------------------------------------------
// mux2_registered_reset_seq.sv
// Escenarios especificos de reset asincrono.
//------------------------------------------------------------------------------
class mux2_registered_reset_seq extends uvm_sequence#(mux2_registered_transaction);

    `uvm_object_utils(mux2_registered_reset_seq)

    function new(string name = "mux2_registered_reset_seq");
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
            `uvm_error("SEQ", "randomize() fallo")
        finish_item(req);
    endtask

    task send_reset();
        mux2_registered_transaction req = mux2_registered_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with { assert_reset == 1'b1; })
            `uvm_error("SEQ", "randomize() fallo en reset")
        finish_item(req);
    endtask

    task body();
        // A: reset simple + write alternando selects
        send_write(1'b0, 16'hABCD, 16'h0000, 1'b1);
        send_reset();
        send_write(1'b1, 16'h0000, 16'hFEED, 1'b1);
        send_reset();
        send_write(1'b0, 16'hDEAD, 16'h0000, 1'b1);

        // B: dos resets consecutivos
        send_reset();
        send_reset();

        // C: write, hold, reset
        send_write(1'b1, 16'h0000, 16'hBEEF, 1'b1);
        send_write(1'b1, 16'hFFFF, 16'hFFFF, 1'b0);
        send_write(1'b1, 16'hFFFF, 16'hFFFF, 1'b0);
        send_reset();

        // D: reset + hold sostenido
        send_reset();
        repeat (3) send_write(1'b0, 16'hFFFF, 16'hFFFF, 1'b0);

        // E: reset + rafaga alternando selects
        send_reset();
        send_write(1'b0, 16'h1234, 16'h5678, 1'b1);
        send_write(1'b1, 16'h1234, 16'h5678, 1'b1);
        send_write(1'b0, 16'h9ABC, 16'hDEF0, 1'b1);
    endtask

endclass
