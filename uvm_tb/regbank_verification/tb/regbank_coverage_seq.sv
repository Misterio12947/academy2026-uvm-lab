//------------------------------------------------------------------------------
// regbank_coverage_seq.sv
// Sequence orientada a cerrar coverage funcional. Fuerza combinaciones
// especificas para cubrir todos los bins del cx_wr_en_rst y las transiciones.
//------------------------------------------------------------------------------
class regbank_coverage_seq extends uvm_sequence#(regbank_transaction);

    `uvm_object_utils(regbank_coverage_seq)

    function new(string name = "regbank_coverage_seq");
        super.new(name);
    endfunction

    task send_action(bit wr, bit rst_flag, bit [WIDTH-1:0] value);
        regbank_transaction req = regbank_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {
            wr_en        == wr;
            in           == value;
            assert_reset == rst_flag;
        })
            `uvm_error("SEQ", "randomize() fallo en coverage_seq")
        finish_item(req);
    endtask

    task body();
        // Loop 1: ejercitar todas las combinaciones (wr_en, assert_reset)
        // varias veces con valores variados para poblar cx_wr_en_rst y cp_in
        int unsigned reps = 20;

        // 40 writes normales (wr_en=1, rst=0) con valores en todos los rangos
        repeat (reps) send_action(1'b1, 1'b0, 8'h00);        // in=zero
        repeat (reps) send_action(1'b1, 1'b0, 8'h10);        // in=low
        repeat (reps) send_action(1'b1, 1'b0, 8'h80);        // in=mid
        repeat (reps) send_action(1'b1, 1'b0, 8'hF0);        // in=high
        repeat (reps) send_action(1'b1, 1'b0, 8'hFF);        // in=max

        // Holds sostenidos de varias duraciones (para cg_hold_duration)
        // 1-ciclo hold
        send_action(1'b1, 1'b0, 8'h5A);
        send_action(1'b0, 1'b0, 8'h00);
        send_action(1'b1, 1'b0, 8'hA5);

        // Short hold (3 ciclos)
        send_action(1'b1, 1'b0, 8'h5A);
        repeat (3) send_action(1'b0, 1'b0, 8'h00);
        send_action(1'b1, 1'b0, 8'hA5);

        // Medium hold (10 ciclos)
        send_action(1'b1, 1'b0, 8'h5A);
        repeat (10) send_action(1'b0, 1'b0, 8'h00);
        send_action(1'b1, 1'b0, 8'hA5);

        // Long hold (25 ciclos)
        send_action(1'b1, 1'b0, 8'h5A);
        repeat (25) send_action(1'b0, 1'b0, 8'h00);

        // Resets intercalados (para cx_wr_en_rst con rst=1)
        repeat (5) begin
            send_action(1'b0, 1'b1, 8'h00);
            send_action(1'b1, 1'b0, 8'hAB);
        end

        // Rafaga final de transiciones criticas
        // hold -> write -> hold -> reset -> write -> reset -> hold
        send_action(1'b0, 1'b0, 8'h00);
        send_action(1'b1, 1'b0, 8'h11);
        send_action(1'b0, 1'b0, 8'h00);
        send_action(1'b0, 1'b1, 8'h00);
        send_action(1'b1, 1'b0, 8'h22);
        send_action(1'b0, 1'b1, 8'h00);
        send_action(1'b0, 1'b0, 8'h00);
    endtask

endclass
