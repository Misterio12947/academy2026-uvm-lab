//------------------------------------------------------------------------------
// mux4_registered_transaction.sv
// Sequence item con estimulos (wr_en, sel, in1..in4, assert_reset) y
// observados (rst, out).
//------------------------------------------------------------------------------
class mux4_registered_transaction extends uvm_sequence_item;

    // Estimulos
    rand bit                 wr_en;
    rand bit [1:0]           sel;
    rand bit [WIDTH-1:0]     in1;
    rand bit [WIDTH-1:0]     in2;
    rand bit [WIDTH-1:0]     in3;
    rand bit [WIDTH-1:0]     in4;
    rand bit                 assert_reset;

    // Observados (llenados por el monitor)
    bit                      rst;
    bit [WIDTH-1:0]          out;

    `uvm_object_utils_begin(mux4_registered_transaction)
        `uvm_field_int(wr_en,        UVM_ALL_ON)
        `uvm_field_int(sel,          UVM_ALL_ON)
        `uvm_field_int(in1,          UVM_ALL_ON)
        `uvm_field_int(in2,          UVM_ALL_ON)
        `uvm_field_int(in3,          UVM_ALL_ON)
        `uvm_field_int(in4,          UVM_ALL_ON)
        `uvm_field_int(assert_reset, UVM_ALL_ON)
        `uvm_field_int(rst,          UVM_ALL_ON)
        `uvm_field_int(out,          UVM_ALL_ON)
    `uvm_object_utils_end

    // Reset raro por default: 5% de las transacciones piden reset
    constraint c_assert_reset_dist { assert_reset dist { 0 := 95, 1 := 5 }; }

    // wr_en 50/50
    constraint c_wr_en_dist        { wr_en        dist { 0 := 50, 1 := 50 }; }

    function new(string name = "mux4_registered_transaction");
        super.new(name);
    endfunction

endclass
