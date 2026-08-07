// filelist_golden.f
// RTL para la verificacion del top con golden model DPI-C.
// Usa las mismas rutas que el filelist.f del env UVM del top.
//
// Si ya consolidaste a project/rtl/ (Opcion A), apunta ahi:
//   ../../../rtl/<archivo>.sv
// Si aun usas las copias en uvm_tb (Opcion C), usa estas rutas:

+incdir+../rtl

// Dependencias RTL: todos los submodulos ya firmados
../../mux4_verification/rtl/mux4.sv
../../mux4_registered_verification/rtl/mux4_registered.sv
../../mux2_verification/rtl/mux2.sv
../../mux2_registered_verification/rtl/mux2_registered.sv
../../regbank_verification/rtl/register_bank.sv
../../memory_verification/rtl/memory.sv
../../alu_verification/rtl/alu.sv
../../control_verification/rtl/control.sv

// RTL del bloque top
../rtl/top.sv
