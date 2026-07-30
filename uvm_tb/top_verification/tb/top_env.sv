//------------------------------------------------------------------------------
// top_env.sv
//------------------------------------------------------------------------------
class top_env extends uvm_env;

    `uvm_component_utils(top_env)

    top_agent      agent;
    top_scoreboard scb;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = top_agent::type_id::create("agent", this);
        scb   = top_scoreboard::type_id::create("scb", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.mon.ap.connect(scb.ap_imp);
    endfunction

endclass
