//------------------------------------------------------------------------------
// memory_transaction.sv
// Sequence item para la memoria. addr[2:0] se usa como indice real.
//------------------------------------------------------------------------------
class memory_transaction extends uvm_sequence_item;

    rand bit                     memoryWrite;
    rand bit                     memoryRead;
    rand bit [7:0]               memoryAddress;
    rand bit [2*WIDTH-1:0]       memoryWriteData;

    bit [2*WIDTH-1:0]            memoryOutData;

    `uvm_object_utils_begin(memory_transaction)
        `uvm_field_int(memoryWrite,     UVM_ALL_ON)
        `uvm_field_int(memoryRead,      UVM_ALL_ON)
        `uvm_field_int(memoryAddress,   UVM_ALL_ON)
        `uvm_field_int(memoryWriteData, UVM_ALL_ON)
        `uvm_field_int(memoryOutData,   UVM_ALL_ON)
    `uvm_object_utils_end

    // Distribucion balanceada de acciones: idle, read, write, w+r
    constraint c_action_dist {
        {memoryWrite, memoryRead} dist {
            2'b00 := 20,   // idle
            2'b01 := 30,   // read only
            2'b10 := 30,   // write only
            2'b11 := 20    // write + read (raro pero valido)
        };
    }

    // Distribucion uniforme sobre las 8 direcciones utiles (LSB)
    constraint c_addr_range { memoryAddress[2:0] inside {[0:7]}; }

    function new(string name = "memory_transaction");
        super.new(name);
    endfunction

endclass
