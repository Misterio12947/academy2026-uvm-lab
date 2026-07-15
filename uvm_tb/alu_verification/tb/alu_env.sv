//------------------------------------------------------------------------------
// alu_env.sv
// Environment: agent + scoreboard + coverage. Conecta el analysis port
// del monitor a ambos consumidores.
//------------------------------------------------------------------------------
class alu_env extends uvm_env;

    `uvm_component_utils(alu_env)

    alu_agent      agent;
    alu_scoreboard scb;
    alu_coverage   cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = alu_agent::type_id::create("agent", this);
        scb   = alu_scoreboard::type_id::create("scb",   this);
        cov   = alu_coverage::type_id::create("cov",     this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.mon.ap.connect(scb.ap_imp);
        agent.mon.ap.connect(cov.analysis_export);
    endfunction

endclass
