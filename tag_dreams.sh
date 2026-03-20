#!/usr/bin/env bash
# Add dream frontmatter to output text files whose names match a datetime pattern.
# Expected filename format: "YYYY-MM-DD HH.MM.SS.txt"

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/output"

shopt -s nullglob
files=("$OUTPUT_DIR"/*.txt)
shopt -u nullglob

if [ ${#files[@]} -eq 0 ]; then
    echo "No text files found in $OUTPUT_DIR"
    exit 0
fi

tagged=0
for file in "${files[@]}"; do
    basename="$(basename "$file" .txt)"
    if [[ "$basename" =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2})\ ([0-9]{2})\.([0-9]{2})\.([0-9]{2})$ ]]; then
        date="${BASH_REMATCH[1]}"
        hour="${BASH_REMATCH[2]}"
        min="${BASH_REMATCH[3]}"
        sec="${BASH_REMATCH[4]}"
        timestamp="${date}T${hour}:${min}:${sec}"

        # Skip if already tagged
        if head -1 "$file" | grep -q '^---$'; then
            echo "Skipping (already tagged): $(basename "$file")"
            continue
        fi

        frontmatter="---
tags:
  - dream
timestamp: ${timestamp}
---

"
        tmp="$(mktemp)"
        printf '%s' "$frontmatter" > "$tmp"
        cat "$file" >> "$tmp"
        mv "$tmp" "$file"

        echo "Tagged: $(basename "$file") -> $timestamp"
        tagged=$((tagged + 1))
    fi
done

echo "Tagged $tagged file(s)."
