#!/usr/bin/env bash
# Full pipeline: archive old files, fetch new audio, transcribe, tag, and open results.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INPUT_DIR="$SCRIPT_DIR/input"
OUTPUT_DIR="$SCRIPT_DIR/output"
PROCESSED_DIR="$SCRIPT_DIR/processed"

mkdir -p "$INPUT_DIR" "$OUTPUT_DIR" "$PROCESSED_DIR"

# Archive old input and output files
shopt -s nullglob
old_input=("$INPUT_DIR"/*)
old_output=("$OUTPUT_DIR"/*)
shopt -u nullglob

if [ ${#old_input[@]} -gt 0 ]; then
    echo "Archiving ${#old_input[@]} file(s) from input/"
    mv "${old_input[@]}" "$PROCESSED_DIR/"
fi

if [ ${#old_output[@]} -gt 0 ]; then
    echo "Archiving ${#old_output[@]} file(s) from output/"
    mv "${old_output[@]}" "$PROCESSED_DIR/"
fi

# Fetch and transcribe
"$SCRIPT_DIR/process-dropbox.sh"

# Tag dream files
"$SCRIPT_DIR/tag_dreams.sh"

# Open results
shopt -s nullglob
results=("$OUTPUT_DIR"/*.txt)
shopt -u nullglob

if [ ${#results[@]} -gt 0 ]; then
    mousepad "${results[@]}" &
fi
