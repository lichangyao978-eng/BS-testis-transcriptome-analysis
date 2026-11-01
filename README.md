# BS-testis-transcriptome-analysis
Analysis scripts for Iso-Seq, RNA-seq, and small RNA-seq of BS testes across eight developmental stages
This repository documents the computational processing and analysis of PacBio Kinnex Iso-Seq, short-read RNA-seq, and small RNA-seq data from BS testes across eight developmental stages: d7, m1, m2, m4, m6, m8, m10, and m12.
The scripts cover long-read transcript processing and quality control, short-read splice-junction support, Salmon expression quantification, alternative polyadenylation (APA) analysis, and miRNA target prediction/quantification. They are provided to support the traceability and reuse of the processed datasets associated with this study.
1. Iso-Seq processing and annotation
Kinnex reads were segmented with skera, followed by primer/barcode processing using lima and full-length read refinement using Iso-Seq refine. Stage-specific FLNC reads were obtained for eight developmental stages. According to the analysis record, FLNC reads from the stages were also merged for an integrated analysis; the original merge command and its treatment of read identifiers still need to be documented.
The FLNC data used for each analysis were then clustered using isoseq cluster2, aligned against the Sus scrofa Sscrofa11.1 reference genome with pbmm2, and collapsed to nonredundant transcript models using isoseq collapse. Transcript structure was characterized against Ensembl release 115 annotations using SQANTI3, followed by rule-based filtering.
Iso-Seq transcript identifiers (e.g., PB.1.1) were retained rather than reassigned to Ensembl transcript identifiers in the final transcript GTF and FASTA used for Salmon quantification. The exact reference-annotation integration and transcript-to-gene mapping rules should be documented with their corresponding input files; preservation of PB IDs alone does not document the annotation integration step.
2. RNA-seq splice-junction evidence
STAR was used to construct a genome index and align paired-end RNA-seq reads. The resulting SJ.out.tab files were supplied to SQANTI3 using the comma-separated -c argument; for stage-specific analyses, three short-read biological replicates were supplied where available. STAR splice-junction evidence supports isoform quality assessment; it is not equivalent to direct base-level error correction of long reads.
3. RNA-seq expression quantification
Salmon was used to quantify paired-end RNA-seq samples, with a transcript-to-gene mapping file supplied using -g. Results from 24 samples (three replicates for each of eight stages) were combined for gene-level expression reporting using salmon quantmerge -c TPM --genes.
4. APA and PAS usage
TAPIS-related scripts were used in the APA workflow. After internal-priming filtering, the R script 11_PAS_filtering_PAU.R processes the file PAS_expression.no_internal_priming.tsv, retains genes with multiple PAS sites, classifies sites as proximal/distal/middle using the gene's min/max PAS coordinate midpoint and strand orientation, and calculates within-gene PAS usage:
PAS_usage = site_read_count / sum(site_read_count within the same gene)
Gene-level proximal and distal usage fractions are then summarized. This R script does not identify PAS sites de novo or itself remove internal-priming artifacts. The TAPIS and filtering code must be documented as distinct upstream steps.
5. miRNA prediction and quantification
TargetScan and miRanda were used for separate miRNA binding-site predictions; the recorded miRanda parameters included -sc 140 -en -20 -strict. miRDeep2 quantifier.pl was used to quantify miRNAs using mature and hairpin reference sequences and collapsed small RNA reads.
Dependencies and reference resources
Tools used in the supplied workflow include: PacBio SMRT Link v25.1, skera v1.3.0 (as reported), lima, Iso-Seq refine/cluster2/collapse, pbmm2, STAR, SQANTI3 v5.5, Salmon, TAPIS, TargetScan 7.0.2, miRanda, miRDeep2, R and the dplyr package.
- Reference genome: Sus scrofa Sscrofa11.1.
- Reference annotation: Ensembl release 115.
- Exact command-level software versions, genome/reference checksums, and environment packages should be added from the original run logs.
- Python scripts distributed with TAPIS or another upstream tool should retain their original license/attribution if they were copied rather than authored for this study.
