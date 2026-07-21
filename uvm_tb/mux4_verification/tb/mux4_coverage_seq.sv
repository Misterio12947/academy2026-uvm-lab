//------------------------------------------------------------------------------
// mux4_coverage_seq.sv
// Sequence orientada a cerrar coverage funcional. Recorre exhaustivamente
// cada select con valores en todos los rangos.
//------------------------------------------------------------------------------
class mux4_coverage_seq extends uvm_sequence#(mux4_transaction);

    `uvm_object_utils(mux4_coverage_seq)

    function new(string name = "mux4_coverage_seq");
        super.new(name);
    endfunction

    task send_constrained(bit [1:0] sel);
        mux4_transaction req = mux4_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with { select == sel; })
            `uvm_error("SEQ", "randomize() fallo en coverage_seq")
        finish_item(req);
    endtask

    task send_directed(bit [WIDTH-1:0] d1, d2, d3, d4, bit [1:0] sel);
        mux4_transaction req = mux4_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {
            din1   == d1;
            din2   == d2;
            din3   == d3;
            din4   == d4;
            select == sel;
        })
            `uvm_error("SEQ", "randomize() fallo en coverage_seq directed")
        finish_item(req);
    endtask

    task body();
        int unsigned reps = 30;

        // Loop principal: cada select ejercitado varias veces con random
        // para poblar cp_din1..cp_din4 y cp_dout en todos los rangos
        for (int s = 0; s < 4; s++) begin
            repeat (reps) send_constrained(s[1:0]);
        end

        // Directed: cada select con din seleccionado en valores extremos
        // para cerrar cg_edge_cases
        // Extremos zero
        send_directed(8'h00, 8'hAA, 8'hAA, 8'hAA, 2'b00);
        send_directed(8'hAA, 8'h00, 8'hAA, 8'hAA, 2'b01);
        send_directed(8'hAA, 8'hAA, 8'h00, 8'hAA, 2'b10);
        send_directed(8'hAA, 8'hAA, 8'hAA, 8'h00, 2'b11);
        // Extremos max
        send_directed(8'hFF, 8'h55, 8'h55, 8'h55, 2'b00);
        send_directed(8'h55, 8'hFF, 8'h55, 8'h55, 2'b01);
        send_directed(8'h55, 8'h55, 8'hFF, 8'h55, 2'b10);
        send_directed(8'h55, 8'h55, 8'h55, 8'hFF, 2'b11);

        // Extremos en todas las entradas simultaneas (para cerrar cp_dinN)
        send_directed(8'h00, 8'h00, 8'h00, 8'h00, 2'b00);
        send_directed(8'hFF, 8'hFF, 8'hFF, 8'hFF, 2'b00);
        send_directed(8'h10, 8'h80, 8'hF0, 8'h50, 2'b01);
        send_directed(8'h80, 8'h10, 8'h50, 8'hF0, 2'b10);
    endtask

endclass
