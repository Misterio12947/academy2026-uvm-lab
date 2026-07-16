//------------------------------------------------------------------------------
// regbank_agent.sv
//------------------------------------------------------------------------------
typedef uvm_sequencer#(regbank_transaction) regbank_sequencer;

class regbank_agent extends uvm_agent;

    `uvm_component_utils(regbank_agent)

    regbank_driver     drv;
    regbank_monitor    mon;
    regbank_sequencer  sqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = regbank_monitor::type_id::create("mon", this);
        if (get_is_active() == UVM_ACTIVE) begin
            drv = regbank_driver::type_id::create("drv", this);
            sqr = regbank_sequencer::type_id::create("sqr", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (get_is_active() == UVM_ACTIVE)
            drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

endclass
