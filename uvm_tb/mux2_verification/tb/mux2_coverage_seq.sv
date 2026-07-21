//------------------------------------------------------------------------------
// mux2_coverage_seq.sv
// Sequence orientada a cerrar coverage funcional.
//------------------------------------------------------------------------------
class mux2_coverage_seq extends uvm_sequence#(mux2_transaction);

    `uvm_object_utils(mux2_coverage_seq)

    function new(string name = "mux2_coverage_seq");
        super.new(name);
    endfunction

    task send_constrained(bit sel);
        mux2_transaction req = mux2_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with { select == sel; })
            `uvm_error("SEQ", "randomize() fallo en coverage_seq")
        finish_item(req);
    endtask

    task send_directed(bit [WIDTH-1:0] d1, d2, bit sel);
        mux2_transaction req = mux2_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {
            din1   == d1;
            din2   == d2;
            select == sel;
        })
            `uvm_error("SEQ", "randomize() fallo en coverage_seq directed")
        finish_item(req);
    endtask

    task body();
        int unsigned reps = 40;

        // Loop principal: cada select ejercitado varias veces con random
        for (int s = 0; s < 2; s++) begin
            repeat (reps) send_constrained(s[0]);
        end

        // Directed: cada select con din seleccionado en valores extremos
        send_directed(8'h00, 8'hAA, 1'b0);
        send_directed(8'hAA, 8'h00, 1'b1);
        send_directed(8'hFF, 8'h55, 1'b0);
        send_directed(8'h55, 8'hFF, 1'b1);

        // Extremos en todas las entradas
        send_directed(8'h00, 8'h00, 1'b0);
        send_directed(8'hFF, 8'hFF, 1'b0);
        send_directed(8'h10, 8'h80, 1'b0);
        send_directed(8'h80, 8'h10, 1'b1);
        send_directed(8'hF0, 8'h50, 1'b0);
        send_directed(8'h50, 8'hF0, 1'b1);
    endtask

endclass
