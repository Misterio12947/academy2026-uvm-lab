//------------------------------------------------------------------------------
// top_driver.sv
// Driver a nivel de instruccion. Cada instruccion son 4 ciclos del CPU
// multiciclo. El driver mantiene cmd_in/din estables durante la instruccion
// y avanza al ritmo de cpu_rdy.
//
// Timing del CPU: RST_ST -> FETCH_DECODE -> EXECUTE -> STORE(cpu_rdy=1).
// El cmd_in se captura en RST_ST (primera) y en STORE (siguientes), asi que
// mantenemos cmd_in estable y esperamos el ciclo cpu_rdy antes de cambiarlo.
//------------------------------------------------------------------------------
class top_driver extends uvm_driver#(top_transaction);

    `uvm_component_utils(top_driver)

    virtual top_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual top_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "No se encontro el vif en el config_db")
    endfunction

    task run_phase(uvm_phase phase);
        vif.drv_cb.cmd_in <= 7'h00;
        vif.drv_cb.din_1  <= '0;
        vif.drv_cb.din_2  <= '0;
        vif.drv_cb.din_3  <= '0;
        reset_dut();

        forever begin
            top_transaction req;
            seq_item_port.get_next_item(req);
            if (req.assert_reset)
                inject_reset();
            else
                drive_instruction(req);
            seq_item_port.item_done();
        end
    endtask

    task reset_dut();
        vif.rst = 1'b1;
        repeat (3) @(vif.drv_cb);
        vif.rst = 1'b0;
        @(vif.drv_cb);
    endtask

    task inject_reset();
        vif.rst = 1'b1;
        repeat (2) @(vif.drv_cb);
        vif.rst = 1'b0;
        @(vif.drv_cb);
    endtask

    // Presenta una instruccion y espera los 4 ciclos hasta cpu_rdy
    task drive_instruction(top_transaction item);
        vif.drv_cb.cmd_in <= item.get_cmd_in();
        vif.drv_cb.din_1  <= item.din_1;
        vif.drv_cb.din_2  <= item.din_2;
        vif.drv_cb.din_3  <= item.din_3;
        // Mantener estable durante toda la instruccion (4 ciclos)
        repeat (4) @(vif.drv_cb);
    endtask

endclass
