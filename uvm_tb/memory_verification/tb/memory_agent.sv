//------------------------------------------------------------------------------
// memory_agent.sv
//------------------------------------------------------------------------------
typedef uvm_sequencer#(memory_transaction) memory_sequencer;

class memory_agent extends uvm_agent;

    `uvm_component_utils(memory_agent)

    memory_driver     drv;
    memory_monitor    mon;
    memory_sequencer  sqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = memory_monitor::type_id::create("mon", this);
        if (get_is_active() == UVM_ACTIVE) begin
            drv = memory_driver::type_id::create("drv", this);
            sqr = memory_sequencer::type_id::create("sqr", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (get_is_active() == UVM_ACTIVE)
            drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

endclass
