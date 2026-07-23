//------------------------------------------------------------------------------
// mux2_registered_coverage_seq.sv
//------------------------------------------------------------------------------
class mux2_registered_coverage_seq extends uvm_sequence#(mux2_registered_transaction);

    `uvm_object_utils(mux2_registered_coverage_seq)

    function new(string name = "mux2_registered_coverage_seq");
        super.new(name);
    endfunction

    task send_action(bit wr, bit rst_flag, bit s);
        mux2_registered_transaction req = mux2_registered_transaction::type_id::create("req");
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
        int unsigned reps = 30;

        // Cada select ejercitado varias veces con random
        for (int s = 0; s < 2; s++) begin
            repeat (reps) send_action(1'b1, 1'b0, s[0]);
            repeat (reps) send_action(1'b0, 1'b0, s[0]);
        end

        // Holds sostenidos de varias duraciones
        send_action(1'b1, 1'b0, 1'b0);
        send_action(1'b0, 1'b0, 1'b0);
        send_action(1'b1, 1'b0, 1'b0);

        send_action(1'b1, 1'b0, 1'b1);
        repeat (3) send_action(1'b0, 1'b0, 1'b1);
        send_action(1'b1, 1'b0, 1'b1);

        send_action(1'b1, 1'b0, 1'b0);
        repeat (10) send_action(1'b0, 1'b0, 1'b0);
        send_action(1'b1, 1'b0, 1'b0);

        send_action(1'b1, 1'b0, 1'b1);
        repeat (25) send_action(1'b0, 1'b0, 1'b1);

        // Resets intercalados
        for (int s = 0; s < 2; s++) begin
            send_action(1'b0, 1'b1, s[0]);
            send_action(1'b1, 1'b0, s[0]);
        end

        // Transiciones criticas
        send_action(1'b0, 1'b0, 1'b0);
        send_action(1'b1, 1'b0, 1'b1);
        send_action(1'b0, 1'b0, 1'b0);
        send_action(1'b0, 1'b1, 1'b1);
        send_action(1'b1, 1'b0, 1'b0);
        send_action(1'b0, 1'b1, 1'b1);
        send_action(1'b0, 1'b0, 1'b0);
    endtask

endclass
