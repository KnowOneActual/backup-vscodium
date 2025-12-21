<p align="center">
<img src="assets/img/backup-vscodium_logo.webp" alt="alt text" width="150">
</p>

# backup-vscodium

[![Project Status: Active](https://img.shields.io/badge/Project%20Status-Active-brightgreen)](https://github.com/knowoneactual/backup-vscodium)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ask Me Anything !](https://img.shields.io/badge/Ask%20me-anything-1abc9c.svg)](https://GitHub.com/knowoneactual/backup-vscodium/issues)
[![Latest Version](https://img.shields.io/badge/Version-2.0.0-blue.svg)](https://github.com/knowoneactual/backup-vscodium/releases)

A robust, feature-rich set of shell scripts to back up and restore VSCodium settings on **macOS** and **Linux**.

VSCodium is an open-source build of VS Code. Its one missing piece is the built-in Settings Sync, which requires a Microsoft account. This project provides a simple, local-first alternative with advanced features like checksums, dry-run mode, and selective backups.

---

## ✨ What's New in v2.0

- 🔐 **Checksum Verification** - SHA256 checksums ensure backup integrity
- 📋 **Manifest Files** - Detailed records of what's backed up
- 🏃 **Dry-Run Mode** - Preview backups/restores without modifying files
- 🎯 **Selective Operations** - Back up/restore only what you need
- 📝 **Comprehensive Logging** - Full audit trail of all operations
- 🛡️ **Safety Prompts** - Confirmation before overwriting configurations
- 📊 **Summary Reports** - Clear before/after status information
- ⏰ **Timestamped Backups** - Version your backups automatically
- 🎯 **Argument Parsing** - Full CLI with `--help` and detailed options
- ✅ **Improved Error Handling** - Better detection and reporting of issues

---

## 💾 What it Backs Up

This tool finds your VSCodium configuration and copies:
* `settings.json` (Your settings)
* `keybindings.json` (Your custom shortcuts)
* `snippets/` (All your user snippets)
* A list of your installed extensions (saved to `extensions.txt`)

Optionally creates:
* `backup.sha256` (Checksums for all files)
* `manifest.txt` (Detailed backup inventory)
* `backup.log` / `restore.log` (Complete operation logs)

## ⚙️ Requirements

1. VSCodium must be installed
2. The `codium` command must be available in your system's `PATH`
   - This is used to list and install extensions
   - If not available, extension backup/restore will be skipped automatically
3. Bash 4.0+ (most modern systems)
4. Standard Unix utilities: `cp`, `mkdir`, `sha256sum` (for checksums)

## 🚀 Quick Start

### Installation

```sh
git clone https://github.com/knowoneactual/backup-vscodium.git
cd backup-vscodium
chmod +x backup-codium.sh restore-codium.sh
```

### Basic Usage

```sh
# Backup everything
./backup-codium.sh

# Restore everything (with confirmation)
./restore-codium.sh
```

### Get Help

```sh
./backup-codium.sh --help
./restore-codium.sh --help
```

---

## 📖 Advanced Usage

### Backup Options

#### Custom Backup Location
```sh
# Save to Dropbox or cloud storage
./backup-codium.sh --location ~/Dropbox/VSCodium_Backup

# Add timestamp to backup folder
./backup-codium.sh --timestamp
# Creates: VSCodium_Backup_20250321_143025/
```

#### Selective Backup
```sh
# Backup only settings
./backup-codium.sh --only-settings

# Backup everything except extensions
./backup-codium.sh --no-extensions

# Backup only snippets
./backup-codium.sh --only-snippets
```

#### Dry-Run & Preview
```sh
# See what would be backed up without doing anything
./backup-codium.sh --dry-run

# Verbose output with logging
./backup-codium.sh --verbose
```

#### Advanced
```sh
# Create backup without checksums (slightly faster)
./backup-codium.sh --no-checksums

# Backup without manifest file
./backup-codium.sh --no-manifest

# Combine multiple options
./backup-codium.sh --location ~/my-backup --timestamp --verbose --no-extensions
```

### Restore Options

#### Basic Restore
```sh
# Restore from default location (interactive)
./restore-codium.sh

# Restore from custom location
./restore-codium.sh --backup ~/Dropbox/VSCodium_Backup

# Force restore without confirmation
./restore-codium.sh --force
```

#### Selective Restore
```sh
# Restore only settings
./restore-codium.sh --only-settings

# Restore without extensions
./restore-codium.sh --no-extensions

# Restore only keybindings
./restore-codium.sh --only-keybindings
```

#### Verification & Preview
```sh
# Dry-run to see what would be restored
./restore-codium.sh --dry-run

# Skip checksum verification (fast restore)
./restore-codium.sh --skip-verify

# Verbose logging
./restore-codium.sh --verbose
```

#### Combined Examples
```sh
# Restore from backup with detailed output
./restore-codium.sh --backup ~/backups/vscodium --verbose

# Restore only specific components
./restore-codium.sh --only-settings --only-extensions --force

# Preview restore with full details
./restore-codium.sh --dry-run --verbose
```

---

## 🔍 How It Works

The scripts automatically detect your operating system and use the correct configuration paths:

* **macOS:** `~/Library/Application Support/VSCodium`
* **Linux:** `~/.config/VSCodium`

This means the same scripts work across platforms without any configuration.

### Backup Process
1. Detect OS and find VSCodium config directory
2. Create backup folder structure
3. Copy all settings files and directories
4. Export list of installed extensions
5. Generate SHA256 checksums (optional)
6. Create manifest with backup metadata
7. Log all operations to backup.log
8. Print summary with statistics

### Restore Process
1. Detect OS and find VSCodium config directory
2. Verify backup integrity with checksums (optional)
3. Prompt for confirmation before overwriting
4. Copy all settings files and directories
5. Reinstall extensions from backup list
6. Log all operations to restore.log
7. Print summary and prompt to restart VSCodium

---

## 📊 Backup Output Example

```
Starting VSCodium backup...
Detected macOS. Config path: /Users/user/Library/Application Support/VSCodium
✓ Backed up: settings.json
✓ Backed up: keybindings.json
✓ Backed up directory: snippets
✓ Backed up extension list (24 extensions)
✓ Created checksums file: backup.sha256
✓ Created manifest file: manifest.txt

========================================
         BACKUP SUMMARY
========================================
Backup Location: /Users/user/Documents/VSCodium_Backup
Backup Size: 2.5 MB

Components:
  ✓ Settings
  ✓ Keybindings
  ✓ Snippets
  ✓ Extensions

✓ Checksums created
✓ Manifest created
✓ Log file: /Users/user/Documents/VSCodium_Backup/backup.log
========================================
```

---

## 🛡️ Safety & Verification

### Checksum Verification

Backups include SHA256 checksums. Verify integrity anytime:

```sh
cd ~/Documents/VSCodium_Backup
sha256sum -c backup.sha256
```

### Restore automatically verifies checksums before proceeding.

### Manifest File

Each backup includes a `manifest.txt` listing:
- When the backup was created
- What system it was backed up from
- Which components are included
- Complete file listing

### Log Files

All operations are logged:
- `backup.log` - Created during backup
- `restore.log` - Created during restore

View logs anytime:
```sh
cat ~/Documents/VSCodium_Backup/backup.log
cat ~/Documents/VSCodium_Backup/restore.log
```

---

## 🧪 Dry-Run Mode

Always test before critical operations:

```sh
# Preview backup
./backup-codium.sh --dry-run --verbose

# Preview restore
./restore-codium.sh --dry-run --verbose
```

Dry-run shows:
- ✓ What files would be backed up/restored
- ✓ File counts and sizes
- ✓ No actual file modifications

---

## 🐛 Troubleshooting

### "codium command not found"

Make sure VSCodium is installed and `codium` is in your PATH.

**macOS:**
```sh
# Install via Homebrew
brew install vscodium

# Or add to PATH if installed elsewhere
export PATH="/Applications/VSCodium.app/Contents/Resources/app/bin:$PATH"
```

**Linux:**
```sh
# Install via package manager (Ubuntu/Debian)
sudo apt install codium

# Or from AUR (Arch)
yay -S vscodium-bin
```

### Backup fails with permission errors

```sh
# Check permissions on VSCodium config
ls -la ~/Library/Application\ Support/VSCodium  # macOS
ls -la ~/.config/VSCodium  # Linux

# Make sure backup location is writable
touch ~/Documents/test_file.txt && rm ~/Documents/test_file.txt
```

### "Backup directory not found" on restore

Make sure you're using the correct path:

```sh
# Check if backup exists
ls -la ~/Documents/VSCodium_Backup

# Use --verbose to see what path is being used
./restore-codium.sh --verbose

# Explicitly specify the backup location
./restore-codium.sh --backup /path/to/backup
```

### Checksum verification fails

This may indicate the backup was corrupted or files were modified.

```sh
# Skip verification if you trust the backup
./restore-codium.sh --skip-verify

# Or create a new backup
./backup-codium.sh --location ~/backup-new
```

### Extensions won't reinstall

Some extension servers may be temporarily unavailable.

```sh
# Try again later, or skip extensions
./restore-codium.sh --no-extensions

# Then manually reinstall from VSCodium extensions panel
```

---

## 🤝 Contributing

Contributions are welcome! If you have a suggestion or find a bug:

1. [Open an issue](https://github.com/knowoneactual/backup-vscodium/issues) to discuss
2. Fork the repository
3. Create a feature branch: `git checkout -b feature/my-feature`
4. Make your changes
5. Test thoroughly
6. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

## 🙋 Questions?

Have questions or need help?

- [Check the issues](https://github.com/knowoneactual/backup-vscodium/issues)
- [Read the docs](docs/)
- [Open a discussion](https://github.com/knowoneactual/backup-vscodium/discussions)

---

**Made with ❤️ for the VSCodium community**
