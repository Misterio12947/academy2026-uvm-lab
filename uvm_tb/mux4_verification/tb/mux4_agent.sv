//------------------------------------------------------------------------------
// mux4_agent.sv
//------------------------------------------------------------------------------
typedef uvm_sequencer#(mux4_transaction) mux4_sequencer;

class mux4_agent extends uvm_agent;

    `uvm_component_utils(mux4_agent)

    mux4_driver     drv;
    mux4_monitor    mon;
    mux4_sequencer  sqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = mux4_monitor::type_id::create("mon", this);
        if (get_is_active() == UVM_ACTIVE) begin
            drv = mux4_driver::type_id::create("drv", this);
            sqr = mux4_sequencer::type_id::create("sqr", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (get_is_active() == UVM_ACTIVE)
            drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

endclass
