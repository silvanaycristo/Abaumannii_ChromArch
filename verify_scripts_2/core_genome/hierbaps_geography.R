#!/usr/bin/env Rscript

# ==============================================================================
# Script title: Summarize hierBAPS clusters by geographic origin
# Author: Silvana Yalú Cristo Martínez
# Creation date: 2026-05-13
# Last update: 2026-05-13
#
# Description:
# This script compares hierBAPS cluster assignments with manually curated
# geographic metadata. It calculates geographic counts and proportions within
# each hierBAPS level, identifies the dominant geographic origin per cluster, and
# writes summary tables for downstream interpretation and plotting.
#
# The script:
# - Loads de-duplicated hierBAPS metadata
# - Standardizes missing geographic values as Unknown
# - Counts geographic origins within level 1 and level 2 clusters
# - Identifies the dominant geographic origin for each cluster
# - Saves cluster tables, dominant-origin tables, and a text summary
#
# Requirements:
# - R packages: readr, dplyr
# - De-duplicated hierBAPS metadata table with geographic annotations
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

infile <- file.path(project_dir, "results/hierbaps/hierbaps_clusters_with_metadata_no_refdup.csv")

out_l1 <- file.path(project_dir, "results/hierbaps/cluster_vs_geography_level1_no_refdup.csv")
out_l2 <- file.path(project_dir, "results/hierbaps/cluster_vs_geography_level2_no_refdup.csv")
out_dom_l1 <- file.path(project_dir, "results/hierbaps/dominant_geography_by_level1_no_refdup.csv")
out_dom_l2 <- file.path(project_dir, "results/hierbaps/dominant_geography_by_level2_no_refdup.csv")
out_summary <- file.path(project_dir, "results/hierbaps/geography_summary_no_refdup.txt")


# ==============================================================================
# LOAD AND STANDARDIZE METADATA
# ==============================================================================

meta <- read_csv(infile, show_col_types = FALSE)

meta <- meta %>%
  mutate(
    level.1 = as.factor(level.1),
    level.2 = as.factor(level.2),
    manual_geo_loc = ifelse(
      is.na(manual_geo_loc) | manual_geo_loc == "" | manual_geo_loc == "-",
      "Unknown",
      as.character(manual_geo_loc)
    )
  )


# ==============================================================================
# COUNT GEOGRAPHIC ORIGINS BY HIERBAPS LEVEL 1 CLUSTER
# ==============================================================================

cluster_geo_l1 <- meta %>%
  count(level.1, manual_geo_loc, name = "n") %>%
  group_by(level.1) %>%
  mutate(prop_in_cluster = n / sum(n)) %>%
  arrange(level.1, desc(n)) %>%
  ungroup()


# ==============================================================================
# COUNT GEOGRAPHIC ORIGINS BY HIERBAPS LEVEL 2 CLUSTER
# ==============================================================================

cluster_geo_l2 <- meta %>%
  count(level.2, manual_geo_loc, name = "n") %>%
  group_by(level.2) %>%
  mutate(prop_in_cluster = n / sum(n)) %>%
  arrange(level.2, desc(n)) %>%
  ungroup()


# ==============================================================================
# IDENTIFY DOMINANT GEOGRAPHIC ORIGIN PER CLUSTER
# ==============================================================================

dominant_l1 <- cluster_geo_l1 %>%
  group_by(level.1) %>%
  slice_max(n, n = 1, with_ties = FALSE) %>%
  ungroup()

dominant_l2 <- cluster_geo_l2 %>%
  group_by(level.2) %>%
  slice_max(n, n = 1, with_ties = FALSE) %>%
  ungroup()


# ==============================================================================
# WRITE OUTPUT TABLES
# ==============================================================================

write_csv(cluster_geo_l1, out_l1)
write_csv(cluster_geo_l2, out_l2)
write_csv(dominant_l1, out_dom_l1)
write_csv(dominant_l2, out_dom_l2)


# ==============================================================================
# WRITE TEXT SUMMARY
# ==============================================================================

sink(out_summary)
cat("Total rows:", nrow(meta), "\n")
cat("Unique RefSeq accessions:", n_distinct(meta$acc_num_refseq), "\n\n")

cat("Geography counts:\n")
print(sort(table(meta$manual_geo_loc), decreasing = TRUE))

cat("\nDominant geography by level 1 cluster:\n")
print(dominant_l1)

cat("\nDominant geography by level 2 cluster:\n")
print(dominant_l2)
sink()


# ==============================================================================
# END OF SCRIPT
# ==============================================================================

cat("Done.\n")
cat("Level 1 vs geography:", out_l1, "\n")
cat("Level 2 vs geography:", out_l2, "\n")
cat("Summary:", out_summary, "\n")
