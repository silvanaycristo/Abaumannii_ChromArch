#!/bin/bash

# ==============================================================================
# Script title: Convert Parsnp XMFA alignment to PHYLIP with PGDSpider
# Author: Silvana Yalú Cristo Martínez
# Creation date: 2026-05-13
# Last update: 2026-05-13
#
# Description:
# This script converts the Parsnp XMFA output into PHYLIP format using
# PGDSpider. The resulting PHYLIP alignment is used as input for downstream
# core-genome population structure analyses.
#
# The script:
# - Defines the project paths for Parsnp and PGDSpider files
# - Uses a PGDSpider SPID template for XMFA-to-PHYLIP conversion
# - Redirects PGDSpider messages to a log file
# - Reports the start and end time of the conversion
#
# Requirements:
# - PGDSpider2-cli installed and available in the PATH
# - Java available for running PGDSpider
# - Parsnp XMFA output file
# - PGDSpider SPID template file
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

INPUT="$PROJECT_DIR/results/parsnp/parsnp.xmfa"
SPID="$PROJECT_DIR/results/parsnp/template_XMFA_PHYLIP.spid"
OUTPUT="$PROJECT_DIR/results/parsnp/parsnp.phy"
LOG="$PROJECT_DIR/logs/pgdspider.log"


# ==============================================================================
# INITIAL MESSAGES
# ==============================================================================

echo "Starting PGDSpider conversion..."
date

# ------------------------------------------------------------------------------
# ASSIGN ADDITIONAL JAVA MEMORY IF NEEDED
# ------------------------------------------------------------------------------

# export _JAVA_OPTIONS="-Xmx12g"


# ==============================================================================
# RUN PGDSPIDER CONVERSION
# ==============================================================================

PGDSpider2-cli \
-inputfile "$INPUT" \
-inputformat XMFA \
-outputfile "$OUTPUT" \
-outputformat PHYLIP \
-spid "$SPID" \
> "$LOG" 2>&1


# ==============================================================================
# END OF SCRIPT
# ==============================================================================

echo "PGDSpider finished."
date
