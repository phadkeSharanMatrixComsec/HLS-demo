#!/bin/bash

# Check if input file is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <input_mp4_file>"
    exit 1
fi

INPUT_FILE=$1
BASE_DIR="/home/sharanphadke/Documents/Docs/HLS/examples/VOD_ABR"
VARIANTS=("720p" "480p" "360p")
BITRATES=("2800k" "1400k" "800k")
RESOLUTIONS=("1280x720" "854x480" "640x360")

# Create output directory
mkdir -p "$BASE_DIR"

# Create variant playlists for each quality level
for i in "${!VARIANTS[@]}"; do
    mkdir -p "$BASE_DIR/${VARIANTS[$i]}"
    
    ffmpeg -i "$INPUT_FILE" \
        -profile:v main \
        -vf "scale=${RESOLUTIONS[$i]}" \
        -c:v h264 \
        -b:v ${BITRATES[$i]} \
        -c:a aac \
        -b:a 128k \
        -hls_time 10 \
        -hls_list_size 0 \
        -f hls \
        -hls_segment_filename "$BASE_DIR/${VARIANTS[$i]}/segment%d.ts" \
        "$BASE_DIR/${VARIANTS[$i]}/playlist.m3u8"
done

# Create master playlist
cat > "$BASE_DIR/master.m3u8" << EOF
#EXTM3U
#EXT-X-VERSION:3
EOF

for i in "${!VARIANTS[@]}"; do
    echo "#EXT-X-STREAM-INF:BANDWIDTH=$((${BITRATES[$i]%k}*1000)),RESOLUTION=${RESOLUTIONS[$i]}" >> "$BASE_DIR/master.m3u8"
    echo "${VARIANTS[$i]}/playlist.m3u8" >> "$BASE_DIR/master.m3u8"
done

echo "ABR HLS conversion complete. Files are in $BASE_DIR"
