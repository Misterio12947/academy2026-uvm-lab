
//------------------------------------------------------------------------------
// mux4_registered_coverage_seq.sv
// Closure de covergroups: recorre cada select con random, holds de varias
// duraciones, resets intercalados.
//------------------------------------------------------------------------------
class mux4_registered_coverage_seq extends uvm_sequence#(mux4_registered_transaction);

    `uvm_object_utils(mux4_registered_coverage_seq)

    function new(string name = "mux4_registered_coverage_seq");
        super.new(name);
    endfunction

    task send_action(bit wr, bit rst_flag, bit [1:0] s);
        mux4_registered_transaction req = mux4_registered_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {
            wr_en        == wr;
            sel          == s;
            assert_reset == rst_flag;
        })
            `uvm_error("SEQ", "randomize() fallo en coverage_seq")
        finish_item(req);
    endtask

    task body();
        int unsigned reps = 15;

        // Loop principal: cada select ejercitado varias veces con random
        for (int s = 0; s < 4; s++) begin
            repeat (reps) send_action(1'b1, 1'b0, s[1:0]);
            repeat (reps) send_action(1'b0, 1'b0, s[1:0]);
        end

        // Holds sostenidos de varias duraciones
        send_action(1'b1, 1'b0, 2'b00);
        send_action(1'b0, 1'b0, 2'b00);
        send_action(1'b1, 1'b0, 2'b00);

        send_action(1'b1, 1'b0, 2'b01);
        repeat (3) send_action(1'b0, 1'b0, 2'b01);
        send_action(1'b1, 1'b0, 2'b01);

        send_action(1'b1, 1'b0, 2'b10);
        repeat (10) send_action(1'b0, 1'b0, 2'b10);
        send_action(1'b1, 1'b0, 2'b10);

        send_action(1'b1, 1'b0, 2'b11);
        repeat (25) send_action(1'b0, 1'b0, 2'b11);

        // Resets intercalados con distintos selects
        for (int s = 0; s < 4; s++) begin
            send_action(1'b0, 1'b1, s[1:0]);
            send_action(1'b1, 1'b0, s[1:0]);
        end

        // Transiciones criticas
        send_action(1'b0, 1'b0, 2'b00);
        send_action(1'b1, 1'b0, 2'b01);
        send_action(1'b0, 1'b0, 2'b10);
        send_action(1'b0, 1'b1, 2'b11);
        send_action(1'b1, 1'b0, 2'b00);
        send_action(1'b0, 1'b1, 2'b01);
        send_action(1'b0, 1'b0, 2'b10);
    endtask

endclass
