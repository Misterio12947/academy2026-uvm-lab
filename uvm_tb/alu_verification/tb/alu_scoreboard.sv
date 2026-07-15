//------------------------------------------------------------------------------
// alu_scoreboard.sv
// Scoreboard con reference model. Predice out/zero/error segun spec del lab
// y compara contra lo observado por el monitor.
//------------------------------------------------------------------------------
`uvm_analysis_imp_decl(_alu)

class alu_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(alu_scoreboard)

    uvm_analysis_imp_alu#(alu_transaction, alu_scoreboard) ap_imp;

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

    // Reference model: replica exacta de la spec del ALU
    function void predict(input  bit [WIDTH-1:0]   in1,
                          input  bit [WIDTH-1:0]   in2,
                          input  bit [3:0]         op,
                          input  bit               invalid_data,
                          output bit [2*WIDTH-1:0] exp_out,
                          output bit               exp_zero,
                          output bit               exp_error);
        bit [2*WIDTH-1:0] minus_one;
        minus_one = {(2*WIDTH){1'b1}};

        exp_out   = '0;
        exp_zero  = 1'b0;
        exp_error = 1'b0;

        if (invalid_data) begin
            exp_error = 1'b1;
            exp_out   = minus_one;
            exp_zero  = 1'b0;
        end
        else begin
            case (op[2:0])
                3'b000: begin exp_out = in1 + in2;   exp_zero = (exp_out == '0); end // ADD
                3'b001: begin exp_out = in1 - in2;   exp_zero = (exp_out == '0); end // SUB
                3'b010: begin exp_out = in1 * in2;   exp_zero = (exp_out == '0); end // MUL
                3'b011: begin                                                        // DIV
                    if (in2 == '0) begin
                        exp_error = 1'b1;
                        exp_out   = minus_one;
                        exp_zero  = 1'b0;
                    end
                    else begin
                        exp_out  = in1 / in2;
                        exp_zero = (exp_out == '0);
                    end
                end
                3'b101,                                                             // LOAD
                3'b110: begin exp_out = in2;         exp_zero = (exp_out == '0); end // STORE
                3'b100,                                                             // NOP
                3'b111: begin exp_out = '0;          exp_zero = 1'b1;            end // NOP
                default: begin
                    exp_out   = minus_one;
                    exp_zero  = 1'b0;
                    exp_error = 1'b1;
                end
            endcase
        end
    endfunction

    function void write_alu(alu_transaction tr);
        bit [2*WIDTH-1:0] exp_out;
        bit               exp_zero;
        bit               exp_error;

        predict(tr.in1, tr.in2, tr.op, tr.invalid_data,
                exp_out, exp_zero, exp_error);

        num_checked++;

        if ((tr.out !== exp_out) || (tr.zero !== exp_zero) || (tr.error !== exp_error)) begin
            num_errors++;
            `uvm_error("SCB",
                $sformatf("MISMATCH | in1=%0h in2=%0h op=%0b invalid=%0b || DUT: out=%0h zero=%0b err=%0b || REF: out=%0h zero=%0b err=%0b",
                    tr.in1, tr.in2, tr.op, tr.invalid_data,
                    tr.out,  tr.zero,  tr.error,
                    exp_out, exp_zero, exp_error))
        end
        else begin
            `uvm_info("SCB",
                $sformatf("MATCH    | in1=%0h in2=%0h op=%0b invalid=%0b -> out=%0h zero=%0b err=%0b",
                    tr.in1, tr.in2, tr.op, tr.invalid_data,
                    tr.out, tr.zero, tr.error),
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
