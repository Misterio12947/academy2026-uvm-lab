//------------------------------------------------------------------------------
// regbank_test.sv
// Tests del register_bank: base + 4 individuales + regression.
//------------------------------------------------------------------------------

class regbank_base_test extends uvm_test;

    `uvm_component_utils(regbank_base_test)

    regbank_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = regbank_env::type_id::create("env", this);
    endfunction

endclass


class regbank_random_test extends regbank_base_test;

    `uvm_component_utils(regbank_random_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        regbank_seq_rand seq;
        phase.raise_objection(this);
        seq = regbank_seq_rand::type_id::create("seq");
        seq.start(env.agent.sqr);
        #100ns;
        phase.drop_objection(this);
    endtask

endclass


class regbank_directed_test extends regbank_base_test;

    `uvm_component_utils(regbank_directed_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        regbank_directed_seq seq;
        phase.raise_objection(this);
        seq = regbank_directed_seq::type_id::create("seq");
        seq.start(env.agent.sqr);
        #100ns;
        phase.drop_objection(this);
    endtask

endclass


class regbank_reset_test extends regbank_base_test;

    `uvm_component_utils(regbank_reset_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        regbank_reset_seq seq;
        phase.raise_objection(this);
        seq = regbank_reset_seq::type_id::create("seq");
        seq.start(env.agent.sqr);
        #100ns;
        phase.drop_objection(this);
    endtask

endclass


class regbank_coverage_test extends regbank_base_test;

    `uvm_component_utils(regbank_coverage_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        regbank_coverage_seq seq;
        phase.raise_objection(this);
        seq = regbank_coverage_seq::type_id::create("seq");
        seq.start(env.agent.sqr);
        #100ns;
        phase.drop_objection(this);
    endtask

endclass


// Regression: encadena directed + reset + coverage_seq + random
class regbank_regression_test extends regbank_base_test;

    `uvm_component_utils(regbank_regression_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        regbank_directed_seq s_dir;
        regbank_reset_seq    s_rst;
        regbank_coverage_seq s_cov;
        regbank_seq_rand     s_rnd;

        phase.raise_objection(this);

        s_dir = regbank_directed_seq::type_id::create("s_dir");
        s_dir.start(env.agent.sqr);

        s_rst = regbank_reset_seq::type_id::create("s_rst");
        s_rst.start(env.agent.sqr);

        s_cov = regbank_coverage_seq::type_id::create("s_cov");
        s_cov.start(env.agent.sqr);

        s_rnd = regbank_seq_rand::type_id::create("s_rnd");
        s_rnd.start(env.agent.sqr);

        #100ns;
        phase.drop_objection(this);
    endtask

endclass
