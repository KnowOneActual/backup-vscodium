#!/bin/bash

# A simple script to back up VSCodium configuration files and extensions.

# --- Configuration ---
# Set this to the directory where you want to store your backups.
BACKUP_DIR=~/Documents/VSCodium_Backup

# VSCodium configuration directory
CONFIG_DIR=~/.config/VSCodium

echo "Starting VSCodium backup..."

# --- Create Backup Directory ---
mkdir -p "$BACKUP_DIR/User"
mkdir -p "$BACKUP_DIR/snippets"

echo "Backup directory created at $BACKUP_DIR"

# --- Backup Core Files ---
cp "$CONFIG_DIR/User/settings.json" "$BACKUP_DIR/User/"
cp "$CONFIG_DIR/User/keybindings.json" "$BACKUP_DIR/User/"
cp -r "$CONFIG_DIR/User/snippets/." "$BACKUP_DIR/snippets/"

echo "Settings, keybindings, and snippets backed up."

# --- Backup Extension List ---
codium --list-extensions > "$BACKUP_DIR/extensions.txt"

echo "Extension list saved to extensions.txt."
echo "Backup complete! ✨"