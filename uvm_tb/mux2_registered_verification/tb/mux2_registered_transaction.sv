//------------------------------------------------------------------------------
// mux2_registered_transaction.sv
// Sequence item con bus de 2*WIDTH bits para in1, in2, out.
//------------------------------------------------------------------------------
class mux2_registered_transaction extends uvm_sequence_item;

    // Estimulos
    rand bit                     wr_en;
    rand bit                     sel;
    rand bit [2*WIDTH-1:0]       in1;
    rand bit [2*WIDTH-1:0]       in2;
    rand bit                     assert_reset;

    // Observados
    bit                          rst;
    bit [2*WIDTH-1:0]            out;

    `uvm_object_utils_begin(mux2_registered_transaction)
        `uvm_field_int(wr_en,        UVM_ALL_ON)
        `uvm_field_int(sel,          UVM_ALL_ON)
        `uvm_field_int(in1,          UVM_ALL_ON)
        `uvm_field_int(in2,          UVM_ALL_ON)
        `uvm_field_int(assert_reset, UVM_ALL_ON)
        `uvm_field_int(rst,          UVM_ALL_ON)
        `uvm_field_int(out,          UVM_ALL_ON)
    `uvm_object_utils_end

    constraint c_assert_reset_dist { assert_reset dist { 0 := 95, 1 := 5 }; }
    constraint c_wr_en_dist        { wr_en        dist { 0 := 50, 1 := 50 }; }

    function new(string name = "mux2_registered_transaction");
        super.new(name);
    endfunction

endclass
