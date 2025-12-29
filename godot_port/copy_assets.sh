#!/bin/bash
# Script to copy audio assets from Python res/ directory to Godot project

echo "Copying audio assets to Godot project..."

# Source directory (Python project)
SRC_DIR="../res"

# Destination directory (Godot project)
DEST_DIR="./assets/sounds"

# Create destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# List of required sound files
sounds=(
    "fire.wav"
    "thrust.wav"
    "explode1.wav"
    "explode2.wav"
    "explode3.wav"
    "lsaucer.wav"
    "ssaucer.wav"
    "sfire.wav"
    "extralife.wav"
)

# Copy each sound file
for sound in "${sounds[@]}"; do
    if [ -f "$SRC_DIR/$sound" ]; then
        cp "$SRC_DIR/$sound" "$DEST_DIR/"
        echo "✓ Copied $sound"
    else
        echo "✗ Warning: $sound not found in $SRC_DIR"
    fi
done

# Copy font if it exists
if [ -f "$SRC_DIR/Hyperspace.otf" ]; then
    mkdir -p "./assets/fonts"
    cp "$SRC_DIR/Hyperspace.otf" "./assets/fonts/"
    echo "✓ Copied Hyperspace.otf font"
fi

echo ""
echo "Audio asset copy complete!"
echo "Next: Open project in Godot and the sounds will be automatically imported."
