#!/bin/bash
BASE_DIR="$(dirname $(realpath $0))";SOURCE_DIR="modpack-1.20.1";EPOCH_TIME=$(date +%s);BASE_NAME="$BASE_DIR/$SOURCE_DIR-$EPOCH_TIME";ARCHIVE_NAME="$BASE_NAME.zip";MODS_TRUE_DIR="$BASE_DIR/modpack-1.20.1/mods";HASH_NAME="$BASE_NAME-hashes.sha512sum";OUTPUT_DIR="$BASE_DIR/output";remove_dir_if_exists(){ if [ -d "$1" ];then echo "Removing $1...";rm -rf "$1";if [ $? -ne 0 ];then echo "Failed to remove $1.";exit 1;fi;fi;};remove_dir_if_exists "$OUTPUT_DIR";remove_dir_if_exists "$BASE_DIR/mods";cp -rf ~/.minecraft/mods "$BASE_DIR/mods";if [ $? -ne 0 ];then echo "Failed to copy mods.";exit 1;fi;cd "$BASE_DIR/mods";find . -type f -name '*.d' -exec rm -f {} \;;find . -type f \( -name 'meteor*' -o -name 'wurst*' -o -name 'fabric_hider*' -o -name 'Meteor*' -o -name 'Wurst*' -o -name 'seedcracker*' -o -name 'showoperatortab*' \) -exec rm -f {} \;;cd "$BASE_DIR";cp -rf "$BASE_DIR/mods" "$MODS_TRUE_DIR";if [ $? -ne 0 ];then echo "Failed to copy mods. (part two)";exit 1;fi;zip -r0 "$ARCHIVE_NAME" "$SOURCE_DIR";if [ $? -ne 0 ];then echo "Failed to create ZIP archive.";exit 1;fi;find "$SOURCE_DIR" -type f -exec sha512sum {} \;>"$HASH_NAME";mkdir -p "$OUTPUT_DIR";mv "$ARCHIVE_NAME" "$OUTPUT_DIR/";mv "$HASH_NAME" "$OUTPUT_DIR/";if [ -d "$MODS_TRUE_DIR" ];then rm -rf "$MODS_TRUE_DIR";fi;rm -rf "$BASE_DIR/mods"
