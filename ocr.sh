#!/bin/bash

# File paths
IMG_PATH="/tmp/screenshot_ocr.png"
OUT_PATH="/tmp/ocr_output"

# Take interactive screenshot and save to IMG_PATH
flameshot gui -r > "$IMG_PATH"

# Exit if no image was captured
if [ ! -s "$IMG_PATH" ]; then
    notify-send "OCR Cancelled" "No screenshot taken."
    exit 1
fi

# Run OCR and output to file
tesseract "$IMG_PATH" "$OUT_PATH" >/dev/null 2>&1

# Copy OCR result to clipboard
cat "$OUT_PATH.txt" | xclip -selection clipboard

# Optional: Notify user with preview
notify-send "OCR Copied" "$(head -n 3 $OUT_PATH.txt)..."
