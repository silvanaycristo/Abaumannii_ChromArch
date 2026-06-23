#!/usr/bin/env Rscript

# ==============================================================================
# Script title: PCA of Parsnp core-genome SNPs with SNPRelate
# Author: Silvana Yalú Cristo Martínez
# Creation date: 2026-05-13
# Last update: 2026-05-13
#
# Description:
# This script performs principal component analysis on the Parsnp VCF using
# SNPRelate. It converts the VCF file to GDS format, calculates PCA coordinates,
# merges PCA results with hierBAPS metadata, and saves a PCA plot colored by
# hierBAPS level 1 cluster.
#
# The script:
# - Converts the Parsnp VCF into SNPRelate GDS format
# - Runs PCA on core-genome SNPs
# - Saves the variance explained by each principal component
# - Extracts RefSeq accessions from sample identifiers
# - Merges PCA coordinates with hierBAPS metadata
# - Exports a PDF plot colored by level 1 cluster
#
# Requirements:
# - R packages: gdsfmt, SNPRelate, readr, dplyr, ggplot2
# - Parsnp VCF file
# - De-duplicated hierBAPS metadata table
# - Rscript
# ==============================================================================


# ==============================================================================
# LOAD REQUIRED PACKAGES
# ==============================================================================

library(gdsfmt)
library(SNPRelate)
library(readr)
library(dplyr)
library(ggplot2)


# ==============================================================================
# DEFINE INPUTS AND OUTPUTS
# ==============================================================================

project_dir <- "/export/space3/users/silvanac/Abaumannii_ChromArch"

vcf_file <- file.path(project_dir, "results/parsnp/parsnp.vcf")

gds_file <- file.path(project_dir, "results/hierbaps/parsnp.gds")

metadata_file <- file.path(
  project_dir,
  "results/hierbaps/hierbaps_clusters_with_metadata_no_refdup.csv"
)

out_pca_csv <- file.path(project_dir, "results/hierbaps/pca_variance.csv")

out_plot <- file.path(project_dir, "results/hierbaps/pca_level1.pdf")


# ==============================================================================
# CONVERT VCF TO GDS
# ==============================================================================

snpgdsVCF2GDS(
  vcf.fn = vcf_file,
  out.fn = gds_file,
  method = "biallelic.only",
  verbose = TRUE
)


# ==============================================================================
# OPEN GDS FILE
# ==============================================================================

genofile <- snpgdsOpen(gds_file)


# ==============================================================================
# RUN PCA
# ==============================================================================

pca <- snpgdsPCA(
  genofile,
  autosome.only = FALSE,
  num.thread = 4
)


# ==============================================================================
# SAVE VARIANCE EXPLAINED
# ==============================================================================

pc.percent <- pca$varprop * 100

variance_df <- data.frame(
  PC = paste0("PC", 1:length(pc.percent)),
  Variance = pc.percent
)

write_csv(variance_df, out_pca_csv)


# ==============================================================================
# LOAD METADATA
# ==============================================================================

meta <- read_csv(metadata_file, show_col_types = FALSE)


# ==============================================================================
# BUILD PCA DATA FRAME
# ==============================================================================

# ------------------------------------------------------------------------------
# SNPRELATE SAMPLE IDS
# ------------------------------------------------------------------------------

sample_ids <- pca$sample.id

# ------------------------------------------------------------------------------
# EXTRACT REFSEQ ACCESSION
# ------------------------------------------------------------------------------

sample_acc <- sub(".*(GCF_[0-9]+\\.[0-9]+).*", "\\1", sample_ids)

pca_df <- data.frame(
  sample.id = sample_ids,
  acc_num_refseq = sample_acc,
  PC1 = pca$eigenvect[,1],
  PC2 = pca$eigenvect[,2]
)

# ------------------------------------------------------------------------------
# MERGE PCA COORDINATES WITH METADATA
# ------------------------------------------------------------------------------

pca_df <- left_join(
  pca_df,
  meta,
  by = "acc_num_refseq"
)


# ==============================================================================
# PLOT PCA BY HIERBAPS LEVEL 1 CLUSTER
# ==============================================================================

p <- ggplot(
  pca_df,
  aes(
    x = PC1,
    y = PC2,
    color = factor(level.1)
  )
) +

  geom_point(size = 3, alpha = 0.9) +

  labs(
    title = "PCA of core-genome SNPs",
    x = paste0("PC1 (", round(pc.percent[1], 1), "%)"),
    y = paste0("PC2 (", round(pc.percent[2], 1), "%)"),
    color = "Level 1"
  ) +

  theme_minimal(base_size = 14) +

  theme(
    plot.title = element_text(
      face = "bold",
      hjust = 0.5
    )
  )

ggsave(
  out_plot,
  p,
  width = 8,
  height = 6
)


# ==============================================================================
# CLOSE GDS FILE
# ==============================================================================

snpgdsClose(genofile)


# ==============================================================================
# END OF SCRIPT
# ==============================================================================

cat("Done.\n")
cat("PCA plot:", out_plot, "\n")
