//------------------------------------------------------------------------------
// alu_scoreboard.sv
// Reference model per encoding one-hot. Predice out/zero/error y compara.
//------------------------------------------------------------------------------
`uvm_analysis_imp_decl(_alu)

class alu_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(alu_scoreboard)

    uvm_analysis_imp_alu#(alu_transaction, alu_scoreboard) ap_imp;

    // Encoding one-hot (matches RTL)
    localparam logic [3:0] OP_NOP = 4'b0000;
    localparam logic [3:0] OP_ADD = 4'b0001;
    localparam logic [3:0] OP_SUB = 4'b0010;
    localparam logic [3:0] OP_MUL = 4'b0100;
    localparam logic [3:0] OP_DIV = 4'b1000;

    localparam logic [2*WIDTH-1:0] MINUS_ONE = {(2*WIDTH){1'b1}};

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

    // Reference model: replica exacta de la logica del RTL
    function void predict(input  bit [WIDTH-1:0]     i1, i2,
                          input  bit [3:0]           op,
                          input  bit                 invalid_data,
                          output bit [2*WIDTH-1:0]   exp_out,
                          output bit                 exp_zero,
                          output bit                 exp_error);
        exp_out   = '0;
        exp_zero  = 1'b0;
        exp_error = 1'b0;

        if (invalid_data) begin
            exp_error = 1'b1;
            exp_out   = MINUS_ONE;
            exp_zero  = 1'b0;
        end
        else begin
            case (op)
                OP_NOP: begin
                    exp_out   = '0;
                    exp_zero  = 1'b1;
                    exp_error = 1'b0;
                end
                OP_ADD: begin
                    exp_out  = i1 + i2;
                    exp_zero = (exp_out == '0);
                end
                OP_SUB: begin
                    exp_out  = i1 - i2;
                    exp_zero = (exp_out == '0);
                end
                OP_MUL: begin
                    exp_out  = i1 * i2;
                    exp_zero = (exp_out == '0);
                end
                OP_DIV: begin
                    if (i2 == '0) begin
                        exp_error = 1'b1;
                        exp_out   = MINUS_ONE;
                        exp_zero  = 1'b0;
                    end
                    else begin
                        exp_out  = i1 / i2;
                        exp_zero = (exp_out == '0);
                    end
                end
                default: begin
                    // op multi-hot: se trata como error de codificacion
                    exp_out   = MINUS_ONE;
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
                $sformatf("MISMATCH | op=%04b in1=%0h in2=%0h invalid=%0b || DUT: out=%0h zero=%0b error=%0b || REF: exp_out=%0h exp_zero=%0b exp_error=%0b",
                    tr.op, tr.in1, tr.in2, tr.invalid_data,
                    tr.out, tr.zero, tr.error,
                    exp_out, exp_zero, exp_error))
        end
        else begin
            `uvm_info("SCB",
                $sformatf("MATCH    | op=%04b in1=%0h in2=%0h -> out=%0h zero=%0b error=%0b",
                    tr.op, tr.in1, tr.in2,
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