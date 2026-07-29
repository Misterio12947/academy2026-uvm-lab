//------------------------------------------------------------------------------
// alu_transaction.sv
// Sequence item del ALU. Encoding one-hot, solo 4 operaciones validas.
//------------------------------------------------------------------------------
class alu_transaction extends uvm_sequence_item;

    // Estimulos
    rand bit [WIDTH-1:0]         in1;
    rand bit [WIDTH-1:0]         in2;
    rand bit [3:0]               op;
    rand bit                     invalid_data;

    // Observados
    bit [2*WIDTH-1:0]            out;
    bit                          zero;
    bit                          error;

    `uvm_object_utils_begin(alu_transaction)
        `uvm_field_int(in1,          UVM_ALL_ON)
        `uvm_field_int(in2,          UVM_ALL_ON)
        `uvm_field_int(op,           UVM_ALL_ON)
        `uvm_field_int(invalid_data, UVM_ALL_ON)
        `uvm_field_int(out,          UVM_ALL_ON)
        `uvm_field_int(zero,         UVM_ALL_ON)
        `uvm_field_int(error,        UVM_ALL_ON)
    `uvm_object_utils_end

    // Restriccion: op debe ser uno de los 4 one-hot validos.
    // La FSM nunca envia 0000 ni multi-hot, asi que el estimulo tampoco.
    // DIV recibe algo mas de peso para ejercitar div-by-zero.
    constraint c_op_valid_dist {
        op dist {
            4'b0001 := 25,   // ADD
            4'b0010 := 25,   // SUB
            4'b0100 := 25,   // MUL
            4'b1000 := 25    // DIV
        };
    }

    // invalid_data raro (5%) para no dominar coverage con MINUS_ONE
    constraint c_invalid_dist {
        invalid_data dist { 0 := 95, 1 := 5 };
    }

    // Aumenta probabilidad de in2=0 para ejercitar div-by-zero
    constraint c_in2_dist {
        in2 dist {
            0             := 10,
            [1:'hFE]      := 85,
            'hFF          := 5
        };
    }

    function new(string name = "alu_transaction");
        super.new(name);
    endfunction

endclass