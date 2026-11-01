#!/usr/bin/env bash
set -euo pipefail
# TargetScan 7.0.2 prediction using supplied seed and UTR input files.
# Usage: bash 01_TargetScan_prediction.sh <targetscan_70.pl> <seed.txt> <UTR_input> <output.txt>
if [[ $# -ne 4 ]]; then
  echo "Usage: bash $0 <targetscan_70.pl> <seed.txt> <UTR_input> <output.txt>" >&2
  exit 1
fi
SCRIPT="$1"; SEED="$2"; UTR="$3"; OUTPUT="$4"
for f in "$SCRIPT" "$SEED" "$UTR"; do
  [[ -f "$f" ]] || { echo "Missing input: $f" >&2; exit 1; }
done
command -v perl >/dev/null || { echo 'Perl not found' >&2; exit 1; }
mkdir -p "$(dirname "$OUTPUT")"
perl "$SCRIPT" "$SEED" "$UTR" "$OUTPUT"
echo "TargetScan completed: $OUTPUT"
