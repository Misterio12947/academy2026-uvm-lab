# ==========================================================================
# run_syn.tcl - Orquestador del flujo de synthesis
# ==========================================================================
# EJECUCION (desde syn/work/):
#   dc_shell -f ../scripts/run_syn.tcl | tee logs/synthesis.log
# ==========================================================================

echo "########################################"
echo "#  Synthesis CPU multiciclo (top)      #"
echo "#  Target: SKY130 sky130_fd_sc_hd      #"
echo "########################################"

source ../scripts/setup.tcl
source ../scripts/read_design.tcl
source ../scripts/compile.tcl

echo "########################################"
echo "#  Flujo completo terminado            #"
echo "########################################"

exit