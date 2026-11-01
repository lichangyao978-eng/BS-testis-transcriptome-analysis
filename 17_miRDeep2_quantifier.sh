
#!/usr/bin/env bash
set -euo pipefail

# ==========================================================
# Step 01: miRNA quantification using miRDeep2
# Software: miRDeep2
#
# Input:
#   Hairpin precursor reference FASTA
#   Mature miRNA reference FASTA
#   Collapsed small RNA reads FASTA
#
# Output:
#   miRNA quantification results
# ==========================================================

if [[ $# -ne 4 ]]; then
    echo "Usage: bash $0 <hairpin.fa> <mature.fa> <reads_collapsed.fa> <sample_tag>"
    exit 1
fi

HAIRPIN="$1"
MATURE="$2"
READS="$3"
TAG="$4"

# Check input files
for FILE in "$HAIRPIN" "$MATURE" "$READS"; do
    [[ -f "$FILE" ]] || {
        echo "ERROR: Input file not found: $FILE"
        exit 1
    }
done

# Run miRNA quantification
quantifier.pl \
    -p "$HAIRPIN" \
    -m "$MATURE" \
    -r "$READS" \
    -y "$TAG"

echo "miRNA quantification completed: $TAG"

