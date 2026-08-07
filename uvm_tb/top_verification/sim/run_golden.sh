#!/bin/bash
#==============================================================================
# run_golden.sh
# Corre la verificacion del top vs golden model (DPI-C) con VCS.
#
# El golden model en C (cpu_model.c) se compila junto con el TB via -CFLAGS.
# VCS lo linkea automaticamente y las funciones import "DPI-C" del TB llaman
# al C nativo durante la simulacion.
#==============================================================================

# Ruta a los RTL (ajustar segun la estructura: fuente unica en rtl/ o en uvm_tb)
RTL_DIR="../../../rtl"        # si ya consolidaste a project/rtl (Opcion A)
# RTL_DIR alternativo si aun usas las copias en uvm_tb (Opcion C):
# usa el filelist.f del bloque top que ya referencia los submodulos.

echo "=== Compilando top + golden model (DPI-C) con VCS ==="

vcs -full64 -sverilog -debug_access+all \
    -timescale=1ns/1ps \
    -CFLAGS "-I." \
    ../golden/cpu_model.c \
    -f filelist_golden.f \
    ../golden/tb_top_golden.sv \
    -top tb_top_golden \
    -l golden_compile.log -o simv_golden

if [ $? -ne 0 ]; then
    echo "ERROR: fallo la compilacion. Ver golden_compile.log"
    exit 1
fi

echo "=== Simulando ==="
./simv_golden -l golden_sim.log

echo ""
echo "=== Resultado ==="
grep -E "Ciclos comparados|Mismatches|GOLDEN MODEL MATCH|MISMATCHES" golden_sim.log
