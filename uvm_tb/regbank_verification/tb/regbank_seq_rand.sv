//------------------------------------------------------------------------------
// regbank_seq_rand.sv
// Sequence aleatoria: 1000 transacciones para asegurar hits del cross
// wr_en x rst (reset a 5%, wr_en 50/50).
//------------------------------------------------------------------------------
class regbank_seq_rand extends uvm_sequence#(regbank_transaction);

    `uvm_object_utils(regbank_seq_rand)

    rand int unsigned num_txn = 1000;

    function new(string name = "regbank_seq_rand");
        super.new(name);
    endfunction

    task body();
        repeat (num_txn) begin
            regbank_transaction req = regbank_transaction::type_id::create("req");
            start_item(req);
            if (!req.randomize())
                `uvm_error("SEQ", "randomize() fallo")
            finish_item(req);
        end
    endtask

endclass
