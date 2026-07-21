//------------------------------------------------------------------------------
// mux4_coverage.sv
// Componente de coverage funcional. Extiende uvm_subscriber y muestrea
// covergroups atados a la spec del mux4:
//   - cp_select: 4 bins (uno por cada valor de select)
//   - cp_din1..cp_din4: rangos zero/low/mid/high/max
//   - cp_dout: rangos zero/low/mid/high/max
//   - Cross cp_select x cp_dout: verifica que cada select produce salidas
//     en todos los rangos
//   - Edge cases: cada select con din_seleccionado en valores extremos
//     (0x00 y 0xFF) para asegurar propagacion end-to-end
//------------------------------------------------------------------------------
class mux4_coverage extends uvm_subscriber#(mux4_transaction);

    `uvm_component_utils(mux4_coverage)

    mux4_transaction tr;

    //--------------------------------------------------------------------------
    // Covergroup principal
    //--------------------------------------------------------------------------
    covergroup cg_mux4;
        option.per_instance = 1;
        option.name         = "cg_mux4";

        // Cada valor de select (4 bins)
        cp_select: coverpoint tr.select {
            bins sel_din1 = {2'b00};
            bins sel_din2 = {2'b01};
            bins sel_din3 = {2'b10};
            bins sel_din4 = {2'b11};
        }

        // Rangos de cada entrada
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

        cp_din3: coverpoint tr.din3 {
            bins zero    = {0};
            bins low     = {[1:('h1F)]};
            bins mid     = {[('h20):('hDF)]};
            bins high    = {[('hE0):('hFE)]};
            bins max_val = {'hFF};
        }

        cp_din4: coverpoint tr.din4 {
            bins zero    = {0};
            bins low     = {[1:('h1F)]};
            bins mid     = {[('h20):('hDF)]};
            bins high    = {[('hE0):('hFE)]};
            bins max_val = {'hFF};
        }

        // Rangos de la salida
        cp_dout: coverpoint tr.dout {
            bins zero    = {0};
            bins low     = {[1:('h1F)]};
            bins mid     = {[('h20):('hDF)]};
            bins high    = {[('hE0):('hFE)]};
            bins max_val = {'hFF};
        }

        // Cross: cada select debe producir salidas en todos los rangos
        cx_select_dout: cross cp_select, cp_dout;

    endgroup

    //--------------------------------------------------------------------------
    // Covergroup de casos borde: cada select con din seleccionado en extremos
    //--------------------------------------------------------------------------
    covergroup cg_edge_cases;
        option.per_instance = 1;
        option.name         = "cg_edge_cases";

        // Cada select con din seleccionado en 0x00
        cp_select_din_zero: coverpoint {tr.select, tr.dout == '0} {
            bins sel00_dout_zero = {3'b00_1};
            bins sel01_dout_zero = {3'b01_1};
            bins sel10_dout_zero = {3'b10_1};
            bins sel11_dout_zero = {3'b11_1};
        }

        // Cada select con din seleccionado en 0xFF
        cp_select_din_max: coverpoint {tr.select, tr.dout == 8'hFF} {
            bins sel00_dout_max = {3'b00_1};
            bins sel01_dout_max = {3'b01_1};
            bins sel10_dout_max = {3'b10_1};
            bins sel11_dout_max = {3'b11_1};
        }

    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg_mux4       = new();
        cg_edge_cases = new();
    endfunction

    virtual function void write(mux4_transaction t);
        this.tr = t;
        cg_mux4.sample();
        cg_edge_cases.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("COV",
            $sformatf("Coverage funcional: cg_mux4=%0.2f%% | cg_edge_cases=%0.2f%%",
                cg_mux4.get_inst_coverage(),
                cg_edge_cases.get_inst_coverage()),
            UVM_NONE)
    endfunction

endclass
