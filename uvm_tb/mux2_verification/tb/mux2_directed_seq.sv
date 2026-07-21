//------------------------------------------------------------------------------
// mux2_directed_seq.sv
// Sequence directed con casos borde derivados del standalone TB.
//------------------------------------------------------------------------------
class mux2_directed_seq extends uvm_sequence#(mux2_transaction);

    `uvm_object_utils(mux2_directed_seq)

    function new(string name = "mux2_directed_seq");
        super.new(name);
    endfunction

    task send(bit [WIDTH-1:0] d1, d2, bit sel);
        mux2_transaction req = mux2_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {
            din1   == d1;
            din2   == d2;
            select == sel;
        })
            `uvm_error("SEQ", "randomize() fallo en directed")
        finish_item(req);
    endtask

    task body();
        // Cada select con valores distintivos
        send(8'hAA, 8'hBB, 1'b0);
        send(8'hAA, 8'hBB, 1'b1);

        // Cada select con din seleccionado en 0x00
        send(8'h00, 8'hFF, 1'b0);
        send(8'hFF, 8'h00, 1'b1);

        // Cada select con din seleccionado en 0xFF
        send(8'hFF, 8'h00, 1'b0);
        send(8'h00, 8'hFF, 1'b1);

        // Patrones alternados
        send(8'h5A, 8'hA5, 1'b0);
        send(8'h5A, 8'hA5, 1'b1);
        send(8'h3C, 8'hC3, 1'b0);
        send(8'h3C, 8'hC3, 1'b1);
    endtask

endclass
