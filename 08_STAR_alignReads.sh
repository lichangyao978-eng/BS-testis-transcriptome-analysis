
#!/usr/bin/env bash
set -euo pipefail

# ==========================================================
# Step 08: STAR alignment for splice junction detection
# Software: STAR
# Reference genome: Sus scrofa Sscrofa11.1
#
# Input:
#   STAR genome index
#   Paired-end RNA-seq FASTQ files
#
# Output:
#   Unsorted BAM and SJ.out.tab files
# ==========================================================

if [[ $# -ne 5 ]]; then
    echo "Usage: bash $0 <index_dir> <R1.fq.gz> <R2.fq.gz> <output_dir> <sample_id>"
    exit 1
fi

INDEX_DIR="$1"
READ1="$2"
READ2="$3"
OUT_DIR="$4"
SAMPLE_ID="$5"

# Check inputs
[[ -d "$INDEX_DIR" ]] || exit 1
[[ -f "$READ1" ]] || exit 1
[[ -f "$READ2" ]] || exit 1

mkdir -p "$OUT_DIR"

PREFIX="${OUT_DIR%/}/${SAMPLE_ID}."

# Align RNA-seq reads
STAR \
    --runThreadN 50 \
    --runMode alignReads \
    --genomeDir "$INDEX_DIR" \
    --readFilesIn "$READ1" "$READ2" \
    --readFilesCommand zcat \
    --outFileNamePrefix "$PREFIX" \
    --outSAMtype BAM Unsorted \
    --outSAMattributes NH HI AS nM MD \
    --outFilterMultimapNmax 20

echo "STAR alignment completed."
echo "Splice junction file: ${PREFIX}SJ.out.tab"

