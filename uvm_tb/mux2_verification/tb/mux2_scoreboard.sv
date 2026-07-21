//------------------------------------------------------------------------------
// mux2_scoreboard.sv
// Scoreboard con reference model. Predice dout segun select y compara.
//------------------------------------------------------------------------------
`uvm_analysis_imp_decl(_mux2)

class mux2_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(mux2_scoreboard)

    uvm_analysis_imp_mux2#(mux2_transaction, mux2_scoreboard) ap_imp;

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

    function bit [WIDTH-1:0] predict(bit [WIDTH-1:0] d1, d2, bit sel);
        return sel ? d2 : d1;
    endfunction

    function void write_mux2(mux2_transaction tr);
        bit [WIDTH-1:0] expected;

        expected = predict(tr.din1, tr.din2, tr.select);

        num_checked++;

        if (tr.dout !== expected) begin
            num_errors++;
            `uvm_error("SCB",
                $sformatf("MISMATCH | din1=%0h din2=%0h sel=%0b || DUT: dout=%0h || REF: expected=%0h",
                    tr.din1, tr.din2, tr.select, tr.dout, expected))
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
