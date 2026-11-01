
#!/usr/bin/env bash
set -euo pipefail

# ==========================================================
# Step 04: Isoform clustering
# Software: PacBio Iso-Seq cluster2
#
# Input:
#   FLNC BAM file from Iso-Seq refine
#
# Output:
#   Clustered consensus transcript BAM file
# ==========================================================

if [[ $# -ne 2 ]]; then
    echo "Usage: bash $0 <input.flnc.bam> <output.bam>"
    exit 1
fi

INPUT_BAM="$1"
OUTPUT_BAM="$2"

# Check input file
[[ -f "$INPUT_BAM" ]] || {
    echo "ERROR: FLNC BAM not found: $INPUT_BAM"
    exit 1
}

mkdir -p "$(dirname "$OUTPUT_BAM")"

# Cluster FLNC reads
isoseq cluster2 \
    "$INPUT_BAM" \
    "$OUTPUT_BAM" \
    -j 20 \
    --use-qvs

echo "Transcript clustering completed: $OUTPUT_BAM"

