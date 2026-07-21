//------------------------------------------------------------------------------
// mux2_env.sv
//------------------------------------------------------------------------------
class mux2_env extends uvm_env;

    `uvm_component_utils(mux2_env)

    mux2_agent      agent;
    mux2_scoreboard scb;
    mux2_coverage   cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = mux2_agent::type_id::create("agent", this);
        scb   = mux2_scoreboard::type_id::create("scb",   this);
        cov   = mux2_coverage::type_id::create("cov",     this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.mon.ap.connect(scb.ap_imp);
        agent.mon.ap.connect(cov.analysis_export);
    endfunction

endclass
