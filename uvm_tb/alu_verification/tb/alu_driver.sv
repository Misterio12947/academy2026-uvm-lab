//------------------------------------------------------------------------------
// alu_driver.sv
// Driver: recibe transacciones del sequencer y las maneja sobre el vif
// via clocking block (drv_cb) para evitar race conditions.
//------------------------------------------------------------------------------
class alu_driver extends uvm_driver#(alu_transaction);

    `uvm_component_utils(alu_driver)

    virtual alu_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "No se encontro el vif en el config_db")
    endfunction

    task run_phase(uvm_phase phase);
        // Estado seguro inicial
        vif.drv_cb.in1          <= '0;
        vif.drv_cb.in2          <= '0;
        vif.drv_cb.op           <= '0;
        vif.drv_cb.invalid_data <= 1'b0;

        forever begin
            alu_transaction req;
            seq_item_port.get_next_item(req);
            drive_item(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_item(alu_transaction item);
        @(vif.drv_cb);
        vif.drv_cb.in1          <= item.in1;
        vif.drv_cb.in2          <= item.in2;
        vif.drv_cb.op           <= item.op;
        vif.drv_cb.invalid_data <= item.invalid_data;
        // Un ciclo mas para que el monitor pueda samplear
        @(vif.drv_cb);
    endtask

endclass
