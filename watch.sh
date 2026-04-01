#!/usr/bin/env bash
# Watch ~/Dropbox/audio/ for new files and automatically run the transcription pipeline.
# Uses a 30-second debounce window so multiple files arriving in quick succession
# are processed together in a single batch.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DROPBOX_DIR="$HOME/Dropbox/audio"

if ! command -v inotifywait &>/dev/null; then
    echo "Error: inotifywait not found. Install with: sudo apt install inotify-tools"
    exit 1
fi

mkdir -p "$DROPBOX_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

log "Watching $DROPBOX_DIR for new files (30s debounce)..."

inotifywait -m -e close_write -e moved_to --format '%f' "$DROPBOX_DIR" |
while read -r filename; do
    log "Detected: $filename"
    # Debounce: keep resetting the timer while new files arrive within 30s
    while read -t 30 -r next_filename; do
        log "Detected: $next_filename"
    done
    log "No new files for 30s, running pipeline..."
    if "$SCRIPT_DIR/run.sh"; then
        log "Pipeline completed successfully."
    else
        log "Pipeline failed with exit code $?."
    fi
    log "Resuming watch..."
done
