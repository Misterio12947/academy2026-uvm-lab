//==============================================================================
// alu_cov_excludes.el
//
// Exclusion file para URG. Cierra holes de coverage estructural que son
// unreachable-by-design en el RTL de la ALU.
//
// Uso:
//   urg -dir simv.vdb -format both -report cov_report -elfile alu_cov_excludes.el
//
// Nota: los numeros de linea corresponden a rtl/alu.sv en el commit
// actual. Si el RTL se modifica, regenerar este archivo con Verdi:
//   1. make verdi
//   2. En Coverage view seleccionar los holes
//   3. Right-click -> Exclude -> agregar annotation
//   4. File -> Save Exclusion File -> alu_cov_excludes.el
//==============================================================================

CHECKSUM: ""

//------------------------------------------------------------------------------
// ALU: default del unique case (rtl/alu.sv, lineas 74-78)
//
// op[2:0] son 3 bits y las 8 combinaciones (ADD, SUB, MUL, DIV, NOP0, LOAD,
// STORE, NOP1) estan enumeradas explicitamente en el case. El default nunca
// se ejecuta en simulacion 2-estados con opcode valido. Existe como defensa
// contra corrupcion de X propagada desde el entorno.
//------------------------------------------------------------------------------
INSTANCE: testbench.dut
ANNOTATION: "Default del unique case unreachable-by-design (opcode 3-bit enumerado completo)"
Line 74
Line 75
Line 76
Line 77
Line 78
