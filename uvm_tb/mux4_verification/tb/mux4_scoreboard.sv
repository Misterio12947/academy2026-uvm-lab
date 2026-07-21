//------------------------------------------------------------------------------
// mux4_scoreboard.sv
// Scoreboard con reference model. Predice dout segun select y compara
// contra lo observado por el monitor.
//------------------------------------------------------------------------------
`uvm_analysis_imp_decl(_mux4)

class mux4_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(mux4_scoreboard)

    uvm_analysis_imp_mux4#(mux4_transaction, mux4_scoreboard) ap_imp;

    int unsigned num_checked;
    int unsigned num_errors;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap_imp      = new("ap_imp", this);
        num_checked = 0;
        num_errors  = 0;
    endfunction

    // Reference model: replica exacta de la spec del mux4
    function bit [WIDTH-1:0] predict(bit [WIDTH-1:0] d1, d2, d3, d4,
                                     bit [1:0]       sel);
        case (sel)
            2'b00: return d1;
            2'b01: return d2;
            2'b10: return d3;
            2'b11: return d4;
            default: return '0;
        endcase
    endfunction

    function void write_mux4(mux4_transaction tr);
        bit [WIDTH-1:0] expected;

        expected = predict(tr.din1, tr.din2, tr.din3, tr.din4, tr.select);

        num_checked++;

        if (tr.dout !== expected) begin
            num_errors++;
            `uvm_error("SCB",
                $sformatf("MISMATCH | din1=%0h din2=%0h din3=%0h din4=%0h sel=%0b || DUT: dout=%0h || REF: expected=%0h",
                    tr.din1, tr.din2, tr.din3, tr.din4, tr.select,
                    tr.dout, expected))
        end
        else begin
            `uvm_info("SCB",
                $sformatf("MATCH    | sel=%0b -> dout=%0h",
                    tr.select, tr.dout),
                UVM_HIGH)
        end
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCB",
            $sformatf("Transacciones verificadas: %0d | Errores: %0d",
                num_checked, num_errors),
            UVM_NONE)
    endfunction

endclass
