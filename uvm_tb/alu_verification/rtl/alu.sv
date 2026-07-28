//------------------------------------------------------------------------------
// alu.sv
// ALU parametrizada per lab spec (op 4 bits, out 2*WIDTH, -1 en error).
//
// Encoding del opcode: ONE-HOT sobre 4 bits (cada operacion es un bit).
//   4'b0000 = NOP     (ALU pasiva - usado por FSM en LOAD/STORE/NOP)
//   4'b0001 = ADD     (op[0]=1)
//   4'b0010 = SUB     (op[1]=1)
//   4'b0100 = MUL     (op[2]=1)
//   4'b1000 = DIV     (op[3]=1)
//
// Cualquier op multi-hot (0011, 0101, 0110, ..., 1111) es un error de
// codificacion y se maneja en el default como salida forzada -1 + error=1.
// En operacion normal, la FSM NUNCA envia multi-hot; el default existe
// como defensa contra corrupcion de X en simulacion.
//------------------------------------------------------------------------------
module ALU #(
    parameter WIDTH = 8
) (
    input  logic [WIDTH-1:0]     in1, in2,
    input  logic [3:0]           op,
    input  logic                 invalid_data,
    output logic [2*WIDTH-1:0]   out,
    output logic                 zero,
    output logic                 error
);

    // -1 en 2*WIDTH bits = all-ones (complemento a dos)
    localparam logic [2*WIDTH-1:0] MINUS_ONE = {(2*WIDTH){1'b1}};

    // Encoding one-hot del opcode (per lab spec y feedback del revisor)
    localparam logic [3:0] OP_NOP = 4'b0000;
    localparam logic [3:0] OP_ADD = 4'b0001;
    localparam logic [3:0] OP_SUB = 4'b0010;
    localparam logic [3:0] OP_MUL = 4'b0100;
    localparam logic [3:0] OP_DIV = 4'b1000;

    always_comb begin
        // Defaults defensivos: previenen latches inferidos
        out   = '0;
        zero  = 1'b0;
        error = 1'b0;

        if (invalid_data) begin
            error = 1'b1;
            out   = MINUS_ONE;
            zero  = 1'b0;
        end
        else begin
            unique case (op)
                OP_NOP: begin
                    // ALU pasiva: FSM envia 0000 en LOAD, STORE, NOP0, NOP1
                    out   = '0;
                    zero  = 1'b1;
                    error = 1'b0;
                end
                OP_ADD: begin
                    out  = in1 + in2;
                    zero = (out == '0);
                end
                OP_SUB: begin
                    out  = in1 - in2;
                    zero = (out == '0);
                end
                OP_MUL: begin
                    out  = in1 * in2;
                    zero = (out == '0);
                end
                OP_DIV: begin
                    if (in2 == '0) begin
                        error = 1'b1;
                        out   = MINUS_ONE;
                        zero  = 1'b0;
                    end
                    else begin
                        out  = in1 / in2;
                        zero = (out == '0);
                    end
                end
                // VCS coverage off
                // Default: op multi-hot (codificacion invalida). En operacion
                // normal la FSM nunca lo envia. Salida forzada -1 + error=1
                // como defensa contra corrupcion. No cuenta en coverage.
                default: begin
                    out   = MINUS_ONE;
                    zero  = 1'b0;
                    error = 1'b1;
                end
                // VCS coverage on
            endcase
        end
    end

endmodule