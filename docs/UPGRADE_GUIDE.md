# Upgrade Guide: v1.0 → v2.0

Welcome to backup-vscodium v2.0! This guide helps you understand what's changed and how to use the new features.

## ✅ Good News

**Your existing backups are fully compatible!** You can restore v1.0 backups with v2.0 scripts without any modifications.

```bash
# This still works
./restore-codium.sh  # Restores from ~/Documents/VSCodium_Backup
```

## 🌟 What's New

### Major Features

#### 1. **Checksum Verification** ✓

Backups now include SHA256 checksums for integrity verification:

```bash
# Automatically created during backup
ls ~/Documents/VSCodium_Backup/backup.sha256

# Verify anytime
cd ~/Documents/VSCodium_Backup
sha256sum -c backup.sha256

# Automatically verified during restore
./restore-codium.sh  # ← Checks checksums before proceeding
```

#### 2. **Dry-Run Mode** 🎯

Preview operations without modifying files:

```bash
# Preview what would be backed up
./backup-codium.sh --dry-run

# Preview what would be restored
./restore-codium.sh --dry-run
```

#### 3. **Selective Operations** 🎚️

Back up and restore only what you need:

```bash
# Backup only settings
./backup-codium.sh --only-settings

# Restore only extensions
./restore-codium.sh --only-extensions

# Skip extensions backup
./backup-codium.sh --no-extensions
```

#### 4. **Custom Locations** 📁

Specify backup location via argument:

**v1.0 (hardcoded):**
```bash
# Had to edit script or create symlink
# Always used ~/Documents/VSCodium_Backup
```

**v2.0 (flexible):**
```bash
# Specify location directly
./backup-codium.sh --location ~/Dropbox/VSCodium_Backup
./restore-codium.sh --backup ~/Dropbox/VSCodium_Backup
```

#### 5. **Timestamped Backups** ⏰

Automatically version your backups:

```bash
# Creates: VSCodium_Backup_20250321_143025/
./backup-codium.sh --timestamp

# Keep multiple versions
./backup-codium.sh --timestamp  # Run daily
ls ~/Documents/VSCodium_Backup_*
```

#### 6. **Safety Prompts** 🛡️

Confirm before overwriting existing configuration:

**v1.0 (silent overwrites):**
```bash
./restore-codium.sh  # ← Would silently overwrite
```

**v2.0 (interactive):**
```bash
./restore-codium.sh
# → "This will overwrite your current VSCodium configuration. Continue? (yes/no):"
```

#### 7. **Comprehensive Logging** 📝

Everything is logged with timestamps:

```bash
# View backup log
cat ~/Documents/VSCodium_Backup/backup.log

# View restore log
cat ~/Documents/VSCodium_Backup/restore.log

# Verbose output
./backup-codium.sh --verbose
```

#### 8. **Manifest Files** 📋

Detailed inventory of what was backed up:

```bash
# View backup manifest
cat ~/Documents/VSCodium_Backup/manifest.txt

# Shows:
# - When backed up
# - What system
# - Which components
# - Complete file listing
```

## 🔄 Migration Examples

### Example 1: Move from Hardcoded to Cloud Backup

**Before (v1.0):**
```bash
# Backup was stuck in ~/Documents/VSCodium_Backup
./backup-codium.sh
# → Created ~/Documents/VSCodium_Backup
```

**After (v2.0):**
```bash
# Backup to Dropbox
./backup-codium.sh --location ~/Dropbox/VSCodium_Backup

# Restore from Dropbox on new machine
./restore-codium.sh --backup ~/Dropbox/VSCodium_Backup
```

### Example 2: Upgrade Safely

**Before (v1.0):**
```bash
# Backup before upgrade (no dry-run)
./backup-codium.sh

# Upgrade VSCodium
brew upgrade vscodium

# Problem? No good way to verify restore would work
```

**After (v2.0):**
```bash
# Backup before upgrade (with timestamp)
./backup-codium.sh --timestamp

# Upgrade VSCodium
brew upgrade vscodium

# Preview restore (no modifications)
./restore-codium.sh --dry-run --verbose

# Actually restore if needed
./restore-codium.sh --backup ~/Documents/VSCodium_Backup_20250321_143025
```

### Example 3: Partial Restore

**Before (v1.0):**
```bash
# All-or-nothing restore
./restore-codium.sh  # Restores everything
```

**After (v2.0):**
```bash
# Restore only settings
./restore-codium.sh --only-settings

# Restore everything except extensions
./restore-codium.sh --no-extensions

# Restore only keybindings
./restore-codium.sh --only-keybindings
```

## 🎛️ Feature Comparison

