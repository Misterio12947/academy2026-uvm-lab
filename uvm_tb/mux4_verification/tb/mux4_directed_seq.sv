//------------------------------------------------------------------------------
// mux4_directed_seq.sv
// Sequence directed: cada select con al menos un caso en cada rango extremo,
// mas patrones alternados.
//------------------------------------------------------------------------------
class mux4_directed_seq extends uvm_sequence#(mux4_transaction);

    `uvm_object_utils(mux4_directed_seq)

    function new(string name = "mux4_directed_seq");
        super.new(name);
    endfunction

    task send(bit [WIDTH-1:0] d1, d2, d3, d4, bit [1:0] sel);
        mux4_transaction req = mux4_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {
            din1   == d1;
            din2   == d2;
            din3   == d3;
            din4   == d4;
            select == sel;
        })
            `uvm_error("SEQ", "randomize() fallo en directed")
        finish_item(req);
    endtask

    task body();
        // Cada select con valores distintivos
        send(8'hAA, 8'hBB, 8'hCC, 8'hDD, 2'b00);
        send(8'hAA, 8'hBB, 8'hCC, 8'hDD, 2'b01);
        send(8'hAA, 8'hBB, 8'hCC, 8'hDD, 2'b10);
        send(8'hAA, 8'hBB, 8'hCC, 8'hDD, 2'b11);

        // Cada select con din seleccionado en 0x00
        send(8'h00, 8'hFF, 8'hFF, 8'hFF, 2'b00);
        send(8'hFF, 8'h00, 8'hFF, 8'hFF, 2'b01);
        send(8'hFF, 8'hFF, 8'h00, 8'hFF, 2'b10);
        send(8'hFF, 8'hFF, 8'hFF, 8'h00, 2'b11);

        // Cada select con din seleccionado en 0xFF
        send(8'hFF, 8'h00, 8'h00, 8'h00, 2'b00);
        send(8'h00, 8'hFF, 8'h00, 8'h00, 2'b01);
        send(8'h00, 8'h00, 8'hFF, 8'h00, 2'b10);
        send(8'h00, 8'h00, 8'h00, 8'hFF, 2'b11);

        // Patrones alternados
        send(8'h5A, 8'hA5, 8'h3C, 8'hC3, 2'b00);
        send(8'h5A, 8'hA5, 8'h3C, 8'hC3, 2'b01);
        send(8'h5A, 8'hA5, 8'h3C, 8'hC3, 2'b10);
        send(8'h5A, 8'hA5, 8'h3C, 8'hC3, 2'b11);
    endtask

endclass
