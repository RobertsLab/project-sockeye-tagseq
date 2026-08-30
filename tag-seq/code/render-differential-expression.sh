#!/usr/bin/env bash
# Render the differential-expression notebook once per tissue.
#
# Run from the project root. Results are written to
# tag-seq/DESEQ_output/<tissue>/ ; because those files are tracked in git,
# `git diff` after this script is the reproduction test.
set -euo pipefail

for tissue in liver gonad; do
  echo "--- rendering ${tissue} ---"
  quarto render tag-seq/code/02-differential-expression.qmd \
    -P "tissue:${tissue}" \
    --output "02-differential-expression-${tissue}.html"
done
