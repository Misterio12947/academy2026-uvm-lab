//------------------------------------------------------------------------------
// mux4_registered_driver.sv
// Driver combinando:
//   - Reset inicial (reset_dut) igual que regbank
//   - Reset mid-sequence con toggle dirty/clean (garantiza reset_write bin)
//   - Drive de wr_en, sel, in1..in4 igual que mux4 base
//------------------------------------------------------------------------------
class mux4_registered_driver extends uvm_driver#(mux4_registered_transaction);

    `uvm_component_utils(mux4_registered_driver)

    virtual mux4_registered_if vif;

    // Toggle para alternar modos de reset (dirty/clean)
    bit reset_mode_toggle = 1'b0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual mux4_registered_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "No se encontro el vif en el config_db")
    endfunction

    task run_phase(uvm_phase phase);
        // Estado seguro inicial + reset del DUT
        vif.drv_cb.wr_en <= 1'b0;
        vif.drv_cb.sel   <= 2'b00;
        vif.drv_cb.in1   <= '0;
        vif.drv_cb.in2   <= '0;
        vif.drv_cb.in3   <= '0;
        vif.drv_cb.in4   <= '0;
        reset_dut();

        forever begin
            mux4_registered_transaction req;
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

    // Alterna dirty/clean cada llamada
    task inject_reset();
        reset_mode_toggle = ~reset_mode_toggle;
        if (reset_mode_toggle)
            inject_reset_dirty();
        else
            inject_reset_clean();
    endtask

    // Dirty: NBA delay del wr_en -> genera reset_write si prev era write
    task inject_reset_dirty();
        vif.rst = 1'b1;
        vif.drv_cb.wr_en <= 1'b0;
        repeat (2) @(vif.drv_cb);
        vif.rst = 1'b0;
        @(vif.drv_cb);
    endtask

    // Clean: asignaciones inmediatas + fuerza reset_write mid-reset
    task inject_reset_clean();
        vif.wr_en = 1'b0;
        vif.rst   = 1'b1;
        @(vif.drv_cb);        // reset_only
        vif.wr_en = 1'b1;
        @(vif.drv_cb);        // reset_write (guaranteed)
        vif.wr_en = 1'b0;
        @(vif.drv_cb);        // reset_only
        vif.rst   = 1'b0;
        vif.wr_en = 1'b1;
        @(vif.drv_cb);        // write (reset_to_write)
        vif.wr_en = 1'b0;
        @(vif.drv_cb);        // hold
    endtask

    // Escritura sincrona via clocking block
    task drive_write(mux4_registered_transaction item);
        @(vif.drv_cb);
        vif.drv_cb.wr_en <= item.wr_en;
        vif.drv_cb.sel   <= item.sel;
        vif.drv_cb.in1   <= item.in1;
        vif.drv_cb.in2   <= item.in2;
        vif.drv_cb.in3   <= item.in3;
        vif.drv_cb.in4   <= item.in4;
        @(vif.drv_cb);
    endtask

endclass
