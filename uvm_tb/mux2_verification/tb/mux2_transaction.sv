//------------------------------------------------------------------------------
// mux2_transaction.sv
// Sequence item del mux2.
//------------------------------------------------------------------------------
class mux2_transaction extends uvm_sequence_item;

    rand bit [WIDTH-1:0]     din1;
    rand bit [WIDTH-1:0]     din2;
    rand bit                 select;

    bit [WIDTH-1:0]          dout;

    `uvm_object_utils_begin(mux2_transaction)
        `uvm_field_int(din1,   UVM_ALL_ON)
        `uvm_field_int(din2,   UVM_ALL_ON)
        `uvm_field_int(select, UVM_ALL_ON)
        `uvm_field_int(dout,   UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "mux2_transaction");
        super.new(name);
    endfunction

endclass
