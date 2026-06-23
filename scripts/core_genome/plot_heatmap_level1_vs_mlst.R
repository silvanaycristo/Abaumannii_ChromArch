#!/usr/bin/env Rscript

# ==============================================================================
# Script title: Heatmap of hierBAPS level 1 clusters versus MLST Pasteur ST
# Author: Silvana Yalú Cristo Martínez
# Creation date: 2026-05-13
# Last update: 2026-05-13
#
# Description:
# This script plots the relationship between hierBAPS level 1 clusters and MLST
# Pasteur sequence types. It keeps the most frequent STs as individual
# categories, groups the remaining STs as "Other", and exports the heatmap as a
# PDF.
#
# The script:
# - Loads the level 1 cluster-by-MLST count table
# - Selects the most frequent MLST Pasteur STs
# - Groups remaining STs as Other
# - Plots isolate counts as a heatmap
# - Saves the figure to results/hierbaps
#
# Requirements:
# - R packages: readr, dplyr, ggplot2
# - cluster_vs_mlst_level1_no_refdup.csv table
# - Rscript
# ==============================================================================


# ==============================================================================
# LOAD REQUIRED PACKAGES
# ==============================================================================

library(readr)
library(dplyr)
library(ggplot2)


# ==============================================================================
# DEFINE INPUT AND OUTPUT FILES
# ==============================================================================

project_dir <- "/export/space3/users/silvanac/Abaumannii_ChromArch"

input_file <- file.path(
  project_dir,
  "results/hierbaps/cluster_vs_mlst_level1_no_refdup.csv"
)

output_pdf <- file.path(
  project_dir,
  "results/hierbaps/heatmap_level1_vs_mlst.pdf"
)


# ==============================================================================
# LOAD DATA
# ==============================================================================

df <- read_csv(input_file, show_col_types = FALSE)


# ==============================================================================
# GROUP MLST TYPES FOR PLOTTING
#
# Keeping only the most frequent STs as individual categories improves figure
# readability.
# ==============================================================================

top_st <- df %>%
  group_by(MLST.Pasteur.ST) %>%
  summarise(total = sum(n), .groups = "drop") %>%
  arrange(desc(total)) %>%
  slice_head(n = 8) %>%
  pull(MLST.Pasteur.ST)

df_plot <- df %>%
  mutate(
    MLST_grouped = ifelse(
      MLST.Pasteur.ST %in% top_st,
      MLST.Pasteur.ST,
      "Other"
    )
  ) %>%
  group_by(level.1, MLST_grouped) %>%
  summarise(
    n = sum(n),
    .groups = "drop"
  )


# ==============================================================================
# PLOT HEATMAP
# ==============================================================================

p <- ggplot(df_plot,
            aes(
              x = MLST_grouped,
              y = factor(level.1),
              fill = n
            )) +

  geom_tile(color = "white") +

  geom_text(aes(label = n),
            size = 4) +

  scale_fill_gradient(
    low = "white",
    high = "steelblue"
  ) +

  labs(
    title = "hierBAPS Level 1 Clusters vs MLST Pasteur ST",
    x = "MLST Pasteur ST",
    y = "hierBAPS Level 1 Cluster",
    fill = "Number of isolates"
  ) +

  theme_minimal(base_size = 14) +

  theme(
    plot.title = element_text(
      face = "bold",
      hjust = 0.5
    ),

    axis.text.x = element_text(
      angle = 45,
      hjust = 1
    )
  )


# ==============================================================================
# SAVE FIGURE
# ==============================================================================

ggsave(
  output_pdf,
  p,
  width = 10,
  height = 6
)


# ==============================================================================
# END OF SCRIPT
# ==============================================================================

cat("Heatmap saved to:\n")
cat(output_pdf, "\n")
