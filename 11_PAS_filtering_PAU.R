#!/usr/bin/env Rscript
# PAS filtering, positional classification, and PAS usage (PAU)
# Based on the analysis rules supplied by the study authors.
# Usage: Rscript scripts/11_PAS_filtering_PAU.R INPUT.tsv OUTPUT_DIR STAGE
# Example: Rscript scripts/11_PAS_filtering_PAU.R PAS_expression.no_internal_priming.tsv results/d7 d7
# Dependency: dplyr (record actual installed version for archival release).

suppressPackageStartupMessages(library(dplyr))
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 3L) {
  stop("Usage: Rscript 11_PAS_filtering_PAU.R <input.tsv> <output_dir> <stage_id>", call. = FALSE)
}
input_file <- args[[1L]]
out_dir <- args[[2L]]
stage <- args[[3L]]
if (!file.exists(input_file)) stop("Input file does not exist: ", input_file)
if (!grepl("^[A-Za-z0-9_-]+$", stage)) stop("stage_id should contain only letters, numbers, underscores or hyphens")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

dat <- read.delim(input_file, sep = "\t", header = TRUE, check.names = FALSE,
                  stringsAsFactors = FALSE)
required <- c("gene", "PAS_site", "strand", "site_read_count")
missing_cols <- setdiff(required, names(dat))
if (length(missing_cols)) stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
if (anyNA(dat[required])) stop("Missing values in key columns; inspect source data before analysis")
if (!is.numeric(dat$PAS_site) || !is.numeric(dat$site_read_count)) {
  stop("PAS_site and site_read_count must be numeric")
}
if (any(!dat$strand %in% c("+", "-"))) stop("strand must be '+' or '-'")
if (any(dat$site_read_count < 0)) stop("site_read_count must be nonnegative")
if (any(!is.finite(dat$PAS_site)) || any(!is.finite(dat$site_read_count))) stop("Non-finite values detected")
# Each gene is expected to lie on a single strand.
strand_count <- dat %>% distinct(gene, strand) %>% count(gene, name = "strand_count")
if (any(strand_count$strand_count > 1L)) stop("Genes with mixed strands detected; check input annotations")
# Original analysis uses a >=2-row criterion. Input is assumed to contain one row per PAS site.
# If duplicate gene/PAS_site rows are present, stop rather than silently counting them as distinct sites.
if (any(duplicated(dat[c("gene", "PAS_site")])) ) {
  stop("Duplicate gene/PAS_site pairs detected; collapse duplicates upstream or inspect source data")
}

pas <- dat %>%
  group_by(gene) %>%
  filter(n() >= 2L) %>%
  mutate(
    site_num = n(),
    max = max(PAS_site),
    min = min(PAS_site),
    midpoint = (max + min) / 2,
    type = case_when(
      strand == "+" & PAS_site < midpoint ~ "proximal",
      strand == "+" & PAS_site > midpoint ~ "distal",
      strand == "-" & PAS_site > midpoint ~ "proximal",
      strand == "-" & PAS_site < midpoint ~ "distal",
      PAS_site == midpoint ~ "middle",
      TRUE ~ NA_character_
    ),
    gene_pas_reads = sum(site_read_count),
    PAS_usage = if_else(gene_pas_reads > 0, site_read_count / gene_pas_reads, NA_real_)
  ) %>% ungroup()

if (any(pas$gene_pas_reads == 0)) {
  warning("Some genes have zero total PAS reads; PAS_usage is NA for those genes")
}

preference <- pas %>%
  group_by(gene) %>%
  summarise(
    proximal_usage = sum(PAS_usage[type == "proximal"], na.rm = TRUE),
    distal_usage = sum(PAS_usage[type == "distal"], na.rm = TRUE),
    middle_usage = sum(PAS_usage[type == "middle"], na.rm = TRUE),
    total_pas_reads = first(gene_pas_reads),
    .groups = "drop"
  ) %>%
  mutate(preference = case_when(
    total_pas_reads == 0 ~ NA_character_,
    distal_usage > proximal_usage ~ "D_gene",
    proximal_usage > distal_usage ~ "P_gene",
    TRUE ~ "equal"
  ))

write.table(pas, file.path(out_dir, paste0(stage, "_PAS_quantification_usage.txt")),
            sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE, na = "NA")
write.table(preference, file.path(out_dir, paste0(stage, "_PAS_preference.txt")),
            sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE, na = "NA")
cat("Processed ", n_distinct(pas$gene), " multi-PAS genes for stage ", stage, "\n", sep = "")
