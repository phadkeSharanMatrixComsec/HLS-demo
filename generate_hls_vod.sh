#!/bin/bash

# Check if input file is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <input_mp4_file>"
    exit 1
fi

INPUT_FILE=$1
BASE_DIR="/home/sharanphadke/Documents/Docs/HLS"
OUTPUT_DIR="$BASE_DIR/examples/VOD"
SEGMENTS_DIR="$OUTPUT_DIR"

# Create directories if they don't exist
mkdir -p "$SEGMENTS_DIR"

# Generate HLS segments and playlist
ffmpeg -i "$INPUT_FILE" \
    -profile:v baseline \
    -start_number 0 \
    -hls_time 10 \
    -hls_list_size 0 \
    -f hls \
    -hls_segment_filename "$SEGMENTS_DIR/segment%d.ts" \
    "$OUTPUT_DIR/playlist.m3u8"

echo "HLS conversion complete. Files are in $OUTPUT_DIR"
