//------------------------------------------------------------------------------
// alu_monitor.sv
// Monitor: samplea inputs y outputs del DUT en cada posedge y publica
// la transaccion por el analysis port hacia scoreboard y coverage.
//------------------------------------------------------------------------------
class alu_monitor extends uvm_monitor;

    `uvm_component_utils(alu_monitor)

    virtual alu_if                        vif;
    uvm_analysis_port#(alu_transaction)   ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "No se encontro el vif en el config_db")
    endfunction

    task run_phase(uvm_phase phase);
        alu_transaction tr;
        forever begin
            @(vif.mon_cb);
            // Filtro defensivo: descartar samples con X en cualquier senal.
            // Prevents spurious mismatches en el primer edge antes de que el
            // driver haya escrito valores validos, y protege contra estados X
            // transitorios en general.
            if ($isunknown({vif.mon_cb.in1, vif.mon_cb.in2,
                            vif.mon_cb.op,  vif.mon_cb.invalid_data,
                            vif.mon_cb.out, vif.mon_cb.zero, vif.mon_cb.error}))
                continue;

            tr              = alu_transaction::type_id::create("tr");
            tr.in1          = vif.mon_cb.in1;
            tr.in2          = vif.mon_cb.in2;
            tr.op           = vif.mon_cb.op;
            tr.invalid_data = vif.mon_cb.invalid_data;
            tr.out          = vif.mon_cb.out;
            tr.zero         = vif.mon_cb.zero;
            tr.error        = vif.mon_cb.error;
            ap.write(tr);
        end
    endtask

endclass