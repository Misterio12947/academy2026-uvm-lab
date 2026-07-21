//------------------------------------------------------------------------------
// mux4_transaction.sv
// Sequence item del mux4. Contiene estimulos (din1..din4, select) y salida
// observada (dout).
//------------------------------------------------------------------------------
class mux4_transaction extends uvm_sequence_item;

    // Estimulos
    rand bit [WIDTH-1:0]     din1;
    rand bit [WIDTH-1:0]     din2;
    rand bit [WIDTH-1:0]     din3;
    rand bit [WIDTH-1:0]     din4;
    rand bit [1:0]           select;

    // Observado (llenado por el monitor)
    bit [WIDTH-1:0]          dout;

    `uvm_object_utils_begin(mux4_transaction)
        `uvm_field_int(din1,   UVM_ALL_ON)
        `uvm_field_int(din2,   UVM_ALL_ON)
        `uvm_field_int(din3,   UVM_ALL_ON)
        `uvm_field_int(din4,   UVM_ALL_ON)
        `uvm_field_int(select, UVM_ALL_ON)
        `uvm_field_int(dout,   UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "mux4_transaction");
        super.new(name);
    endfunction

endclass
