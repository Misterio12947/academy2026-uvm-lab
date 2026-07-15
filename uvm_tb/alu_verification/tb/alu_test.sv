//------------------------------------------------------------------------------
// alu_test.sv
// Coleccion de tests: base + random + directed + coverage closure.
//------------------------------------------------------------------------------

// Test base: instancia el env; los tests especificos heredan de este
class alu_base_test extends uvm_test;

    `uvm_component_utils(alu_base_test)

    alu_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = alu_env::type_id::create("env", this);
    endfunction

endclass


// Test aleatorio (500 transacciones)
class alu_random_test extends alu_base_test;

    `uvm_component_utils(alu_random_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        alu_seq_rand seq;
        phase.raise_objection(this);
        seq = alu_seq_rand::type_id::create("seq");
        seq.start(env.agent.sqr);
        #100ns;
        phase.drop_objection(this);
    endtask

endclass


// Test directed (casos borde derivados de la spec)
class alu_directed_test extends alu_base_test;

    `uvm_component_utils(alu_directed_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        alu_directed_seq seq;
        phase.raise_objection(this);
        seq = alu_directed_seq::type_id::create("seq");
        seq.start(env.agent.sqr);
        #100ns;
        phase.drop_objection(this);
    endtask

endclass


// Test de coverage closure (recorre todos los opcodes multiples veces)
class alu_coverage_test extends alu_base_test;

    `uvm_component_utils(alu_coverage_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        alu_coverage_seq seq;
        phase.raise_objection(this);
        seq = alu_coverage_seq::type_id::create("seq");
        seq.start(env.agent.sqr);
        #100ns;
        phase.drop_objection(this);
    endtask

endclass


// Test regresion: encadena directed + coverage_seq + random en un solo run
class alu_regression_test extends alu_base_test;

    `uvm_component_utils(alu_regression_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        alu_directed_seq  s_dir;
        alu_coverage_seq  s_cov;
        alu_seq_rand      s_rnd;

        phase.raise_objection(this);

        s_dir = alu_directed_seq::type_id::create("s_dir");
        s_dir.start(env.agent.sqr);

        s_cov = alu_coverage_seq::type_id::create("s_cov");
        s_cov.start(env.agent.sqr);

        s_rnd = alu_seq_rand::type_id::create("s_rnd");
        s_rnd.start(env.agent.sqr);

        #100ns;
        phase.drop_objection(this);
    endtask

endclass
