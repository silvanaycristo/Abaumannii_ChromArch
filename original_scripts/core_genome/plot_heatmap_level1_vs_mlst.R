#!/usr/bin/env Rscript

library(readr)
library(dplyr)
library(ggplot2)

project_dir <- "/export/space3/users/silvanac/Abaumannii_ChromArch"

input_file <- file.path(
  project_dir,
  "results/hierbaps/cluster_vs_mlst_level1_no_refdup.csv"
)

output_pdf <- file.path(
  project_dir,
  "results/hierbaps/heatmap_level1_vs_mlst.pdf"
)

# -----------------------------
# Load data
# -----------------------------

df <- read_csv(input_file, show_col_types = FALSE)

# -----------------------------
# Keep only frequent STs
# (helps readability)
# -----------------------------

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

# -----------------------------
# Plot
# -----------------------------

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
