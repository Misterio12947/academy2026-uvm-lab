//------------------------------------------------------------------------------
// mux2_registered_env.sv
//------------------------------------------------------------------------------
class mux2_registered_env extends uvm_env;

    `uvm_component_utils(mux2_registered_env)

    mux2_registered_agent      agent;
    mux2_registered_scoreboard scb;
    mux2_registered_coverage   cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = mux2_registered_agent::type_id::create("agent", this);
        scb   = mux2_registered_scoreboard::type_id::create("scb",   this);
        cov   = mux2_registered_coverage::type_id::create("cov",     this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.mon.ap.connect(scb.ap_imp);
        agent.mon.ap.connect(cov.analysis_export);
    endfunction

endclass
