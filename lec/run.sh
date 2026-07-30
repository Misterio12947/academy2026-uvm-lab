#!/bin/bash
# ==========================================================================
# run.sh - Corre el LEC con Formality
# ==========================================================================
# EJECUCION (desde lec/):
#   ./run.sh
# ==========================================================================

mkdir -p reports

# fm_shell en batch (sin GUI). Usa formality en su lugar si quieres GUI.
fm_shell -f scripts/fm.tcl | tee formality.log

echo ""
echo "=== Resultado del LEC ==="
grep -E "Verification (SUCCEEDED|FAILED|INCONCLUSIVE)|Passing|Failing" formality.log
