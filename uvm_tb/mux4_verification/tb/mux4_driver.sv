//------------------------------------------------------------------------------
// mux4_driver.sv
// Driver del mux4: recibe transacciones del sequencer y las maneja sobre
// el vif via clocking block (drv_cb) para evitar race conditions.
//------------------------------------------------------------------------------
class mux4_driver extends uvm_driver#(mux4_transaction);

    `uvm_component_utils(mux4_driver)

    virtual mux4_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual mux4_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "No se encontro el vif en el config_db")
    endfunction

    task run_phase(uvm_phase phase);
        // Estado seguro inicial
        vif.drv_cb.din1   <= '0;
        vif.drv_cb.din2   <= '0;
        vif.drv_cb.din3   <= '0;
        vif.drv_cb.din4   <= '0;
        vif.drv_cb.select <= '0;

        forever begin
            mux4_transaction req;
            seq_item_port.get_next_item(req);
            drive_item(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_item(mux4_transaction item);
        @(vif.drv_cb);
        vif.drv_cb.din1   <= item.din1;
        vif.drv_cb.din2   <= item.din2;
        vif.drv_cb.din3   <= item.din3;
        vif.drv_cb.din4   <= item.din4;
        vif.drv_cb.select <= item.select;
        // Un ciclo mas para que el monitor pueda samplear
        @(vif.drv_cb);
    endtask

endclass
