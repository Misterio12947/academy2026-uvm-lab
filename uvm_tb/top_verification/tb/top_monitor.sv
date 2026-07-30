//------------------------------------------------------------------------------
// top_monitor.sv
// Samplea en cada cpu_rdy=1. Emite el cmd_in visible y el dout visible.
// IMPORTANTE: por la latencia de 1 instruccion del pipeline (ver
// docs/PIPELINE_TIMING.md), el dout observado corresponde a la instruccion
// ANTERIOR, no a la del cmd_in visible. El scoreboard maneja esa alineacion
// con un buffer de latencia 1.
//------------------------------------------------------------------------------
class top_monitor extends uvm_monitor;

    `uvm_component_utils(top_monitor)

    virtual top_if                        vif;
    uvm_analysis_port#(top_transaction)   ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual top_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "No se encontro el vif en el config_db")
    endfunction

    task run_phase(uvm_phase phase);
        top_transaction tr;

        forever begin
            @(vif.mon_cb);

            if (vif.mon_cb.rst)
                continue;

            if (vif.mon_cb.cpu_rdy) begin
                tr = top_transaction::type_id::create("tr");

                // cmd_in visible (la instruccion que se presenta ahora)
                tr.muxA   = vif.mon_cb.cmd_in[6:5];
                tr.muxB   = vif.mon_cb.cmd_in[4:3];
                tr.isa_op = vif.mon_cb.cmd_in[2:0];
                tr.din_1  = vif.mon_cb.din_1;
                tr.din_2  = vif.mon_cb.din_2;
                tr.din_3  = vif.mon_cb.din_3;

                // dout visible (resultado de la instruccion ANTERIOR)
                tr.dout_low  = vif.mon_cb.dout_low;
                tr.dout_high = vif.mon_cb.dout_high;
                tr.cpu_rdy   = vif.mon_cb.cpu_rdy;
                tr.zero      = vif.mon_cb.zero;
                tr.error     = vif.mon_cb.error;

                ap.write(tr);
            end
        end
    endtask

endclass