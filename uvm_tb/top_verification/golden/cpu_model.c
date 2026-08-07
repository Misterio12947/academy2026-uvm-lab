//==============================================================================
// cpu_model.c
// Golden model ciclo-a-ciclo del CPU multiciclo (top) para verificacion DPI-C.
//
// Replica EXACTAMENTE la estructura y el timing del RTL de top.sv:
//   - FSM de 4 estados (RST_ST, FETCH_DECODE, EXECUTE, STORE)
//   - Registros con sus enables precisos (aluin_reg_en, aluout_reg_en,
//     datain_reg_en) en los estados correctos
//   - Feedback loop (muxA/muxB sel=11 -> dout_high/dout_low previos)
//   - ALU one-hot con ADD neutro para instrucciones no-aritmeticas
//   - Memoria de 8 palabras (address = mux_a_out)
//   - Encoding one-hot: ADD=0001, SUB=0010, MUL=0100, DIV=1000
//
// Al modelar cada registro con su timing real, este modelo captura el
// desfase opcode/operandos del pipeline que el modelo atomico UVM no podia:
//   - El opcode viene de cmd_reg_out (registrado con datain_reg_en)
//   - Los operandos vienen de mux_a_out/mux_b_out (registrados con aluin_reg_en)
//   Estos se actualizan en momentos distintos, y el modelo lo replica.
//
// Uso via DPI-C desde SystemVerilog:
//   import "DPI-C" function void cpu_model_reset();
//   import "DPI-C" function void cpu_model_step(...);
//
// Tambien compilable como programa C puro (con -DSTANDALONE_TEST) para
// validar la logica del pipeline sin VCS.
//==============================================================================

#include <stdint.h>
#include <string.h>

//------------------------------------------------------------------------------
// Parametros del diseño (WIDTH=8)
//------------------------------------------------------------------------------
#define WIDTH       8
#define MEM_WORDS   8
#define MASK8       0xFFu
#define MASK16      0xFFFFu

// Estados de la FSM (matches RTL)
#define RST_ST        0
#define FETCH_DECODE  1
#define EXECUTE       2
#define STORE_ST      3

// ISA opcodes (cmd_in[2:0])
#define ISA_ADD    0
#define ISA_SUB    1
#define ISA_MUL    2
#define ISA_DIV    3
#define ISA_NOP0   4
#define ISA_LOAD   5
#define ISA_STORE  6
#define ISA_NOP1   7

// Opcode ALU one-hot
#define OP_ADD   0x1
#define OP_SUB   0x2
#define OP_MUL   0x4
#define OP_DIV   0x8

//------------------------------------------------------------------------------
// Estado persistente del CPU (los registros del datapath + FSM + memoria)
//------------------------------------------------------------------------------
typedef struct {
    // FSM
    uint8_t  current_state;

    // Registros del datapath
    uint8_t  mux_a_out;      // operando A registrado (aluin_reg_en, FETCH_DECODE)
    uint8_t  mux_b_out;      // operando B registrado (aluin_reg_en, FETCH_DECODE)
    uint8_t  dout_high;      // salida alta registrada (aluout_reg_en, EXECUTE)
    uint8_t  dout_low;       // salida baja registrada (aluout_reg_en, EXECUTE)
    uint8_t  reg_zero;       // flag zero registrado (aluout_reg_en)
    uint8_t  reg_error;      // flag error registrado (aluout_reg_en)
    uint8_t  cmd_reg_out;    // cmd_in registrado (datain_reg_en, RST_ST y STORE)

    // Memoria
    uint16_t mem[MEM_WORDS];
} cpu_state_t;

static cpu_state_t st;

//------------------------------------------------------------------------------
// Traduccion ISA -> opcode ALU one-hot (replica de cmd_to_alu_opcode del RTL)
// ADD neutro (0001) para instrucciones no-aritmeticas.
//------------------------------------------------------------------------------
static uint8_t cmd_to_alu_opcode(uint8_t cmd_op) {
    switch (cmd_op & 0x7) {
        case ISA_ADD: return OP_ADD;
        case ISA_SUB: return OP_SUB;
        case ISA_MUL: return OP_MUL;
        case ISA_DIV: return OP_DIV;
        // NOP0/LOAD/STORE/NOP1 -> ADD neutro
        default:      return OP_ADD;
    }
}

