//------------------------------------------------------------------------------
// mux4_monitor.sv
// Monitor del mux4. Samplea cada posedge clk y publica la transaccion via
// analysis port hacia scoreboard y coverage.
//------------------------------------------------------------------------------
class mux4_monitor extends uvm_monitor;

    `uvm_component_utils(mux4_monitor)

    virtual mux4_if                        vif;
    uvm_analysis_port#(mux4_transaction)   ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual mux4_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "No se encontro el vif en el config_db")
    endfunction

    task run_phase(uvm_phase phase);
        mux4_transaction tr;
        forever begin
            @(vif.mon_cb);
            // Filtro defensivo: descartar samples con X
            if ($isunknown({vif.mon_cb.din1, vif.mon_cb.din2,
                            vif.mon_cb.din3, vif.mon_cb.din4,
                            vif.mon_cb.select, vif.mon_cb.dout}))
                continue;

            tr        = mux4_transaction::type_id::create("tr");
            tr.din1   = vif.mon_cb.din1;
            tr.din2   = vif.mon_cb.din2;
            tr.din3   = vif.mon_cb.din3;
            tr.din4   = vif.mon_cb.din4;
            tr.select = vif.mon_cb.select;
            tr.dout   = vif.mon_cb.dout;
            ap.write(tr);
        end
    endtask

endclass
