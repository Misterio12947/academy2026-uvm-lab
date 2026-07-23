//------------------------------------------------------------------------------
// mux2_registered_agent.sv
//------------------------------------------------------------------------------
typedef uvm_sequencer#(mux2_registered_transaction) mux2_registered_sequencer;

class mux2_registered_agent extends uvm_agent;

    `uvm_component_utils(mux2_registered_agent)

    mux2_registered_driver     drv;
    mux2_registered_monitor    mon;
    mux2_registered_sequencer  sqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = mux2_registered_monitor::type_id::create("mon", this);
        if (get_is_active() == UVM_ACTIVE) begin
            drv = mux2_registered_driver::type_id::create("drv", this);
            sqr = mux2_registered_sequencer::type_id::create("sqr", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (get_is_active() == UVM_ACTIVE)
            drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

endclass
