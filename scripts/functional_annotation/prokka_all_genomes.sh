#!/usr/bin/env bash

# ==============================================================================
# Script title: Automatic annotation of A. baumannii genomes with Prokka
# Author: Silvana Yalú Cristo Martínez
# Creation date: 2026-05-13
# Last update: 2026-05-13
#
# Description:
# This script runs automatic genome annotation for multiple bacterial genomes
# using Prokka. It iterates over all .fna files in the input directory, generates
# a reproducible locus tag from each genome accession, and saves the annotation
# outputs in independent directories.
#
# The script:
# - Detects FASTA files automatically (.fna)
# - Generates locus tags based on RefSeq/GenBank accession IDs
# - Organizes outputs by genome
# - Uses annotation parameters specific for Acinetobacter baumannii
#
# Requirements:
# - Prokka installed and available in the PATH
# - .fna files in the input directory
# - Bash >= 4
# ==============================================================================


# ==============================================================================
# GENERAL SCRIPT CONFIGURATION
# ==============================================================================

set -euo pipefail


# ==============================================================================
# DEFINE DIRECTORIES AND PARAMETERS
# ==============================================================================

PROJECT_DIR="/export/space3/users/silvanac/Abaumannii_ChromArch"
INPUT_DIR="${PROJECT_DIR}/data/genomes_ncbi/fasta"

OUT_DIR="${PROJECT_DIR}/results/prokka"

CPUS=8


# ==============================================================================
# INITIAL MESSAGES
# ==============================================================================

echo "Starting annotation with Prokka"
echo "Input directory: $INPUT_DIR"
echo "Output directory: $OUT_DIR"
echo "CPUs per genome: $CPUS"
echo


# ==============================================================================
# GENOME COUNTER
# ==============================================================================

i=0


# ==============================================================================
# MAIN LOOP OVER GENOMES
# ==============================================================================

for GENOME in "${INPUT_DIR}"/*.fna; do

    # --------------------------------------------------------------------------
    # UPDATE GENOME COUNTER
    # --------------------------------------------------------------------------

    i=$((i + 1))


    # --------------------------------------------------------------------------
    # GET GENOME BASENAME
    # --------------------------------------------------------------------------

    BASENAME=$(basename "$GENOME" .fna)


    # --------------------------------------------------------------------------
    # EXTRACT ACCESSION AND GENERATE LOCUS TAG
    #
    # Example:
    # GCF_000018445.1  -->  GCF000018445
    # --------------------------------------------------------------------------

    ACCESSION=$(echo "$BASENAME" | grep -oE 'GC[AF]_[0-9]+\.[0-9]+' | head -n 1)

    LOCUSTAG=$(echo "$ACCESSION" | sed 's/_//g' | cut -d'.' -f1)


    # --------------------------------------------------------------------------
    # DISPLAY CURRENT GENOME INFORMATION
    # --------------------------------------------------------------------------

    echo "======================================================"
    echo "Genome $i"
    echo "File: $GENOME"
    echo "Basename: $BASENAME"
    echo "Accession: $ACCESSION"
    echo "Locus tag: $LOCUSTAG"
    echo "Output: ${OUT_DIR}/${BASENAME}"
    echo "======================================================"


    # --------------------------------------------------------------------------
    # RUN PROKKA
    # --------------------------------------------------------------------------

    prokka "$GENOME" \
        --outdir "${OUT_DIR}/${BASENAME}" \
        --prefix "$BASENAME" \
        --locustag "$LOCUSTAG" \
        --genus Acinetobacter \
        --species baumannii \
        --kingdom Bacteria \
        --cpus "$CPUS" \
        --force


    # --------------------------------------------------------------------------
    # FINAL MESSAGE FOR CURRENT GENOME
    # --------------------------------------------------------------------------

    echo "Finished: $BASENAME"
    echo

done


# ==============================================================================
# END OF SCRIPT
# ==============================================================================

echo "All annotations finished."
