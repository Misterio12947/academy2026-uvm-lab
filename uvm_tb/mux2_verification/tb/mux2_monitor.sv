//------------------------------------------------------------------------------
// mux2_monitor.sv
//------------------------------------------------------------------------------
class mux2_monitor extends uvm_monitor;

    `uvm_component_utils(mux2_monitor)

    virtual mux2_if                        vif;
    uvm_analysis_port#(mux2_transaction)   ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual mux2_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "No se encontro el vif en el config_db")
    endfunction

    task run_phase(uvm_phase phase);
        mux2_transaction tr;
        forever begin
            @(vif.mon_cb);
            if ($isunknown({vif.mon_cb.din1, vif.mon_cb.din2,
                            vif.mon_cb.select, vif.mon_cb.dout}))
                continue;

            tr        = mux2_transaction::type_id::create("tr");
            tr.din1   = vif.mon_cb.din1;
            tr.din2   = vif.mon_cb.din2;
            tr.select = vif.mon_cb.select;
            tr.dout   = vif.mon_cb.dout;
            ap.write(tr);
        end
    endtask

endclass
