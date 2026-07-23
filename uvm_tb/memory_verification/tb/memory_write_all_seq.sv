//------------------------------------------------------------------------------
// memory_write_all_seq.sv
// Popula las 8 direcciones con valores distintivos. Util para preparar
// coverage tests que despues hacen reads.
//------------------------------------------------------------------------------
class memory_write_all_seq extends uvm_sequence#(memory_transaction);

    `uvm_object_utils(memory_write_all_seq)

    function new(string name = "memory_write_all_seq");
        super.new(name);
    endfunction

    task body();
        for (int i = 0; i < 8; i++) begin
            memory_transaction req = memory_transaction::type_id::create("req");
            start_item(req);
            if (!req.randomize() with {
                memoryWrite     == 1'b1;
                memoryRead      == 1'b0;
                memoryAddress   == i;
                memoryWriteData == (16'hA000 + i);   // valores distintivos
            })
                `uvm_error("SEQ", "randomize() fallo en write_all")
            finish_item(req);
        end
    endtask

endclass
