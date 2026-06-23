#!/bin/bash

set -euo pipefail

PROJECT_DIR="/export/space3/users/silvanac/Abaumannii_ChromArch"

INPUT="$PROJECT_DIR/results/parsnp/parsnp.xmfa"
SPID="$PROJECT_DIR/results/parsnp/template_XMFA_PHYLIP.spid"
OUTPUT="$PROJECT_DIR/results/parsnp/parsnp.phy"
LOG="$PROJECT_DIR/logs/pgdspider.log"

echo "Starting PGDSpider conversion..."
date

# asignar memoria suficiente a Java de ser necesario 
# export _JAVA_OPTIONS="-Xmx12g"

PGDSpider2-cli \
-inputfile "$INPUT" \
-inputformat XMFA \
-outputfile "$OUTPUT" \
-outputformat PHYLIP \
-spid "$SPID" \
> "$LOG" 2>&1

echo "PGDSpider finished."
date
