#!/usr/bin/env Rscript

library(readr)
library(dplyr)
library(ggplot2)

project_dir <- "/export/space3/users/silvanac/Abaumannii_ChromArch"

input_file <- file.path(
  project_dir,
  "results/hierbaps/cluster_vs_geography_level1_no_refdup.csv"
)

output_pdf <- file.path(
  project_dir,
  "results/hierbaps/heatmap_level1_vs_geography.pdf"
)

# -----------------------------
# Load data
# -----------------------------

df <- read_csv(input_file, show_col_types = FALSE)

# -----------------------------
# Keep most frequent countries
# -----------------------------

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

# -----------------------------
# Plot
# -----------------------------

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

# -----------------------------
# Save
# -----------------------------

ggsave(
  output_pdf,
  p,
  width = 10,
  height = 6
)

cat("Heatmap saved to:\n")
cat(output_pdf, "\n")
