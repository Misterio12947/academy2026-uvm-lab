//------------------------------------------------------------------------------
// control_transaction.sv
// Sequence item del control. Estimulos: cmd_in (descompuesto), p_error,
// assert_reset. Observados: todas las salidas + estado inferido.
//------------------------------------------------------------------------------
class control_transaction extends uvm_sequence_item;

    // Estimulos
    rand bit [1:0]  muxA;         // cmd_in[6:5]
    rand bit [1:0]  muxB;         // cmd_in[4:3]
    rand bit [2:0]  isa_op;       // cmd_in[2:0]
    rand bit        p_error;
    rand bit        assert_reset;

    // Observados (llenados por el monitor)
    bit             rst;
    bit             aluin_reg_en;
    bit             datain_reg_en;
    bit             memoryWrite;
    bit             memoryRead;
    bit             selmux2;
    bit             cpu_rdy;
    bit             aluout_reg_en;
    bit             nvalid_data;
    bit [1:0]       in_select_a;
    bit [1:0]       in_select_b;
    bit [3:0]       opcode;

    // Estado observado (inferido por el modelo del monitor/scoreboard)
    bit [1:0]       state_observed;
	// Marca: esta transaccion es la primera tras un reset (no forma
    // transicion valida con la anterior para cg_transitions)
    bit             first_after_reset;
	
    `uvm_object_utils_begin(control_transaction)
        `uvm_field_int(muxA,           UVM_ALL_ON)
        `uvm_field_int(muxB,           UVM_ALL_ON)
        `uvm_field_int(isa_op,         UVM_ALL_ON)
        `uvm_field_int(p_error,        UVM_ALL_ON)
        `uvm_field_int(assert_reset,   UVM_ALL_ON)
        `uvm_field_int(rst,            UVM_ALL_ON)
        `uvm_field_int(aluin_reg_en,   UVM_ALL_ON)
        `uvm_field_int(datain_reg_en,  UVM_ALL_ON)
        `uvm_field_int(memoryWrite,    UVM_ALL_ON)
        `uvm_field_int(memoryRead,     UVM_ALL_ON)
        `uvm_field_int(selmux2,        UVM_ALL_ON)
        `uvm_field_int(cpu_rdy,        UVM_ALL_ON)
        `uvm_field_int(aluout_reg_en,  UVM_ALL_ON)
        `uvm_field_int(nvalid_data,    UVM_ALL_ON)
        `uvm_field_int(in_select_a,    UVM_ALL_ON)
        `uvm_field_int(in_select_b,    UVM_ALL_ON)
        `uvm_field_int(opcode,         UVM_ALL_ON)
		`uvm_field_int(first_after_reset, UVM_ALL_ON)
    `uvm_object_utils_end

    // Reset raro (5%)
    constraint c_reset_dist   { assert_reset dist { 0 := 95, 1 := 5 }; }
    // p_error moderado para ejercitar nvalid_data
    constraint c_perror_dist  { p_error      dist { 0 := 70, 1 := 30 }; }
    // ISA op uniforme sobre las 8 instrucciones
    constraint c_isa_dist     { isa_op       inside {[0:7]}; }

    function new(string name = "control_transaction");
        super.new(name);
    endfunction

    // Helper: reconstruye cmd_in de 7 bits
    function bit [6:0] get_cmd_in();
        return {muxA, muxB, isa_op};
    endfunction

endclass
