# 🦧 backup-vscodium

A robust, feature-rich backup and restore solution for VSCodium configuration, settings, keybindings, snippets, and extensions.

**Status:** ✅ All tests passing | 🟢 Production ready

---

## ✨ Features

✅ **Complete Configuration Backup**
- Settings (settings.json)
- Keybindings (keybindings.json)
- Code snippets
- Installed extensions

✅ **Smart Backup Options**
- Custom backup locations
- Selective backup/restore (choose what to backup)
- Timestamps for versioned backups
- Checksum verification for integrity
- Manifest files for metadata

✅ **Safety Features**
- Dry-run mode to preview changes
- Checksum verification before restore
- Confirmation prompts
- Comprehensive logging
- Content preservation

✅ **Cross-Platform Support**
- macOS (Application Support directories)
- Linux (.config directories)
- Easy to extend to Windows/other platforms

✅ **Professional Grade**
- Bash 4.0+ compatible
- ShellCheck clean (zero warnings)
- Comprehensive test coverage
- Production-ready error handling

---

## 🚀 Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/KnowOneActual/backup-vscodium.git
cd backup-vscodium

# Make scripts executable
chmod +x backup-codium.sh restore-codium.sh

# (Optional) Add to your PATH
cp backup-codium.sh ~/.local/bin/
cp restore-codium.sh ~/.local/bin/
```

### Basic Backup

```bash
# Backup everything to default location (~/Documents/VSCodium_Backup)
./backup-codium.sh

# See what would be backed up (dry-run)
./backup-codium.sh --dry-run

# Backup with verbose output
./backup-codium.sh --verbose
```

### Basic Restore

```bash
# Restore everything from default location
./restore-codium.sh

# Preview restore without making changes
./restore-codium.sh --dry-run

# Restore without confirmation prompts
./restore-codium.sh --force
```

---

## 📚 Examples

### Backup Examples

#### Backup to Custom Location
```bash
# Backup to Dropbox for cloud sync
./backup-codium.sh --location ~/Dropbox/VSCodium_Backup

# Backup to external drive
./backup-codium.sh --location /Volumes/ExternalDrive/Backups
```

#### Create Versioned Backups
```bash
# Add timestamp to backup folder
./backup-codium.sh --timestamp
# Creates: ~/Documents/VSCodium_Backup_20251221_152345

# Combine with custom location
./backup-codium.sh --location ~/Dropbox/VSCodium --timestamp
```

#### Selective Backups
```bash
# Backup only settings
./backup-codium.sh --only-settings

# Backup only keybindings and snippets
./backup-codium.sh --no-settings --no-extensions

# Backup only extensions list (useful for quick reinstall)
./backup-codium.sh --only-extensions
```

#### Advanced Backup Options
```bash
# Backup without checksums (faster, less storage)
./backup-codium.sh --no-checksums

# Backup without manifest file
./backup-codium.sh --no-manifest

# Exclude everything except settings
./backup-codium.sh --only-settings --verbose
```

#### Full Example: Automated Daily Backup
```bash
# Add to crontab for daily backups at 2 AM
0 2 * * * /path/to/backup-codium.sh --location ~/Backups/VSCodium --timestamp --verbose >> /tmp/vscodium_backup.log 2>&1
```

### Restore Examples

#### Basic Restore
```bash
# Restore from default location (interactive - asks for confirmation)
./restore-codium.sh

# Restore from custom location
./restore-codium.sh --backup ~/Dropbox/VSCodium_Backup

# Restore and skip confirmation
./restore-codium.sh --force
```

#### Selective Restore
```bash
# Restore only settings
./restore-codium.sh --only-settings

# Restore only keybindings and snippets (skip extensions)
./restore-codium.sh --no-extensions

# Restore only extensions (for quick setup on new machine)
./restore-codium.sh --only-extensions
```

#### Advanced Restore Options
```bash
# Restore without checksum verification (faster, less safe)
./restore-codium.sh --skip-verify

# Restore with verbose logging
./restore-codium.sh --verbose

# Preview what would be restored
./restore-codium.sh --dry-run --verbose
```

#### Real-World Scenarios

**Scenario 1: New Machine Setup**
```bash
# Preview what you're restoring
./restore-codium.sh --backup ~/Dropbox/VSCodium_Backup --dry-run

# Verify everything looks good, then restore
./restore-codium.sh --backup ~/Dropbox/VSCodium_Backup --force

# Restart VSCodium to apply settings
```

**Scenario 2: Restore Only Settings (Keep Local Extensions)**
```bash
# You've installed local extensions you want to keep
# Restore only settings and keybindings
./restore-codium.sh --no-extensions --force
```

**Scenario 3: Test Restore Before Committing**
```bash
# Always use dry-run first
./restore-codium.sh --dry-run --verbose

# Review the output, then commit
./restore-codium.sh --force
```

---

## 🔧 Command Reference

### backup-codium.sh

```bash
Usage: backup-codium.sh [OPTIONS]

