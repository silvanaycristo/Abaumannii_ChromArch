#!/usr/bin/env Rscript

library(gdsfmt)
library(SNPRelate)
library(readr)
library(dplyr)
library(ggplot2)

project_dir <- "/export/space3/users/silvanac/Abaumannii_ChromArch"

vcf_file <- file.path(project_dir, "results/parsnp/parsnp.vcf")

gds_file <- file.path(project_dir, "results/hierbaps/parsnp.gds")

metadata_file <- file.path(
  project_dir,
  "results/hierbaps/hierbaps_clusters_with_metadata_no_refdup.csv"
)

out_pca_csv <- file.path(project_dir, "results/hierbaps/pca_variance.csv")

out_plot <- file.path(project_dir, "results/hierbaps/pca_level1.pdf")

# -----------------------------------
# Convert VCF -> GDS
# -----------------------------------

snpgdsVCF2GDS(
  vcf.fn = vcf_file,
  out.fn = gds_file,
  method = "biallelic.only",
  verbose = TRUE
)

# -----------------------------------
# Open GDS
# -----------------------------------

genofile <- snpgdsOpen(gds_file)

# -----------------------------------
# PCA
# -----------------------------------

pca <- snpgdsPCA(
  genofile,
  autosome.only = FALSE,
  num.thread = 4
)

# -----------------------------------
# Variance explained
# -----------------------------------

pc.percent <- pca$varprop * 100

variance_df <- data.frame(
  PC = paste0("PC", 1:length(pc.percent)),
  Variance = pc.percent
)

write_csv(variance_df, out_pca_csv)

# -----------------------------------
# Metadata
# -----------------------------------

meta <- read_csv(metadata_file, show_col_types = FALSE)

# SNPRelate sample IDs
sample_ids <- pca$sample.id

# Extract accession
sample_acc <- sub(".*(GCF_[0-9]+\\.[0-9]+).*", "\\1", sample_ids)

pca_df <- data.frame(
  sample.id = sample_ids,
  acc_num_refseq = sample_acc,
  PC1 = pca$eigenvect[,1],
  PC2 = pca$eigenvect[,2]
)

# merge with metadata
pca_df <- left_join(
  pca_df,
  meta,
  by = "acc_num_refseq"
)

# -----------------------------------
# Plot
# -----------------------------------

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

# -----------------------------------
# Close
# -----------------------------------

snpgdsClose(genofile)

cat("Done.\n")
cat("PCA plot:", out_plot, "\n")
