//------------------------------------------------------------------------------
// regbank_env.sv
//------------------------------------------------------------------------------
class regbank_env extends uvm_env;

    `uvm_component_utils(regbank_env)

    regbank_agent      agent;
    regbank_scoreboard scb;
    regbank_coverage   cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = regbank_agent::type_id::create("agent", this);
        scb   = regbank_scoreboard::type_id::create("scb",   this);
        cov   = regbank_coverage::type_id::create("cov",     this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.mon.ap.connect(scb.ap_imp);
        agent.mon.ap.connect(cov.analysis_export);
    endfunction

endclass
