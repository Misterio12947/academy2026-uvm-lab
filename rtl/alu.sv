//------------------------------------------------------------------------------
// alu.sv
// ALU parametrizada per lab spec (op 4 bits, out 2*WIDTH, -1 en error).
//
// Encoding del opcode: ONE-HOT sobre 4 bits. Solo 4 operaciones (per spec:
// "This ALU has to have addition, subtraction, multiplication and division
// operations").
//   4'b0001 = ADD  (op[0]=1)
//   4'b0010 = SUB  (op[1]=1)
//   4'b0100 = MUL  (op[2]=1)
//   4'b1000 = DIV  (op[3]=1)
//
// La FSM SIEMPRE envia uno de estos 4 opcodes validos (nunca 0000 ni
// multi-hot). Para instrucciones no-aritmeticas (LOAD/STORE/NOP), la FSM
// envia ADD (0001) como opcode neutro y el datapath ignora el resultado
// (selmux2 toma memoria en LOAD, aluout_reg_en=0 en STORE).
//
// El 'default' del case existe UNICAMENTE como defensa contra corrupcion
// de X / latches inferidos. En operacion normal NUNCA se ejecuta, por eso
// esta envuelto en pragma coverage off.
//
// error se asserta en: (a) division por cero, (b) invalid_data=1 (feedback
// loop con resultado previo invalido, per spec del CPU).
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

    // Encoding one-hot de las 4 operaciones (per spec + revisor feedback)
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
                // Default puramente defensivo. La FSM siempre envia uno de
                // los 4 opcodes one-hot validos (ADD/SUB/MUL/DIV), nunca
                // 0000 ni multi-hot. Este branch existe solo para evitar
                // latches inferidos y como defensa contra corrupcion de X.
                // No se ejecuta en operacion normal.
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