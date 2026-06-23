#!/usr/bin/env Rscript

library(ape)

project_dir <- "/export/space3/users/silvanac/Abaumannii_ChromArch"

tree_file <- file.path(project_dir, "results/parsnp/parsnp.tree")
metadata_file <- file.path(project_dir, "results/hierbaps/hierbaps_clusters_with_metadata.csv")

out_level1 <- file.path(project_dir, "results/hierbaps/parsnp_tree_level1.pdf")
out_level2 <- file.path(project_dir, "results/hierbaps/parsnp_tree_level2.pdf")
unmatched_file <- file.path(project_dir, "results/hierbaps/tree_metadata_unmatched_tips.csv")

tree <- read.tree(tree_file)
meta <- read.csv(metadata_file, stringsAsFactors = FALSE, check.names = FALSE)

# Extract GCF accession from tree tip labels
tree_acc <- sub(".*(GCF_[0-9]+\\.[0-9]+).*", "\\1", tree$tip.label)
meta_acc <- meta$acc_num_refseq

# Match tree tips to metadata rows
match_idx <- match(tree_acc, meta_acc)

unmatched <- data.frame(
  tip_label = tree$tip.label[is.na(match_idx)],
  extracted_acc = tree_acc[is.na(match_idx)]
)

write.csv(unmatched, unmatched_file, row.names = FALSE)

if (nrow(unmatched) > 0) {
  warning("Some tree tips did not match metadata. See: ", unmatched_file)
}

plot_tree_by_cluster <- function(cluster_col, output_file, title_text) {
  clusters <- meta[[cluster_col]][match_idx]
  clusters <- as.factor(clusters)

  pal <- rainbow(length(levels(clusters)))
  names(pal) <- levels(clusters)

  tip_cols <- pal[as.character(clusters)]
  tip_cols[is.na(tip_cols)] <- "gray70"

  pdf(output_file, width = 14, height = 18)
  par(mar = c(1, 1, 4, 1))

  plot(
    tree,
    type = "phylogram",
    cex = 0.35,
    tip.color = tip_cols,
    main = title_text,
    no.margin = FALSE
  )

  title(main = title_text, line = 1.5, cex.main = 1.1)

  legend(
    "topright",
    legend = names(pal),
    col = pal,
    pch = 19,
    cex = 0.8,
    title = cluster_col,
    bty = "n"
  )

  dev.off()
}

plot_tree_by_cluster("level.1", out_level1, "Parsnp core-SNP tree colored by hierBAPS level 1")
plot_tree_by_cluster("level.2", out_level2, "Parsnp core-SNP tree colored by hierBAPS level 2")

cat("Done.\n")
cat("Level 1 tree:", out_level1, "\n")
cat("Level 2 tree:", out_level2, "\n")
cat("Unmatched tips:", unmatched_file, "\n")

