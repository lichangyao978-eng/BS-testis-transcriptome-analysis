
#!/usr/bin/env bash
set -euo pipefail

# ==========================================================
# Step 07: STAR genome index generation
# Software: STAR
# Reference genome: Sus scrofa Sscrofa11.1
# Annotation: Ensembl release 115
#
# Input:
#   Reference genome FASTA
#   Reference annotation GTF
#
# Output:
#   STAR genome index directory
# ==========================================================

if [[ $# -ne 3 ]]; then
    echo "Usage: bash $0 <reference.fa> <annotation.gtf> <index_dir>"
    exit 1
fi

REF_FASTA="$1"
REF_GTF="$2"
INDEX_DIR="$3"

# Check input files
for FILE in "$REF_FASTA" "$REF_GTF"; do
    if [[ ! -f "$FILE" ]]; then
        echo "ERROR: Input file not found: $FILE"
        exit 1
    fi
done

command -v STAR >/dev/null 2>&1 || {
    echo "ERROR: STAR not found"
    exit 1
}

mkdir -p "$INDEX_DIR"

# Generate STAR genome index
STAR \
    --runMode genomeGenerate \
    --runThreadN 30 \
    --genomeDir "$INDEX_DIR" \
    --genomeFastaFiles "$REF_FASTA" \
    --sjdbGTFfile "$REF_GTF" \
    --sjdbOverhang 149

echo "STAR genome index generation completed: $INDEX_DIR"

