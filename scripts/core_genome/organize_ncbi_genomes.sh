#!/usr/bin/env bash

# ==============================================================================
# Script title: Organize NCBI genome download files by data type
# Author: Silvana Yalú Cristo Martínez
# Creation date: 2026-05-13
# Last update: 2026-05-13
#
# Description:
# This script reorganizes genome files downloaded with the NCBI Datasets
# structure. It iterates over each RefSeq genome directory and copies the main
# genome FASTA, CDS, GFF, GBFF, and protein files into project-specific folders.
#
# The script:
# - Detects RefSeq genome directories automatically
# - Copies genomic FASTA files into data/genomes_ncbi/fasta
# - Copies CDS, GFF, GBFF, and protein files into separate folders
# - Reports missing files without stopping the full organization step
#
# Requirements:
# - NCBI Datasets download directory present under data/genomes_ncbi/raw_download
# - Destination folders already created under data/genomes_ncbi
# - Bash >= 4
# ==============================================================================


# ==============================================================================
# GENERAL SCRIPT CONFIGURATION
# ==============================================================================

set -euo pipefail


# ==============================================================================
# DEFINE DIRECTORIES
# ==============================================================================

BASE=/export/space3/users/silvanac/Abaumannii_ChromArch/data/genomes_ncbi
RAW=$BASE/raw_download/ncbi_dataset/data


# ==============================================================================
# MAIN LOOP OVER NCBI GENOME DIRECTORIES
# ==============================================================================

for dir in "$RAW"/GCF_*; do
    [ -d "$dir" ] || continue

    acc=$(basename "$dir")

    # --------------------------------------------------------------------------
    # COPY GENOME FASTA
    #
    # Only the genomic assembly FASTA is selected; cds_from_genomic.fna is
    # excluded because it contains coding sequences instead of whole genomes.
    # --------------------------------------------------------------------------

    fna=$(find "$dir" -maxdepth 1 -type f -name "*_genomic.fna" ! -name "cds_from_genomic.fna" | head -n 1)
    if [ -n "${fna:-}" ]; then
        cp "$fna" "$BASE/fasta/${acc}_genomic.fna"
    else
        echo "WARNING: missing genome fasta for $acc"
    fi

    # --------------------------------------------------------------------------
    # COPY CDS FASTA
    # --------------------------------------------------------------------------

    cds="$dir/cds_from_genomic.fna"
    if [ -f "$cds" ]; then
        cp "$cds" "$BASE/cds/${acc}_cds_from_genomic.fna"
    else
        echo "WARNING: missing CDS for $acc"
    fi

    # --------------------------------------------------------------------------
    # COPY GFF ANNOTATION
    # --------------------------------------------------------------------------

    if [ -f "$dir/genomic.gff" ]; then
        cp "$dir/genomic.gff" "$BASE/gff/${acc}_genomic.gff"
    elif [ -f "$dir/genomic.gff3" ]; then
        cp "$dir/genomic.gff3" "$BASE/gff/${acc}_genomic.gff"
    else
        gff=$(find "$dir" -maxdepth 1 -type f \( -name "*.gff" -o -name "*.gff3" \) | head -n 1)
        if [ -n "${gff:-}" ]; then
            cp "$gff" "$BASE/gff/${acc}_genomic.gff"
        else
            echo "WARNING: missing GFF for $acc"
        fi
    fi

    # --------------------------------------------------------------------------
    # COPY GENBANK FLAT FILE
    # --------------------------------------------------------------------------

    gbff="$dir/genomic.gbff"
    if [ -f "$gbff" ]; then
        cp "$gbff" "$BASE/gbff/${acc}_genomic.gbff"
    else
        echo "WARNING: missing GBFF for $acc"
    fi

    # --------------------------------------------------------------------------
    # COPY PROTEIN FASTA
    # --------------------------------------------------------------------------

    faa="$dir/protein.faa"
    if [ -f "$faa" ]; then
        cp "$faa" "$BASE/protein/${acc}_protein.faa"
    else
        echo "WARNING: missing protein FAA for $acc"
    fi
done


# ==============================================================================
# END OF SCRIPT
# ==============================================================================

echo "Done."
