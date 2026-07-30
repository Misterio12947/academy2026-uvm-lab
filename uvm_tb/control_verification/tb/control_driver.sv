//------------------------------------------------------------------------------
// control_driver.sv
// Driver. Reset inicial + estimulos cmd_in/p_error. Reset mid-sequence
// segun assert_reset.
//------------------------------------------------------------------------------
class control_driver extends uvm_driver#(control_transaction);

    `uvm_component_utils(control_driver)

    virtual control_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual control_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "No se encontro el vif en el config_db")
    endfunction

    task run_phase(uvm_phase phase);
        // Estado seguro + reset inicial
        vif.drv_cb.cmd_in  <= 7'h00;
        vif.drv_cb.p_error <= 1'b0;
        reset_dut();

        forever begin
            control_transaction req;
            seq_item_port.get_next_item(req);
            if (req.assert_reset)
                inject_reset();
            else
                drive_item(req);
            seq_item_port.item_done();
        end
    endtask

    task reset_dut();
        vif.rst = 1'b1;
        repeat (2) @(vif.drv_cb);
        vif.rst = 1'b0;
        @(vif.drv_cb);
    endtask

    task inject_reset();
        vif.rst = 1'b1;
        @(vif.drv_cb);
        vif.rst = 1'b0;
        @(vif.drv_cb);
    endtask

    task drive_item(control_transaction item);
        @(vif.drv_cb);
        vif.drv_cb.cmd_in  <= item.get_cmd_in();
        vif.drv_cb.p_error <= item.p_error;
        @(vif.drv_cb);
    endtask

endclass
