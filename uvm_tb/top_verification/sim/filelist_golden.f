// filelist_golden.f
// RTL para la verificacion del top con golden model DPI-C.
// Usa las mismas rutas que el filelist.f del env UVM del top.
//
// Si ya consolidaste a project/rtl/ (Opcion A), apunta ahi:
//   ../../../rtl/<archivo>.sv
// Si aun usas las copias en uvm_tb (Opcion C), usa estas rutas:

+incdir+../../../rtl

// Dependencias RTL: todos los submodulos ya firmados
../../../rtl/mux4.sv
../../../rtl/mux4_registered.sv
../../../rtl/mux2.sv
../../../rtl/mux2_registered.sv
../../../rtl/register_bank.sv
../../../rtl/memory.sv
../../../rtl/alu.sv
../../../rtl/control.sv

// RTL del bloque top
../../../rtl/top.sv
