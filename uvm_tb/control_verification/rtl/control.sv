//------------------------------------------------------------------------------
// control.sv
// Unidad de control del CPU multiciclo (Lab III del laboratorio Synopsys).
// FSM Moore de 4 estados basada en el diagrama del spec:
//   RST_ST -> FETCH_DECODE -> EXECUTE -> STORE -> FETCH_DECODE (loop)
//
// El estado RST_ST captura el primer cmd_in del master ("avoid losing one
// cycle" per spec) mientras los demas registros del datapath permanecen en 0
// por el reset asincrono.
//
// Decodificacion de cmd_in:
//   [6:5] -> in_select_a (muxA del datapath)
//   [4:3] -> in_select_b (muxB del datapath)
//   [2:0] -> ISA opcode base (ver tabla en cmd_to_alu_opcode)
//
// Encoding del opcode ALU (one-hot per revisor feedback):
//   ADD  -> 4'b0001 (op[0]=1)
//   SUB  -> 4'b0010 (op[1]=1)
//   MUL  -> 4'b0100 (op[2]=1)
//   DIV  -> 4'b1000 (op[3]=1)
//   NOP0/LOAD/STORE/NOP1 -> 4'b0000 (ALU pasiva)
//
// nvalid_data se asserta en EXECUTE cuando la instruccion previa termino en
// error (p_error=1) Y algun mux selecciona feedback loop (2'b11).
//------------------------------------------------------------------------------
module control (
    input  logic       clk,
    input  logic       rst,           // Reset asincrono activo alto
    input  logic [6:0] cmd_in,
    input  logic       p_error,       // Error de instruccion previa (registrado externamente)
    output logic       aluin_reg_en,
    output logic       datain_reg_en,
    output logic       memoryWrite,
    output logic       memoryRead,
    output logic       selmux2,
    output logic       cpu_rdy,       // Pulso de 1 ciclo en STORE
    output logic       aluout_reg_en,
    output logic       nvalid_data,
    output logic [1:0] in_select_a,
    output logic [1:0] in_select_b,
    output logic [3:0] opcode         // 4 bits one-hot per spec del lab
);

    // Opcodes ISA (3 bits, extraidos de cmd_in[2:0])
    localparam logic [2:0] ISA_ADD   = 3'b000;
    localparam logic [2:0] ISA_SUB   = 3'b001;
    localparam logic [2:0] ISA_MUL   = 3'b010;
    localparam logic [2:0] ISA_DIV   = 3'b011;
    localparam logic [2:0] ISA_NOP0  = 3'b100;
    localparam logic [2:0] ISA_LOAD  = 3'b101;
    localparam logic [2:0] ISA_STORE = 3'b110;
    localparam logic [2:0] ISA_NOP1  = 3'b111;

    // Estados de la FSM (4 estados, incluyendo RST_ST explicito per spec)
    typedef enum logic [1:0] {
        RST_ST       = 2'b00,
        FETCH_DECODE = 2'b01,
        EXECUTE      = 2'b10,
        STORE        = 2'b11
    } state_t;

    state_t current_state, next_state;

    // Extraccion de campos del cmd_in
    logic [1:0] cmd_muxA;
    logic [1:0] cmd_muxB;
    logic [2:0] cmd_op;
    always_comb begin
        cmd_muxA = cmd_in[6:5];
        cmd_muxB = cmd_in[4:3];
        cmd_op   = cmd_in[2:0];
    end

	// Funcion helper: traduce cmd_in[2:0] (ISA) al encoding one-hot del ALU.
    // La ALU tiene exactamente 4 operaciones (ADD/SUB/MUL/DIV), sin NOP.
    // Para instrucciones no-aritmeticas (LOAD/STORE/NOP0/NOP1), se envia ADD
    // (0001) como opcode NEUTRO: la ALU computa in1+in2 pero el datapath
    // ignora el resultado (selmux2=1 toma memoria en LOAD, aluout_reg_en=0
    // en STORE). La FSM NUNCA envia 0000 - el default de la ALU es solo
    // defensa contra latches.
    function automatic logic [3:0] cmd_to_alu_opcode(input logic [2:0] cmd_op);
        unique case (cmd_op)
            ISA_ADD:  cmd_to_alu_opcode = 4'b0001;  // ADD -> op[0]
            ISA_SUB:  cmd_to_alu_opcode = 4'b0010;  // SUB -> op[1]
            ISA_MUL:  cmd_to_alu_opcode = 4'b0100;  // MUL -> op[2]
            ISA_DIV:  cmd_to_alu_opcode = 4'b1000;  // DIV -> op[3]
            // Instrucciones no-aritmeticas: ADD (0001) como opcode neutro.
            // El resultado se ignora via datapath.
            ISA_NOP0,
            ISA_LOAD,
            ISA_STORE,
            ISA_NOP1: cmd_to_alu_opcode = 4'b0001;  // ADD neutro
            // VCS coverage off
            default:  cmd_to_alu_opcode = 4'b0001;
            // VCS coverage on
        endcase
    endfunction

    //--------------------------------------------------------------------------
    // Registro de estado (reset asincrono activo alto)
    //--------------------------------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= RST_ST;
        else
            current_state <= next_state;
    end

    //--------------------------------------------------------------------------
    // Logica de transiciones
    //--------------------------------------------------------------------------
    always_comb begin
        unique case (current_state)
            RST_ST:       next_state = FETCH_DECODE;
            FETCH_DECODE: next_state = EXECUTE;
            EXECUTE:      next_state = STORE;
            STORE:        next_state = FETCH_DECODE;
            // VCS coverage off
            default:      next_state = RST_ST;
            // VCS coverage on
        endcase
    end

    //--------------------------------------------------------------------------
    // Logica de salidas (FSM Moore)
    //--------------------------------------------------------------------------
    always_comb begin
        // Defaults defensivos: todas las senales inactivas
        aluin_reg_en   = 1'b0;
        datain_reg_en  = 1'b0;
        memoryWrite    = 1'b0;
        memoryRead     = 1'b0;
        selmux2        = 1'b0;
        cpu_rdy        = 1'b0;
        aluout_reg_en  = 1'b0;
        nvalid_data    = 1'b0;
        // Senales de control del datapath salen siempre con la instruccion actual
        in_select_a    = cmd_muxA;
        in_select_b    = cmd_muxB;
        opcode         = cmd_to_alu_opcode(cmd_op);

        unique case (current_state)
            RST_ST: begin
                // Captura el primer cmd_in del master para no perder un ciclo
                // (spec: "instruction stored for next stage").
                datain_reg_en = 1'b1;
            end

            FETCH_DECODE: begin
                // Decodifica y captura operandos A y B en los registros del ALU
                aluin_reg_en = 1'b1;
            end

			EXECUTE: begin
                // ALU computa, resultado se captura al final del ciclo.
                // EXCEPCION STORE: NO capturamos en el registro de salida
                // (aluout_reg_en=0) para preservar el {dout_high, dout_low}
                // de la instruccion previa. Ese es justamente el dato que la
                // instruccion STORE va a escribir a memoria (per spec:
                // "the result of the computed instruction is shared at the
                // output... if it is a store instruction, it occurs in this
                // cycle"). Si capturaramos aqui, la ALU pasiva (out=0)
                // sobreescribiria el dato a guardar.
				
                // Solo las operaciones aritmeticas (ADD/SUB/MUL/DIV) y LOAD
                // capturan en el registro de salida. STORE y NOP preservan
                // el estado previo de {dout_high, dout_low}:
                //   - STORE: preserva el dato a escribir a memoria
                //   - NOP0/NOP1: "mantiene el estado" (no altera la salida)
                if (cmd_op != ISA_STORE &&
                    cmd_op != ISA_NOP0  &&
                    cmd_op != ISA_NOP1)
                    aluout_reg_en = 1'b1;

                // Si la instruccion previa termino en error Y algun mux
                // selecciona feedback loop, notificar a la ALU.
                nvalid_data = p_error &&
                              ((cmd_muxA == 2'b11) || (cmd_muxB == 2'b11));

                // LOAD: leer memoria en paralelo con la ALU
                if (cmd_op == ISA_LOAD) begin
                    memoryRead = 1'b1;
                    selmux2    = 1'b1;   // ruta memoria -> registro de salida
                end
            end

            STORE: begin
                // Fase final: pulso cpu_rdy, captura siguiente cmd_in, y si
                // la instruccion es STORE escribe a memoria.
                cpu_rdy       = 1'b1;
                datain_reg_en = 1'b1;
                if (cmd_op == ISA_STORE) begin
                    memoryWrite = 1'b1;
                end
            end

            // VCS coverage off
            default: ;
            // VCS coverage on
        endcase
    end

endmodule