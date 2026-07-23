#-------------------------------------------------------------------------------
# Makefile para verificacion UVM del mux2_registered
#-------------------------------------------------------------------------------

TEST      ?= mux2_registered_regression_test
SEED      ?= 1
FILELIST  ?= filelist.f
UVM_VERB  ?= UVM_MEDIUM

COV_FLAGS = -cm line+cond+fsm+tgl+branch+assert
COV_NAME  = -cm_name $(TEST) -cm_dir simv.vdb
COV_HIER  = -cm_hier cm_hier.cfg

VCS_FLAGS = -full64 -sverilog -debug_access+all -kdb \
            -ntb_opts uvm-1.2 \
            -timescale=1ns/1ps \
            $(COV_FLAGS) $(COV_HIER)

SIM_FLAGS = +UVM_TESTNAME=$(TEST) \
            +UVM_VERBOSITY=$(UVM_VERB) \
            +ntb_random_seed=$(SEED) \
            $(COV_FLAGS) $(COV_NAME)

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

cov:
	@echo "=== Generando reporte de cobertura con URG ==="
	urg -dir simv.vdb -format both -report cov_report
	@echo "=== Reporte HTML en: cov_report/dashboard.html ==="

verdi:
	verdi -cov -covdir simv.vdb &

regress:
	@echo "=== Regresion: random + directed + reset + coverage ==="
	$(MAKE) sim TEST=mux2_registered_random_test    SEED=1
	$(MAKE) sim TEST=mux2_registered_directed_test  SEED=2
	$(MAKE) sim TEST=mux2_registered_reset_test     SEED=3
	$(MAKE) sim TEST=mux2_registered_coverage_test  SEED=4
	$(MAKE) cov

clean:
	rm -rf simv simv.daidir simv.vdb csrc ucli.key \
	       *.log *.fsdb *.vpd cov_report \
	       verdiLog novas.* vdCovLog vc_hdrs.h .fsm.*

help:
	@echo "Targets disponibles:"
	@echo "  make compile              - Compilacion con coverage"
	@echo "  make sim TEST=<name>      - Ejecuta un test"
	@echo "  make cov                  - Reporte HTML de coverage"
	@echo "  make verdi                - Verdi para explorar coverage"
	@echo "  make regress              - Ejecuta los 4 tests + reporte"
	@echo "  make clean                - Limpia artefactos"
