#-------------------------------------------------------------------------------
# Makefile para verificacion UVM del ALU  -  Flujo QUESTA (Questa One)
#
# Flujo clasico de 3 pasos: vlib -> vlog -> vopt -> vsim
#
# Targets principales:
#   make comp                - crea lib work y compila design + TB (vlog)
#   make opt                 - optimiza + instrumenta coverage (vopt)
#   make sim   TEST=<test>   - ejecuta simulacion (default: alu_regression_test)
#   make cov                 - fusiona UCDBs y genera reporte HTML (vcover)
#   make visualizer          - abre Visualizer con el ultimo qwave.db
#   make regress             - corre los 3 tests principales y reporta
#   make clean               - borra artefactos
#
# Ondas (variable WAVE):
#   WAVE=none      (default) sin volcado, corre rapido (regresion)
#   WAVE=wlf       volcado clasico .wlf  (log -r /*)   -> ver con: vsim -view vsim.wlf
#   WAVE=qwavedb   volcado Visualizer (qwave.db)       -> ver con: make visualizer
#
# Tests disponibles:
#   alu_random_test / alu_directed_test / alu_coverage_test
#   alu_regression_test  (default)
#-------------------------------------------------------------------------------

TEST      ?= alu_regression_test
SEED      ?= 1
FILELIST  ?= filelist.f
UVM_VERB  ?= UVM_MEDIUM
WAVE      ?= none

# Imagen optimizada que sale de vopt, y top del TB.
OPT        = testbench_opt
TOP        = testbench

# Libreria UVM precompilada que trae Questa.
# 'mtiUvm' apunta por defecto a uvm-1.1d. Para paridad con tu baseline de VCS
# (uvm-1.2) apuntamos -L directo a la lib precompilada 1.2 del install.
# 'import uvm_pkg::*' agrega el +incdir correcto segun la lib que se resuelva.
# OJO: -L debe repetirse en vlog, vopt y vsim; vopt/vsim NO heredan el -L de vlog
# (warning vopt-10016).
QUESTA_ROOT ?= /opt/siemens/questasim-2025.3/questasim
UVM_VER     ?= uvm-1.2
# uvm-1.2 (paridad con VCS) | uvm-1.1d (built-in por defecto) | uvm (IEEE 1800.2)
UVM_LIB      = -L $(QUESTA_ROOT)/$(UVM_VER)

# Tipos de coverage: s=statement(line) b=branch c=cond f=fsm t=toggle
# Equivale a VCS  -cm line+cond+fsm+tgl+branch.
# La UVM viene precompilada SIN instrumentar, asi que el coverage cae en el
# codigo de usuario (DUT + TB). Ver COVER_SCOPE abajo si quieres reproducir
# exactamente el cm_hier.cfg (solo modulos ALU y testbench).
COVER      = sbcft

# --- Alcance del coverage ---------------------------------------------------
# Opcion A (default, pragmatica): instrumenta todo el codigo de usuario.
# COVER_INSTR = +cover=$(COVER)
# Opcion B (equivalente fiel al cm_hier.cfg: solo modulos ALU y testbench,
# dejando fuera el codigo de las clases UVM del TB). Descomenta para usarla:
COVER_INSTR = +cover=$(COVER)+ALU. +cover=$(COVER)+testbench.
# ---------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# vopt: visibilidad de ondas segun WAVE
#   - none    : sin visibilidad -> corre mas rapido (caso regresion)
#   - wlf     : +acc para WLF/GUI clasica (en 2025.3 avisa que +acc se deprecara;
#               si molesta, cambia a -debug o -access=rw+/.)
#   - qwavedb : Visualizer (-debug -designfile genera design.bin para qwave)
ifeq ($(WAVE),qwavedb)
    VOPT_DBG  = -debug -designfile design.bin
    VSIM_WAVE = -visualizer -qwavedb=+signal+class
else ifeq ($(WAVE),wlf)
    VOPT_DBG  = +acc
    VSIM_WAVE =
