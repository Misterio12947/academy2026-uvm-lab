//------------------------------------------------------------------------------
// memory_env.sv
//------------------------------------------------------------------------------
class memory_env extends uvm_env;

    `uvm_component_utils(memory_env)

    memory_agent      agent;
    memory_scoreboard scb;
    memory_coverage   cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = memory_agent::type_id::create("agent", this);
        scb   = memory_scoreboard::type_id::create("scb",   this);
        cov   = memory_coverage::type_id::create("cov",     this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.mon.ap.connect(scb.ap_imp);
        agent.mon.ap.connect(cov.analysis_export);
    endfunction

endclass
