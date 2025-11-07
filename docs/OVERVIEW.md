# Project Overview

## What is this project?

This project provides a simple, local-first method for backing up and restoring VSCodium configurations.

It consists of two cross-platform shell scripts:
* `backup-codium.sh`: Backs up settings, keybindings, snippets, and extensions.
* `restore-codium.sh`: Restores that configuration to a new or existing VSCodium installation.

It is designed to work on both **macOS** and **Linux**.

## Why does this project exist?

VSCodium, the open-source build of VS Code, does not include the built-in "Settings Sync" feature. That feature is proprietary and requires a Microsoft account, which goes against the philosophy of a fully open-source tool.

This project fills that gap. It provides a free, simple, and transparent alternative for users who want to back up their setup and move it between machines without relying on a cloud service or third-party extension.

## How it Works: The Methodology

The logic is based on directly targeting the configuration files and using VSCodium's own command-line tools.

### 1. Identifying Core Files

The most important parts of a VSCodium setup are the user-generated text files. This project targets:
* `User/settings.json`: All your custom editor settings.
* `User/keybindings.json`: All your custom keyboard shortcuts.
* `User/snippets/`: The directory containing all your custom code snippets.
* **Extension List**: A plain text list of all installed extensions.

### 2. Cross-Platform Path Detection

The main challenge is that macOS and Linux store these files in different places.
* **macOS Path**: `$HOME/Library/Application Support/VSCodium`
* **Linux Path**: `$HOME/.config/VSCodium`

Both scripts solve this by using the `uname` command to get the OS name.
* If `uname` returns "Darwin" (the kernel name for macOS), it sets the macOS path.
* If `uname` returns "Linux", it sets the Linux path.
* This allows the *same script* to be used on both systems without changes.

### 3. The Backup Process (`backup-codium.sh`)

1.  **Detects OS** to set the correct configuration path.
2.  **Creates a backup directory** (default: `~/Documents/VSCodium_Backup`).
3.  **Copies Files**: It copies `settings.json`, `keybindings.json`, and the entire `snippets` folder into the backup directory.
4.  **Saves Extensions**: It runs the command `codium --list-extensions` and pipes the output into `extensions.txt` in the backup directory. This creates a simple list of all installed extension IDs.

### 4. The Restore Process (`restore-codium.sh`)

1.  **Detects OS** to find the correct destination path.
2.  **Copies Files**: It copies the configuration files *from* the backup directory *to* the proper VSCodium configuration folder, overwriting any existing files.
3.  **Reinstalls Extensions**: It reads `extensions.txt` line by line. For each line (each extension ID), it runs the command `codium --install-extension "extension-id"`.

This methodology ensures the backup is complete, local, and easily auditable, as all backups are just simple files.