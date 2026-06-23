#!/usr/bin/env Rscript

# ==============================================================================
# Script title: Summarize hierBAPS clusters by MLST Pasteur sequence type
# Author: Silvana Yalú Cristo Martínez
# Creation date: 2026-05-13
# Last update: 2026-05-13
#
# Description:
# This script compares hierBAPS cluster assignments with MLST Pasteur sequence
# types. It removes duplicated RefSeq accessions introduced by the reference
# genome, calculates MLST counts and proportions within each hierBAPS level, and
# writes summary tables for downstream interpretation and plotting.
#
# The script:
# - Loads hierBAPS cluster assignments with metadata
# - Removes duplicated RefSeq accessions
# - Counts MLST Pasteur STs within level 1 and level 2 clusters
# - Identifies the dominant MLST ST for each cluster
# - Saves cleaned metadata, tables, and a text summary
#
# Requirements:
# - R packages: readr, dplyr
# - hierBAPS metadata table with MLST Pasteur annotations
# - Rscript
# ==============================================================================


# ==============================================================================
# LOAD REQUIRED PACKAGES
# ==============================================================================

library(readr)
library(dplyr)


# ==============================================================================
# DEFINE INPUTS AND OUTPUTS
# ==============================================================================

project_dir <- "/export/space3/users/silvanac/Abaumannii_ChromArch"

infile <- file.path(project_dir, "results/hierbaps/hierbaps_clusters_with_metadata.csv")

out_clean <- file.path(project_dir, "results/hierbaps/hierbaps_clusters_with_metadata_no_refdup.csv")
out_l1 <- file.path(project_dir, "results/hierbaps/cluster_vs_mlst_level1_no_refdup.csv")
out_l2 <- file.path(project_dir, "results/hierbaps/cluster_vs_mlst_level2_no_refdup.csv")
out_dom_l1 <- file.path(project_dir, "results/hierbaps/dominant_mlst_by_level1_no_refdup.csv")
out_dom_l2 <- file.path(project_dir, "results/hierbaps/dominant_mlst_by_level2_no_refdup.csv")
out_summary <- file.path(project_dir, "results/hierbaps/mlst_summary_no_refdup.txt")


# ==============================================================================
# LOAD METADATA
# ==============================================================================

meta <- read_csv(infile, show_col_types = FALSE)


# ==============================================================================
# REMOVE TECHNICAL DUPLICATES AND STANDARDIZE MLST VALUES
#
# The reference genome was also present in the dataset, which introduced a
# duplicate RefSeq accession. This keeps one biological representative per
# RefSeq accession and labels missing MLST values as Unknown.
# ==============================================================================

meta_clean <- meta %>%
  distinct(acc_num_refseq, .keep_all = TRUE) %>%
  mutate(
    level.1 = as.factor(level.1),
    level.2 = as.factor(level.2),
    MLST.Pasteur.ST = ifelse(
      is.na(MLST.Pasteur.ST) | MLST.Pasteur.ST == "",
      "Unknown",
      as.character(MLST.Pasteur.ST)
    )
  )

write_csv(meta_clean, out_clean)


# ==============================================================================
# COUNT MLST TYPES BY HIERBAPS LEVEL 1 CLUSTER
# ==============================================================================

cluster_mlst_l1 <- meta_clean %>%
  count(level.1, MLST.Pasteur.ST, name = "n") %>%
  group_by(level.1) %>%
  mutate(prop_in_cluster = n / sum(n)) %>%
  arrange(level.1, desc(n)) %>%
  ungroup()


# ==============================================================================
# COUNT MLST TYPES BY HIERBAPS LEVEL 2 CLUSTER
# ==============================================================================

cluster_mlst_l2 <- meta_clean %>%
  count(level.2, MLST.Pasteur.ST, name = "n") %>%
  group_by(level.2) %>%
  mutate(prop_in_cluster = n / sum(n)) %>%
  arrange(level.2, desc(n)) %>%
  ungroup()


# ==============================================================================
# IDENTIFY DOMINANT MLST TYPE PER CLUSTER
# ==============================================================================

dominant_l1 <- cluster_mlst_l1 %>%
  group_by(level.1) %>%
  slice_max(n, n = 1, with_ties = FALSE) %>%
  ungroup()

dominant_l2 <- cluster_mlst_l2 %>%
  group_by(level.2) %>%
  slice_max(n, n = 1, with_ties = FALSE) %>%
  ungroup()


# ==============================================================================
# WRITE OUTPUT TABLES
# ==============================================================================

write_csv(cluster_mlst_l1, out_l1)
write_csv(cluster_mlst_l2, out_l2)
write_csv(dominant_l1, out_dom_l1)
write_csv(dominant_l2, out_dom_l2)


# ==============================================================================
# WRITE TEXT SUMMARY
# ==============================================================================

sink(out_summary)
cat("Original rows:", nrow(meta), "\n")
cat("Rows after removing duplicate RefSeq accessions:", nrow(meta_clean), "\n")
cat("Unique RefSeq accessions:", n_distinct(meta_clean$acc_num_refseq), "\n\n")

cat("Level 1 cluster sizes:\n")
print(table(meta_clean$level.1))

cat("\nLevel 2 cluster sizes:\n")
print(table(meta_clean$level.2))

cat("\nMLST Pasteur ST counts:\n")
print(sort(table(meta_clean$MLST.Pasteur.ST), decreasing = TRUE))

cat("\nDominant MLST by level 1 cluster:\n")
print(dominant_l1)

cat("\nDominant MLST by level 2 cluster:\n")
print(dominant_l2)
sink()


# ==============================================================================
# END OF SCRIPT
# ==============================================================================

cat("Done.\n")
cat("Clean metadata:", out_clean, "\n")
cat("Level 1 vs MLST:", out_l1, "\n")
cat("Level 2 vs MLST:", out_l2, "\n")
cat("Summary:", out_summary, "\n")