else
    VOPT_DBG  =
    VSIM_WAVE =
endif

VLOG_FLAGS = -sv -timescale "1ns/1ps" $(UVM_LIB)
VOPT_FLAGS = $(UVM_LIB) $(COVER_INSTR) $(VOPT_DBG) -o $(OPT)
VSIM_FLAGS = -c -coverage $(UVM_LIB) $(VSIM_WAVE) \
             +UVM_TESTNAME=$(TEST) \
             +UVM_VERBOSITY=$(UVM_VERB) \
             -sv_seed $(SEED)

#-------------------------------------------------------------------------------
.PHONY: all comp opt sim cov visualizer regress clean help

all: comp opt sim cov

comp:
	@echo "=== [1/3] vlib + vlog ==="
	@test -d work || vlib work
	vlog $(VLOG_FLAGS) -f $(FILELIST) -l comp.log
	@echo "=== vlog OK ==="

opt:
	@echo "=== [2/3] vopt (+cover, visibilidad WAVE=$(WAVE)) ==="
	vopt $(VOPT_FLAGS) $(TOP) -l opt.log
	@echo "=== vopt OK -> imagen $(OPT) ==="

sim:
	@echo "=== [3/3] vsim  test=$(TEST) seed=$(SEED) wave=$(WAVE) ==="
	vsim $(VSIM_FLAGS) $(OPT) \
	     -do "set wave_mode $(WAVE); set test_name $(TEST); do run.do" \
	     -l sim_$(TEST).log
	@echo "=== UCDB: $(TEST).ucdb   log: sim_$(TEST).log ==="

# Fusiona los UCDB, aplica exclusiones en modo viewcov (equivalente al
# 'urg -elfile' de VCS) y genera el reporte HTML sobre el UCDB ya excluido.
cov:
	@echo "=== Fusionando UCDBs ==="
	vcover merge -64 merged.ucdb *.ucdb
	@echo "=== Aplicando exclusiones (viewcov) ==="
	vsim -c -viewcov merged.ucdb \
	     -do "do cov_exclude.do; coverage save merged_excl.ucdb; quit -f"
	@echo "=== Reporte HTML ==="
	vcover report -html -output covhtml -details -threshL 50 -threshH 90 merged_excl.ucdb
	@echo "=== Reportes TXT (equivalente a urg -format both) ==="
	vcover report -details merged_excl.ucdb      > cov_report.txt
	vcover report -cvg -details merged_excl.ucdb > cov_cvg.txt
	@echo "=== HTML: covhtml/index.html | TXT: cov_report.txt (codigo) , cov_cvg.txt (funcional) ==="

# Abre Visualizer standalone (requiere haber corrido con WAVE=qwavedb)
visualizer:
	visualizer -designfile design.bin -wavefile qwave.db &

# Corre los 3 tests; cada uno deja su propio <test>.ucdb, luego se fusionan.
regress:
	@echo "=== Regresion: random + directed + coverage ==="
	$(MAKE) sim TEST=alu_random_test    SEED=1
	$(MAKE) sim TEST=alu_directed_test  SEED=2
	$(MAKE) sim TEST=alu_coverage_test  SEED=3
	$(MAKE) cov

clean:
	rm -rf work transcript *.log *.wlf *.ucdb covhtml \
	       cov_report.txt cov_cvg.txt \
	       design.bin qwave.db qwave.db.dir *.vstf vish_stacktrace.vstf \
	       $(OPT)

help:
	@echo "Targets: comp opt sim cov visualizer regress clean"
	@echo "Variables:"
	@echo "  TEST=<nombre>              (actual: $(TEST))"
	@echo "  SEED=<numero>              (actual: $(SEED))"
	@echo "  UVM_VERB=UVM_HIGH|MEDIUM   (actual: $(UVM_VERB))"
	@echo "  WAVE=none|wlf|qwavedb      (actual: $(WAVE))"
