//------------------------------------------------------------------------------
// control_opcode_sweep_seq.sv
// Barrido de cada opcode ISA con cada combinacion de muxA/muxB.
// Cierra cx_state_isa y cp_muxA/cp_muxB.
//------------------------------------------------------------------------------
class control_opcode_sweep_seq extends uvm_sequence#(control_transaction);

    `uvm_object_utils(control_opcode_sweep_seq)

    function new(string name = "control_opcode_sweep_seq");
        super.new(name);
    endfunction

    task send(bit [1:0] mA, bit [1:0] mB, bit [2:0] op);
        control_transaction req = control_transaction::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {
            muxA         == mA;
            muxB         == mB;
            isa_op       == op;
            p_error      == 1'b0;
            assert_reset == 1'b0;
        })
            `uvm_error("SEQ", "randomize() fallo en sweep")
        finish_item(req);
    endtask

    task body();
        // Para cada opcode, cada combinacion de muxA (4) x muxB (4) = 16
        // Repetido 4 ciclos para que cada instruccion pase por los 4 estados
        for (int op = 0; op < 8; op++) begin
            for (int a = 0; a < 4; a++) begin
                for (int b = 0; b < 4; b++) begin
                    repeat (4) send(a[1:0], b[1:0], op[2:0]);
                end
            end
        end
    endtask

endclass
