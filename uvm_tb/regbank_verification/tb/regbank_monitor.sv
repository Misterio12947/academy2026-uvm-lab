//------------------------------------------------------------------------------
// regbank_monitor.sv
// Monitor del register_bank. Samplea cada posedge clk con skew #1 (POST-edge)
// para capturar el resultado ya actualizado en el flip-flop. Publica cada
// sample como una tx via analysis port hacia scoreboard y coverage.
// Filtro $isunknown defensivo contra estados X transitorios.
//------------------------------------------------------------------------------
class regbank_monitor extends uvm_monitor;

    `uvm_component_utils(regbank_monitor)

    virtual regbank_if                         vif;
    uvm_analysis_port#(regbank_transaction)    ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual regbank_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "No se encontro el vif en el config_db")
    endfunction

    task run_phase(uvm_phase phase);
        regbank_transaction tr;
        forever begin
            @(vif.mon_cb);
            if ($isunknown({vif.mon_cb.wr_en, vif.mon_cb.in,
                            vif.mon_cb.rst,   vif.mon_cb.out}))
                continue;

            tr              = regbank_transaction::type_id::create("tr");
            tr.wr_en        = vif.mon_cb.wr_en;
            tr.in           = vif.mon_cb.in;
            tr.rst          = vif.mon_cb.rst;
            tr.out          = vif.mon_cb.out;
            // assert_reset es del sequence item; el monitor no lo conoce.
            tr.assert_reset = 1'b0;
            ap.write(tr);
        end
    endtask

endclass
