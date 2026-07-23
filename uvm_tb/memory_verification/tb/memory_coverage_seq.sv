//------------------------------------------------------------------------------
// memory_coverage_seq.sv
// Closure exhaustivo:
//   - Write-then-read en cada direccion (para cg_transitions)
//   - Escrituras con valores en todos los rangos (para cp_write_data)
//   - Lecturas con datos en todos los rangos (para cp_read_data)
//   - Cross addr x wr_en y addr x rd_en (cerrando 16 bins cada uno)
//------------------------------------------------------------------------------
class memory_coverage_seq extends uvm_sequence#(memory_transaction);

    `uvm_object_utils(memory_coverage_seq)

    function new(string name = "memory_coverage_seq");
        super.new(name);
    endfunction

    task send_action(bit [2:0] addr, bit [2*WIDTH-1:0] data,
                     bit wr, bit rd);
        memory_transaction req = memory_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {
            memoryWrite     == wr;
            memoryRead      == rd;
            memoryAddress   == {5'b0, addr};
            memoryWriteData == data;
        })
            `uvm_error("SEQ", "randomize() fallo en send_action")
        finish_item(req);
    endtask

    task body();
        // Fase 1: escribir cada direccion con valores en cada rango de bin.
        // Esto cierra cp_write_data (5 rangos) y cx_addr_wr_en (8x2=16).
        bit [2*WIDTH-1:0] range_vals [5];
        range_vals[0] = 16'h0000;   // zero
        range_vals[1] = 16'h0100;   // low
        range_vals[2] = 16'h8000;   // mid
        range_vals[3] = 16'hF000;   // high
        range_vals[4] = 16'hFFFF;   // max

        for (int a = 0; a < 8; a++) begin
            for (int r = 0; r < 5; r++) begin
                send_action(a[2:0], range_vals[r], 1'b1, 1'b0);
            end
        end

        // Fase 2: write-then-read por cada direccion (cierra cg_transitions).
        for (int a = 0; a < 8; a++) begin
            send_action(a[2:0], (16'h1000 + a), 1'b1, 1'b0);
            send_action(a[2:0], '0, 1'b0, 1'b1);
        end

        // Fase 3: reads con datos en distintos rangos para cerrar cp_read_data.
        // Primero escribir con cada rango de dato, luego leer.
        for (int r = 0; r < 5; r++) begin
            send_action(3'd0, range_vals[r], 1'b1, 1'b0);   // write range r
            send_action(3'd0, '0,            1'b0, 1'b1);   // read back
        end

        // Fase 4: crosses cx_addr_rd_en (8 bins con rd_en=1, 8 con rd_en=0)
        for (int a = 0; a < 8; a++) begin
            send_action(a[2:0], '0, 1'b0, 1'b1);  // read only
            send_action(a[2:0], '0, 1'b0, 1'b0);  // idle en esa direccion
        end

        // Fase 5: write+read simultaneos (cerrar action=2'b11)
        for (int a = 0; a < 8; a++) begin
            send_action(a[2:0], (16'h2000 + a), 1'b1, 1'b1);
        end
    endtask

endclass
