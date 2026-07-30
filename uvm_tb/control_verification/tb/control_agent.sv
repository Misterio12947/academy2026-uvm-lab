//------------------------------------------------------------------------------
// control_agent.sv
//------------------------------------------------------------------------------
typedef uvm_sequencer#(control_transaction) control_sequencer;

class control_agent extends uvm_agent;

    `uvm_component_utils(control_agent)

    control_driver     drv;
    control_monitor    mon;
    control_sequencer  sqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = control_monitor::type_id::create("mon", this);
        if (get_is_active() == UVM_ACTIVE) begin
            drv = control_driver::type_id::create("drv", this);
            sqr = control_sequencer::type_id::create("sqr", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (get_is_active() == UVM_ACTIVE)
            drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

endclass
