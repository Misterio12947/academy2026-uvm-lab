//------------------------------------------------------------------------------
// mux4_registered_seq_rand.sv
// Sequence aleatoria: 1000 tx.
//------------------------------------------------------------------------------
class mux4_registered_seq_rand extends uvm_sequence#(mux4_registered_transaction);

    `uvm_object_utils(mux4_registered_seq_rand)

    rand int unsigned num_txn = 1000;

    function new(string name = "mux4_registered_seq_rand");
        super.new(name);
    endfunction

    task body();
        repeat (num_txn) begin
            mux4_registered_transaction req = mux4_registered_transaction::type_id::create("req");
            start_item(req);
            if (!req.randomize())
                `uvm_error("SEQ", "randomize() fallo")
            finish_item(req);
        end
    endtask

endclass
