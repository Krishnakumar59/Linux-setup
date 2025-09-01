#!/bin/bash

# Output paths
IMG_PATH="/tmp/ocr_temp.png"
OUT_PATH="/tmp/ocr_text"

# Use ImageMagick's `import` to select region and capture screenshot
import "$IMG_PATH"

# Run OCR
tesseract "$IMG_PATH" "$OUT_PATH" >/dev/null 2>&1

# Copy text to clipboard
cat "$OUT_PATH.txt" | xclip -selection clipboard

# Show a short preview
notify-send "OCR Copied to Clipboard" "$(head -n 3 $OUT_PATH.txt)..."
