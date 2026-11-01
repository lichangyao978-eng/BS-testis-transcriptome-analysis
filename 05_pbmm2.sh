
#!/usr/bin/env bash
set -euo pipefail

# ==========================================================
# Step 05: Alignment of clustered Iso-Seq transcripts
# Software: pbmm2
# Reference genome: Sus scrofa (Sscrofa11.1)
#
# Input:
#   Reference genome FASTA
#   Clustered transcript BAM
#
# Output:
#   Coordinate-sorted alignment BAM
# ==========================================================

if [[ $# -ne 3 ]]; then
    echo "Usage: bash $0 <reference.fa> <transcript.bam> <output.bam>"
    exit 1
fi

REF_FASTA="$1"
INPUT_BAM="$2"
OUTPUT_BAM="$3"

# Check input files
for FILE in "$REF_FASTA" "$INPUT_BAM"; do
    if [[ ! -f "$FILE" ]]; then
        echo "ERROR: Input file not found: $FILE"
        exit 1
    fi
done

mkdir -p "$(dirname "$OUTPUT_BAM")"

# Align consensus transcripts to the reference genome
pbmm2 align \
    "$REF_FASTA" \
    "$INPUT_BAM" \
    "$OUTPUT_BAM" \
    --sort \
    --preset ISOSEQ \
    -j 80

echo "pbmm2 alignment completed: $OUTPUT_BAM"

