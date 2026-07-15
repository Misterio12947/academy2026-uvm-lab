//------------------------------------------------------------------------------
// alu_seq_rand.sv
// Sequence con transacciones totalmente aleatorias segun constraints
// definidos en alu_transaction.
//------------------------------------------------------------------------------
class alu_seq_rand extends uvm_sequence#(alu_transaction);

    `uvm_object_utils(alu_seq_rand)

    rand int unsigned num_txn = 500;

    function new(string name = "alu_seq_rand");
        super.new(name);
    endfunction

    task body();
        repeat (num_txn) begin
            alu_transaction req = alu_transaction::type_id::create("req");
            start_item(req);
            if (!req.randomize())
                `uvm_error("SEQ", "randomize() fallo en alu_seq_rand")
            finish_item(req);
        end
    endtask

endclass
