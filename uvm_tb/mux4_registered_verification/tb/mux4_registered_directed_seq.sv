//------------------------------------------------------------------------------
// mux4_registered_directed_seq.sv
// Casos borde: cada select capturado, hold sostenido, back-to-back writes,
// reset intercalado.
//------------------------------------------------------------------------------
class mux4_registered_directed_seq extends uvm_sequence#(mux4_registered_transaction);

    `uvm_object_utils(mux4_registered_directed_seq)

    function new(string name = "mux4_registered_directed_seq");
        super.new(name);
    endfunction

    task send_write(bit [1:0] s, bit [WIDTH-1:0] d1, d2, d3, d4, bit enable);
        mux4_registered_transaction req = mux4_registered_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {
            sel          == s;
            in1          == d1;
            in2          == d2;
            in3          == d3;
            in4          == d4;
            wr_en        == enable;
            assert_reset == 1'b0;
        })
            `uvm_error("SEQ", "randomize() fallo en directed write")
        finish_item(req);
    endtask

    task send_reset();
        mux4_registered_transaction req = mux4_registered_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with { assert_reset == 1'b1; })
            `uvm_error("SEQ", "randomize() fallo en directed reset")
        finish_item(req);
    endtask

    task body();
        // Bloque 1: cada select capturado
        send_write(2'b00, 8'hAA, 8'hBB, 8'hCC, 8'hDD, 1'b1);
        send_write(2'b01, 8'hAA, 8'hBB, 8'hCC, 8'hDD, 1'b1);
        send_write(2'b10, 8'hAA, 8'hBB, 8'hCC, 8'hDD, 1'b1);
        send_write(2'b11, 8'hAA, 8'hBB, 8'hCC, 8'hDD, 1'b1);

        // Bloque 2: hold sostenido (wr_en=0)
        repeat (5) send_write(2'b00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 1'b0);

        // Bloque 3: back-to-back writes con distintos selects
        send_write(2'b00, 8'h11, 8'h22, 8'h33, 8'h44, 1'b1);
        send_write(2'b01, 8'h11, 8'h22, 8'h33, 8'h44, 1'b1);
        send_write(2'b10, 8'h11, 8'h22, 8'h33, 8'h44, 1'b1);
        send_write(2'b11, 8'h11, 8'h22, 8'h33, 8'h44, 1'b1);

        // Bloque 4: reset y write inmediato
        send_reset();
        send_write(2'b00, 8'hBE, 8'h00, 8'h00, 8'h00, 1'b1);

        // Bloque 5: toggle write/hold con select fijo
        send_write(2'b10, 8'h01, 8'h02, 8'h04, 8'h08, 1'b1);
        send_write(2'b10, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 1'b0);
        send_write(2'b10, 8'h10, 8'h20, 8'h40, 8'h80, 1'b1);
    endtask

endclass
