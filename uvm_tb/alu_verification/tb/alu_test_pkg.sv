//------------------------------------------------------------------------------
// alu_test_pkg.sv
// Paquete que agrupa sequences y tests. Se separa de alu_pkg para permitir
// desarrollo independiente de tests sin recompilar la infraestructura.
//------------------------------------------------------------------------------
package alu_test_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import alu_pkg::*;

    // Orden de dependencia:
    //   sequences (usan alu_transaction del alu_pkg)
    //   tests (usan sequences y env)
    `include "alu_seq_rand.sv"
    `include "alu_directed_seq.sv"
    `include "alu_coverage_seq.sv"
    `include "alu_test.sv"

endpackage
