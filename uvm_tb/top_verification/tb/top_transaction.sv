//------------------------------------------------------------------------------
// top_transaction.sv
// Una instruccion del CPU. Estimulos: cmd_in descompuesto + din_1/2/3.
// Observados: dout, flags, cpu_rdy (capturados cuando cpu_rdy=1).
//------------------------------------------------------------------------------
class top_transaction extends uvm_sequence_item;

    // Estimulos
    rand bit [1:0]         muxA;      // cmd_in[6:5]
    rand bit [1:0]         muxB;      // cmd_in[4:3]
    rand bit [2:0]         isa_op;    // cmd_in[2:0]
    rand bit [WIDTH-1:0]   din_1;
    rand bit [WIDTH-1:0]   din_2;
    rand bit [WIDTH-1:0]   din_3;
    rand bit               assert_reset;

    // Observados (cuando cpu_rdy=1)
    bit [WIDTH-1:0]        dout_low;
    bit [WIDTH-1:0]        dout_high;
    bit                    cpu_rdy;
    bit                    zero;
    bit                    error;

    `uvm_object_utils_begin(top_transaction)
        `uvm_field_int(muxA,         UVM_ALL_ON)
        `uvm_field_int(muxB,         UVM_ALL_ON)
        `uvm_field_int(isa_op,       UVM_ALL_ON)
        `uvm_field_int(din_1,        UVM_ALL_ON)
        `uvm_field_int(din_2,        UVM_ALL_ON)
        `uvm_field_int(din_3,        UVM_ALL_ON)
        `uvm_field_int(assert_reset, UVM_ALL_ON)
        `uvm_field_int(dout_low,     UVM_ALL_ON)
        `uvm_field_int(dout_high,    UVM_ALL_ON)
        `uvm_field_int(zero,         UVM_ALL_ON)
        `uvm_field_int(error,        UVM_ALL_ON)
    `uvm_object_utils_end

    constraint c_reset_dist { assert_reset dist { 0 := 97, 1 := 3 }; }
    constraint c_isa_dist   { isa_op inside {[0:7]}; }

    function new(string name = "top_transaction");
        super.new(name);
    endfunction

    function bit [6:0] get_cmd_in();
        return {muxA, muxB, isa_op};
    endfunction

endclass
