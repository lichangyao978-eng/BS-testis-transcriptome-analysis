
#!/usr/bin/env bash
set -euo pipefail

# ==========================================================
# Step 09: SQANTI3 transcript quality control
# Software: SQANTI3 v5.5
#
# Input:
#   Collapsed Iso-Seq transcript GFF
#   Ensembl reference GTF
#   Reference genome FASTA
#   STAR splice junction files
#   Iso-Seq transcript abundance file
#
# Output:
#   SQANTI3 classification and quality-control results
# ==========================================================

if [[ $# -ne 6 ]]; then
    echo "Usage: bash $0 <sqanti3_qc.py> <collapsed.gff> <reference.gtf> <genome.fa> <SJ1,SJ2,SJ3> <abundance.txt>"
    exit 1
fi

SQANTI_QC="$1"
ISOFORMS="$2"
REF_GTF="$3"
REF_FASTA="$4"
SJ_CSV="$5"
ABUNDANCE="$6"

# Check input files
for FILE in "$SQANTI_QC" "$ISOFORMS" "$REF_GTF" "$REF_FASTA" "$ABUNDANCE"; do
    [[ -f "$FILE" ]] || {
        echo "ERROR: Input file not found: $FILE"
        exit 1
    }
done

# Check splice junction files
IFS=',' read -r -a SJ_FILES <<< "$SJ_CSV"

for FILE in "${SJ_FILES[@]}"; do
    [[ -f "$FILE" ]] || {
        echo "ERROR: STAR junction file not found: $FILE"
        exit 1
    }
done

# Run SQANTI3 quality control
python "$SQANTI_QC" \
    --isoforms "$ISOFORMS" \
    --refGTF "$REF_GTF" \
    --refFasta "$REF_FASTA" \
    -c "$SJ_CSV" \
    -fl "$ABUNDANCE"

echo "SQANTI3 QC completed."

