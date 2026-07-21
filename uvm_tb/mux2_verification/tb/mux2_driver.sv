//------------------------------------------------------------------------------
// mux2_driver.sv
//------------------------------------------------------------------------------
class mux2_driver extends uvm_driver#(mux2_transaction);

    `uvm_component_utils(mux2_driver)

    virtual mux2_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual mux2_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "No se encontro el vif en el config_db")
    endfunction

    task run_phase(uvm_phase phase);
        vif.drv_cb.din1   <= '0;
        vif.drv_cb.din2   <= '0;
        vif.drv_cb.select <= 1'b0;

        forever begin
            mux2_transaction req;
            seq_item_port.get_next_item(req);
            drive_item(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_item(mux2_transaction item);
        @(vif.drv_cb);
        vif.drv_cb.din1   <= item.din1;
        vif.drv_cb.din2   <= item.din2;
        vif.drv_cb.select <= item.select;
        @(vif.drv_cb);
    endtask

endclass
