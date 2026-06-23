# Abaumannii_ChromArch

Chromosome architecture and core-genome population structure analysis for
*Acinetobacter baumannii*.

## Overview

This repository contains scripts and documentation used to adapt a chromosome
architecture analysis framework to *Acinetobacter baumannii* genomes. The
project focuses on the organization of the core genome, population structure
inferred from core-genome SNPs, and the relationship between genomic clusters,
geographic origin, and MLST profiles.

The work is based on the analytical rationale described in:

Castro-Jaimes, S., Bello-Lopez, E., Velazquez-Acosta, C.,
Volkow-Fernandez, P., Lozano-Zarain, P., Castillo-Ramirez, S., & Cevallos,
M. A. (2020). Chromosome architecture and gene content of the emergent pathogen
*Acinetobacter haemolyticus*. *Frontiers in Microbiology*, 11, 926.
https://doi.org/10.3389/fmicb.2020.00926

Rather than providing a fully generalized pipeline, this repository preserves
the project scripts used for genome organization, annotation, core-genome
alignment, SNP-based clustering, and summary visualization.

## Repository Structure

```text
.
├── scripts/
│   ├── core_genome/
│   └── functional_annotation/
├── LICENSE
└── README.md
```

- `scripts/core_genome/`: scripts for genome file organization, Parsnp alignment, PGDSpider conversion, hierBAPS clustering, PCA, and cluster visualizations.
- `scripts/functional_annotation/`: scripts for batch genome annotation with Prokka.

## Analysis Workflow

The current workflow is organized into the following analysis blocks.

### 1. Genome File Organization

`scripts/core_genome/organize_ncbi_genomes.sh` reorganizes files downloaded from NCBI
datasets into project-specific folders for:

- genomic FASTA files (`.fna`)
- coding sequences
- GFF annotations
- GenBank flat files
- protein FASTA files

This step prepares the input structure expected by downstream scripts.

### 2. Functional Annotation

`scripts/functional_annotation/prokka_all_genomes.sh` runs Prokka on all genome FASTA
files in the project input directory. Outputs are written into one directory per
genome accession.

The script sets annotation parameters for *Acinetobacter baumannii* and builds
reproducible locus tags from RefSeq or GenBank accession identifiers.

### 3. Core-Genome Alignment

`scripts/core_genome/parsnp.sh` runs Parsnp using a selected reference genome and the
project genome FASTA collection. Parsnp outputs are written under
`results/parsnp/` and include the core-genome alignment, tree, VCF, and related
files.

`scripts/core_genome/pgdspider.sh` converts the Parsnp XMFA alignment to PHYLIP format
with PGDSpider, producing the alignment used for downstream clustering.

### 4. Population Structure with hierBAPS

`scripts/core_genome/hierbaps.R` loads the Parsnp PHYLIP alignment, removes
non-informative sites, writes an informative-site FASTA alignment, and runs
hierBAPS with two clustering levels.

Main outputs include:

- `hierbaps_clusters.csv`
- `hierbaps_result.rds`
- `parsnp_informative_sites.fasta`

### 5. Cluster Summaries and Metadata Integration

The downstream R scripts summarize how hierBAPS clusters relate to available
metadata:

- `hierbaps_mlst.R`: summarizes cluster composition by Pasteur MLST sequence
  type and removes duplicate RefSeq accessions introduced by reference handling.
- `hierbaps_geography.R`: summarizes cluster composition by geographic origin.
- `plot_heatmap_level1_vs_mlst.R`: plots level 1 clusters against MLST.
- `plot_heatmap_level1_vs_geography.R`: plots level 1 clusters against
  geographic origin.

### 6. Core-SNP PCA and Tree Visualization

- `pca_snprelate.R`: converts the Parsnp VCF to GDS, runs PCA with SNPRelate,
  saves explained variance, and plots PC1/PC2 colored by hierBAPS level 1.
- `plot_parsnp_tree_hierbaps.R`: plots the Parsnp tree colored by hierBAPS
  level 1 and level 2 assignments.

