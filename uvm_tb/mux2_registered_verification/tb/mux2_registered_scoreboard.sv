//------------------------------------------------------------------------------
// mux2_registered_scoreboard.sv
// Mismo patron reactive (opcion A) que mux4_registered/regbank.
//------------------------------------------------------------------------------
`uvm_analysis_imp_decl(_mux2r)

class mux2_registered_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(mux2_registered_scoreboard)

    uvm_analysis_imp_mux2r#(mux2_registered_transaction, mux2_registered_scoreboard) ap_imp;

    bit [2*WIDTH-1:0] model_reg;

    int unsigned num_checked;
    int unsigned num_errors;
    int unsigned num_warmup;

    localparam int unsigned WARMUP_CYCLES = 4;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap_imp      = new("ap_imp", this);
        model_reg   = '0;
        num_checked = 0;
        num_errors  = 0;
        num_warmup  = 0;
    endfunction

    function bit [2*WIDTH-1:0] mux2_select(bit [2*WIDTH-1:0] i1, i2, bit s);
        return s ? i2 : i1;
    endfunction

    function bit [2*WIDTH-1:0] predict(bit [2*WIDTH-1:0] current,
                                       bit               rst,
                                       bit               wr_en,
                                       bit [2*WIDTH-1:0] i1, i2,
                                       bit               s);
        if (rst)        return '0;
        else if (wr_en) return mux2_select(i1, i2, s);
        else            return current;
    endfunction

    function void write_mux2r(mux2_registered_transaction tr);
        bit [2*WIDTH-1:0] current_expected;

        current_expected = tr.rst ? '0 : model_reg;

        if (num_warmup < WARMUP_CYCLES) begin
            num_warmup++;
            model_reg = predict(model_reg, tr.rst, tr.wr_en,
                                tr.in1, tr.in2, tr.sel);
            return;
        end

        num_checked++;

        if (tr.out !== current_expected) begin
            num_errors++;
            `uvm_error("SCB",
                $sformatf("MISMATCH | rst=%0b wr_en=%0b sel=%0b in1=%04h in2=%04h || DUT: out=%04h || REF: expected=%04h",
                    tr.rst, tr.wr_en, tr.sel, tr.in1, tr.in2,
                    tr.out, current_expected))
        end
        else begin
            `uvm_info("SCB",
                $sformatf("MATCH    | rst=%0b wr_en=%0b sel=%0b -> out=%04h",
                    tr.rst, tr.wr_en, tr.sel, tr.out),
                UVM_HIGH)
        end

        model_reg = predict(model_reg, tr.rst, tr.wr_en,
                            tr.in1, tr.in2, tr.sel);
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCB",
            $sformatf("Transacciones verificadas: %0d | Errores: %0d | Warmup: %0d",
                num_checked, num_errors, num_warmup),
            UVM_NONE)
    endfunction

endclass
