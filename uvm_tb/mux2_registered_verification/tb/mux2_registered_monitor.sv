//------------------------------------------------------------------------------
// mux2_registered_monitor.sv
//------------------------------------------------------------------------------
class mux2_registered_monitor extends uvm_monitor;

    `uvm_component_utils(mux2_registered_monitor)

    virtual mux2_registered_if                         vif;
    uvm_analysis_port#(mux2_registered_transaction)    ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual mux2_registered_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "No se encontro el vif en el config_db")
    endfunction

    task run_phase(uvm_phase phase);
        mux2_registered_transaction tr;
        forever begin
            @(vif.mon_cb);
            if ($isunknown({vif.mon_cb.wr_en, vif.mon_cb.sel,
                            vif.mon_cb.in1, vif.mon_cb.in2,
                            vif.mon_cb.rst, vif.mon_cb.out}))
                continue;

            tr              = mux2_registered_transaction::type_id::create("tr");
            tr.wr_en        = vif.mon_cb.wr_en;
            tr.sel          = vif.mon_cb.sel;
            tr.in1          = vif.mon_cb.in1;
            tr.in2          = vif.mon_cb.in2;
            tr.rst          = vif.mon_cb.rst;
            tr.out          = vif.mon_cb.out;
            tr.assert_reset = 1'b0;
            ap.write(tr);
        end
    endtask

endclass
