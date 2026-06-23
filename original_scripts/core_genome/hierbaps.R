library(rhierbaps)
library(ape)

alignment_file <- "/export/space3/users/silvanac/Abaumannii_ChromArch/results/parsnp/parsnp.phy"

outdir <- "/export/space3/users/silvanac/Abaumannii_ChromArch/results/hierbaps"
dir.create(outdir, recursive = TRUE, showWarnings = FALSE)

alignment <- ape::read.dna(
  alignment_file,
  format = "sequential"
)

cat("Dimensiones originales:\n")
print(dim(alignment))

alignment_char <- as.character(alignment)
alignment_char <- toupper(alignment_char)

informative_sites <- apply(alignment_char, 2, function(col) {
  col2 <- col[col != "-" & col != "N"]
  length(unique(col2)) > 1
})

cat("Sitios informativos:\n")
print(sum(informative_sites))

alignment_inf <- alignment[, informative_sites]

cat("Dimensiones filtradas:\n")
print(dim(alignment_inf))

# guardar alignment filtrado como FASTA
filtered_fasta <- file.path(outdir, "parsnp_informative_sites.fasta")

ape::write.dna(
  alignment_inf,
  file = filtered_fasta,
  format = "fasta",
  nbcol = -1,
  colsep = ""
)

cat("FASTA filtrado guardado en:\n")
print(filtered_fasta)

# cargar con función propia de rhierbaps
snp_matrix <- load_fasta(filtered_fasta)

cat("Objeto cargado con load_fasta\n")

hb <- hierBAPS(
  snp_matrix,
  max.depth = 2,
  n.pops = 20
)

write.csv(
  hb$partition.df,
  file = file.path(outdir, "hierbaps_clusters.csv"),
  row.names = FALSE
)

saveRDS(
  hb,
  file = file.path(outdir, "hierbaps_result.rds")
)
