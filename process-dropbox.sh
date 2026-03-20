#!/usr/bin/env bash
# Move audio files from Dropbox to ./input and transcribe them,
# writing output text files to ./output.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DROPBOX_DIR="$HOME/Dropbox/audio"
INPUT_DIR="$SCRIPT_DIR/input"
OUTPUT_DIR="$SCRIPT_DIR/output"

mkdir -p "$INPUT_DIR" "$OUTPUT_DIR"

# Move all files from Dropbox audio dir to input
shopt -s nullglob
files=("$DROPBOX_DIR"/*)
shopt -u nullglob

if [ ${#files[@]} -eq 0 ]; then
    echo "No files found in $DROPBOX_DIR"
    exit 0
fi

echo "Moving ${#files[@]} file(s) from $DROPBOX_DIR to $INPUT_DIR"
mv "${files[@]}" "$INPUT_DIR/"

# Run transcription
python3 "$SCRIPT_DIR/transcribe.py" "$INPUT_DIR" --output-dir "$OUTPUT_DIR"
