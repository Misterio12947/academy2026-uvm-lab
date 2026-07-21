//------------------------------------------------------------------------------
// mux4_env.sv
//------------------------------------------------------------------------------
class mux4_env extends uvm_env;

    `uvm_component_utils(mux4_env)

    mux4_agent      agent;
    mux4_scoreboard scb;
    mux4_coverage   cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = mux4_agent::type_id::create("agent", this);
        scb   = mux4_scoreboard::type_id::create("scb",   this);
        cov   = mux4_coverage::type_id::create("cov",     this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.mon.ap.connect(scb.ap_imp);
        agent.mon.ap.connect(cov.analysis_export);
    endfunction

endclass
