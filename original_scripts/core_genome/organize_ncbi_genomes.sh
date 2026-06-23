#!/usr/bin/env bash

set -euo pipefail

BASE=/export/space3/users/silvanac/Abaumannii_ChromArch/data/genomes_ncbi
RAW=$BASE/raw_download/ncbi_dataset/data

for dir in "$RAW"/GCF_*; do
    [ -d "$dir" ] || continue

    acc=$(basename "$dir")

    # genome fasta: solo el ensamblado genómico, no cds_from_genomic.fna
    fna=$(find "$dir" -maxdepth 1 -type f -name "*_genomic.fna" ! -name "cds_from_genomic.fna" | head -n 1)
    if [ -n "${fna:-}" ]; then
        cp "$fna" "$BASE/fasta/${acc}_genomic.fna"
    else
        echo "WARNING: missing genome fasta for $acc"
    fi

    # cds
    cds="$dir/cds_from_genomic.fna"
    if [ -f "$cds" ]; then
        cp "$cds" "$BASE/cds/${acc}_cds_from_genomic.fna"
    else
        echo "WARNING: missing CDS for $acc"
    fi

    # gff
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

    # gbff
    gbff="$dir/genomic.gbff"
    if [ -f "$gbff" ]; then
        cp "$gbff" "$BASE/gbff/${acc}_genomic.gbff"
    else
        echo "WARNING: missing GBFF for $acc"
    fi

    # protein
    faa="$dir/protein.faa"
    if [ -f "$faa" ]; then
        cp "$faa" "$BASE/protein/${acc}_protein.faa"
    else
        echo "WARNING: missing protein FAA for $acc"
    fi
done

echo "Done."
