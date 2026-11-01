
#!/usr/bin/env bash
set -euo pipefail

# ==========================================================
# Step 02: Primer and barcode removal
# Software: lima (PacBio SMRT Link v25.1)
#
# Input:
#   Iso-Seq BAM file
#   Primer/barcode FASTA file
#
# Output:
#   Full-length read BAM files
# ==========================================================

if [[ $# -ne 3 ]]; then
    echo "Usage: bash $0 <input.bam> <primers.fasta> <output.bam>"
    exit 1
fi

INPUT_BAM="$1"
PRIMER_FASTA="$2"
OUTPUT_BAM="$3"

# Check input files
[[ -f "$INPUT_BAM" ]] || {
    echo "ERROR: Input BAM not found: $INPUT_BAM"
    exit 1
}

[[ -f "$PRIMER_FASTA" ]] || {
    echo "ERROR: Primer FASTA not found: $PRIMER_FASTA"
    exit 1
}

mkdir -p "$(dirname "$OUTPUT_BAM")"

# Primer and barcode removal
lima \
    "$INPUT_BAM" \
    "$PRIMER_FASTA" \
    "$OUTPUT_BAM" \
    --isoseq \
    --peek-guess \
    --min-passes 3 \
    --min-score 80 \
    -j 50

echo "lima processing completed: $OUTPUT_BAM"

