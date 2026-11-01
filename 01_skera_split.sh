
#!/usr/bin/env bash
set -euo pipefail

# ==========================================================
# Step 01: Kinnex read segmentation
# Software: skera v1.3.0
# SMRT Link: v25.1
#
# Purpose:
# Split concatenated Kinnex Iso-Seq reads into individual
# segments for downstream full-length read processing.
#
# Input:
#   Raw Kinnex BAM
#
# Output:
#   Segmented BAM
# ==========================================================

if [[ $# -ne 3 ]]; then
    echo "Usage: bash $0 <input.bam> <output.bam> <skera_primers.fasta>"
    exit 1
fi

INPUT_BAM="$1"
OUTPUT_BAM="$2"
PRIMER_FASTA="$3"

# Check input files
[[ -f "$INPUT_BAM" ]] || {
    echo "ERROR: Input BAM not found: $INPUT_BAM"
    exit 1
}

[[ -f "$PRIMER_FASTA" ]] || {
    echo "ERROR: Primer FASTA not found: $PRIMER_FASTA"
    exit 1
}

# Run Kinnex segmentation
skera split \
    "$INPUT_BAM" \
    "$PRIMER_FASTA" \
    "$OUTPUT_BAM"

echo "Kinnex segmentation completed."

