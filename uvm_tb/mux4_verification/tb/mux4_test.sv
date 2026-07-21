//------------------------------------------------------------------------------
// mux4_test.sv
// Tests del mux4: base + 3 individuales + regression.
//------------------------------------------------------------------------------

class mux4_base_test extends uvm_test;

    `uvm_component_utils(mux4_base_test)

    mux4_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = mux4_env::type_id::create("env", this);
    endfunction

endclass


class mux4_random_test extends mux4_base_test;

    `uvm_component_utils(mux4_random_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        mux4_seq_rand seq;
        phase.raise_objection(this);
        seq = mux4_seq_rand::type_id::create("seq");
        seq.start(env.agent.sqr);
        #100ns;
        phase.drop_objection(this);
    endtask

endclass


class mux4_directed_test extends mux4_base_test;

    `uvm_component_utils(mux4_directed_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        mux4_directed_seq seq;
        phase.raise_objection(this);
        seq = mux4_directed_seq::type_id::create("seq");
        seq.start(env.agent.sqr);
        #100ns;
        phase.drop_objection(this);
    endtask

endclass


class mux4_coverage_test extends mux4_base_test;

    `uvm_component_utils(mux4_coverage_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        mux4_coverage_seq seq;
        phase.raise_objection(this);
        seq = mux4_coverage_seq::type_id::create("seq");
        seq.start(env.agent.sqr);
        #100ns;
        phase.drop_objection(this);
    endtask

endclass


// Regression: encadena directed + coverage_seq + random
class mux4_regression_test extends mux4_base_test;

    `uvm_component_utils(mux4_regression_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        mux4_directed_seq s_dir;
        mux4_coverage_seq s_cov;
        mux4_seq_rand     s_rnd;

        phase.raise_objection(this);

        s_dir = mux4_directed_seq::type_id::create("s_dir");
        s_dir.start(env.agent.sqr);

        s_cov = mux4_coverage_seq::type_id::create("s_cov");
        s_cov.start(env.agent.sqr);

        s_rnd = mux4_seq_rand::type_id::create("s_rnd");
        s_rnd.start(env.agent.sqr);

        #100ns;
        phase.drop_objection(this);
    endtask

endclass
