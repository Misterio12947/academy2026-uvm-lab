//------------------------------------------------------------------------------
// mux2_coverage.sv
// Coverage funcional del mux2:
//   - cp_select: 2 bins (uno por cada valor de select)
//   - cp_din1, cp_din2: rangos zero/low/mid/high/max
//   - cp_dout: rangos zero/low/mid/high/max
//   - Cross cp_select x cp_dout: 10 bins
//   - Edge cases: cada select con din_seleccionado en 0x00 y 0xFF (4 bins)
//------------------------------------------------------------------------------
class mux2_coverage extends uvm_subscriber#(mux2_transaction);

    `uvm_component_utils(mux2_coverage)

    mux2_transaction tr;

    covergroup cg_mux2;
        option.per_instance = 1;
        option.name         = "cg_mux2";

        cp_select: coverpoint tr.select {
            bins sel_din1 = {1'b0};
            bins sel_din2 = {1'b1};
        }

        cp_din1: coverpoint tr.din1 {
            bins zero    = {0};
            bins low     = {[1:('h1F)]};
            bins mid     = {[('h20):('hDF)]};
            bins high    = {[('hE0):('hFE)]};
            bins max_val = {'hFF};
        }

        cp_din2: coverpoint tr.din2 {
            bins zero    = {0};
            bins low     = {[1:('h1F)]};
            bins mid     = {[('h20):('hDF)]};
            bins high    = {[('hE0):('hFE)]};
            bins max_val = {'hFF};
        }

        cp_dout: coverpoint tr.dout {
            bins zero    = {0};
            bins low     = {[1:('h1F)]};
            bins mid     = {[('h20):('hDF)]};
            bins high    = {[('hE0):('hFE)]};
            bins max_val = {'hFF};
        }

        cx_select_dout: cross cp_select, cp_dout;

    endgroup

    covergroup cg_edge_cases;
        option.per_instance = 1;
        option.name         = "cg_edge_cases";

        // Cada select con din seleccionado en 0x00 (2 bins)
        cp_select_din_zero: coverpoint {tr.select, tr.dout == '0} {
            bins sel0_dout_zero = {2'b0_1};
            bins sel1_dout_zero = {2'b1_1};
        }

        // Cada select con din seleccionado en 0xFF (2 bins)
        cp_select_din_max: coverpoint {tr.select, tr.dout == 8'hFF} {
            bins sel0_dout_max = {2'b0_1};
            bins sel1_dout_max = {2'b1_1};
        }

    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg_mux2       = new();
        cg_edge_cases = new();
    endfunction

    virtual function void write(mux2_transaction t);
        this.tr = t;
        cg_mux2.sample();
        cg_edge_cases.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("COV",
            $sformatf("Coverage funcional: cg_mux2=%0.2f%% | cg_edge_cases=%0.2f%%",
                cg_mux2.get_inst_coverage(),
                cg_edge_cases.get_inst_coverage()),
            UVM_NONE)
    endfunction

endclass
