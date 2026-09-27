//------------------------------------------------------------------------------
// testbench.sv
// Top-level del testbench.
//   - Genera clk (solo para el harness; el DUT es combinacional)
//   - Instancia interface y DUT
//   - Publica el vif via config_db
//   - Lanza run_test()
//   - Dump de ondas: FSDB (Verdi/VCS) o gestionado por el simulador (Questa)
//------------------------------------------------------------------------------
module testbench;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import alu_pkg::*;
    import alu_test_pkg::*;

    // Clock del TB (100 MHz)
    logic clk;
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Interface
    alu_if #(.WIDTH(WIDTH)) alu_vif (.clk(clk));

    // DUT
    ALU #(.WIDTH(WIDTH)) dut (
        .in1          (alu_vif.in1),
        .in2          (alu_vif.in2),
        .op           (alu_vif.op),
        .invalid_data (alu_vif.invalid_data),
        .out          (alu_vif.out),
        .zero         (alu_vif.zero),
        .error        (alu_vif.error)
    );

    // Publicar vif y arrancar UVM
    initial begin
        uvm_config_db#(virtual alu_if)::set(null, "uvm_test_top.env.agent*", "vif", alu_vif);
        run_test();
    end

    // Dump para Verdi: SOLO bajo VCS (VCS define el macro `VCS automaticamente).
    // En Questa el volcado lo maneja sim/run.do:
    //   WAVE=wlf      -> log -r /*        (waveform clasico .wlf)
    //   WAVE=qwavedb  -> vsim -qwavedb    (Visualizer / qwave.db)
`ifdef VCS
    initial begin
        $fsdbDumpfile("waves.fsdb");
        $fsdbDumpvars(0, testbench);
    end
`endif

    // Watchdog: previene simulaciones infinitas si algo se cuelga.
    // Excluido de coverage (ver sim/cov_exclude.do): solo corre si el env falla.
    initial begin
        #500us;
        `uvm_fatal("TB", "Watchdog: la simulacion excedio 500us")
    end

endmodule
