//------------------------------------------------------------------------------
// memory_coverage.sv
// Coverage funcional. Tres covergroups:
//   - cg_memory: bins por direccion, datos, wr_en, rd_en, y crosses
//   - cg_access_patterns: idle/read/write/write+read
//   - cg_transitions: patrones write-then-read por direccion (8 bins)
//------------------------------------------------------------------------------
class memory_coverage extends uvm_subscriber#(memory_transaction);

    `uvm_component_utils(memory_coverage)

    memory_transaction tr;

    // Estado para transiciones write-then-read por direccion
    bit [7:0] last_write_addr_mask;
    bit [2:0] last_write_addr_val;
    bit       last_was_write;

    covergroup cg_memory;
        option.per_instance = 1;
        option.name         = "cg_memory";

        // Cada direccion individual (0..7)
        cp_addr: coverpoint tr.memoryAddress[2:0] {
            bins addr0 = {0};
            bins addr1 = {1};
            bins addr2 = {2};
            bins addr3 = {3};
            bins addr4 = {4};
            bins addr5 = {5};
            bins addr6 = {6};
            bins addr7 = {7};
        }

        cp_wr_en: coverpoint tr.memoryWrite {
            bins low  = {1'b0};
            bins high = {1'b1};
        }

        cp_rd_en: coverpoint tr.memoryRead {
            bins low  = {1'b0};
            bins high = {1'b1};
        }

        cp_write_data: coverpoint tr.memoryWriteData iff (tr.memoryWrite) {
            bins zero    = {0};
            bins low     = {[1:('h1FFF)]};
            bins mid     = {[('h2000):('hDFFF)]};
            bins high    = {[('hE000):('hFFFE)]};
            bins max_val = {'hFFFF};
        }

        cp_read_data: coverpoint tr.memoryOutData iff (tr.memoryRead) {
            bins zero    = {0};
            bins low     = {[1:('h1FFF)]};
            bins mid     = {[('h2000):('hDFFF)]};
            bins high    = {[('hE000):('hFFFE)]};
            bins max_val = {'hFFFF};
        }

        // Crosses: cada dir con write y con read
        cx_addr_wr_en: cross cp_addr, cp_wr_en;
        cx_addr_rd_en: cross cp_addr, cp_rd_en;

    endgroup

    covergroup cg_access_patterns;
        option.per_instance = 1;
        option.name         = "cg_access_patterns";

        // 4 modos de acceso
        cp_action: coverpoint {tr.memoryWrite, tr.memoryRead} {
            bins idle       = {2'b00};
            bins read_only  = {2'b01};
            bins write_only = {2'b10};
            bins write_read = {2'b11};
        }

    endgroup

    covergroup cg_transitions with function sample(bit hit, bit [2:0] addr);
        option.per_instance = 1;
        option.name         = "cg_transitions";

        // Un bin por direccion para el patron write->read en la misma addr
        cp_write_read_addr: coverpoint addr iff (hit) {
            bins wr_rd_addr0 = {0};
            bins wr_rd_addr1 = {1};
            bins wr_rd_addr2 = {2};
            bins wr_rd_addr3 = {3};
            bins wr_rd_addr4 = {4};
            bins wr_rd_addr5 = {5};
            bins wr_rd_addr6 = {6};
            bins wr_rd_addr7 = {7};
        }
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg_memory          = new();
        cg_access_patterns = new();
        cg_transitions     = new();
        last_write_addr_val = '0;
        last_was_write      = 1'b0;
    endfunction

    virtual function void write(memory_transaction t);
        bit hit_wr_rd;
        bit [2:0] cur_addr;

        this.tr = t;
        cg_memory.sample();
        cg_access_patterns.sample();

        cur_addr = t.memoryAddress[2:0];

        // Detectar patron write-then-read: read a la misma addr donde acabamos
        // de escribir en la tx anterior
        hit_wr_rd = last_was_write && t.memoryRead &&
                    (last_write_addr_val == cur_addr);

        cg_transitions.sample(hit_wr_rd, cur_addr);

        // Actualizar estado para la siguiente tx
        last_was_write      = t.memoryWrite;
        last_write_addr_val = cur_addr;
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("COV",
            $sformatf("Coverage funcional: cg_memory=%0.2f%% | cg_access_patterns=%0.2f%% | cg_transitions=%0.2f%%",
                cg_memory.get_inst_coverage(),
                cg_access_patterns.get_inst_coverage(),
                cg_transitions.get_inst_coverage()),
            UVM_NONE)
    endfunction

endclass
