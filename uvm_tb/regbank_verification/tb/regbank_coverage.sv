//------------------------------------------------------------------------------
// regbank_coverage.sv
// Coverage funcional del register_bank. Covergroups atados directamente a
// requerimientos de la spec:
//   - Combinaciones de wr_en y rst (cross de 4 bins)
//   - Duracion de hold (ciclos consecutivos con wr_en=0)
//   - Reset durante intento de escritura (wr_en=1 + rst=1)
//   - Rangos de valores escritos
//   - Transiciones criticas: hold -> write, write -> hold, write -> reset
//------------------------------------------------------------------------------
class regbank_coverage extends uvm_subscriber#(regbank_transaction);

    `uvm_component_utils(regbank_coverage)

    regbank_transaction tr;

    // Contador de ciclos consecutivos con wr_en=0 (hold sostenido)
    int unsigned hold_count;

    //--------------------------------------------------------------------------
    // Covergroup principal
    //--------------------------------------------------------------------------
    covergroup cg_regbank;
        option.per_instance = 1;
        option.name         = "cg_regbank";

        cp_wr_en: coverpoint tr.wr_en {
            bins low  = {1'b0};
            bins high = {1'b1};
        }

        cp_rst: coverpoint tr.rst {
            bins low  = {1'b0};
            bins high = {1'b1};
        }

        // Cross de 4 bins: cubre las 4 combinaciones de wr_en x rst.
        // El bin (wr_en=1, rst=1) es el caso "reset durante write" del REQ-CON-01.
        cx_wr_en_rst: cross cp_wr_en, cp_rst;

        // Rangos del valor escrito (in)
        cp_in: coverpoint tr.in iff (tr.wr_en && !tr.rst) {
            bins zero    = {0};
            bins low     = {[1:('h1F)]};
            bins mid     = {[('h20):('hDF)]};
            bins high    = {[('hE0):('hFE)]};
            bins max_val = {'hFF};
        }

        // Rango de out en cualquier momento (verifica que el DUT llega a
        // distintos estados, no solo a 0 o a max)
        cp_out: coverpoint tr.out {
            bins zero    = {0};
            bins low     = {[1:('h1F)]};
            bins mid     = {[('h20):('hDF)]};
            bins high    = {[('hE0):('hFE)]};
            bins max_val = {'hFF};
        }

    endgroup

    //--------------------------------------------------------------------------
    // Covergroup de transiciones (secuenciales - una tras otra)
    //--------------------------------------------------------------------------
    covergroup cg_transitions;
        option.per_instance = 1;
        option.name         = "cg_transitions";

        // Transiciones del par (wr_en, rst) entre ciclos consecutivos.
        // Encapsulado como 2-bit code: {wr_en, rst}
        cp_action: coverpoint {tr.wr_en, tr.rst} {
            bins hold        = {2'b00};
            bins write       = {2'b10};
            bins reset_only  = {2'b01};
            bins reset_write = {2'b11};
        }

        // Transiciones criticas: verifican que el TB ejercita cambios de accion
        // (no solo bloques monolithicos del mismo tipo)
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
    // Covergroup de duracion de hold (para REQ-CON-04)
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
        cg_regbank       = new();
        cg_transitions   = new();
        cg_hold_duration = new();
        hold_count       = 0;
    endfunction

    virtual function void write(regbank_transaction t);
        this.tr = t;
        cg_regbank.sample();
        cg_transitions.sample();

        // Actualizar contador de hold y disparar sample al terminar una racha
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
        // Ultimo grupo de hold que quede abierto
        if (hold_count > 0)
            cg_hold_duration.sample(hold_count);

        `uvm_info("COV",
            $sformatf("Coverage funcional: cg_regbank=%0.2f%% | cg_transitions=%0.2f%% | cg_hold_duration=%0.2f%%",
                cg_regbank.get_inst_coverage(),
                cg_transitions.get_inst_coverage(),
                cg_hold_duration.get_inst_coverage()),
            UVM_NONE)
    endfunction

endclass
