//------------------------------------------------------------------------------
// control_coverage.sv
// 5 covergroups:
//   cg_control          - estados, ISA op, ALU op, muxA, muxB, p_error
//   cg_transitions      - 4 transiciones FSM validas
//   cg_alu_opcode_map   - cross ISA op x ALU opcode (verifica traduccion)
//   cg_error_propagation- p_error x feedback -> nvalid_data
//   cg_reg_enables      - cross ISA op x aluout_reg_en (STORE/NOP dan 0)
//------------------------------------------------------------------------------
class control_coverage extends uvm_subscriber#(control_transaction);

    `uvm_component_utils(control_coverage)

    control_transaction tr;

    bit [1:0] prev_state;
    bit       has_prev;

    covergroup cg_control;
        option.per_instance = 1;
        option.name         = "cg_control";

        cp_state: coverpoint tr.state_observed {
            bins rst_st       = {2'b00};
            bins fetch_decode = {2'b01};
            bins execute      = {2'b10};
            bins store        = {2'b11};
        }

        cp_isa_op: coverpoint tr.isa_op {
            bins add   = {3'b000};
            bins sub   = {3'b001};
            bins mul   = {3'b010};
            bins div   = {3'b011};
            bins nop0  = {3'b100};
            bins load  = {3'b101};
            bins store = {3'b110};
            bins nop1  = {3'b111};
        }

        cp_alu_opcode: coverpoint tr.opcode {
            bins op_add = {4'b0001};
            bins op_sub = {4'b0010};
            bins op_mul = {4'b0100};
            bins op_div = {4'b1000};
        }

        cp_muxA: coverpoint tr.muxA {
            bins sel[] = {[0:3]};
        }

        cp_muxB: coverpoint tr.muxB {
            bins sel[] = {[0:3]};
        }

        cp_p_error: coverpoint tr.p_error {
            bins low  = {1'b0};
            bins high = {1'b1};
        }

        // Cross estado x ISA op: cada instruccion pasa por cada estado
        cx_state_isa: cross cp_state, cp_isa_op;

    endgroup

	covergroup cg_transitions with function sample(bit [1:0] from_st, bit [1:0] to_st);
        option.per_instance = 1;
        option.name         = "cg_transitions";

        cp_trans: coverpoint {from_st, to_st} {
            bins rst_to_fetch     = {4'b00_01};
            bins fetch_to_execute = {4'b01_10};
            bins execute_to_store = {4'b10_11};
            bins store_to_fetch   = {4'b11_01};
            // Transiciones ilegales (nunca en operacion normal sin reset)
            illegal_bins illegal  = {4'b00_10, 4'b00_11,
                                     4'b01_00, 4'b01_11,
                                     4'b10_00, 4'b10_01,
                                     4'b11_00, 4'b11_10};
        }
    endgroup

	covergroup cg_alu_opcode_map;
        option.per_instance = 1;
        option.name         = "cg_alu_opcode_map";

        // Coverpoints PRIMERO
        cp_isa_local: coverpoint tr.isa_op {
            bins add   = {3'b000};
            bins sub   = {3'b001};
            bins mul   = {3'b010};
            bins div   = {3'b011};
            bins nop0  = {3'b100};
            bins load  = {3'b101};
            bins store = {3'b110};
            bins nop1  = {3'b111};
        }

        cp_alu_local: coverpoint tr.opcode {
            bins a_add = {4'b0001};
            bins a_sub = {4'b0010};
            bins a_mul = {4'b0100};
            bins a_div = {4'b1000};
        }

        // Cross DESPUES. Solo nombramos los 8 mappings validos; el resto
        // de combinaciones del cross (24) no se nombran y quedan como
        // "default" del cross, que no cuenta para el 100% de los bins
        // nombrados. Usamos option.cross_auto_bin_max=0 para desactivar
        // los bins automaticos y contar solo los nuestros.
        cp_map: cross cp_isa_local, cp_alu_local {
            option.cross_auto_bin_max = 0;

            bins add_maps   = binsof(cp_isa_local.add)   && binsof(cp_alu_local.a_add);
            bins sub_maps   = binsof(cp_isa_local.sub)   && binsof(cp_alu_local.a_sub);
            bins mul_maps   = binsof(cp_isa_local.mul)   && binsof(cp_alu_local.a_mul);
            bins div_maps   = binsof(cp_isa_local.div)   && binsof(cp_alu_local.a_div);
            bins nop0_maps  = binsof(cp_isa_local.nop0)  && binsof(cp_alu_local.a_add);
            bins load_maps  = binsof(cp_isa_local.load)  && binsof(cp_alu_local.a_add);
            bins store_maps = binsof(cp_isa_local.store) && binsof(cp_alu_local.a_add);
            bins nop1_maps  = binsof(cp_isa_local.nop1)  && binsof(cp_alu_local.a_add);
        }

    endgroup

    covergroup cg_error_propagation;
        option.per_instance = 1;
        option.name         = "cg_error_propagation";

        cp_perror: coverpoint tr.p_error {
            bins low  = {1'b0};
            bins high = {1'b1};
        }

        cp_feedback: coverpoint {(tr.muxA == 2'b11), (tr.muxB == 2'b11)} {
            bins no_feedback   = {2'b00};
            bins muxB_feedback = {2'b01};
            bins muxA_feedback = {2'b10};
            bins both_feedback = {2'b11};
        }

        cp_nvalid: coverpoint tr.nvalid_data {
            bins low  = {1'b0};
            bins high = {1'b1};
        }

        // Cross: solo en EXECUTE nvalid puede ser 1. Verifica que
        // nvalid=1 sii p_error=1 && algun feedback.
        cx_perror_feedback_nvalid: cross cp_perror, cp_feedback, cp_nvalid {
            // nvalid=1 requiere p_error=1 y feedback
            illegal_bins nvalid_sin_perror =
                binsof(cp_nvalid.high) && binsof(cp_perror.low);
            illegal_bins nvalid_sin_feedback =
                binsof(cp_nvalid.high) && binsof(cp_feedback.no_feedback);
        }

    endgroup

	covergroup cg_reg_enables with function sample(bit [2:0] isa, bit aluout, bit [1:0] st);
        option.per_instance = 1;
        option.name         = "cg_reg_enables";

        // Solo se samplea en EXECUTE (filtrado en el write). Verifica el
        // valor de aluout_reg_en para cada opcode:
        //   ADD/SUB/MUL/DIV/LOAD -> aluout=1
        //   STORE/NOP0/NOP1      -> aluout=0
        cp_isa_aluout: coverpoint {isa, aluout} {
            bins add_capture   = {4'b000_1};  // ADD  -> aluout=1
            bins sub_capture   = {4'b001_1};  // SUB  -> aluout=1
            bins mul_capture   = {4'b010_1};  // MUL  -> aluout=1
            bins div_capture   = {4'b011_1};  // DIV  -> aluout=1
            bins nop0_hold     = {4'b100_0};  // NOP0 -> aluout=0
            bins load_capture  = {4'b101_1};  // LOAD -> aluout=1
            bins store_hold    = {4'b110_0};  // STORE-> aluout=0
            bins nop1_hold     = {4'b111_0};  // NOP1 -> aluout=0
            // Cualquier otra combinacion es un bug (ej. STORE con aluout=1)
            illegal_bins wrong = {4'b000_0, 4'b001_0, 4'b010_0, 4'b011_0,
                                  4'b100_1, 4'b101_0, 4'b110_1, 4'b111_1};
        }
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg_control           = new();
        cg_transitions       = new();
        cg_alu_opcode_map    = new();
        cg_error_propagation = new();
        cg_reg_enables       = new();
        has_prev             = 1'b0;
    endfunction

	virtual function void write(control_transaction t);
        this.tr = t;

        cg_control.sample();
        cg_alu_opcode_map.sample();
        cg_error_propagation.sample();

        // cg_reg_enables: solo en EXECUTE (donde aluout_reg_en se decide)
        if (t.state_observed == 2'b10) begin  // EXECUTE
            cg_reg_enables.sample(t.isa_op, t.aluout_reg_en, t.state_observed);
        end

        if (has_prev && !t.first_after_reset) begin
            cg_transitions.sample(prev_state, t.state_observed);
        end
        prev_state = t.state_observed;
        has_prev   = 1'b1;
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("COV",
            $sformatf({"Coverage funcional:\n",
                       "  cg_control=%0.2f%% | cg_transitions=%0.2f%%\n",
                       "  cg_alu_opcode_map=%0.2f%% | cg_error_propagation=%0.2f%%\n",
                       "  cg_reg_enables=%0.2f%%"},
                cg_control.get_inst_coverage(),
                cg_transitions.get_inst_coverage(),
                cg_alu_opcode_map.get_inst_coverage(),
                cg_error_propagation.get_inst_coverage(),
                cg_reg_enables.get_inst_coverage()),
            UVM_NONE)
    endfunction

endclass
