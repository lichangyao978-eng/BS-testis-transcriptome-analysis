#!/usr/bin/env bash
set -euo pipefail

# Single-sample paired-end RNA-seq quantification with Salmon.
# Preserves the original options: -l A and -g transcript-to-gene mapping.
# Usage: bash 01_salmon_quant.sh <salmon_index_dir> <R1.fq.gz> <R2.fq.gz> <tx2gene.txt> <output_dir>

if [[ $# -ne 5 ]]; then
  echo "Usage: bash $0 <salmon_index_dir> <R1.fq.gz> <R2.fq.gz> <tx2gene.txt> <output_dir>" >&2
  exit 1
fi
INDEX=$1
R1=$2
R2=$3
GENEMAP=$4
OUT=$5
command -v salmon >/dev/null 2>&1 || { echo "ERROR: salmon is not installed or not in PATH" >&2; exit 1; }
[[ -d "$INDEX" ]] || { echo "ERROR: index not found: $INDEX" >&2; exit 1; }
for path in "$R1" "$R2" "$GENEMAP"; do
  [[ -f "$path" ]] || { echo "ERROR: file not found: $path" >&2; exit 1; }
done
mkdir -p "$(dirname "$OUT")"
[[ ! -e "$OUT" ]] || { echo "ERROR: output already exists: $OUT" >&2; exit 1; }

salmon quant \
  -i "$INDEX" \
  -l A \
  -1 "$R1" \
  -2 "$R2" \
  -g "$GENEMAP" \
  -o "$OUT"

echo "Completed Salmon quantification: $OUT"
