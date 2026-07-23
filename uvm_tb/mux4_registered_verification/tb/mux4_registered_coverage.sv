//------------------------------------------------------------------------------
// mux4_registered_coverage.sv
// Coverage funcional. Combina crosses del regbank (wr_en x rst,
// transiciones, hold_duration) con crosses del mux4 (sel x salidas).
//------------------------------------------------------------------------------
class mux4_registered_coverage extends uvm_subscriber#(mux4_registered_transaction);

    `uvm_component_utils(mux4_registered_coverage)

    mux4_registered_transaction tr;

    int unsigned hold_count;

    //--------------------------------------------------------------------------
    // Covergroup principal
    //--------------------------------------------------------------------------
    covergroup cg_mux4r;
        option.per_instance = 1;
        option.name         = "cg_mux4r";

        cp_wr_en: coverpoint tr.wr_en {
            bins low  = {1'b0};
            bins high = {1'b1};
        }

        cp_rst: coverpoint tr.rst {
            bins low  = {1'b0};
            bins high = {1'b1};
        }

        cp_sel: coverpoint tr.sel {
            bins sel_din1 = {2'b00};
            bins sel_din2 = {2'b01};
            bins sel_din3 = {2'b10};
            bins sel_din4 = {2'b11};
        }

        cp_out: coverpoint tr.out {
            bins zero    = {0};
            bins low     = {[1:('h1F)]};
            bins mid     = {[('h20):('hDF)]};
            bins high    = {[('hE0):('hFE)]};
            bins max_val = {'hFF};
        }

        // Cross: 4 combinaciones wr_en x rst (incluye reset_write)
        cx_wr_en_rst: cross cp_wr_en, cp_rst;

        // Cross: cada sel produce salidas en todos los rangos
        cx_sel_out: cross cp_sel, cp_out;

    endgroup

    //--------------------------------------------------------------------------
    // Covergroup de transiciones (mismo patron que regbank)
    //--------------------------------------------------------------------------
    covergroup cg_transitions;
        option.per_instance = 1;
        option.name         = "cg_transitions";

        cp_action: coverpoint {tr.wr_en, tr.rst} {
            bins hold        = {2'b00};
            bins write       = {2'b10};
            bins reset_only  = {2'b01};
            bins reset_write = {2'b11};
        }

        cp_transitions: coverpoint {tr.wr_en, tr.rst} {
            bins hold_to_write        = (2'b00 => 2'b10);
            bins write_to_hold        = (2'b10 => 2'b00);
            bins write_to_reset       = (2'b10 => 2'b01);
            bins hold_to_reset        = (2'b00 => 2'b01);
            bins reset_to_write       = (2'b01 => 2'b10);
            bins reset_to_hold        = (2'b01 => 2'b00);
            bins write_to_write       = (2'b10 => 2'b10);
            bins hold_to_hold         = (2'b00 => 2'b00);
        }

    endgroup

    //--------------------------------------------------------------------------
    // Covergroup de duracion de hold
    //--------------------------------------------------------------------------
    covergroup cg_hold_duration with function sample(int unsigned duration);
        option.per_instance = 1;
        option.name         = "cg_hold_duration";

        cp_hold_len: coverpoint duration {
            bins one_cycle    = {1};
            bins short_hold   = {[2:5]};
            bins medium_hold  = {[6:20]};
            bins long_hold    = {[21:$]};
        }
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg_mux4r         = new();
        cg_transitions   = new();
        cg_hold_duration = new();
        hold_count       = 0;
    endfunction

    virtual function void write(mux4_registered_transaction t);
        this.tr = t;
        cg_mux4r.sample();
        cg_transitions.sample();

        if (!t.rst && !t.wr_en) begin
            hold_count++;
        end
        else begin
            if (hold_count > 0) begin
                cg_hold_duration.sample(hold_count);
                hold_count = 0;
            end
        end
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        if (hold_count > 0)
            cg_hold_duration.sample(hold_count);

        `uvm_info("COV",
            $sformatf("Coverage funcional: cg_mux4r=%0.2f%% | cg_transitions=%0.2f%% | cg_hold_duration=%0.2f%%",
                cg_mux4r.get_inst_coverage(),
                cg_transitions.get_inst_coverage(),
                cg_hold_duration.get_inst_coverage()),
            UVM_NONE)
    endfunction

endclass
