//------------------------------------------------------------------------------
// regbank_scoreboard.sv
// Scoreboard con estado interno. A diferencia del ALU (combinacional),
// aqui el modelo es SECUENCIAL: mantiene un model_reg que se actualiza igual
// que el DUT en cada ciclo.
//
// Metodologia (opcion A - reactive model):
//   1. Recibe una tx del monitor (samplada 1 tick post-edge).
//   2. Predice el next state que el DUT debio computar: predict(model_reg, tx).
//   3. Compara tx.out contra la prediccion.
//   4. Avanza model_reg = predicted (para la siguiente tx).
//
// Nota: los primeros samples (durante el reset inicial) pueden llegar con
// rst=1 antes de que el modelo haya sincronizado. Toleramos hasta 3 ciclos
// de warmup antes de empezar a comparar (skip_warmup).
//------------------------------------------------------------------------------
`uvm_analysis_imp_decl(_regbank)

class regbank_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(regbank_scoreboard)

    uvm_analysis_imp_regbank#(regbank_transaction, regbank_scoreboard) ap_imp;

    // Estado interno del modelo
    bit [WIDTH-1:0] model_reg;

    // Contadores
    int unsigned num_checked;
    int unsigned num_errors;
    int unsigned num_warmup;

    // Warmup: primeras tx se descartan (el modelo se sincroniza con el DUT
    // durante el reset inicial del driver).
    localparam int unsigned WARMUP_CYCLES = 4;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap_imp      = new("ap_imp", this);
        model_reg   = '0;
        num_checked = 0;
        num_errors  = 0;
        num_warmup  = 0;
    endfunction

    // Reference model: replica exacta del comportamiento del RTL
    function bit [WIDTH-1:0] predict(bit [WIDTH-1:0] current,
                                     bit             rst,
                                     bit             wr_en,
                                     bit [WIDTH-1:0] in);
        if (rst)         return '0;
        else if (wr_en)  return in;
        else             return current;
    endfunction

    function void write_regbank(regbank_transaction tr);
        bit [WIDTH-1:0] expected;

        // Predice el estado que el DUT debio calcular en este edge
        expected = predict(model_reg, tr.rst, tr.wr_en, tr.in);

        // Warmup: sincroniza el modelo sin verificar
        if (num_warmup < WARMUP_CYCLES) begin
            num_warmup++;
            model_reg = expected;
            `uvm_info("SCB",
                $sformatf("WARMUP %0d/%0d | rst=%0b wr_en=%0b in=%0h -> out=%0h",
                    num_warmup, WARMUP_CYCLES, tr.rst, tr.wr_en, tr.in, tr.out),
                UVM_HIGH)
            return;
        end

        num_checked++;

        if (tr.out !== expected) begin
            num_errors++;
            `uvm_error("SCB",
                $sformatf("MISMATCH | rst=%0b wr_en=%0b in=%0h || DUT: out=%0h || REF: expected=%0h (prev_state=%0h)",
                    tr.rst, tr.wr_en, tr.in, tr.out, expected, model_reg))
        end
        else begin
            `uvm_info("SCB",
                $sformatf("MATCH    | rst=%0b wr_en=%0b in=%0h -> out=%0h",
                    tr.rst, tr.wr_en, tr.in, tr.out),
                UVM_HIGH)
        end

        // Avanza el estado del modelo para la proxima tx
        model_reg = expected;
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCB",
            $sformatf("Transacciones verificadas: %0d | Errores: %0d | Warmup: %0d",
                num_checked, num_errors, num_warmup),
            UVM_NONE)
    endfunction

endclass
