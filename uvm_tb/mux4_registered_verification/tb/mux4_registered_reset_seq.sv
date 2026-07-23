//------------------------------------------------------------------------------
// mux4_registered_reset_seq.sv
// Escenarios de reset asincrono especificos.
//------------------------------------------------------------------------------
class mux4_registered_reset_seq extends uvm_sequence#(mux4_registered_transaction);

    `uvm_object_utils(mux4_registered_reset_seq)

    function new(string name = "mux4_registered_reset_seq");
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
            `uvm_error("SEQ", "randomize() fallo")
        finish_item(req);
    endtask

    task send_reset();
        mux4_registered_transaction req = mux4_registered_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with { assert_reset == 1'b1; })
            `uvm_error("SEQ", "randomize() fallo en reset")
        finish_item(req);
    endtask

    task body();
        // A: reset simple + write + reset + write
        send_write(2'b00, 8'hAB, 8'h00, 8'h00, 8'h00, 1'b1);
        send_reset();
        send_write(2'b01, 8'h00, 8'hCD, 8'h00, 8'h00, 1'b1);
        send_reset();
        send_write(2'b10, 8'h00, 8'h00, 8'hEF, 8'h00, 1'b1);

        // B: dos resets consecutivos
        send_reset();
        send_reset();

        // C: write, hold, reset
        send_write(2'b11, 8'h00, 8'h00, 8'h00, 8'h77, 1'b1);
        send_write(2'b11, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 1'b0);
        send_write(2'b11, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 1'b0);
        send_reset();

        // D: reset + hold sostenido
        send_reset();
        repeat (3) send_write(2'b00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 1'b0);

        // E: reset + rafaga de writes con distintos selects
        send_reset();
        send_write(2'b00, 8'h10, 8'h20, 8'h30, 8'h40, 1'b1);
        send_write(2'b01, 8'h10, 8'h20, 8'h30, 8'h40, 1'b1);
        send_write(2'b10, 8'h10, 8'h20, 8'h30, 8'h40, 1'b1);
        send_write(2'b11, 8'h10, 8'h20, 8'h30, 8'h40, 1'b1);
    endtask

endclass
