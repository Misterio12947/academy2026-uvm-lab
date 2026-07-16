//------------------------------------------------------------------------------
// regbank_driver.sv
// Driver del register_bank.
//   - Aplica un reset inicial al arranque de run_phase.
//   - Por cada tx recibida:
//       * Si assert_reset=1: pulso de reset asincrono >= 2 ciclos (garantiza
//         visibilidad en al menos un edge del monitor).
//       * Si assert_reset=0: escritura sincrona via drv_cb.
//   - rst se maneja fuera del clocking block (senal asincrona por definicion).
//------------------------------------------------------------------------------
class regbank_driver extends uvm_driver#(regbank_transaction);

    `uvm_component_utils(regbank_driver)

    virtual regbank_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual regbank_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "No se encontro el vif en el config_db")
    endfunction

    task run_phase(uvm_phase phase);
        // Estado seguro inicial + reset del DUT
        vif.drv_cb.wr_en <= 1'b0;
        vif.drv_cb.in    <= '0;
        reset_dut();

        forever begin
            regbank_transaction req;
            seq_item_port.get_next_item(req);
            if (req.assert_reset)
                inject_reset();
            else
                drive_write(req);
            seq_item_port.item_done();
        end
    endtask

    // Reset inicial: rst=1 por 3 ciclos, luego libera
    task reset_dut();
        vif.rst = 1'b1;
        repeat (3) @(vif.drv_cb);
        vif.rst = 1'b0;
        @(vif.drv_cb);
    endtask

    // Reset mid-sequence: >= 2 ciclos para garantizar visibilidad en edge
    task inject_reset();
        vif.rst = 1'b1;
        vif.drv_cb.wr_en <= 1'b0;
        repeat (2) @(vif.drv_cb);
        vif.rst = 1'b0;
        @(vif.drv_cb);
    endtask

    // Escritura sincrona via clocking block
    task drive_write(regbank_transaction item);
        @(vif.drv_cb);
        vif.drv_cb.wr_en <= item.wr_en;
        vif.drv_cb.in    <= item.in;
        @(vif.drv_cb);   // ciclo para que el monitor pueda samplear
    endtask

endclass
