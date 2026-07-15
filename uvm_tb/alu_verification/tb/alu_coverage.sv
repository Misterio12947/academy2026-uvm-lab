//------------------------------------------------------------------------------
// alu_coverage.sv
// Componente de coverage funcional. Extiende uvm_subscriber y muestrea
// covergroups atados directamente a las specs del lab:
//   - Todos los opcodes de la ISA
//   - invalid_data en ambos estados
//   - div-by-zero
//   - error condition => out == -1
//   - zero flag activo/inactivo
//   - Rangos de operandos
//   - Cross de opcode x invalid_data (para forzar visitar cada combinacion)
//------------------------------------------------------------------------------
class alu_coverage extends uvm_subscriber#(alu_transaction);

    `uvm_component_utils(alu_coverage)

    // Copia local para samplear los covergroups
    alu_transaction tr;

    // Constantes para checkear la spec del -1
    localparam bit [2*WIDTH-1:0] MINUS_ONE = {(2*WIDTH){1'b1}};

    //--------------------------------------------------------------------------
    // Covergroup principal
    //--------------------------------------------------------------------------
    covergroup cg_alu;
        option.per_instance = 1;
        option.name         = "cg_alu";

        // Cobertura de todos los opcodes de la ISA (spec del lab)
        cp_op: coverpoint tr.op[2:0] {
            bins ADD   = {3'b000};
            bins SUB   = {3'b001};
            bins MUL   = {3'b010};
            bins DIV   = {3'b011};
            bins NOP0  = {3'b100};
            bins LOAD  = {3'b101};
            bins STORE = {3'b110};
            bins NOP1  = {3'b111};
        }

        // Cobertura del flag invalid_data
        cp_invalid: coverpoint tr.invalid_data {
            bins deasserted = {1'b0};
            bins asserted   = {1'b1};
        }

        // Cobertura del flag zero de salida
        cp_zero: coverpoint tr.zero {
            bins low  = {1'b0};
            bins high = {1'b1};
        }

        // Cobertura del flag error de salida
        cp_error: coverpoint tr.error {
            bins low  = {1'b0};
            bins high = {1'b1};
        }

        // Rango de in1 (operando A)
        cp_in1: coverpoint tr.in1 {
            bins zero    = {0};
            bins low     = {[1:('h1F)]};
            bins mid     = {[('h20):('hDF)]};
            bins high    = {[('hE0):('hFE)]};
            bins max_val = {'hFF};
        }

        // Rango de in2 (operando B)
        cp_in2: coverpoint tr.in2 {
            bins zero    = {0};
            bins low     = {[1:('h1F)]};
            bins mid     = {[('h20):('hDF)]};
            bins high    = {[('hE0):('hFE)]};
            bins max_val = {'hFF};
        }

        // Cross opcode x invalid_data: garantiza que cada opcode se pruebe
        // con y sin invalid_data (2 x 8 = 16 combinaciones)
        cx_op_invalid: cross cp_op, cp_invalid;

        // Cross opcode x error: para atrapar propagacion de error
        cx_op_error: cross cp_op, cp_error;

    endgroup

    //--------------------------------------------------------------------------
    // Covergroup dedicado a casos borde criticos
    //--------------------------------------------------------------------------
    covergroup cg_edge_cases;
        option.per_instance = 1;
        option.name         = "cg_edge_cases";

        // DIV con in2 == 0: caso borde obligatorio de la spec
        cp_div_by_zero: coverpoint {tr.op[2:0], (tr.in2 == '0)} {
            bins div_by_zero_hit  = {4'b0111};  // op=DIV, in2==0
            bins div_normal       = {4'b0110};  // op=DIV, in2!=0
        }

        // Verifica que en error, la salida sea exactamente -1 (spec del lab)
        cp_error_forces_minus_one: coverpoint (tr.error && (tr.out == MINUS_ONE)) {
            bins error_out_is_minus_one = {1'b1};
        }

        // Verifica que en error, zero NO este asertado (consistencia)
        cp_error_zero_consistency: coverpoint {tr.error, tr.zero} {
            bins error_only        = {2'b10};
            bins zero_only         = {2'b01};
            bins neither           = {2'b00};
            illegal_bins both      = {2'b11};   // ERROR: error y zero juntos
        }

    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg_alu        = new();
        cg_edge_cases = new();
    endfunction

    // El uvm_subscriber recibe transacciones por aqui
    virtual function void write(alu_transaction t);
        this.tr = t;
        cg_alu.sample();
        cg_edge_cases.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("COV",
            $sformatf("Coverage funcional: cg_alu=%0.2f%% | cg_edge_cases=%0.2f%%",
                cg_alu.get_inst_coverage(),
                cg_edge_cases.get_inst_coverage()),
            UVM_NONE)
    endfunction

endclass
