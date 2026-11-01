#!/usr/bin/env bash
set -euo pipefail
# miRanda prediction with original score, energy and strict filtering flags.
# Usage: bash 02_miRanda_prediction.sh <mature_miRNAs.fa> <aUTR.fa> <output.out>
if [[ $# -ne 3 ]]; then
  echo "Usage: bash $0 <mature_miRNAs.fa> <aUTR.fa> <output.out>" >&2
  exit 1
fi
MIRNAS="$1"; UTR="$2"; OUTPUT="$3"
for f in "$MIRNAS" "$UTR"; do
  [[ -f "$f" ]] || { echo "Missing input: $f" >&2; exit 1; }
done
command -v miranda >/dev/null || { echo 'miRanda not found' >&2; exit 1; }
mkdir -p "$(dirname "$OUTPUT")"
miranda "$MIRNAS" "$UTR" -sc 140 -en -20 -strict > "$OUTPUT"
echo "miRanda completed: $OUTPUT"
