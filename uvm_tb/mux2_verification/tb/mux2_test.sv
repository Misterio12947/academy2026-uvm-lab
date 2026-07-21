//------------------------------------------------------------------------------
// mux2_test.sv
//------------------------------------------------------------------------------

class mux2_base_test extends uvm_test;

    `uvm_component_utils(mux2_base_test)

    mux2_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = mux2_env::type_id::create("env", this);
    endfunction

endclass


class mux2_random_test extends mux2_base_test;

    `uvm_component_utils(mux2_random_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        mux2_seq_rand seq;
        phase.raise_objection(this);
        seq = mux2_seq_rand::type_id::create("seq");
        seq.start(env.agent.sqr);
        #100ns;
        phase.drop_objection(this);
    endtask

endclass


class mux2_directed_test extends mux2_base_test;

    `uvm_component_utils(mux2_directed_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        mux2_directed_seq seq;
        phase.raise_objection(this);
        seq = mux2_directed_seq::type_id::create("seq");
        seq.start(env.agent.sqr);
        #100ns;
        phase.drop_objection(this);
    endtask

endclass


class mux2_coverage_test extends mux2_base_test;

    `uvm_component_utils(mux2_coverage_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        mux2_coverage_seq seq;
        phase.raise_objection(this);
        seq = mux2_coverage_seq::type_id::create("seq");
        seq.start(env.agent.sqr);
        #100ns;
        phase.drop_objection(this);
    endtask

endclass


class mux2_regression_test extends mux2_base_test;

    `uvm_component_utils(mux2_regression_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        mux2_directed_seq s_dir;
        mux2_coverage_seq s_cov;
        mux2_seq_rand     s_rnd;

        phase.raise_objection(this);

        s_dir = mux2_directed_seq::type_id::create("s_dir");
        s_dir.start(env.agent.sqr);

        s_cov = mux2_coverage_seq::type_id::create("s_cov");
        s_cov.start(env.agent.sqr);

        s_rnd = mux2_seq_rand::type_id::create("s_rnd");
        s_rnd.start(env.agent.sqr);

        #100ns;
        phase.drop_objection(this);
    endtask

endclass
