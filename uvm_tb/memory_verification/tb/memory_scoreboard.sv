//------------------------------------------------------------------------------
// memory_scoreboard.sv
// Modelo de referencia: array asociativo de 8 palabras.
//
// Semantica DUT (per spec):
//   - Write sincrono: en posedge clk, si memoryWrite=1, mem[addr[2:0]] <= data
//   - Read asincrono: memoryRead=1 -> out = mem[addr[2:0]] combinacional
//                     memoryRead=0 -> out = 0 (gating)
//
// Solo verifica reads a direcciones ya escritas (written_mask filtering).
//------------------------------------------------------------------------------
`uvm_analysis_imp_decl(_mem)

class memory_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(memory_scoreboard)

    uvm_analysis_imp_mem#(memory_transaction, memory_scoreboard) ap_imp;

    // Modelo de la memoria: 8 palabras de 2*WIDTH bits.
    bit [2*WIDTH-1:0] model_mem [0:7];

    // Mascara: bit N=1 si la direccion N ya fue escrita.
    bit [7:0] written_mask;

    int unsigned num_checked_read;
    int unsigned num_writes_seen;
    int unsigned num_reads_skipped;   // reads a addr no escritas (filtrados)
    int unsigned num_gating_checked;  // reads con memoryRead=0 (out debe ser 0)
    int unsigned num_errors;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap_imp             = new("ap_imp", this);
        written_mask       = '0;
        num_checked_read   = 0;
        num_writes_seen    = 0;
        num_reads_skipped  = 0;
        num_gating_checked = 0;
        num_errors         = 0;
    endfunction

    function void write_mem(memory_transaction tr);
        bit [2:0]         idx;
        bit [2*WIDTH-1:0] expected;

        idx = tr.memoryAddress[2:0];

        // 1. Verificar gating: si memoryRead=0, out debe ser 0
        if (!tr.memoryRead) begin
            num_gating_checked++;
            if (tr.memoryOutData !== '0) begin
                num_errors++;
                `uvm_error("SCB",
                    $sformatf("GATING FAIL | memoryRead=0 pero out=%04h (esperaba 0)",
                        tr.memoryOutData))
            end
        end
        // 2. Verificar read: solo si esa direccion ya fue escrita
        else if (written_mask[idx]) begin
            expected = model_mem[idx];
            num_checked_read++;
            if (tr.memoryOutData !== expected) begin
                num_errors++;
                `uvm_error("SCB",
                    $sformatf("READ MISMATCH | addr=%0d || DUT: out=%04h || REF: expected=%04h",
                        idx, tr.memoryOutData, expected))
            end
            else begin
                `uvm_info("SCB",
                    $sformatf("READ MATCH    | addr=%0d -> out=%04h",
                        idx, tr.memoryOutData),
                    UVM_HIGH)
            end
        end
        // 3. Read a direccion no escrita: filtrado
        else begin
            num_reads_skipped++;
            `uvm_info("SCB",
                $sformatf("READ SKIP     | addr=%0d nunca escrito (uninit)", idx),
                UVM_HIGH)
        end

        // 4. Update del modelo si hay write (posterior a la verificacion del
        //    read porque el read en la misma tx es del edge previo)
        if (tr.memoryWrite) begin
            model_mem[idx]      = tr.memoryWriteData;
            written_mask[idx]   = 1'b1;
            num_writes_seen++;
        end
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCB",
            $sformatf("Reads verificados: %0d | Reads filtrados (uninit): %0d | Writes: %0d | Gating checks: %0d | Errores: %0d",
                num_checked_read, num_reads_skipped, num_writes_seen,
                num_gating_checked, num_errors),
            UVM_NONE)
    endfunction

endclass
