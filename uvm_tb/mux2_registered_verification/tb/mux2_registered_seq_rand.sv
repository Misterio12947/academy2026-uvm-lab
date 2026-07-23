//------------------------------------------------------------------------------
// mux2_registered_seq_rand.sv
//------------------------------------------------------------------------------
class mux2_registered_seq_rand extends uvm_sequence#(mux2_registered_transaction);

    `uvm_object_utils(mux2_registered_seq_rand)

    rand int unsigned num_txn = 1000;

    function new(string name = "mux2_registered_seq_rand");
        super.new(name);
    endfunction

    task body();
        repeat (num_txn) begin
            mux2_registered_transaction req = mux2_registered_transaction::type_id::create("req");
            start_item(req);
            if (!req.randomize())
                `uvm_error("SEQ", "randomize() fallo")
            finish_item(req);
        end
    endtask

endclass
