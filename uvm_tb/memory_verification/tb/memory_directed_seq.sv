//------------------------------------------------------------------------------
// memory_directed_seq.sv
// Casos borde: write-then-read en cada direccion, overwrites, edge cases.
//------------------------------------------------------------------------------
class memory_directed_seq extends uvm_sequence#(memory_transaction);

    `uvm_object_utils(memory_directed_seq)

    function new(string name = "memory_directed_seq");
        super.new(name);
    endfunction

    task send_write(bit [2:0] addr, bit [2*WIDTH-1:0] data);
        memory_transaction req = memory_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {
            memoryWrite     == 1'b1;
            memoryRead      == 1'b0;
            memoryAddress   == {5'b0, addr};
            memoryWriteData == data;
        })
            `uvm_error("SEQ", "randomize() fallo en send_write")
        finish_item(req);
    endtask

    task send_read(bit [2:0] addr);
        memory_transaction req = memory_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {
            memoryWrite   == 1'b0;
            memoryRead    == 1'b1;
            memoryAddress == {5'b0, addr};
        })
            `uvm_error("SEQ", "randomize() fallo en send_read")
        finish_item(req);
    endtask

    task send_idle();
        memory_transaction req = memory_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {
            memoryWrite == 1'b0;
            memoryRead  == 1'b0;
        })
            `uvm_error("SEQ", "randomize() fallo en send_idle")
        finish_item(req);
    endtask

    task body();
        // Bloque 1: escribir todas las 8 direcciones
        send_write(3'd0, 16'hCAFE);
        send_write(3'd1, 16'h1111);
        send_write(3'd2, 16'h2222);
        send_write(3'd3, 16'h3333);
        send_write(3'd4, 16'h4444);
        send_write(3'd5, 16'h5555);
        send_write(3'd6, 16'h6666);
        send_write(3'd7, 16'h7777);

        // Bloque 2: leer todas las 8 direcciones
        send_read(3'd0);
        send_read(3'd1);
        send_read(3'd2);
        send_read(3'd3);
        send_read(3'd4);
        send_read(3'd5);
        send_read(3'd6);
        send_read(3'd7);

        // Bloque 3: overwrite en una direccion
        send_write(3'd5, 16'hAAAA);
        send_read(3'd5);
        send_write(3'd5, 16'hBBBB);
        send_read(3'd5);

        // Bloque 4: valores extremos
        send_write(3'd0, 16'h0000);
        send_read(3'd0);
        send_write(3'd7, 16'hFFFF);
        send_read(3'd7);

        // Bloque 5: gating (memoryRead=0 debe forzar out=0)
        send_idle();

        // Bloque 6: write-then-read consecutivos en la misma direccion
        send_write(3'd2, 16'hDEAD);
        send_read(3'd2);
        send_write(3'd3, 16'hBEEF);
        send_read(3'd3);
    endtask

endclass