//------------------------------------------------------------------------------
// ALU combinacional (replica exacta de alu.sv)
//   invalid_data -> error, out=-1 (0xFFFF)
//   DIV por cero -> error, out=-1
//   solo 4 operaciones one-hot + default defensivo
//------------------------------------------------------------------------------
static void alu_compute(uint8_t in1, uint8_t in2, uint8_t op, uint8_t invalid,
                        uint16_t *out, uint8_t *zero, uint8_t *error) {
    uint16_t result = 0;
    uint8_t  z = 0, e = 0;

    if (invalid) {
        e = 1; result = MASK16; z = 0;
    } else {
        switch (op) {
            case OP_ADD:
                result = (uint16_t)((in1 + in2) & MASK16);
                z = (result == 0);
                break;
            case OP_SUB:
                result = (uint16_t)((in1 - in2) & MASK16);
                z = (result == 0);
                break;
            case OP_MUL:
                result = (uint16_t)((in1 * in2) & MASK16);
                z = (result == 0);
                break;
            case OP_DIV:
                if (in2 == 0) {
                    e = 1; result = MASK16; z = 0;
                } else {
                    result = (uint16_t)((in1 / in2) & MASK16);
                    z = (result == 0);
                }
                break;
            default:  // defensivo (nunca en operacion normal)
                result = MASK16; z = 0; e = 1;
                break;
        }
    }
    *out   = result;
    *zero  = z;
    *error = e;
}

//------------------------------------------------------------------------------
// Mux4: resuelve un operando segun sel (feedback en sel=11)
//------------------------------------------------------------------------------
static uint8_t mux4_sel(uint8_t sel, uint8_t d1, uint8_t d2, uint8_t d3,
                        uint8_t feedback) {
    switch (sel & 0x3) {
        case 0: return d1;
        case 1: return d2;
        case 2: return d3;
        case 3: return feedback;
    }
    return 0;
}

//------------------------------------------------------------------------------
// Reset del modelo (equivalente al reset asincrono del RTL)
//------------------------------------------------------------------------------
void cpu_model_reset(void) {
    st.current_state = RST_ST;
    st.mux_a_out   = 0;
    st.mux_b_out   = 0;
    st.dout_high   = 0;
    st.dout_low    = 0;
    st.reg_zero    = 0;
    st.reg_error   = 0;
    st.cmd_reg_out = 0;
    memset(st.mem, 0, sizeof(st.mem));
}

