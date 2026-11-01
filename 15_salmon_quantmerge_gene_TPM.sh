#!/usr/bin/env bash
set -euo pipefail

# Merge gene-level TPM values across Salmon sample quantification directories.
# Usage: bash 02_salmon_quantmerge_gene_TPM.sh <output.tsv> <sample_quant_dir1> [sample_quant_dir2 ...]
# This script does not automatically add or omit developmental stages.

if [[ $# -lt 2 ]]; then
  echo "Usage: bash $0 <output.tsv> <sample_quant_dir1> [sample_quant_dir2 ...]" >&2
  exit 1
fi
OUTPUT=$1
shift
command -v salmon >/dev/null 2>&1 || { echo "ERROR: salmon not found" >&2; exit 1; }
for dir in "$@"; do
  [[ -f "$dir/quant.genes.sf" ]] || { echo "ERROR: Missing gene-level quantification: $dir/quant.genes.sf" >&2; exit 1; }
done
mkdir -p "$(dirname "$OUTPUT")"
salmon quantmerge \
  -c TPM \
  --quants "$@" \
  --genes \
  -o "$OUTPUT"
echo "Completed gene-level TPM matrix: $OUTPUT"
