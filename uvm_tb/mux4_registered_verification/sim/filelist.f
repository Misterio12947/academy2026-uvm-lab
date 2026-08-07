// Directorios de includes
+incdir+../tb
+incdir+../../../rtl

// Dependencias RTL (single source of truth, sin duplicacion)
../../../rtl/mux4.sv
../../../rtl/register_bank.sv

// RTL del bloque
../../../rtl/mux4_registered.sv

// Verificacion: interface, paquetes y top
../tb/mux4_registered_if.sv
../tb/mux4_registered_pkg.sv
../tb/mux4_registered_test_pkg.sv
../tb/testbench.sv
