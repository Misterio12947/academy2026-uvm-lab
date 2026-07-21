//------------------------------------------------------------------------------
// mux2_seq_rand.sv
// Sequence aleatoria: 500 transacciones.
//------------------------------------------------------------------------------
class mux2_seq_rand extends uvm_sequence#(mux2_transaction);

    `uvm_object_utils(mux2_seq_rand)

    rand int unsigned num_txn = 500;

    function new(string name = "mux2_seq_rand");
        super.new(name);
    endfunction

    task body();
        repeat (num_txn) begin
            mux2_transaction req = mux2_transaction::type_id::create("req");
            start_item(req);
            if (!req.randomize())
                `uvm_error("SEQ", "randomize() fallo")
            finish_item(req);
        end
    endtask

endclass
