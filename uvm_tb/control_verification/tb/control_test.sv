//------------------------------------------------------------------------------
// control_test.sv
//------------------------------------------------------------------------------

class control_base_test extends uvm_test;

    `uvm_component_utils(control_base_test)

    control_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = control_env::type_id::create("env", this);
    endfunction

endclass


class control_random_test extends control_base_test;

    `uvm_component_utils(control_random_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        control_seq_rand seq;
        phase.raise_objection(this);
        seq = control_seq_rand::type_id::create("seq");
        seq.start(env.agent.sqr);
        #100ns;
        phase.drop_objection(this);
    endtask

endclass


class control_directed_test extends control_base_test;

    `uvm_component_utils(control_directed_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        control_directed_seq seq;
        phase.raise_objection(this);
        seq = control_directed_seq::type_id::create("seq");
        seq.start(env.agent.sqr);
        #100ns;
        phase.drop_objection(this);
    endtask

endclass


class control_opcode_sweep_test extends control_base_test;

    `uvm_component_utils(control_opcode_sweep_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        control_opcode_sweep_seq seq;
        phase.raise_objection(this);
        seq = control_opcode_sweep_seq::type_id::create("seq");
        seq.start(env.agent.sqr);
        #100ns;
        phase.drop_objection(this);
    endtask

endclass


class control_reset_test extends control_base_test;

    `uvm_component_utils(control_reset_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        control_reset_seq seq;
        phase.raise_objection(this);
        seq = control_reset_seq::type_id::create("seq");
        seq.start(env.agent.sqr);
        #100ns;
        phase.drop_objection(this);
    endtask

endclass


class control_coverage_test extends control_base_test;

    `uvm_component_utils(control_coverage_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        control_coverage_seq seq;
        phase.raise_objection(this);
        seq = control_coverage_seq::type_id::create("seq");
        seq.start(env.agent.sqr);
        #100ns;
        phase.drop_objection(this);
    endtask

endclass


class control_regression_test extends control_base_test;

    `uvm_component_utils(control_regression_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        control_directed_seq      s_dir;
        control_opcode_sweep_seq  s_swp;
        control_reset_seq         s_rst;
        control_coverage_seq      s_cov;
        control_seq_rand          s_rnd;

        phase.raise_objection(this);

        s_dir = control_directed_seq::type_id::create("s_dir");
        s_dir.start(env.agent.sqr);

        s_swp = control_opcode_sweep_seq::type_id::create("s_swp");
        s_swp.start(env.agent.sqr);

        s_rst = control_reset_seq::type_id::create("s_rst");
        s_rst.start(env.agent.sqr);

        s_cov = control_coverage_seq::type_id::create("s_cov");
        s_cov.start(env.agent.sqr);

        s_rnd = control_seq_rand::type_id::create("s_rnd");
        s_rnd.start(env.agent.sqr);

        #100ns;
        phase.drop_objection(this);
    endtask

endclass
