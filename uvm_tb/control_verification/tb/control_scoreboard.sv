//------------------------------------------------------------------------------
// control_scoreboard.sv
// Reference model: replica EXACTA de la logica Moore del control.sv.
// Para cada transaccion, dado (state_observed, cmd_in, p_error), predice
// todas las salidas y las compara con las del DUT.
//------------------------------------------------------------------------------
`uvm_analysis_imp_decl(_ctrl)

class control_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(control_scoreboard)

    uvm_analysis_imp_ctrl#(control_transaction, control_scoreboard) ap_imp;

    // Estados (matches RTL)
    localparam bit [1:0] RST_ST       = 2'b00;
    localparam bit [1:0] FETCH_DECODE = 2'b01;
    localparam bit [1:0] EXECUTE      = 2'b10;
    localparam bit [1:0] STORE        = 2'b11;

    // ISA opcodes (matches RTL)
    localparam bit [2:0] ISA_ADD   = 3'b000;
    localparam bit [2:0] ISA_SUB   = 3'b001;
    localparam bit [2:0] ISA_MUL   = 3'b010;
    localparam bit [2:0] ISA_DIV   = 3'b011;
    localparam bit [2:0] ISA_NOP0  = 3'b100;
    localparam bit [2:0] ISA_LOAD  = 3'b101;
    localparam bit [2:0] ISA_STORE = 3'b110;
    localparam bit [2:0] ISA_NOP1  = 3'b111;

    int unsigned num_checked;
    int unsigned num_errors;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap_imp      = new("ap_imp", this);
        num_checked = 0;
        num_errors  = 0;
    endfunction

    // Replica de cmd_to_alu_opcode del RTL
    function bit [3:0] ref_opcode(bit [2:0] cmd_op);
        case (cmd_op)
            ISA_ADD: return 4'b0001;
            ISA_SUB: return 4'b0010;
            ISA_MUL: return 4'b0100;
            ISA_DIV: return 4'b1000;
            default: return 4'b0001;   // NOP0/LOAD/STORE/NOP1 -> ADD neutro
        endcase
    endfunction

    // Reference model: replica exacta de la logica de salidas Moore
    function void predict(input  control_transaction tr,
                          output bit exp_aluin, exp_datain, exp_memW, exp_memR,
                          output bit exp_selmux2, exp_cpurdy, exp_aluout, exp_nvalid,
                          output bit [1:0] exp_sela, exp_selb,
                          output bit [3:0] exp_opcode);
        // Defaults (matches RTL)
        exp_aluin   = 1'b0;
        exp_datain  = 1'b0;
        exp_memW    = 1'b0;
        exp_memR    = 1'b0;
        exp_selmux2 = 1'b0;
        exp_cpurdy  = 1'b0;
        exp_aluout  = 1'b0;
        exp_nvalid  = 1'b0;

        // Salidas siempre presentes
        exp_sela   = tr.muxA;
        exp_selb   = tr.muxB;
        exp_opcode = ref_opcode(tr.isa_op);

        case (tr.state_observed)
            RST_ST: begin
                exp_datain = 1'b1;
            end
            FETCH_DECODE: begin
                exp_aluin = 1'b1;
            end
            EXECUTE: begin
                if (tr.isa_op != ISA_STORE &&
                    tr.isa_op != ISA_NOP0  &&
                    tr.isa_op != ISA_NOP1)
                    exp_aluout = 1'b1;

                exp_nvalid = tr.p_error &&
                             ((tr.muxA == 2'b11) || (tr.muxB == 2'b11));

                if (tr.isa_op == ISA_LOAD) begin
                    exp_memR    = 1'b1;
                    exp_selmux2 = 1'b1;
                end
            end
            STORE: begin
                exp_cpurdy  = 1'b1;
                exp_datain  = 1'b1;
                if (tr.isa_op == ISA_STORE)
                    exp_memW = 1'b1;
            end
            default: ;
        endcase
    endfunction

    function void write_ctrl(control_transaction tr);
        bit exp_aluin, exp_datain, exp_memW, exp_memR;
        bit exp_selmux2, exp_cpurdy, exp_aluout, exp_nvalid;
        bit [1:0] exp_sela, exp_selb;
        bit [3:0] exp_opcode;
        bit mismatch;

        predict(tr, exp_aluin, exp_datain, exp_memW, exp_memR,
                exp_selmux2, exp_cpurdy, exp_aluout, exp_nvalid,
                exp_sela, exp_selb, exp_opcode);

        num_checked++;

        mismatch = (tr.aluin_reg_en  !== exp_aluin)   ||
                   (tr.datain_reg_en !== exp_datain)  ||
                   (tr.memoryWrite   !== exp_memW)    ||
                   (tr.memoryRead    !== exp_memR)    ||
                   (tr.selmux2       !== exp_selmux2) ||
                   (tr.cpu_rdy       !== exp_cpurdy)  ||
                   (tr.aluout_reg_en !== exp_aluout)  ||
                   (tr.nvalid_data   !== exp_nvalid)  ||
                   (tr.in_select_a   !== exp_sela)    ||
                   (tr.in_select_b   !== exp_selb)    ||
                   (tr.opcode        !== exp_opcode);

        if (mismatch) begin
            num_errors++;
            `uvm_error("SCB",
                $sformatf({"MISMATCH | state=%0d isa_op=%0d p_error=%0b muxA=%0b muxB=%0b\n",
                           "  DUT: aluin=%0b datain=%0b memW=%0b memR=%0b selmux2=%0b cpurdy=%0b aluout=%0b nvalid=%0b sela=%0b selb=%0b op=%04b\n",
                           "  REF: aluin=%0b datain=%0b memW=%0b memR=%0b selmux2=%0b cpurdy=%0b aluout=%0b nvalid=%0b sela=%0b selb=%0b op=%04b"},
                    tr.state_observed, tr.isa_op, tr.p_error, tr.muxA, tr.muxB,
                    tr.aluin_reg_en, tr.datain_reg_en, tr.memoryWrite, tr.memoryRead,
                    tr.selmux2, tr.cpu_rdy, tr.aluout_reg_en, tr.nvalid_data,
                    tr.in_select_a, tr.in_select_b, tr.opcode,
                    exp_aluin, exp_datain, exp_memW, exp_memR,
                    exp_selmux2, exp_cpurdy, exp_aluout, exp_nvalid,
                    exp_sela, exp_selb, exp_opcode))
        end
        else begin
            `uvm_info("SCB",
                $sformatf("MATCH    | state=%0d isa_op=%0d -> op=%04b aluout=%0b nvalid=%0b",
                    tr.state_observed, tr.isa_op, tr.opcode,
                    tr.aluout_reg_en, tr.nvalid_data),
                UVM_HIGH)
        end
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCB",
            $sformatf("Transacciones verificadas: %0d | Errores: %0d",
                num_checked, num_errors),
            UVM_NONE)
    endfunction

endclass
