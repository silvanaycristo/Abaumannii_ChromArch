#!/usr/bin/env Rscript

library(readr)
library(dplyr)

project_dir <- "/export/space3/users/silvanac/Abaumannii_ChromArch"

infile <- file.path(project_dir, "results/hierbaps/hierbaps_clusters_with_metadata_no_refdup.csv")

out_l1 <- file.path(project_dir, "results/hierbaps/cluster_vs_geography_level1_no_refdup.csv")
out_l2 <- file.path(project_dir, "results/hierbaps/cluster_vs_geography_level2_no_refdup.csv")
out_dom_l1 <- file.path(project_dir, "results/hierbaps/dominant_geography_by_level1_no_refdup.csv")
out_dom_l2 <- file.path(project_dir, "results/hierbaps/dominant_geography_by_level2_no_refdup.csv")
out_summary <- file.path(project_dir, "results/hierbaps/geography_summary_no_refdup.txt")

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

cluster_geo_l1 <- meta %>%
  count(level.1, manual_geo_loc, name = "n") %>%
  group_by(level.1) %>%
  mutate(prop_in_cluster = n / sum(n)) %>%
  arrange(level.1, desc(n)) %>%
  ungroup()

cluster_geo_l2 <- meta %>%
  count(level.2, manual_geo_loc, name = "n") %>%
  group_by(level.2) %>%
  mutate(prop_in_cluster = n / sum(n)) %>%
  arrange(level.2, desc(n)) %>%
  ungroup()

dominant_l1 <- cluster_geo_l1 %>%
  group_by(level.1) %>%
  slice_max(n, n = 1, with_ties = FALSE) %>%
  ungroup()

dominant_l2 <- cluster_geo_l2 %>%
  group_by(level.2) %>%
  slice_max(n, n = 1, with_ties = FALSE) %>%
  ungroup()

write_csv(cluster_geo_l1, out_l1)
write_csv(cluster_geo_l2, out_l2)
write_csv(dominant_l1, out_dom_l1)
write_csv(dominant_l2, out_dom_l2)

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

cat("Done.\n")
cat("Level 1 vs geography:", out_l1, "\n")
cat("Level 2 vs geography:", out_l2, "\n")
cat("Summary:", out_summary, "\n")

