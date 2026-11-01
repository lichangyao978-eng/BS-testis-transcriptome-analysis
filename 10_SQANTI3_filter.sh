
#!/usr/bin/env bash
set -euo pipefail

# ==========================================================
# Step 10: SQANTI3 rule-based transcript filtering
# Software: SQANTI3 v5.5
#
# Input:
#   SQANTI3 classification file
#   Corrected GFF3 annotation
#   Corrected transcript FASTA
#   Corrected transcript GTF
#
# Output:
#   Rule-filtered transcript results
# ==========================================================

if [[ $# -ne 7 ]]; then
    echo "Usage: bash $0 <sqanti3_filter.py> <classification.txt> <corrected.cds.gff3> <corrected.fasta> <corrected.gtf> <output_prefix> <output_dir>"
    exit 1
fi

SQANTI_FILTER="$1"
CLASSIFICATION="$2"
ANNOT_GFF3="$3"
CORRECTED_FASTA="$4"
CORRECTED_GTF="$5"
PREFIX="$6"
OUTDIR="$7"

# Check input files
for FILE in "$SQANTI_FILTER" "$CLASSIFICATION" \
            "$ANNOT_GFF3" "$CORRECTED_FASTA" "$CORRECTED_GTF"; do
    [[ -f "$FILE" ]] || {
        echo "ERROR: Input file not found: $FILE"
        exit 1
    }
done

mkdir -p "$OUTDIR"

# Run SQANTI3 rule-based filtering
python "$SQANTI_FILTER" rules \
    --sqanti_class "$CLASSIFICATION" \
    --isoAnnotGFF3 "$ANNOT_GFF3" \
    --filter_isoforms "$CORRECTED_FASTA" \
    --filter_gtf "$CORRECTED_GTF" \
    -o "$PREFIX" \
    -d "$OUTDIR"

echo "SQANTI3 filtering completed: $OUTDIR"

