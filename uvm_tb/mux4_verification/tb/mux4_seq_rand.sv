//------------------------------------------------------------------------------
// mux4_seq_rand.sv
// Sequence aleatoria: 500 transacciones con din1..din4 y select uniformes.
//------------------------------------------------------------------------------
class mux4_seq_rand extends uvm_sequence#(mux4_transaction);

    `uvm_object_utils(mux4_seq_rand)

    rand int unsigned num_txn = 500;

    function new(string name = "mux4_seq_rand");
        super.new(name);
    endfunction

    task body();
        repeat (num_txn) begin
            mux4_transaction req = mux4_transaction::type_id::create("req");
            start_item(req);
            if (!req.randomize())
                `uvm_error("SEQ", "randomize() fallo")
            finish_item(req);
        end
    endtask

endclass
