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

    // Toggle para alternar modos de reset entre dirty y clean.
    // Ambos modos ejercitan bins distintos del coverage: dirty cubre
    // 'reset_write' (cp_action) via el NBA delay del wr_en; clean cubre
    // 'write_to_reset' y 'reset_to_write' (cp_transitions) via
    // asignaciones inmediatas que evitan el ciclo intermedio.
    bit reset_mode_toggle = 1'b0;

    task inject_reset();
        reset_mode_toggle = ~reset_mode_toggle;
        if (reset_mode_toggle)
            inject_reset_dirty();
        else
            inject_reset_clean();
    endtask

    // Reset "dirty": rst=1 inmediato pero wr_en via NBA (con output #1).
    // Si el estado previo era write (wr_en=1), el sample del primer edge
    // ve (wr_en=1, rst=1) = reset_write, cubriendo ese bin de cp_action.
    task inject_reset_dirty();
        vif.rst = 1'b1;
        vif.drv_cb.wr_en <= 1'b0;
        repeat (2) @(vif.drv_cb);
        vif.rst = 1'b0;
        @(vif.drv_cb);
    endtask

    // Reset "clean": wr_en y rst se asignan de forma INMEDIATA (bypasean
    // el clocking block) para eliminar la ventana intermedia de reset_write.
    // Cubre write_to_reset (si prev=write) porque el sample ve directamente
    // (wr_en=0, rst=1) = reset_only sin pasar por (11).
    // Al final, sube wr_en tambien inmediato para que el sig. sample vea
    // (wr_en=1, rst=0) = write, cubriendo reset_to_write.
    //
    // Fases intermedias adicionales fuerzan un sample de reset_write (11)
    // aunque el modo dirty no lo produzca de forma consistente en VCS.
    // Con esto el bin reset_write se cubre deterministicamente en cada
    // llamada de modo clean.
    task inject_reset_clean();
        vif.wr_en = 1'b0;
        vif.rst   = 1'b1;
        @(vif.drv_cb);        // sample: (0, 1) = reset_only.
                              // Trans prev->reset_only: write_to_reset o hold_to_reset.

        // Fase forzada: subir wr_en durante rst=1 para producir reset_write.
        vif.wr_en = 1'b1;
        @(vif.drv_cb);        // sample: (1, 1) = reset_write. Cubre cp_action.reset_write
                              // y cx_wr_en_rst[high][high] deterministicamente.

        // Regresar a reset_only para continuar el flow del clean reset.
        vif.wr_en = 1'b0;
        @(vif.drv_cb);        // sample: (0, 1) = reset_only.

        // Cierre del clean reset: rst=0 + wr_en=1 inmediato para reset_to_write.
        vif.rst   = 1'b0;
        vif.wr_en = 1'b1;
        @(vif.drv_cb);        // sample: (1, 0) = write. Trans reset_only->write = reset_to_write.

        vif.wr_en = 1'b0;     // Regresa a estado neutro para el proximo item.
        @(vif.drv_cb);        // sample: (0, 0) = hold.
    endtask

    // Escritura sincrona via clocking block
    task drive_write(regbank_transaction item);
        @(vif.drv_cb);
        vif.drv_cb.wr_en <= item.wr_en;
        vif.drv_cb.in    <= item.in;
        @(vif.drv_cb);   // ciclo para que el monitor pueda samplear
    endtask

endclass