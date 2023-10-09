#!/bin/bash

# Define the base directory
BASE_DIR="$(dirname $(realpath $0))"

# Define the variables
SOURCE_DIR="modpack-1.20.1"
EPOCH_TIME=$(date +%s)
BASE_NAME="$BASE_DIR/$SOURCE_DIR-$EPOCH_TIME"
ARCHIVE_NAME="$BASE_NAME.zip"
MODS_TRUE_DIR="$BASE_DIR/modpack-1.20.1/mods"
HASH_NAME="$BASE_NAME-hashes.sha512sum"
OUTPUT_DIR="$BASE_DIR/output"

# Function to remove directory if it exists
remove_dir_if_exists() {
  if [ -d "$1" ]; then
    echo "Removing $1..."
    rm -rf "$1"
    if [ $? -ne 0 ]; then
      echo "Failed to remove $1."
      exit 1
    fi
  fi
}

# Remove the output folder from the current directory if it exists
remove_dir_if_exists "$OUTPUT_DIR"

# Remove the mods folder from the current directory if it exists
remove_dir_if_exists "$BASE_DIR/mods"

# Overwrite the mods folder with the one from ~/.minecraft/mods
cp -rf ~/.minecraft/mods "$BASE_DIR/mods"
if [ $? -ne 0 ]; then
  echo "Failed to copy mods."
  exit 1
fi

# Navigate to the mods folder
cd "$BASE_DIR/mods"

# Remove any files ending with .d
find . -type f -name '*.d' -exec rm -f {} \;

# Remove files starting with specific strings
find . -type f \( -name 'meteor*' -o -name 'wurst*' -o -name 'fabric_hider*' -o -name 'Meteor*' -o -name 'Wurst*' -o -name 'seedcracker*' -o -name 'showoperatortab*' \) -exec rm -f {} \;

# Go back to the original directory
cd "$BASE_DIR"

# Copy the mods folder to the true directory
cp -rf "$BASE_DIR/mods" "$MODS_TRUE_DIR"
if [ $? -ne 0 ]; then
  echo "Failed to copy mods. (part two)"
  exit 1
fi

# Create the ZIP archive from the source directory
zip -r0 "$ARCHIVE_NAME" "$SOURCE_DIR"
if [ $? -ne 0 ]; then
  echo "Failed to create ZIP archive."
  exit 1
fi

# Generate the SHA-512 hash for the original files
find "$SOURCE_DIR" -type f -exec sha512sum {} \; > "$HASH_NAME"

# Make output directory
mkdir -p "$OUTPUT_DIR"

# Copy files to output
mv "$ARCHIVE_NAME" "$OUTPUT_DIR/"
mv "$HASH_NAME" "$OUTPUT_DIR/"

# Remove unnecessary files
# Check if MODS_TRUE_DIR exists before removing
if [ -d "$MODS_TRUE_DIR" ]; then
  rm -rf "$MODS_TRUE_DIR"
fi

rm -rf "$BASE_DIR/mods"
