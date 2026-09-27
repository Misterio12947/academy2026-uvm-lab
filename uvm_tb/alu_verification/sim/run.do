#-------------------------------------------------------------------------------
# run.do  -  script de simulacion, parametrizado por variables tcl:
#   $wave_mode  = none | wlf | qwavedb   (lo setea el Makefile)
#   $test_name  = nombre del test         (para nombrar el UCDB)
#
# Se invoca desde el Makefile:
#   vsim ... -do "set wave_mode $(WAVE); set test_name $(TEST); do run.do"
#-------------------------------------------------------------------------------

# Si algo lanza un break, continuar en vez de caer al prompt (util en batch).
onbreak {resume}

# NOTA: las exclusiones de coverage NO van aqui. En Questa se aplican en
# report-time (modo viewcov), igual que el 'urg -elfile' del flujo VCS.
# Ver el target 'cov' del Makefile, que carga sim/cov_exclude.do sobre el UCDB.

# --- Volcado de ondas segun modo ---
# WLF clasico: registrar recursivamente todas las senales del jerarquico.
# qwavedb (Visualizer): el volcado ya lo activa '-qwavedb' en la linea de vsim;
#                       aqui no hace falta nada extra.
if {$wave_mode eq "wlf"} {
    log -r /*
}

# --- Guardar coverage AL SALIR ---
# Clave: run_test() de UVM termina con $finish, que en batch puede matar el
# proceso de vsim ANTES de un 'coverage save' posterior. Con -onexit el guardado
# se engancha a la salida y siempre ocurre.
coverage save -onexit ${test_name}.ucdb

# --- Correr hasta el final ---
run -all

# En batch, cerrar (en GUI para debug, comenta esta linea).
quit -f

