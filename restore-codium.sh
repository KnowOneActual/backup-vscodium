#!/bin/bash

# The directory where your backup is stored.
BACKUP_DIR=~/Documents/VSCodium_Backup

# --- Detect OS and set config path ---
OS_NAME=$(uname)
CONFIG_DIR=""

if [[ "$OS_NAME" == "Darwin" ]]; then
    # macOS
    CONFIG_DIR="$HOME/Library/Application Support/VSCodium"
    echo "Detected macOS. Restoring to: $CONFIG_DIR"
elif [[ "$OS_NAME" == "Linux" ]]; then
    # Linux
    CONFIG_DIR="$HOME/.config/VSCodium"
    echo "Detected Linux. Restoring to: $CONFIG_DIR"
else
    echo "Error: Unsupported OS ($OS_NAME). Exiting."
    exit 1
fi

echo "Starting VSCodium restore..."

# --- Create Target Directories ---
# Make sure the target User/snippets directories exist before copying
mkdir -p "$CONFIG_DIR/User"
mkdir -p "$CONFIG_DIR/User/snippets"

echo "Created config directories at $CONFIG_DIR"

# --- Restore Core Files ---
# We'll check if each file/dir exists in the backup before restoring

if [ -f "$BACKUP_DIR/User/settings.json" ]; then
    cp "$BACKUP_DIR/User/settings.json" "$CONFIG_DIR/User/"
    echo "Restored settings.json"
else
    echo "Info: settings.json not found in backup. Skipping."
fi

if [ -f "$BACKUP_DIR/User/keybindings.json" ]; then
    cp "$BACKUP_DIR/User/keybindings.json" "$CONFIG_DIR/User/"
    echo "Restored keybindings.json"
else
    echo "Info: keybindings.json not found in backup. Skipping."
fi

# Restore the snippets directory
if [ -d "$BACKUP_DIR/snippets" ]; then
    # Copy the contents of the snippets folder
    cp -r "$BACKUP_DIR/snippets/." "$CONFIG_DIR/User/snippets/"
    echo "Restored snippets directory."
else
    echo "Info: Backup/snippets directory not found. Skipping."
fi

# --- Reinstall Extensions ---
EXTENSIONS_FILE="$BACKUP_DIR/extensions.txt"

if [ -f "$EXTENSIONS_FILE" ]; then
    echo "Installing extensions from list..."
    # Read each line from extensions.txt and install
    while read -r extension; do
        # Avoid installing empty lines
        if [ -n "$extension" ]; then
            codium --install-extension "$extension"
        fi
    done < "$EXTENSIONS_FILE"
    echo "All extensions have been installed."
else
    echo "Warning: extensions.txt not found. Skipping extension install."
fi

echo "Restore complete! Please restart VSCodium."