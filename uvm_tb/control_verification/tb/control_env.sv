//------------------------------------------------------------------------------
// control_env.sv
//------------------------------------------------------------------------------
class control_env extends uvm_env;

    `uvm_component_utils(control_env)

    control_agent      agent;
    control_scoreboard scb;
    control_coverage   cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = control_agent::type_id::create("agent", this);
        scb   = control_scoreboard::type_id::create("scb", this);
        cov   = control_coverage::type_id::create("cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.mon.ap.connect(scb.ap_imp);
        agent.mon.ap.connect(cov.analysis_export);
    endfunction

endclass
