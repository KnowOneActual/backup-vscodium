#!/bin/bash

# A script to restore VSCodium configuration from a backup.

# --- Configuration ---
# The directory where your backup is stored.
BACKUP_DIR=~/Documents/VSCodium_Backup

# VSCodium configuration directory
CONFIG_DIR=~/.config/VSCodium

echo "Starting VSCodium restore..."

# --- Restore Core Files ---
# Make sure the target User directory exists
mkdir -p "$CONFIG_DIR/User"

cp "$BACKUP_DIR/User/settings.json" "$CONFIG_DIR/User/"
cp "$BACKUP_DIR/User/keybindings.json" "$CONFIG_DIR/User/"
cp -r "$BACKUP_DIR/snippets/." "$CONFIG_DIR/User/snippets/"

echo "Settings, keybindings, and snippets restored."

# --- Reinstall Extensions ---
EXTENSIONS_FILE="$BACKUP_DIR/extensions.txt"

if [ -f "$EXTENSIONS_FILE" ]; then
    echo "Installing extensions from list..."
    while read -r extension; do
        codium --install-extension "$extension"
    done < "$EXTENSIONS_FILE"
    echo "All extensions have been installed."
else
    echo "Warning: extensions.txt not found. Skipping extension install."
fi

echo "Restore complete! Please restart VSCodium."