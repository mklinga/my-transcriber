#!/usr/bin/env python3
"""Transcribe Finnish spoken notes from OGG audio files."""

import argparse
import sys
import time
from pathlib import Path

from faster_whisper import WhisperModel


def transcribe_file(model: WhisperModel, audio_path: Path) -> str:
    """Transcribe a single audio file and return the text."""
    segments, info = model.transcribe(
        str(audio_path),
        language="fi",
        beam_size=5,
        no_speech_threshold=0.6,
        log_prob_threshold=-1.0,
        hallucination_silence_threshold=2,
    )
    print(f"  Detected language '{info.language}' with probability {info.language_probability:.2f}")

    texts = []
    for segment in segments:
        texts.append(segment.text.strip())

    return "\n".join(texts)


def main():
    parser = argparse.ArgumentParser(description="Transcribe OGG audio files to text using faster-whisper.")
    parser.add_argument(
        "directory",
        nargs="?",
        default=".",
        help="Directory containing OGG files (default: current directory)",
    )
    parser.add_argument(
        "--model",
        default="large-v3",
        help="Whisper model size (default: large-v3)",
    )
    parser.add_argument(
        "--compute-type",
        default="float16",
        help="Compute type for inference (default: float16)",
    )
    parser.add_argument(
        "--output-dir",
        default=None,
        help="Directory for output text files (default: same as input)",
    )
    args = parser.parse_args()

    directory = Path(args.directory).resolve()
    if not directory.is_dir():
        print(f"Error: '{directory}' is not a directory", file=sys.stderr)
        sys.exit(1)

    output_dir = Path(args.output_dir).resolve() if args.output_dir else None
    if output_dir:
        output_dir.mkdir(parents=True, exist_ok=True)

    ogg_files = sorted(directory.glob("*.ogg"))
    if not ogg_files:
        print(f"No OGG files found in '{directory}'")
        sys.exit(0)

    print(f"Found {len(ogg_files)} OGG file(s) in '{directory}'")
    print(f"Loading model '{args.model}' (compute_type={args.compute_type})...")

    model = WhisperModel(args.model, device="cuda", compute_type=args.compute_type)

    for i, ogg_file in enumerate(ogg_files, 1):
        print(f"\n[{i}/{len(ogg_files)}] Transcribing: {ogg_file.name}")
        start = time.time()

        text = transcribe_file(model, ogg_file)

        if output_dir:
            output_path = output_dir / ogg_file.with_suffix(".txt").name
        else:
            output_path = ogg_file.with_suffix(".txt")
        output_path.write_text(text, encoding="utf-8")

        elapsed = time.time() - start
        print(f"  Done in {elapsed:.1f}s -> {output_path.name}")

    print(f"\nAll done. Transcribed {len(ogg_files)} file(s).")


if __name__ == "__main__":
    main()
