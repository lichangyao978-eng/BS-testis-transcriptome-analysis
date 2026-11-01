#!/usr/bin/env python3

import argparse
import pandas as pd
import pysam


def revcomp(seq):
    table = str.maketrans("ACGTNacgtn", "TGCANtgcan")
    return seq.translate(table)[::-1].upper()


def max_consecutive_base(seq, base="A"):
    max_run = 0
    current = 0

    for x in seq.upper():
        if x == base:
            current += 1
            max_run = max(max_run, current)
        else:
            current = 0

    return max_run


def get_downstream_seq(fasta, chrom, site, strand, length):
    """
    site: 1-based PAS coordinate
    return: transcript-direction downstream sequence, 5'->3'
    """

    if strand == "+":
        # + strand downstream: site+1 to site+length
        # pysam fetch uses 0-based half-open
        start = site
        end = site + length
        seq = fasta.fetch(chrom, start, end).upper()

    elif strand == "-":
        # - strand downstream in transcript direction:
        # genomic site-length to site-1, then reverse complement
        start = max(0, site - length - 1)
        end = site - 1
        seq = fasta.fetch(chrom, start, end).upper()
        seq = revcomp(seq)

    else:
        seq = ""

    return seq


def parse_args():
    parser = argparse.ArgumentParser(
        description="Flag and filter internal priming PAS sites"
    )
    parser.add_argument("--pas", required=True, help="PAS expression TSV")
    parser.add_argument("--genome", required=True, help="Genome FASTA indexed by samtools faidx")
    parser.add_argument("--out-prefix", required=True, help="Output prefix")
    parser.add_argument("--downstream-len", type=int, default=20)
    parser.add_argument("--a-content-cutoff", type=float, default=0.80)
    parser.add_argument("--max-a-run-cutoff", type=int, default=6)
    return parser.parse_args()


def main():
    args = parse_args()

    df = pd.read_csv(args.pas, sep="\t")
    fasta = pysam.FastaFile(args.genome)

    required = {"chrom", "strand", "PAS_site"}
    missing = required - set(df.columns)
    if missing:
        raise ValueError(f"Missing required columns: {missing}")

    downstream_seqs = []
    a_contents = []
    max_a_runs = []
    internal_flags = []

    for _, row in df.iterrows():
        chrom = str(row["chrom"])
        strand = row["strand"]
        site = int(row["PAS_site"])

        seq = get_downstream_seq(
            fasta=fasta,
            chrom=chrom,
            site=site,
            strand=strand,
            length=args.downstream_len
        )

        seq_upper = seq.upper()

        if len(seq_upper) == 0:
            a_content = 0
            max_a_run = 0
            flag = True
        else:
            a_count = seq_upper.count("A")
            a_content = a_count / len(seq_upper)
            max_a_run = max_consecutive_base(seq_upper, "A")

            flag = (
                a_content >= args.a_content_cutoff
                or max_a_run >= args.max_a_run_cutoff
            )

        downstream_seqs.append(seq_upper)
        a_contents.append(a_content)
        max_a_runs.append(max_a_run)
        internal_flags.append(flag)

    df["downstream_seq_for_internal_priming"] = downstream_seqs
    df["downstream_A_content"] = a_contents
    df["downstream_max_A_run"] = max_a_runs
    df["internal_priming_flag"] = internal_flags

    df.to_csv(args.out_prefix + ".with_internal_priming.tsv", sep="\t", index=False)

    filtered = df[~df["internal_priming_flag"]].copy()
    filtered.to_csv(args.out_prefix + ".no_internal_priming.tsv", sep="\t", index=False)

    fasta.close()


if __name__ == "__main__":
    main()
