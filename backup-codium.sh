#!/bin/bash

# Set this to the directory where you want to store your backups.
BACKUP_DIR=~/Documents/VSCodium_Backup

# --- Detect OS and set config path ---
OS_NAME=$(uname)
CONFIG_DIR=""

if [[ "$OS_NAME" == "Darwin" ]]; then
    # macOS
    CONFIG_DIR="$HOME/Library/Application Support/VSCodium"
    echo "Detected macOS. Using config path: $CONFIG_DIR"
elif [[ "$OS_NAME" == "Linux" ]]; then
    # Linux
    CONFIG_DIR="$HOME/.config/VSCodium"
    echo "Detected Linux. Using config path: $CONFIG_DIR"
else
    echo "Error: Unsupported OS ($OS_NAME). Exiting."
    exit 1
fi

# Check if the config directory actually exists
if [ ! -d "$CONFIG_DIR" ]; then
    echo "Error: VSCodium config directory not found at $CONFIG_DIR"
    echo "Please check if VSCodium is installed correctly."
    exit 1
fi

echo "Starting VSCodium backup..."

# --- Create Backup Directories ---
mkdir -p "$BACKUP_DIR/User"
mkdir -p "$BACKUP_DIR/snippets"

echo "Backup directory set at $BACKUP_DIR"

# --- Backup Core Files ---
# We'll check if each file/dir exists before copying

if [ -f "$CONFIG_DIR/User/settings.json" ]; then
    cp "$CONFIG_DIR/User/settings.json" "$BACKUP_DIR/User/"
    echo "Backed up settings.json"
else
    echo "Warning: settings.json not found. Skipping."
fi

if [ -f "$CONFIG_DIR/User/keybindings.json" ]; then
    cp "$CONFIG_DIR/User/keybindings.json" "$BACKUP_DIR/User/"
    echo "Backed up keybindings.json"
else
    echo "Info: keybindings.json not found. (This is normal if you haven't set custom keybindings)."
fi

# Backup the snippets directory
if [ -d "$CONFIG_DIR/User/snippets" ]; then
    # Copy the contents of the snippets folder
    cp -r "$CONFIG_DIR/User/snippets/." "$BACKUP_DIR/snippets/"
    echo "Backed up snippets directory."
else
    echo "Info: Snippets directory not found. Skipping."
fi

# --- Backup Extension List ---
echo "Saving extension list..."
codium --list-extensions > "$BACKUP_DIR/extensions.txt"

echo "Backup complete! ✨"