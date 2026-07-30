//------------------------------------------------------------------------------
// top_agent.sv
//------------------------------------------------------------------------------
typedef uvm_sequencer#(top_transaction) top_sequencer;

class top_agent extends uvm_agent;

    `uvm_component_utils(top_agent)

    top_driver     drv;
    top_monitor    mon;
    top_sequencer  sqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = top_monitor::type_id::create("mon", this);
        if (get_is_active() == UVM_ACTIVE) begin
            drv = top_driver::type_id::create("drv", this);
            sqr = top_sequencer::type_id::create("sqr", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (get_is_active() == UVM_ACTIVE)
            drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

endclass
