#-------------------------------------------------------------------------------
# cov_exclude.do  -  exclusiones de coverage
#
# Equivale a:
#   - alu_cov_excludes.el   (exclusion file de URG en VCS)
#   - los pragmas 'VCS coverage off/on' del RTL/TB (que Questa ignora como
#     simples comentarios; aqui se replican como 'coverage exclude').
#
# Se carga en REPORT-TIME (modo viewcov), desde el target 'cov' del Makefile,
# sobre el UCDB ya fusionado. Es el equivalente a 'urg -elfile' de VCS.
# (En sim-time el -comment se ignora con warning; por eso va aqui.)
#
# NOTA (igual que el .el original): los numeros de linea corresponden al commit
# actual de rtl/alu.sv y tb/testbench.sv. Si esos archivos cambian, regenerar
# (en GUI: Coverage -> click derecho sobre el hole -> Exclude) o ajustar a mano.
#
# Si 'coverage exclude -src <ruta>' no matchea por la ruta relativa, prueba solo
# con el nombre de archivo (p.ej. -src alu.sv).
#-------------------------------------------------------------------------------

# ALU: default del unique case (rtl/alu.sv, lineas 74-78).
# op[2:0] tiene las 8 combinaciones enumeradas explicitamente; el default nunca
# se ejecuta con opcode valido en 2-estados. Unreachable-by-design.
coverage exclude -src ../../../rtl/alu.sv -line 74 75 76 77 78 \
    -comment "Default del unique case unreachable-by-design (opcode 3-bit enumerado completo)"

# Watchdog del testbench (tb/testbench.sv, lineas 55-58).
# Solo se ejecuta si el env se cuelga; no debe contar en coverage
# (equivalente a los pragmas 'VCS coverage off/on' del original).
coverage exclude -src ../tb/testbench.sv -line 55 56 57 58 \
    -comment "Watchdog: solo corre ante cuelgue del env (excluido igual que en VCS coverage off/on)"

