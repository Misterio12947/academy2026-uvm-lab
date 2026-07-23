//------------------------------------------------------------------------------
// mux4_registered_test.sv
//------------------------------------------------------------------------------

class mux4_registered_base_test extends uvm_test;

    `uvm_component_utils(mux4_registered_base_test)

    mux4_registered_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = mux4_registered_env::type_id::create("env", this);
    endfunction

endclass


class mux4_registered_random_test extends mux4_registered_base_test;

    `uvm_component_utils(mux4_registered_random_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        mux4_registered_seq_rand seq;
        phase.raise_objection(this);
        seq = mux4_registered_seq_rand::type_id::create("seq");
        seq.start(env.agent.sqr);
        #100ns;
        phase.drop_objection(this);
    endtask

endclass


class mux4_registered_directed_test extends mux4_registered_base_test;

    `uvm_component_utils(mux4_registered_directed_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        mux4_registered_directed_seq seq;
        phase.raise_objection(this);
        seq = mux4_registered_directed_seq::type_id::create("seq");
        seq.start(env.agent.sqr);
        #100ns;
        phase.drop_objection(this);
    endtask

endclass


class mux4_registered_reset_test extends mux4_registered_base_test;

    `uvm_component_utils(mux4_registered_reset_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        mux4_registered_reset_seq seq;
        phase.raise_objection(this);
        seq = mux4_registered_reset_seq::type_id::create("seq");
        seq.start(env.agent.sqr);
        #100ns;
        phase.drop_objection(this);
    endtask

endclass


class mux4_registered_coverage_test extends mux4_registered_base_test;

    `uvm_component_utils(mux4_registered_coverage_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        mux4_registered_coverage_seq seq;
        phase.raise_objection(this);
        seq = mux4_registered_coverage_seq::type_id::create("seq");
        seq.start(env.agent.sqr);
        #100ns;
        phase.drop_objection(this);
    endtask

endclass


class mux4_registered_regression_test extends mux4_registered_base_test;

    `uvm_component_utils(mux4_registered_regression_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        mux4_registered_directed_seq s_dir;
        mux4_registered_reset_seq    s_rst;
        mux4_registered_coverage_seq s_cov;
        mux4_registered_seq_rand     s_rnd;

        phase.raise_objection(this);

        s_dir = mux4_registered_directed_seq::type_id::create("s_dir");
        s_dir.start(env.agent.sqr);

        s_rst = mux4_registered_reset_seq::type_id::create("s_rst");
        s_rst.start(env.agent.sqr);

        s_cov = mux4_registered_coverage_seq::type_id::create("s_cov");
        s_cov.start(env.agent.sqr);

        s_rnd = mux4_registered_seq_rand::type_id::create("s_rnd");
        s_rnd.start(env.agent.sqr);

        #100ns;
        phase.drop_objection(this);
    endtask

endclass
