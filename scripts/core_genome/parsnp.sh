#!/usr/bin/env bash

# ==============================================================================
# Script title: Core-genome alignment of A. baumannii genomes with Parsnp
# Author: Silvana Yalú Cristo Martínez
# Creation date: 2026-05-13
# Last update: 2026-05-13
#
# Description:
# This script runs Parsnp to build a core-genome alignment from the NCBI genome
# FASTA collection. It uses a selected reference genome and writes the Parsnp
# output files to the project results directory.
#
# The script:
# - Defines the reference genome used for alignment
# - Uses all genomes in the FASTA directory as input
# - Runs Parsnp with multiple threads
# - Stores the core-genome alignment and tree outputs in results/parsnp
#
# Requirements:
# - Parsnp installed and available in the PATH
# - Genome FASTA files available in the input directory
# - Bash >= 4
# ==============================================================================


# ==============================================================================
# GENERAL SCRIPT CONFIGURATION
# ==============================================================================

set -euo pipefail


# ==============================================================================
# INITIAL MESSAGES
# ==============================================================================

echo "Starting Parsnp run..."
date


# ==============================================================================
# DEFINE INPUTS AND OUTPUT DIRECTORY
# ==============================================================================

REF=/export/space3/users/silvanac/Abaumannii_ChromArch/data/genomes_ncbi/fasta/GCF_001077675.1_genomic.fna
GENOMES=/export/space3/users/silvanac/Abaumannii_ChromArch/data/genomes_ncbi/fasta
OUTDIR=/export/space3/users/silvanac/Abaumannii_ChromArch/results/parsnp


# ==============================================================================
# RUN PARSNP
# ==============================================================================

parsnp \
-r "$REF" \
-d "$GENOMES" \
-p 14 \
-o "$OUTDIR"


# ==============================================================================
# END OF SCRIPT
# ==============================================================================

echo "Parsnp finished"
date