//------------------------------------------------------------------------------
// cpu_model_step: avanza el modelo UN ciclo de reloj.
//
// Replica el orden del hardware:
//   1. Combinacional: el control genera señales segun current_state y
//      cmd_reg_out (el cmd registrado). Esto define aluin_reg_en,
//      aluout_reg_en, datain_reg_en, memoryRead/Write, selmux2, opcode,
//      in_select_a/b, nvalid_data.
//   2. Combinacional: la ALU computa con mux_a_out/mux_b_out (operandos
//      registrados) y el opcode (derivado de cmd_reg_out).
//   3. Combinacional: la memoria lee/escribe segun mux_a_out.
//   4. Combinacional: el mux de salida elige ALU o memoria.
//   5. Secuencial (flanco): actualiza los registros segun sus enables,
//      captura el siguiente cmd_in, y avanza current_state.
//
// Las SALIDAS que devuelve son los observables DESPUES del flanco (el estado
// registrado), que es lo que el TB observa en el RTL: dout, flags, cpu_rdy.
//
// NOTA sobre cpu_rdy: en el RTL, cpu_rdy es una salida Moore del control que
// vale 1 en el estado STORE. Como es combinacional del estado ACTUAL, la
// reportamos segun el current_state ANTES de la transicion (el estado en el
// que estamos durante este ciclo).
//------------------------------------------------------------------------------
void cpu_model_step(
    // Inputs (mismos que van al RTL este ciclo)
    uint8_t  cmd_in,      // 7 bits
    uint8_t  din_1,
    uint8_t  din_2,
    uint8_t  din_3,
    uint8_t  rst,
    // Outputs (lo que el modelo predice observar DESPUES de este ciclo)
    uint8_t  *dout_high,
    uint8_t  *dout_low,
    uint8_t  *cpu_rdy,
    uint8_t  *zero,
    uint8_t  *error
) {
    // ----- Reset asincrono -----
    if (rst) {
        cpu_model_reset();
        *dout_high = st.dout_high;
        *dout_low  = st.dout_low;
        *cpu_rdy   = 0;
        *zero      = st.reg_zero;
        *error     = st.reg_error;
        return;
    }

    // Snapshot del estado presente (todas las lecturas combinacionales usan
    // los valores ANTES del flanco)
    uint8_t  state   = st.current_state;
    uint8_t  cmd_reg = st.cmd_reg_out;

    // ===== 1. Control: señales combinacionales segun estado y cmd_reg =====
    uint8_t cmd_muxA = (cmd_reg >> 5) & 0x3;
    uint8_t cmd_muxB = (cmd_reg >> 3) & 0x3;
    uint8_t cmd_op   =  cmd_reg       & 0x7;

    uint8_t aluin_reg_en  = 0;
    uint8_t datain_reg_en = 0;
    uint8_t memoryWrite   = 0;
    uint8_t memoryRead    = 0;
    uint8_t selmux2       = 0;
    uint8_t cpu_rdy_comb  = 0;
    uint8_t aluout_reg_en = 0;
    uint8_t nvalid_data   = 0;

    // Salidas siempre presentes
    uint8_t in_select_a = cmd_muxA;
    uint8_t in_select_b = cmd_muxB;
    uint8_t opcode      = cmd_to_alu_opcode(cmd_op);

    switch (state) {
        case RST_ST:
            datain_reg_en = 1;
            break;
        case FETCH_DECODE:
            aluin_reg_en = 1;
            break;
        case EXECUTE:
            // aluout_reg_en=1 excepto STORE/NOP0/NOP1 (preservan estado)
            if (cmd_op != ISA_STORE && cmd_op != ISA_NOP0 && cmd_op != ISA_NOP1)
                aluout_reg_en = 1;
            // nvalid_data = p_error(=reg_error) && feedback
            nvalid_data = st.reg_error && ((cmd_muxA == 3) || (cmd_muxB == 3));
            // LOAD: lee memoria
            if (cmd_op == ISA_LOAD) {
                memoryRead = 1;
                selmux2    = 1;
            }
            break;
        case STORE_ST:
            cpu_rdy_comb  = 1;
            datain_reg_en = 1;
            if (cmd_op == ISA_STORE)
                memoryWrite = 1;
            break;
    }

    // ===== 2. Datapath combinacional (usa registros ACTUALES) =====
    // Operandos: mux con feedback (dout_high/dout_low previos)
    uint8_t opA = mux4_sel(in_select_a, din_1, din_2, din_3, st.dout_high);
    uint8_t opB = mux4_sel(in_select_b, din_1, din_2, din_3, st.dout_low);

    // NOTA: en el RTL, mux_a_out/mux_b_out son REGISTRADOS (se cargan en
    // FETCH_DECODE con aluin_reg_en). La ALU usa esos registros. Aqui,
    // el valor combinacional del mux (opA/opB) es lo que se CARGARA en el
    // registro. La ALU en EXECUTE usa el valor YA REGISTRADO (st.mux_a_out).

    // ALU: usa los operandos REGISTRADOS y el opcode (de cmd_reg actual)
    uint16_t alu_out; uint8_t alu_zero, alu_error;
    alu_compute(st.mux_a_out, st.mux_b_out, opcode, nvalid_data,
                &alu_out, &alu_zero, &alu_error);

    // Memoria: address = mux_a_out (registrado)
    uint8_t  addr = st.mux_a_out & 0x7;
    uint16_t mem_data_out = st.mem[addr];

    // Mux de salida: selmux2 elige ALU (0) o memoria (1)
    uint16_t mux_out_val = selmux2 ? mem_data_out : alu_out;

    // ===== 3. Actualizacion secuencial (flanco de reloj) =====
    // Registro de operandos (aluin_reg_en, en FETCH_DECODE)
    if (aluin_reg_en) {
        st.mux_a_out = opA;
        st.mux_b_out = opB;
    }

    // Registro de salida + flags (aluout_reg_en, en EXECUTE excepto STORE/NOP)
    if (aluout_reg_en) {
        st.dout_high = (mux_out_val >> WIDTH) & MASK8;
        st.dout_low  =  mux_out_val         & MASK8;
        st.reg_zero  = selmux2 ? alu_zero  : alu_zero;   // flags del ALU
        st.reg_error = alu_error;
    }
    // Nota: los flags capturan alu_zero/alu_error incluso en LOAD (ADD neutro).
    // Esto replica el RTL: reg_zero/reg_error tienen wr_en=aluout_reg_en y su
    // entrada es alu_zero/alu_error (no dependen de selmux2).

    // Escritura a memoria (memoryWrite, en STORE)
    if (memoryWrite) {
        // data = {dout_high, dout_low} (el valor previo preservado)
        uint16_t wdata = ((uint16_t)st.dout_high << WIDTH) | st.dout_low;
        st.mem[addr] = wdata;
    }

    // Registro de cmd_in (datain_reg_en, en RST_ST y STORE)
    if (datain_reg_en) {
        st.cmd_reg_out = cmd_in & 0x7F;
    }

    // ===== 4. Avanzar la FSM =====
    uint8_t next_state;
    switch (state) {
        case RST_ST:       next_state = FETCH_DECODE; break;
        case FETCH_DECODE: next_state = EXECUTE;      break;
        case EXECUTE:      next_state = STORE_ST;     break;
        case STORE_ST:     next_state = FETCH_DECODE; break;
        default:           next_state = RST_ST;       break;
    }
    st.current_state = next_state;

    // ===== 5. Salidas observables (estado DESPUES del flanco) =====
    // El TB samplea tras el @(posedge clk), asi que ve el estado YA
    // actualizado. cpu_rdy es una salida Moore: vale 1 cuando el estado
    // (post-flanco) es STORE. Por eso se evalua sobre next_state, NO sobre
    // el estado previo. Esto alinea el pulso de cpu_rdy con el RTL, que
    // tambien lo muestra segun el current_state ya registrado.
    *dout_high = st.dout_high;
    *dout_low  = st.dout_low;
    *cpu_rdy   = (next_state == STORE_ST) ? 1 : 0;
    *zero      = st.reg_zero;
    *error     = st.reg_error;
}
