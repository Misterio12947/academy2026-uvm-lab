//------------------------------------------------------------------------------
// control_monitor.sv
// Samplea todas las salidas del control post-edge. Reconstruye el estado
// observado replicando la FSM (necesario porque current_state es interno).
//------------------------------------------------------------------------------
class control_monitor extends uvm_monitor;

    `uvm_component_utils(control_monitor)

    virtual control_if                        vif;
    uvm_analysis_port#(control_transaction)   ap;

    // Replica del estado de la FSM para etiquetar cada transaccion
    bit [1:0] model_state;
    bit       first_after_reset;

    // Estados (matches RTL)
    localparam bit [1:0] RST_ST       = 2'b00;
    localparam bit [1:0] FETCH_DECODE = 2'b01;
    localparam bit [1:0] EXECUTE      = 2'b10;
    localparam bit [1:0] STORE        = 2'b11;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual control_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "No se encontro el vif en el config_db")
    endfunction

    function bit [1:0] next_state(bit [1:0] s);
        case (s)
            RST_ST:       return FETCH_DECODE;
            FETCH_DECODE: return EXECUTE;
            EXECUTE:      return STORE;
            STORE:        return FETCH_DECODE;
            default:      return RST_ST;
        endcase
    endfunction

    task run_phase(uvm_phase phase);
        control_transaction tr;

        model_state       = RST_ST;
        first_after_reset = 1'b1;

        forever begin
            @(vif.mon_cb);

            // Manejo del reset asincrono: si rst=1, el estado vuelve a RST_ST
            if (vif.mon_cb.rst) begin
                model_state       = RST_ST;
                first_after_reset = 1'b1;
                continue;
            end

            if ($isunknown({vif.mon_cb.cmd_in, vif.mon_cb.opcode,
                            vif.mon_cb.in_select_a, vif.mon_cb.in_select_b}))
                continue;

            tr = control_transaction::type_id::create("tr");

            // Estimulos observados
            tr.muxA    = vif.mon_cb.cmd_in[6:5];
            tr.muxB    = vif.mon_cb.cmd_in[4:3];
            tr.isa_op  = vif.mon_cb.cmd_in[2:0];
            tr.p_error = vif.mon_cb.p_error;

            // Salidas observadas
            tr.rst            = vif.mon_cb.rst;
            tr.aluin_reg_en   = vif.mon_cb.aluin_reg_en;
            tr.datain_reg_en  = vif.mon_cb.datain_reg_en;
            tr.memoryWrite    = vif.mon_cb.memoryWrite;
            tr.memoryRead     = vif.mon_cb.memoryRead;
            tr.selmux2        = vif.mon_cb.selmux2;
            tr.cpu_rdy        = vif.mon_cb.cpu_rdy;
            tr.aluout_reg_en  = vif.mon_cb.aluout_reg_en;
            tr.nvalid_data    = vif.mon_cb.nvalid_data;
            tr.in_select_a    = vif.mon_cb.in_select_a;
            tr.in_select_b    = vif.mon_cb.in_select_b;
            tr.opcode         = vif.mon_cb.opcode;

            // Estado presente (las salidas Moore corresponden a este estado)
            tr.state_observed = model_state;
			tr.first_after_reset = first_after_reset;

            ap.write(tr);

            // Avanzar el modelo de estado para la siguiente muestra
            model_state       = next_state(model_state);
            first_after_reset = 1'b0;
        end
    endtask

endclass