## Expected Inputs

The scripts expect the project to be organized under a server-side directory
similar to:

```text
/export/space3/users/silvanac/Abaumannii_ChromArch
```

Expected input folders include:

```text
data/genomes_ncbi/raw_download/ncbi_dataset/data/
data/genomes_ncbi/fasta/
data/genomes_ncbi/cds/
data/genomes_ncbi/gff/
data/genomes_ncbi/gbff/
data/genomes_ncbi/protein/
```

Genome files and large analysis outputs are not tracked in this repository.

## Main Outputs

Depending on the script, outputs are expected under:

```text
results/prokka/
results/parsnp/
results/hierbaps/
logs/
```

Representative outputs include:

- Prokka annotation directories for each genome
- Parsnp core-genome alignment and tree files
- PHYLIP and FASTA alignments for informative sites
- hierBAPS cluster assignments
- MLST and geography cluster summaries
- PCA variance tables and PDF plots
- Parsnp tree visualizations colored by cluster assignment

## Software Requirements

The scripts use a combination of command-line tools and R packages.

Command-line tools:

- Bash
- Parsnp
- PGDSpider2
- Java, required by PGDSpider
- Prokka

R packages:

- `ape`
- `rhierbaps`
- `readr`
- `dplyr`
- `ggplot2`
- `gdsfmt`
- `SNPRelate`

Package versions are not pinned in the repository yet. For reproducible reruns,
record the software versions used on the analysis server.

## Usage Notes

Most scripts currently contain absolute project paths for the Chaac server. If
running the analyses elsewhere, update the path variables at the top of each
script before execution.

Recommended execution pattern:

```bash
bash scripts/core_genome/organize_ncbi_genomes.sh
bash scripts/functional_annotation/prokka_all_genomes.sh
bash scripts/core_genome/parsnp.sh
bash scripts/core_genome/pgdspider.sh
Rscript scripts/core_genome/hierbaps.R
Rscript scripts/core_genome/hierbaps_mlst.R
Rscript scripts/core_genome/hierbaps_geography.R
Rscript scripts/core_genome/pca_snprelate.R
Rscript scripts/core_genome/plot_parsnp_tree_hierbaps.R
Rscript scripts/core_genome/plot_heatmap_level1_vs_mlst.R
Rscript scripts/core_genome/plot_heatmap_level1_vs_geography.R
```

Before running long jobs, check whether outputs already exist and redirect logs
for expensive steps.

## Reproducibility Status

This repository is currently a project script archive rather than a packaged,
parameterized workflow. The main reproducibility limitations are:

- absolute server paths in scripts
- untracked input genomes and large outputs
- no locked software environment file yet

Recommended future improvements:

- add a project configuration file for paths and thread counts
- add an environment file with exact tool and R package versions- add a small test dataset or dry-run mode
- document the metadata table schema expected by downstream scripts

## Data Availability

Input genomes are expected to come from NCBI datasets. Large genome files,
intermediate alignments, annotation outputs, and result folders are excluded
from this repository to keep it lightweight.

When publishing or sharing the analysis, include accession lists, download
commands, software versions, and any metadata curation steps needed to recreate
the dataset.

## Citation

If you use this repository in your research, please cite:

Cristo-Martinez, S. Y., Escobedo Munoz, A. S., & Cevallos Gaos, M. A. (2026).
*Abaumannii_ChromArch: Chromosome architecture and gene content organization in
Acinetobacter baumannii* (Version 1.0). GitHub.
https://github.com/silvanaycristo/Abaumannii_ChromArch

Once the project is published or presented, update this section with the final
citation format.

## License

This project is distributed under the MIT License. See the `LICENSE` file for
details.

## Contact

For questions, issues, or collaborations, please open an issue in this
repository or contact:

- Silvana Yalu Cristo-Martinez: silvanac@lcg.unam.mx
- Sofel Escobedo-Munoz: aescobed@lcg.unam.mx
- Miguel Angel Cevallos-Gaos: mac@ccg.unam.mx
