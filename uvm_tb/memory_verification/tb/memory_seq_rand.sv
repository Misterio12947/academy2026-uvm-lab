//------------------------------------------------------------------------------
// memory_seq_rand.sv
//------------------------------------------------------------------------------
class memory_seq_rand extends uvm_sequence#(memory_transaction);

    `uvm_object_utils(memory_seq_rand)

    rand int unsigned num_txn = 1000;

    function new(string name = "memory_seq_rand");
        super.new(name);
    endfunction

    task body();
        repeat (num_txn) begin
            memory_transaction req = memory_transaction::type_id::create("req");
            start_item(req);
            if (!req.randomize())
                `uvm_error("SEQ", "randomize() fallo")
            finish_item(req);
        end
    endtask

endclass
