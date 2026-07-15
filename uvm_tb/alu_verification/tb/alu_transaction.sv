//------------------------------------------------------------------------------
// alu_transaction.sv
// Sequence item del ALU. Contiene estimulos (in1, in2, op, invalid_data)
// y salidas observadas (out, zero, error).
//------------------------------------------------------------------------------
class alu_transaction extends uvm_sequence_item;

    // Estimulos
    rand bit [WIDTH-1:0]     in1;
    rand bit [WIDTH-1:0]     in2;
    rand bit [3:0]           op;
    rand bit                 invalid_data;

    // Observados (los llena el monitor)
    bit [2*WIDTH-1:0]        out;
    bit                      zero;
    bit                      error;

    `uvm_object_utils_begin(alu_transaction)
        `uvm_field_int(in1,          UVM_ALL_ON)
        `uvm_field_int(in2,          UVM_ALL_ON)
        `uvm_field_int(op,           UVM_ALL_ON)
        `uvm_field_int(invalid_data, UVM_ALL_ON)
        `uvm_field_int(out,          UVM_ALL_ON)
        `uvm_field_int(zero,         UVM_ALL_ON)
        `uvm_field_int(error,        UVM_ALL_ON)
    `uvm_object_utils_end

    // op[3] esta reservado por la ISA
    constraint c_op_msb_reserved { op[3] == 1'b0; }

    // invalid_data raro: 10%
    constraint c_invalid_dist    { invalid_data dist { 0 := 90, 1 := 10 }; }

    // in2 casi nunca cero (5%)
    constraint c_in2_dist        { in2 dist { 0 := 5, [1:$] := 95 }; }

    function new(string name = "alu_transaction");
        super.new(name);
    endfunction

endclass
