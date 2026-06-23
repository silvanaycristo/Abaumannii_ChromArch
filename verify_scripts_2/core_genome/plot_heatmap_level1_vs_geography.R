#!/usr/bin/env Rscript

# ==============================================================================
# Script title: Heatmap of hierBAPS level 1 clusters versus geography
# Author: Silvana Yalú Cristo Martínez
# Creation date: 2026-05-13
# Last update: 2026-05-13
#
# Description:
# This script plots the relationship between hierBAPS level 1 clusters and
# geographic origin. It groups less frequent countries into an "Other" category
# to improve figure readability and exports the heatmap as a PDF.
#
# The script:
# - Loads the level 1 cluster-by-geography count table
# - Keeps selected frequent countries as individual categories
# - Groups remaining geographic origins as Other
# - Plots isolate counts as a heatmap
# - Saves the figure to results/hierbaps
#
# Requirements:
# - R packages: readr, dplyr, ggplot2
# - cluster_vs_geography_level1_no_refdup.csv table
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
  "results/hierbaps/cluster_vs_geography_level1_no_refdup.csv"
)

output_pdf <- file.path(
  project_dir,
  "results/hierbaps/heatmap_level1_vs_geography.pdf"
)


# ==============================================================================
# LOAD DATA
# ==============================================================================

df <- read_csv(input_file, show_col_types = FALSE)


# ==============================================================================
# GROUP GEOGRAPHIC ORIGINS FOR PLOTTING
# ==============================================================================

top_geo <- c(
  "China",
  "USA",
  "Mexico",
  "India",
  "France",
  "Germany",
  "Canada"
)

df_plot <- df %>%
  mutate(
    geo_grouped = ifelse(
      manual_geo_loc %in% top_geo,
      manual_geo_loc,
      "Other"
    )
  ) %>%
  group_by(level.1, geo_grouped) %>%
  summarise(
    n = sum(n),
    .groups = "drop"
  )


# ==============================================================================
# PLOT HEATMAP
# ==============================================================================

p <- ggplot(df_plot,
            aes(
              x = geo_grouped,
              y = factor(level.1),
              fill = n
            )) +

  geom_tile(color = "white") +

  geom_text(aes(label = n),
            size = 4) +

  scale_fill_gradient(
    low = "white",
    high = "darkred"
  ) +

  labs(
    title = "hierBAPS Level 1 Clusters vs Geography",
    x = "Geographic origin",
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
