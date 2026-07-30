//------------------------------------------------------------------------------
// top_test.sv
//------------------------------------------------------------------------------

class top_base_test extends uvm_test;

    `uvm_component_utils(top_base_test)

    top_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = top_env::type_id::create("env", this);
    endfunction

endclass


class top_sanity_test extends top_base_test;

    `uvm_component_utils(top_sanity_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        top_sanity_seq seq;
        phase.raise_objection(this);
        seq = top_sanity_seq::type_id::create("seq");
        seq.start(env.agent.sqr);
        #200ns;
        phase.drop_objection(this);
    endtask

endclass
