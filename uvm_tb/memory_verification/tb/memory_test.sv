//------------------------------------------------------------------------------
// memory_test.sv
//------------------------------------------------------------------------------

class memory_base_test extends uvm_test;

    `uvm_component_utils(memory_base_test)

    memory_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = memory_env::type_id::create("env", this);
    endfunction

endclass


class memory_random_test extends memory_base_test;

    `uvm_component_utils(memory_random_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        memory_write_all_seq s_init;
        memory_seq_rand      s_rnd;

        phase.raise_objection(this);

        // Popular direcciones primero para que los reads aleatorios verifiquen
        s_init = memory_write_all_seq::type_id::create("s_init");
        s_init.start(env.agent.sqr);

        s_rnd = memory_seq_rand::type_id::create("s_rnd");
        s_rnd.start(env.agent.sqr);

        #100ns;
        phase.drop_objection(this);
    endtask

endclass


class memory_directed_test extends memory_base_test;

    `uvm_component_utils(memory_directed_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        memory_directed_seq seq;
        phase.raise_objection(this);
        seq = memory_directed_seq::type_id::create("seq");
        seq.start(env.agent.sqr);
        #100ns;
        phase.drop_objection(this);
    endtask

endclass


class memory_coverage_test extends memory_base_test;

    `uvm_component_utils(memory_coverage_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        memory_coverage_seq seq;
        phase.raise_objection(this);
        seq = memory_coverage_seq::type_id::create("seq");
        seq.start(env.agent.sqr);
        #100ns;
        phase.drop_objection(this);
    endtask

endclass


class memory_regression_test extends memory_base_test;

    `uvm_component_utils(memory_regression_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        memory_write_all_seq s_init;
        memory_directed_seq  s_dir;
        memory_coverage_seq  s_cov;
        memory_seq_rand      s_rnd;

        phase.raise_objection(this);

        s_init = memory_write_all_seq::type_id::create("s_init");
        s_init.start(env.agent.sqr);

        s_dir = memory_directed_seq::type_id::create("s_dir");
        s_dir.start(env.agent.sqr);

        s_cov = memory_coverage_seq::type_id::create("s_cov");
        s_cov.start(env.agent.sqr);

        s_rnd = memory_seq_rand::type_id::create("s_rnd");
        s_rnd.start(env.agent.sqr);

        #100ns;
        phase.drop_objection(this);
    endtask

endclass
