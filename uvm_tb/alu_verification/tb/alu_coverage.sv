//------------------------------------------------------------------------------
// alu_coverage.sv
// Coverage funcional adaptado a 4 operaciones one-hot (sin NOP):
//   - cp_op: 4 bins (ADD, SUB, MUL, DIV)
//   - cp_in1, cp_in2, cp_out: rangos
//   - cp_invalid_data, cp_zero, cp_error
//   - Crosses: op x in2==0 (div-by-zero), op x invalid_data
//------------------------------------------------------------------------------
class alu_coverage extends uvm_subscriber#(alu_transaction);

    `uvm_component_utils(alu_coverage)

    alu_transaction tr;

    covergroup cg_alu;
        option.per_instance = 1;
        option.name         = "cg_alu";

        // Encoding one-hot: 4 bins validos (sin NOP)
        cp_op: coverpoint tr.op {
            bins op_add = {4'b0001};
            bins op_sub = {4'b0010};
            bins op_mul = {4'b0100};
            bins op_div = {4'b1000};
        }

        cp_in1: coverpoint tr.in1 {
            bins zero    = {0};
            bins low     = {[1:('h1F)]};
            bins mid     = {[('h20):('hDF)]};
            bins high    = {[('hE0):('hFE)]};
            bins max_val = {'hFF};
        }

        cp_in2: coverpoint tr.in2 {
            bins zero    = {0};
            bins low     = {[1:('h1F)]};
            bins mid     = {[('h20):('hDF)]};
            bins high    = {[('hE0):('hFE)]};
            bins max_val = {'hFF};
        }

        cp_out: coverpoint tr.out {
            bins zero      = {0};
            bins low       = {[1:('h1FFF)]};
            bins mid       = {[('h2000):('hDFFF)]};
            bins high      = {[('hE000):('hFFFE)]};
            bins minus_one = {'hFFFF};    // salida en error
        }

        cp_invalid_data: coverpoint tr.invalid_data {
            bins low  = {1'b0};
            bins high = {1'b1};
        }

        cp_zero: coverpoint tr.zero {
            bins low  = {1'b0};
            bins high = {1'b1};
        }

        cp_error: coverpoint tr.error {
            bins low  = {1'b0};
            bins high = {1'b1};
        }

        // Cross critico: cada op con in2=0 (verifica div-by-zero y bordes)
        cx_op_in2_zero: cross cp_op, cp_in2 {
            bins add_in2_zero = binsof(cp_op.op_add) && binsof(cp_in2.zero);
            bins sub_in2_zero = binsof(cp_op.op_sub) && binsof(cp_in2.zero);
            bins mul_in2_zero = binsof(cp_op.op_mul) && binsof(cp_in2.zero);
            bins div_in2_zero = binsof(cp_op.op_div) && binsof(cp_in2.zero);
            ignore_bins non_zero = binsof(cp_in2) intersect {[1:'hFF]};
        }

        // Cross: cada op con invalid_data=1 (fuerza error/-1)
        cx_op_invalid: cross cp_op, cp_invalid_data {
            bins add_invalid = binsof(cp_op.op_add) && binsof(cp_invalid_data.high);
            bins sub_invalid = binsof(cp_op.op_sub) && binsof(cp_invalid_data.high);
            bins mul_invalid = binsof(cp_op.op_mul) && binsof(cp_invalid_data.high);
            bins div_invalid = binsof(cp_op.op_div) && binsof(cp_invalid_data.high);
            ignore_bins invalid_low = binsof(cp_invalid_data.low);
        }

    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg_alu = new();
    endfunction

    virtual function void write(alu_transaction t);
        this.tr = t;
        cg_alu.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("COV",
            $sformatf("Coverage funcional: cg_alu=%0.2f%%",
                cg_alu.get_inst_coverage()),
            UVM_NONE)
    endfunction

endclass