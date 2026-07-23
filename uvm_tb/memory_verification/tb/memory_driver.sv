//------------------------------------------------------------------------------
// memory_driver.sv
// Driver simple: solo maneja los estimulos sincronos. No hay reset.
//------------------------------------------------------------------------------
class memory_driver extends uvm_driver#(memory_transaction);

    `uvm_component_utils(memory_driver)

    virtual memory_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual memory_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "No se encontro el vif en el config_db")
    endfunction

    task run_phase(uvm_phase phase);
        // Estado seguro inicial
        vif.drv_cb.memoryWrite     <= 1'b0;
        vif.drv_cb.memoryRead      <= 1'b0;
        vif.drv_cb.memoryAddress   <= '0;
        vif.drv_cb.memoryWriteData <= '0;

        forever begin
            memory_transaction req;
            seq_item_port.get_next_item(req);
            drive_item(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_item(memory_transaction item);
        @(vif.drv_cb);
        vif.drv_cb.memoryWrite     <= item.memoryWrite;
        vif.drv_cb.memoryRead      <= item.memoryRead;
        vif.drv_cb.memoryAddress   <= item.memoryAddress;
        vif.drv_cb.memoryWriteData <= item.memoryWriteData;
        @(vif.drv_cb);
    endtask

endclass
