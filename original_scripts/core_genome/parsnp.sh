#!/usr/bin/env bash

set -euo pipefail

echo "Starting Parsnp run..."
date

REF=/export/space3/users/silvanac/Abaumannii_ChromArch/data/genomes_ncbi/fasta/GCF_001077675.1_genomic.fna
GENOMES=/export/space3/users/silvanac/Abaumannii_ChromArch/data/genomes_ncbi/fasta
OUTDIR=/export/space3/users/silvanac/Abaumannii_ChromArch/results/parsnp

parsnp \
-r "$REF" \
-d "$GENOMES" \
-p 14 \
-o "$OUTDIR"

echo "Parsnp finished"
date
