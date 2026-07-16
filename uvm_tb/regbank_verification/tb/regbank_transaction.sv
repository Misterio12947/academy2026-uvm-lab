//------------------------------------------------------------------------------
// regbank_transaction.sv
// Sequence item del register_bank.
//   - assert_reset: flag para pedirle al driver que aplique un pulso de reset
//     asincrono en vez de una escritura normal.
//   - Los campos rst/out se llenan por el monitor cuando la tx captura el
//     estado observado del DUT.
//------------------------------------------------------------------------------
class regbank_transaction extends uvm_sequence_item;

    // Estimulos (drive)
    rand bit                 wr_en;
    rand bit [WIDTH-1:0]     in;
    rand bit                 assert_reset;

    // Observados (llenados por el monitor)
    bit                      rst;
    bit [WIDTH-1:0]          out;

    `uvm_object_utils_begin(regbank_transaction)
        `uvm_field_int(wr_en,        UVM_ALL_ON)
        `uvm_field_int(in,           UVM_ALL_ON)
        `uvm_field_int(assert_reset, UVM_ALL_ON)
        `uvm_field_int(rst,          UVM_ALL_ON)
        `uvm_field_int(out,          UVM_ALL_ON)
    `uvm_object_utils_end

    // Reset raro por default: 5% de las transacciones piden reset.
    // Suficiente para cerrar coverage del cross wr_en x rst en 1000 tx.
    constraint c_assert_reset_dist { assert_reset dist { 0 := 95, 1 := 5 }; }

    // wr_en 50/50 para mezclar writes y holds
    constraint c_wr_en_dist        { wr_en        dist { 0 := 50, 1 := 50 }; }

    function new(string name = "regbank_transaction");
        super.new(name);
    endfunction

endclass
