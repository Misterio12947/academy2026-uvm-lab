//------------------------------------------------------------------------------
// mux4_registered_scoreboard.sv
// Scoreboard con estado interno (opcion A). Modelo reactive:
//   1. current_expected = tr.rst ? 0 : model_reg
//   2. Compare tr.out vs current_expected
//   3. Update model_reg = predict(model_reg, rst, wr_en, in1..in4, sel)
//
// predict() replica: reset -> 0; wr_en=1 -> mux4(in1..in4, sel); else hold.
//------------------------------------------------------------------------------
`uvm_analysis_imp_decl(_mux4r)

class mux4_registered_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(mux4_registered_scoreboard)

    uvm_analysis_imp_mux4r#(mux4_registered_transaction, mux4_registered_scoreboard) ap_imp;

    bit [WIDTH-1:0] model_reg;

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

    // Mux4 combinacional
    function bit [WIDTH-1:0] mux4_select(bit [WIDTH-1:0] i1, i2, i3, i4,
                                          bit [1:0]       s);
        case (s)
            2'b00: return i1;
            2'b01: return i2;
            2'b10: return i3;
            2'b11: return i4;
            default: return '0;
        endcase
    endfunction

    // Reference model del bloque compuesto
    function bit [WIDTH-1:0] predict(bit [WIDTH-1:0] current,
                                     bit             rst,
                                     bit             wr_en,
                                     bit [WIDTH-1:0] i1, i2, i3, i4,
                                     bit [1:0]       s);
        if (rst)        return '0;
        else if (wr_en) return mux4_select(i1, i2, i3, i4, s);
        else            return current;
    endfunction

    function void write_mux4r(mux4_registered_transaction tr);
        bit [WIDTH-1:0] current_expected;

        current_expected = tr.rst ? '0 : model_reg;

        if (num_warmup < WARMUP_CYCLES) begin
            num_warmup++;
            model_reg = predict(model_reg, tr.rst, tr.wr_en,
                                tr.in1, tr.in2, tr.in3, tr.in4, tr.sel);
            return;
        end

        num_checked++;

        if (tr.out !== current_expected) begin
            num_errors++;
            `uvm_error("SCB",
                $sformatf("MISMATCH | rst=%0b wr_en=%0b sel=%0b in1=%0h in2=%0h in3=%0h in4=%0h || DUT: out=%0h || REF: expected=%0h",
                    tr.rst, tr.wr_en, tr.sel, tr.in1, tr.in2, tr.in3, tr.in4,
                    tr.out, current_expected))
        end
        else begin
            `uvm_info("SCB",
                $sformatf("MATCH    | rst=%0b wr_en=%0b sel=%0b -> out=%0h",
                    tr.rst, tr.wr_en, tr.sel, tr.out),
                UVM_HIGH)
        end

        model_reg = predict(model_reg, tr.rst, tr.wr_en,
                            tr.in1, tr.in2, tr.in3, tr.in4, tr.sel);
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCB",
            $sformatf("Transacciones verificadas: %0d | Errores: %0d | Warmup: %0d",
                num_checked, num_errors, num_warmup),
            UVM_NONE)
    endfunction

endclass
