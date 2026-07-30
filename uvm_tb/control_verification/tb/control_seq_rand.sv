//------------------------------------------------------------------------------
// control_seq_rand.sv
// 1000 transacciones aleatorias. cmd_in, p_error y reset con distribucion.
//------------------------------------------------------------------------------
class control_seq_rand extends uvm_sequence#(control_transaction);

    `uvm_object_utils(control_seq_rand)

    rand int unsigned num_txn = 1000;

    function new(string name = "control_seq_rand");
        super.new(name);
    endfunction

    task body();
        repeat (num_txn) begin
            control_transaction req = control_transaction::type_id::create("req");
            start_item(req);
            if (!req.randomize())
                `uvm_error("SEQ", "randomize() fallo")
            finish_item(req);
        end
    endtask

endclass