| Feature | v1.0 | v2.0 |
|---------|------|------|
| Basic backup/restore | ✓ | ✓ |
| Settings | ✓ | ✓ |
| Keybindings | ✓ | ✓ |
| Snippets | ✓ | ✓ |
| Extensions | ✓ | ✓ |
| **Custom backup location** | ✗ | ✓ |
| **Timestamped backups** | ✗ | ✓ |
| **Checksum verification** | ✗ | ✓ |
| **Manifest files** | ✗ | ✓ |
| **Comprehensive logging** | ✗ | ✓ |
| **Dry-run mode** | ✗ | ✓ |
| **Selective backup/restore** | ✗ | ✓ |
| **Safety prompts** | ✗ | ✓ |
| **Verbose output** | ✗ | ✓ |
| **Command-line arguments** | ✗ | ✓ |
| **Help system** | ✗ | ✓ |
| **Test suite** | ✗ | ✓ |
| **CI/CD integration** | ✗ | ✓ |

## 🔧 API Changes

### Backup Script

**v1.0:**
```bash
./backup-codium.sh
# Options: edit script variables
```

**v2.0:**
```bash
./backup-codium.sh [OPTIONS]

# Options:
./backup-codium.sh --help                           # Show help
./backup-codium.sh --version                        # Show version
./backup-codium.sh --dry-run                        # Preview
./backup-codium.sh --verbose                        # Detailed output
./backup-codium.sh --location PATH                  # Custom location
./backup-codium.sh --timestamp                      # Versioned backup
./backup-codium.sh --no-extensions                  # Skip extensions
./backup-codium.sh --only-settings                  # Settings only
./backup-codium.sh --no-checksums                   # Faster backup
```

### Restore Script

**v1.0:**
```bash
./restore-codium.sh
# Options: edit script variables
```

**v2.0:**
```bash
./restore-codium.sh [OPTIONS]

# Options:
./restore-codium.sh --help                          # Show help
./restore-codium.sh --version                       # Show version
./restore-codium.sh --dry-run                       # Preview
./restore-codium.sh --verbose                       # Detailed output
./restore-codium.sh --backup PATH                   # Custom location
./restore-codium.sh --force                         # Skip confirmation
./restore-codium.sh --skip-verify                   # Skip checksum check
./restore-codium.sh --no-extensions                 # Skip extensions
./restore-codium.sh --only-settings                 # Settings only
```

## ⚡ Performance Notes

- **Checksums**: Small overhead (~1-2 seconds) but provides integrity verification
- **Logging**: Negligible performance impact
- **Selective operations**: Can be faster if you skip large components
- **Dry-run**: Very fast (no file I/O)

For faster backups without checksums:
```bash
./backup-codium.sh --no-checksums
```

## ⚠️ Breaking Changes

**There are NO breaking changes.** Your old backups work with v2.0:

```bash
# Your v1.0 backup from ~/Documents/VSCodium_Backup
ls ~/Documents/VSCodium_Backup/
# User/
# extensions.txt

# v2.0 can restore it fine
./restore-codium.sh
```

## 🚀 Getting Started with v2.0

### Step 1: Update Scripts

```bash
# Pull latest version
cd ~/projects/backup-vscodium
git pull origin main

# Make executable
chmod +x backup-codium.sh restore-codium.sh
```

### Step 2: Try Dry-Run

```bash
# Preview what would happen
./backup-codium.sh --dry-run --verbose
```

### Step 3: Explore New Features

```bash
# See all available options
./backup-codium.sh --help
./restore-codium.sh --help

# Quick reference
cat docs/QUICK_REFERENCE.md
```

### Step 4: Create Your First v2.0 Backup

```bash
# Backup to cloud with timestamp
./backup-codium.sh --location ~/Dropbox/VSCodium_Backup --timestamp --verbose

# Verify it
cat ~/Dropbox/VSCodium_Backup_*/manifest.txt
ls -la ~/Dropbox/VSCodium_Backup_*/
```

## 🧙 Troubleshooting Upgrades

### Q: Can I mix v1.0 and v2.0 backups?

**A:** Yes! Restore v1.0 backups with v2.0 scripts:
```bash
./restore-codium.sh --backup ~/old-backup-from-v1
```

### Q: My old backup location was hardcoded. How do I move it?

**A:** Copy or move the backup, then use --backup flag:
```bash
# Move backup
mv ~/Documents/VSCodium_Backup ~/Dropbox/VSCodium_Backup

# Restore from new location
./restore-codium.sh --backup ~/Dropbox/VSCodium_Backup
```

### Q: Should I update my cron job?

**A:** Optional, but recommended for versioning:
```bash
# Old (v1.0)
0 8 * * * ~/backup-vscodium/backup-codium.sh

# New (v2.0) - creates timestamped backups
0 8 * * * ~/backup-vscodium/backup-codium.sh --timestamp --location ~/Dropbox/VSCodium_Backup
```

## 📄 Documentation

- **[README.md](../README.md)** - Complete documentation
- **[QUICK_REFERENCE.md](./QUICK_REFERENCE.md)** - Common commands
- **[CHANGELOG.md](../CHANGELOG.md)** - Full change list

## 🩋 Need Help?

- [GitHub Issues](https://github.com/knowoneactual/backup-vscodium/issues)
- [Discussions](https://github.com/knowoneactual/backup-vscodium/discussions)

---

**Welcome to v2.0! Enjoy the new features! 🎉**
