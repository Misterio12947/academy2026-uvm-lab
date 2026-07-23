//------------------------------------------------------------------------------
// memory_monitor.sv
//------------------------------------------------------------------------------
class memory_monitor extends uvm_monitor;

    `uvm_component_utils(memory_monitor)

    virtual memory_if                        vif;
    uvm_analysis_port#(memory_transaction)   ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual memory_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "No se encontro el vif en el config_db")
    endfunction

    task run_phase(uvm_phase phase);
        memory_transaction tr;
        forever begin
            @(vif.mon_cb);
            if ($isunknown({vif.mon_cb.memoryWrite,
                            vif.mon_cb.memoryRead,
                            vif.mon_cb.memoryAddress,
                            vif.mon_cb.memoryWriteData}))
                continue;

            tr                 = memory_transaction::type_id::create("tr");
            tr.memoryWrite     = vif.mon_cb.memoryWrite;
            tr.memoryRead      = vif.mon_cb.memoryRead;
            tr.memoryAddress   = vif.mon_cb.memoryAddress;
            tr.memoryWriteData = vif.mon_cb.memoryWriteData;
            tr.memoryOutData   = vif.mon_cb.memoryOutData;
            ap.write(tr);
        end
    endtask

endclass
