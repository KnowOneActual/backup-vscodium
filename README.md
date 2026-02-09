# 🦧 backup-vscodium

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Build Status](https://github.com/KnowOneActual/backup-vscodium/actions/workflows/test.yml/badge.svg)](https://github.com/KnowOneActual/backup-vscodium/actions/workflows/test.yml)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-gray.svg)]()
[![Bash](https://img.shields.io/badge/language-Bash-4EAA25.svg)]()
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)]()

A robust, feature-rich backup and restore solution for VSCodium configuration, settings, keybindings, snippets, and extensions.

**Current Version:** 2.1.0

---

## ✨ Features

✅ **Complete Configuration Backup**
- Settings (`settings.json`)
- Keybindings (`keybindings.json`)
- Code snippets
- Installed extensions

✅ **Portable Backups (New!)**
- **Single File Archives:** Create `.tar.gz` compressed backups for easy transfer.
- **Smart Restore:** Automatically detects and extracts archives during restore.
- **Cross-Machine Ready:** Perfect for syncing settings between computers.

✅ **Smart Options**
- Custom backup locations
- Selective backup/restore (choose what to sync)
- Timestamps for version control
- Checksum verification for integrity

✅ **Safety First**
- Dry-run mode to preview changes
- Confirmation prompts prevents accidental overwrites
- Comprehensive logging

✅ **Professional Grade**
- Bash 4.0+ compatible
- ShellCheck clean
- Comprehensive test coverage

---

## 🚀 Quick Start

### Installation

```bash
# Clone the repository
git clone [https://github.com/KnowOneActual/backup-vscodium.git](https://github.com/KnowOneActual/backup-vscodium.git)
cd backup-vscodium

# Make scripts executable
chmod +x backup-codium.sh restore-codium.sh

# (Optional) Add to your PATH
cp backup-codium.sh ~/.local/bin/
cp restore-codium.sh ~/.local/bin/

```

### 📦 The "Portable" Workflow (Recommended)

The easiest way to move your settings to a new machine:

```bash
# 1. Create a compressed backup file
./backup-codium.sh --compress --timestamp

# 2. Transfer the resulting .tar.gz file to your new machine...

# 3. Restore directly from the archive
./restore-codium.sh --backup path/to/backup_20260208.tar.gz

```

### Basic Usage

```bash
# Standard backup (creates a folder in ~/Documents/VSCodium_Backup)
./backup-codium.sh

# Standard restore (reads from default location)
./restore-codium.sh

```

---

## 📚 Examples

### Backup Examples

#### Create a Compressed Archive

```bash
# Great for email, cloud storage, or USB drives
./backup-codium.sh --compress

```

#### Backup to Custom Location

```bash
# Backup to Dropbox
./backup-codium.sh --location ~/Dropbox/VSCodium_Backup

```

#### Selective Backups

```bash
# Backup ONLY settings and keybindings (skip extensions)
./backup-codium.sh --only-settings --only-keybindings

# Backup ONLY the extensions list (fastest)
./backup-codium.sh --only-extensions

```

### Restore Examples

#### Restore from Archive

```bash
# The script automatically handles .tar.gz or .zip files
./restore-codium.sh --backup ~/Downloads/my-backup.tar.gz

```

#### Automated/Silent Restore

```bash
# Restore without asking for confirmation (useful for setup scripts)
./restore-codium.sh --force

```

#### Dry Run (Safety Check)

```bash
# See exactly what would happen without changing anything
./restore-codium.sh --dry-run --verbose

```

---

## 🔧 Command Reference

### `backup-codium.sh`

```text
Usage: backup-codium.sh [OPTIONS]

General Options:
  -h, --help              Show help message
  -v, --version           Show script version
  -c, --compress          Create a compressed .tar.gz archive
  -t, --timestamp         Add timestamp to backup name
  -l, --location PATH     Custom backup location (default: ~/Documents/VSCodium_Backup)
  --verbose               Enable verbose output
  --dry-run               Preview without copying

Selective Backup:
  --only-settings         Backup only settings.json
  --only-keybindings      Backup only keybindings.json
  --only-snippets         Backup only snippets directory
  --only-extensions       Backup only extensions list
  --no-checksums          Don't create SHA256 checksums
  --no-manifest           Don't create manifest file

```

### `restore-codium.sh`

```text
Usage: restore-codium.sh [OPTIONS]

General Options:
  -h, --help              Show help message
  -v, --version           Show script version
  -b, --backup PATH       Path to backup folder OR .tar.gz/.zip archive
  -f, --force             Skip confirmation prompts
  --skip-verify           Don't verify checksums
  --verbose               Enable verbose output
  --dry-run               Preview without restoring

Selective Restore:
  --only-settings         Restore only settings.json
  --only-keybindings      Restore only keybindings.json
  --only-extensions       Restore only extensions list

```

---

## 📋 What Gets Backed Up

1. **Settings:** `settings.json` (Themes, fonts, preferences)
2. **Keybindings:** `keybindings.json` (Custom shortcuts)
3. **Snippets:** All files in your snippets directory
4. **Extensions:** A verified list of installed extensions (restored via `codium --install-extension`)
5. **Metadata:** Checksums and manifests to ensure data integrity.

---

## 🧪 Testing & Quality

This project maintains high standards for reliability:

* **Unit Tests:** Run `bash tests/test-all.sh` to verify script logic.
* **Integration Tests:** Run `bash tests/integration-tests.sh` to simulate real backups/restores.
* **Linting:** All scripts are **ShellCheck** clean.

For more details on running tests, see [TESTING.md](TESTING.md).

---

## 🐛 Troubleshooting

| Issue | Solution |
| --- | --- |
| **VSCodium config not found** | Ensure VSCodium is installed and you have run it at least once. |
| **Checksum failed** | The backup file might be corrupted. Try restoring with `--skip-verify` if you are desperate. |
| **Permission denied** | Check that you have write access to the destination folder. |

---

## 🤝 Contributing

Contributions are welcome! Please ensure any changes pass the test suite and do not introduce ShellCheck warnings.

---

## 📝 License

[MIT License](https://www.google.com/search?q=LICENSE) © 2026 Beau Bremer

```

```