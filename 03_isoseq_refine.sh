
#!/usr/bin/env bash
set -euo pipefail

# ==========================================================
# Step 03: Full-length non-concatemer (FLNC) read generation
# Software: Iso-Seq refine (PacBio SMRT Link v25.1)
#
# Input:
#   Primer- and barcode-processed BAM file from lima
#   Primer/barcode FASTA file
#
# Output:
#   FLNC BAM file
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

# Generate FLNC reads
isoseq refine \
    --require-polya \
    "$INPUT_BAM" \
    "$PRIMER_FASTA" \
    "$OUTPUT_BAM" \
    -j 60

echo "FLNC read generation completed: $OUTPUT_BAM"

