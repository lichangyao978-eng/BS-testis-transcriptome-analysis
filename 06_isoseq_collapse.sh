
#!/usr/bin/env bash
set -euo pipefail

# ==========================================================
# Step 06: Collapse redundant Iso-Seq transcript isoforms
# Software: PacBio Iso-Seq collapse
# Reference genome: Sus scrofa Sscrofa11.1
#
# Input:
#   Coordinate-sorted pbmm2 alignment BAM
#
# Output:
#   Collapsed transcript annotation GFF
# ==========================================================

if [[ $# -ne 2 ]]; then
    echo "Usage: bash $0 <input.pbmm2.bam> <output.collapsed.gff>"
    exit 1
fi

INPUT_BAM="$1"
OUTPUT_GFF="$2"

# Check input file
[[ -f "$INPUT_BAM" ]] || {
    echo "ERROR: Input BAM not found: $INPUT_BAM"
    exit 1
}

# Check software availability
command -v isoseq >/dev/null 2>&1 || {
    echo "ERROR: isoseq not found"
    exit 1
}

mkdir -p "$(dirname "$OUTPUT_GFF")"

# Collapse redundant transcript isoforms
isoseq collapse \
    "$INPUT_BAM" \
    "$OUTPUT_GFF" \
    --max-5p-diff 500 \
    --max-3p-diff 1000

echo "Iso-Seq collapse completed: $OUTPUT_GFF"

