#-------------------------------------------------------------------------------
# Makefile para verificacion UVM del ALU
#
# Targets principales:
#   make compile             - compila el design + TB con VCS + cobertura
#   make sim  TEST=<test>    - ejecuta simulacion (default: alu_regression_test)
#   make cov                 - genera reporte HTML de cobertura con URG
#   make verdi               - abre Verdi con la base de datos de coverage
#   make regress             - corre los 3 tests principales en secuencia
#   make clean               - borra artefactos
#
# Tests disponibles:
#   alu_random_test
#   alu_directed_test
#   alu_coverage_test
#   alu_regression_test  (default)
#-------------------------------------------------------------------------------

TEST      ?= alu_regression_test
SEED      ?= 1
FILELIST  ?= filelist.f
UVM_VERB  ?= UVM_MEDIUM

# Coverage: linea, condicion, FSM, toggle, branch, assert
COV_FLAGS = -cm line+cond+fsm+tgl+branch+assert
COV_NAME  = -cm_name $(TEST) -cm_dir simv.vdb
COV_HIER  = -cm_hier cm_hier.cfg

# Flags de compilacion VCS.
# -cm_hier filtra la instrumentacion a solo DUT + testbench para
# excluir la librería UVM del reporte y no ensuciar los porcentajes.
VCS_FLAGS = -full64 -sverilog -debug_access+all -kdb \
            -ntb_opts uvm-1.2 \
            -timescale=1ns/1ps \
            $(COV_FLAGS) $(COV_HIER)

# Flags de simulacion
SIM_FLAGS = +UVM_TESTNAME=$(TEST) \
            +UVM_VERBOSITY=$(UVM_VERB) \
            +ntb_random_seed=$(SEED) \
            $(COV_FLAGS) $(COV_NAME)

#-------------------------------------------------------------------------------
.PHONY: all compile sim cov verdi regress clean help

all: compile sim cov

compile:
	@echo "=== Compilando con VCS + coverage ==="
	vcs $(VCS_FLAGS) -f $(FILELIST) -l compile.log -o simv
	@echo "=== Compilacion OK ==="

sim:
	@echo "=== Simulando test: $(TEST) (seed=$(SEED)) ==="
	./simv $(SIM_FLAGS) -l sim_$(TEST).log
	@echo "=== Simulacion terminada. Ver sim_$(TEST).log ==="

# Genera reporte HTML de coverage.
# Los holes unreachable-by-design se excluyen via pragmas VCS coverage off/on
# directamente en el RTL (rtl/alu.sv, default del case) y en el testbench
# (tb/testbench.sv, watchdog).
cov:
	@echo "=== Generando reporte de cobertura con URG ==="
	urg -dir simv.vdb -format both -report cov_report
	@echo "=== Reporte HTML en: cov_report/dashboard.html ==="

# Abre Verdi con la base de coverage para exploracion interactiva
verdi:
	verdi -cov -covdir simv.vdb &

# Corre los 3 tests principales acumulando coverage en la misma base
regress:
	@echo "=== Regresion: random + directed + coverage ==="
	$(MAKE) sim TEST=alu_random_test    SEED=1
	$(MAKE) sim TEST=alu_directed_test  SEED=2
	$(MAKE) sim TEST=alu_coverage_test  SEED=3
	$(MAKE) cov

clean:
	rm -rf simv simv.daidir simv.vdb csrc ucli.key \
	       *.log *.fsdb *.vpd cov_report \
	       verdiLog novas.* vdCovLog vc_hdrs.h

help:
	@echo "Targets disponibles:"
	@echo "  make compile              - Compilacion con coverage instrumentation"
	@echo "  make sim TEST=<name>      - Ejecuta un test (default: $(TEST))"
	@echo "  make cov                  - Reporte HTML de coverage"
	@echo "  make verdi                - Abre Verdi para explorar coverage"
	@echo "  make regress              - Ejecuta los 3 tests y genera reporte"
	@echo "  make clean                - Limpia artefactos"
	@echo ""
	@echo "Variables:"
	@echo "  TEST=<nombre>             (actual: $(TEST))"
	@echo "  SEED=<numero>             (actual: $(SEED))"
	@echo "  UVM_VERB=UVM_HIGH|MEDIUM  (actual: $(UVM_VERB))"