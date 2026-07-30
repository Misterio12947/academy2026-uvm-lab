//------------------------------------------------------------------------------
// top_scoreboard.sv
// Reference model del CPU completo con buffer de latencia 1.
//
// Por la latencia del pipeline (ver docs/PIPELINE_TIMING.md), el dout que
// llega en la transaccion N corresponde al resultado de la instruccion N-1.
// El scoreboard:
//   1. Recibe la transaccion N (cmd_in visible + dout observado)
//   2. Compara el dout observado contra el resultado esperado de la
//      instruccion ANTERIOR (guardado en el buffer)
//   3. Computa el resultado esperado de la instruccion N y lo guarda en el
//      buffer para la proxima comparacion
//
// El modelo mantiene el estado del CPU: registro de salida, flags y memoria.
//------------------------------------------------------------------------------
`uvm_analysis_imp_decl(_top)

class top_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(top_scoreboard)

    uvm_analysis_imp_top#(top_transaction, top_scoreboard) ap_imp;

    // ISA opcodes
    localparam bit [2:0] ISA_ADD   = 3'b000;
    localparam bit [2:0] ISA_SUB   = 3'b001;
    localparam bit [2:0] ISA_MUL   = 3'b010;
    localparam bit [2:0] ISA_DIV   = 3'b011;
    localparam bit [2:0] ISA_NOP0  = 3'b100;
    localparam bit [2:0] ISA_LOAD  = 3'b101;
    localparam bit [2:0] ISA_STORE = 3'b110;
    localparam bit [2:0] ISA_NOP1  = 3'b111;

    localparam bit [2*WIDTH-1:0] MINUS_ONE = {(2*WIDTH){1'b1}};

    // Estado persistente del CPU (el reference model)
    bit [2*WIDTH-1:0] model_dout;         // {dout_high, dout_low}
    bit               model_zero;
    bit               model_error;
    bit [2*WIDTH-1:0] model_mem [0:7];    // memoria de 8 palabras
    bit [7:0]         mem_written;        // mascara de direcciones escritas

    // Buffer de latencia 1: resultado esperado de la instruccion anterior
    bit [2*WIDTH-1:0] expected_dout;
    bit               expected_zero;
    bit               expected_error;
    bit               buffer_valid;       // false hasta la primera instruccion
	
	int unsigned warmup_count;
    localparam int unsigned WARMUP = 3;   // skip las primeras 3 comparaciones (arranque del pipeline)
    
	int unsigned num_checked;
    int unsigned num_errors;
    int unsigned num_skipped;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap_imp        = new("ap_imp", this);
        model_dout    = '0;
        model_zero    = 1'b0;
        model_error   = 1'b0;
        mem_written   = '0;
        expected_dout = '0;
        expected_zero = 1'b0;
        expected_error= 1'b0;
        buffer_valid  = 1'b0;
        num_checked   = 0;
        num_errors    = 0;
        num_skipped   = 0;
		warmup_count = 0;
    endfunction

    // Mux4: resuelve un operando segun sel (con feedback en sel=11)
    function bit [WIDTH-1:0] mux4_sel(bit [1:0] sel,
                                       bit [WIDTH-1:0] d1, d2, d3,
                                       bit [WIDTH-1:0] feedback);
        case (sel)
            2'b00: return d1;
            2'b01: return d2;
            2'b10: return d3;
            2'b11: return feedback;
            default: return '0;
        endcase
    endfunction

    // Traduccion ISA -> opcode ALU one-hot (ADD neutro para no-aritmeticas)
    function bit [3:0] isa_to_opcode(bit [2:0] op);
        case (op)
            ISA_ADD: return 4'b0001;
            ISA_SUB: return 4'b0010;
            ISA_MUL: return 4'b0100;
            ISA_DIV: return 4'b1000;
            default: return 4'b0001;  // NOP/LOAD/STORE -> ADD neutro
        endcase
    endfunction

    // ALU: replica exacta del RTL
    function void alu_compute(bit [WIDTH-1:0] a, b, bit [3:0] op, bit invalid,
                              output bit [2*WIDTH-1:0] result,
                              output bit z, output bit e);
        result = '0; z = 1'b0; e = 1'b0;
        if (invalid) begin
            e = 1'b1; result = MINUS_ONE; z = 1'b0;
        end
        else begin
            case (op)
                4'b0001: begin result = a + b;  z = (result == '0); end
                4'b0010: begin result = a - b;  z = (result == '0); end
                4'b0100: begin result = a * b;  z = (result == '0); end
                4'b1000: begin
                    if (b == '0) begin e = 1'b1; result = MINUS_ONE; z = 1'b0; end
                    else begin result = a / b; z = (result == '0); end
                end
                default: begin result = MINUS_ONE; z = 1'b0; e = 1'b1; end
            endcase
        end
    endfunction

    // Modela el efecto de una instruccion sobre el estado del CPU.
    // Actualiza model_dout/zero/error/mem y devuelve el nuevo dout esperado.
    function void model_instruction(top_transaction tr,
                                    output bit [2*WIDTH-1:0] exp_dout,
                                    output bit exp_zero,
                                    output bit exp_error);
        bit [WIDTH-1:0]   opA, opB;
        bit [3:0]         opcode;
        bit               nvalid;
        bit [2*WIDTH-1:0] alu_result;
        bit               alu_z, alu_e;
        bit [2:0]         addr;

        // Resolver operandos con feedback (feedback usa model_dout previo)
        opA = mux4_sel(tr.muxA, tr.din_1, tr.din_2, tr.din_3, model_dout[2*WIDTH-1:WIDTH]); // dout_high
        opB = mux4_sel(tr.muxB, tr.din_1, tr.din_2, tr.din_3, model_dout[WIDTH-1:0]);       // dout_low

        // nvalid_data = error previo && feedback
        nvalid = model_error && ((tr.muxA == 2'b11) || (tr.muxB == 2'b11));

        // Opcode ALU (one-hot, ADD neutro)
        opcode = isa_to_opcode(tr.isa_op);

        // ALU computa
        alu_compute(opA, opB, opcode, nvalid, alu_result, alu_z, alu_e);

        // Efecto segun instruccion
        addr = opA[2:0];  // address de memoria = operando A (mux_a_out)

        case (tr.isa_op)
            ISA_ADD, ISA_SUB, ISA_MUL, ISA_DIV: begin
                // Captura resultado de la ALU
                model_dout  = alu_result;
                model_zero  = alu_z;
                model_error = alu_e;
            end
            ISA_LOAD: begin
                // dout = memoria[addr]; flags capturan el ADD neutro
                if (mem_written[addr])
                    model_dout = model_mem[addr];
                else
                    model_dout = '0;  // direccion no escrita (uninit -> tratamos como 0)
                model_zero  = alu_z;   // flags del ADD neutro
                model_error = alu_e;
            end
            ISA_STORE: begin
                // Escribe el dout PREVIO a memoria. NO altera dout ni flags.
                model_mem[addr]   = model_dout;
                mem_written[addr] = 1'b1;
                // model_dout, model_zero, model_error se mantienen
            end
            ISA_NOP0, ISA_NOP1: begin
                // Mantiene el estado (no altera dout ni flags)
            end
            default: ;
        endcase

        exp_dout  = model_dout;
        exp_zero  = model_zero;
        exp_error = model_error;
    endfunction

    function void write_top(top_transaction tr);
        bit [2*WIDTH-1:0] new_exp_dout;
        bit               new_exp_zero, new_exp_error;
        bit [2*WIDTH-1:0] observed_dout;

        observed_dout = {tr.dout_high, tr.dout_low};

        // 1. Comparar el dout observado contra el resultado esperado de la
        //    instruccion ANTERIOR (buffer de latencia 1)
        if (buffer_valid && warmup_count >= WARMUP) begin
            num_checked++;
            if ((observed_dout !== expected_dout) ||
                (tr.zero       !== expected_zero) ||
                (tr.error      !== expected_error)) begin
                num_errors++;
                `uvm_error("SCB",
                    $sformatf({"MISMATCH (resultado de instr previa) |\n",
                               "  DUT: dout=%04h zero=%0b error=%0b\n",
                               "  REF: dout=%04h zero=%0b error=%0b"},
                        observed_dout, tr.zero, tr.error,
                        expected_dout, expected_zero, expected_error))
            end
            else begin
                `uvm_info("SCB",
                    $sformatf("MATCH | dout=%04h zero=%0b error=%0b",
                        observed_dout, tr.zero, tr.error),
                    UVM_HIGH)
            end
        end
        else begin
            num_skipped++;  // warmup: arranque del pipeline, resultados no confiables
        end
        warmup_count++;

        // 2. Computar el resultado esperado de la instruccion ACTUAL y
        //    guardarlo en el buffer para la proxima comparacion
        model_instruction(tr, new_exp_dout, new_exp_zero, new_exp_error);
        expected_dout  = new_exp_dout;
        expected_zero  = new_exp_zero;
        expected_error = new_exp_error;
        buffer_valid   = 1'b1;
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCB",
            $sformatf("Instrucciones verificadas: %0d | Errores: %0d | Skipped (primera): %0d",
                num_checked, num_errors, num_skipped),
            UVM_NONE)
    endfunction

endclass