General Options:
  -h, --help              Show help message
  -v, --version           Show script version
  --verbose               Enable verbose output
  --dry-run               Preview without copying
  -l, --location PATH     Custom backup location (default: ~/Documents/VSCodium_Backup)
  -t, --timestamp         Add timestamp to backup folder name

Selective Backup:
  --only-settings         Backup only settings.json
  --only-keybindings      Backup only keybindings.json
  --only-snippets         Backup only snippets directory
  --only-extensions       Backup only extensions list
  --no-settings           Exclude settings.json
  --no-keybindings        Exclude keybindings.json
  --no-snippets           Exclude snippets directory
  --no-extensions         Exclude extensions list
  --no-checksums          Don't create SHA256 checksums
  --no-manifest           Don't create manifest file
```

### restore-codium.sh

```bash
Usage: restore-codium.sh [OPTIONS]

General Options:
  -h, --help              Show help message
  -v, --version           Show script version
  --verbose               Enable verbose output
  --dry-run               Preview without restoring
  -b, --backup PATH       Path to backup folder (default: ~/Documents/VSCodium_Backup)
  -f, --force             Skip confirmation prompts
  --skip-verify           Don't verify checksums

Selective Restore:
  --only-settings         Restore only settings.json
  --only-keybindings      Restore only keybindings.json
  --only-snippets         Restore only snippets directory
  --only-extensions       Restore only extensions list
  --no-settings           Exclude settings.json
  --no-keybindings        Exclude keybindings.json
  --no-snippets           Exclude snippets directory
  --no-extensions         Exclude extensions list
```

---

## 📋 What Gets Backed Up

### Settings (settings.json)
Your editor preferences:
- Font family and size
- Editor behavior (tabs, spaces, formatting)
- Theme and color scheme
- Window settings
- Workspace settings

### Keybindings (keybindings.json)
Your custom keyboard shortcuts for:
- Commands and actions
- Extensions
- Built-in functionality

### Snippets Directory
All code snippets across:
- All programming languages
- Custom snippet groups
- Snippet metadata

### Extensions List (extensions.txt)
List of installed extensions with version information for easy reinstallation.

### Metadata
- **manifest.txt** - Backup contents and metadata
- **backup.sha256** - Checksums for integrity verification
- **backup.log** - Operation log with timestamps

---

## 🧪 Testing

### Unit Tests
```bash
# Run basic functionality tests
bash tests/test-all.sh
```

Tests:
- ✅ Script existence and executability
- ✅ Bash syntax validation
- ✅ Help and version flags
- ✅ Error handling

### Integration Tests
```bash
# Run real backup/restore tests with mock configs
bash tests/integration-tests.sh
```

Tests:
- ✅ Actual backup operations
- ✅ Selective backup functionality
- ✅ Dry-run mode
- ✅ Restore operations
- ✅ Content preservation

### Code Quality
```bash
# Check shell script syntax
bash -n backup-codium.sh
bash -n restore-codium.sh

# Run ShellCheck linting
shellcheck -x backup-codium.sh
shellcheck -x restore-codium.sh
```

---

## 📖 Documentation

- **[TESTING.md](TESTING.md)** - Comprehensive testing guide and troubleshooting
- **[.github/workflows/test.yml](.github/workflows/test.yml)** - CI/CD pipeline configuration

---

## 🐛 Troubleshooting

### "VSCodium config directory not found"
```bash
# Verify VSCodium is installed
which codium

# Check if config directory exists
ls -la ~/.config/VSCodium  # Linux
ls -la ~/Library/Application\ Support/VSCodium  # macOS
```

### "No write permission for backup location"
```bash
# Check directory permissions
ls -ld ~/Documents/VSCodium_Backup

# Create with proper permissions
mkdir -p ~/Backups/VSCodium
chmod 755 ~/Backups/VSCodium
```

### "codium command not found"
```bash
# The script will skip extension backup/restore
# This is normal if you're not using the codium CLI
# Extensions can be managed through the UI

# To install codium command, check your package manager
apt install vscodium  # Ubuntu/Debian
brew install vscodium  # macOS
```

### "Checksum verification failed"
```bash
# Your backup may be corrupted
# You can skip verification and restore anyway:
./restore-codium.sh --skip-verify

# But it's safer to create a fresh backup
./backup-codium.sh --location ~/Backups/VSCodium_Fresh
```

---

## 🤝 Contributing

Contributions welcome! Please:

1. Test your changes:
   ```bash
   bash tests/test-all.sh
   bash tests/integration-tests.sh
   shellcheck -x backup-codium.sh restore-codium.sh
   ```

2. Ensure no ShellCheck warnings

3. Add tests for new features

4. Update documentation

---

## 📝 License

MIT License - See LICENSE file for details

---

## 🙋 Support

Have questions or issues?

1. Check [TESTING.md](TESTING.md) for common issues
2. Review the examples above
3. Run with `--verbose --dry-run` to see what's happening
4. Open an issue with your error message and logs

---

## 🎉 Acknowledgments

Built with:
- Bash scripting best practices
- Comprehensive testing and CI/CD
- Cross-platform compatibility
- User-friendly design

**Happy backing up!** 🦧
