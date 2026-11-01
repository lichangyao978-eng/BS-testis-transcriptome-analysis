#!/usr/bin/env bash
set -euo pipefail

# Merge Salmon quantifications into a gene-level TPM matrix.
# Eight developmental stages, three biological replicates per stage (24 samples).
# Usage: bash 02_salmon_quantmerge_gene_TPM.sh [quantification_parent_dir] [output_file]
# Quantification directories are expected to be named stage-bszN as below.

QUANT_DIR="${1:-.}"
OUTPUT="${2:-testis_salmon.genes}"

command -v salmon >/dev/null 2>&1 || { echo 'ERROR: salmon not found' >&2; exit 1; }

SAMPLES=(
  d7-bsz1 d7-bsz2 d7-bsz3
  m1-bsz1 m1-bsz2 m1-bsz3
  m2-bsz1 m2-bsz2 m2-bsz3
  m4-bsz1 m4-bsz2 m4-bsz3
  m6-bsz1 m6-bsz2 m6-bsz3
  m8-bsz1 m8-bsz2 m8-bsz3
  m10-bsz1 m10-bsz2 m10-bsz3
  m12-bsz1 m12-bsz2 m12-bsz3
)

QUANTS=()
for sample in "${SAMPLES[@]}"; do
  path="${QUANT_DIR%/}/${sample}"
  [[ -f "$path/quant.sf" ]] || { echo "ERROR: missing $path/quant.sf" >&2; exit 1; }
  QUANTS+=("$path")
done

mkdir -p "$(dirname "$OUTPUT")"
salmon quantmerge -c TPM --quants "${QUANTS[@]}" --genes -o "$OUTPUT"
echo "Gene-level TPM matrix written to: $OUTPUT"
