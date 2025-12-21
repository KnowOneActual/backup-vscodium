# backup-vscodium Quick Reference

Fast lookup for common commands and use cases.

## 📋 Common Commands

### Backup

```bash
# Basic backup
./backup-codium.sh

# Backup to custom location
./backup-codium.sh --location ~/Dropbox/VSCodium_Backup

# Backup with timestamp
./backup-codium.sh --timestamp

# Preview what would be backed up (no files modified)
./backup-codium.sh --dry-run

# Verbose output with logging
./backup-codium.sh --verbose
```

### Restore

```bash
# Basic restore (with confirmation)
./restore-codium.sh

# Restore from custom location
./restore-codium.sh --backup ~/Dropbox/VSCodium_Backup

# Preview restore (no files modified)
./restore-codium.sh --dry-run

# Force restore without confirmation
./restore-codium.sh --force

# Verbose logging
./restore-codium.sh --verbose
```

## 🎯 Use Cases

### Case 1: Cloud Sync Setup

Back up to Dropbox for cloud sync:

```bash
# Initial setup
./backup-codium.sh --location ~/Dropbox/VSCodium_Backup

# On new machine
./restore-codium.sh --backup ~/Dropbox/VSCodium_Backup
```

### Case 2: Versioned Backups

Keep timestamped backups:

```bash
# Creates: VSCodium_Backup_20250321_143025/
./backup-codium.sh --timestamp

# List all backups
ls -la ~/Documents/VSCodium_Backup_*

# Restore from specific backup
./restore-codium.sh --backup ~/Documents/VSCodium_Backup_20250321_143025
```

### Case 3: Settings Only

Quick backup without extensions:

```bash
# Backup only settings and keybindings
./backup-codium.sh --no-extensions --no-snippets

# Restore only settings
./restore-codium.sh --only-settings
```

### Case 4: New Machine Setup

Fast setup on new computer:

```bash
# Copy backup to new machine first
cp -r ~/Documents/VSCodium_Backup /path/on/new/machine/

# Restore everything
./restore-codium.sh --backup /path/on/new/machine/VSCodium_Backup

# Restart VSCodium
```

### Case 5: Test Before Restoring

Always preview first:

```bash
# Check what would be restored
./restore-codium.sh --dry-run --backup ~/my-backup --verbose

# If looks good, actually restore
./restore-codium.sh --backup ~/my-backup
```

### Case 6: Partial Restore

Restore only specific components:

```bash
# Settings only
./restore-codium.sh --only-settings

# Extensions only
./restore-codium.sh --only-extensions

# Snippets + Keybindings (no settings)
./restore-codium.sh --no-settings
```

## 🔍 Verification

### Check Backup Integrity

```bash
# Verify checksums
cd ~/Documents/VSCodium_Backup
sha256sum -c backup.sha256

# View what was backed up
cat manifest.txt

# View backup log
cat backup.log
```

### Check Restore Logs

```bash
cat ~/Documents/VSCodium_Backup/restore.log
```

## 🐛 Troubleshooting

### "codium command not found"

```bash
# Check if VSCodium is in PATH
which codium

# If not found, locate it
find /Applications -name "VSCodium.app" 2>/dev/null  # macOS
which codium 2>/dev/null || echo "Not in PATH"  # Linux

# Add to PATH (macOS)
export PATH="/Applications/VSCodium.app/Contents/Resources/app/bin:$PATH"

# Then try again
./backup-codium.sh --verbose
```

### Backup location permission errors

```bash
# Check if location is writable
touch ~/Documents/test.txt && rm ~/Documents/test.txt

# Create backup directory manually
mkdir -p ~/Documents/VSCodium_Backup

# Then run backup
./backup-codium.sh
```

### Restore fails with checksum error

```bash
# Skip verification if backup is trusted
./restore-codium.sh --skip-verify

# Or create a fresh backup
./backup-codium.sh --location ~/fresh-backup
./restore-codium.sh --backup ~/fresh-backup
```

## 📊 Flags Reference

### Backup Flags

| Flag | Purpose | Example |
|------|---------|----------|
| `--help` | Show help | `./backup-codium.sh --help` |
| `--version` | Show version | `./backup-codium.sh --version` |
| `--verbose` | Detailed output | `./backup-codium.sh --verbose` |
| `--dry-run` | Preview without modifying | `./backup-codium.sh --dry-run` |
| `-l, --location PATH` | Custom backup path | `./backup-codium.sh --location ~/cloud/backup` |
| `-t, --timestamp` | Add timestamp to folder | `./backup-codium.sh --timestamp` |
| `--only-settings` | Backup settings only | `./backup-codium.sh --only-settings` |
| `--no-extensions` | Skip extensions | `./backup-codium.sh --no-extensions` |
| `--no-checksums` | Don't create checksums | `./backup-codium.sh --no-checksums` |

### Restore Flags

| Flag | Purpose | Example |
|------|---------|----------|
| `--help` | Show help | `./restore-codium.sh --help` |
| `--version` | Show version | `./restore-codium.sh --version` |
| `--verbose` | Detailed output | `./restore-codium.sh --verbose` |
| `--dry-run` | Preview without modifying | `./restore-codium.sh --dry-run` |
| `-b, --backup PATH` | Custom backup path | `./restore-codium.sh --backup ~/my-backup` |
| `-f, --force` | Skip confirmation | `./restore-codium.sh --force` |
| `--skip-verify` | Skip checksum check | `./restore-codium.sh --skip-verify` |
| `--only-settings` | Restore settings only | `./restore-codium.sh --only-settings` |
| `--no-extensions` | Skip extensions | `./restore-codium.sh --no-extensions` |

## 🎬 Workflow Examples

### Workflow 1: Daily Automated Backup

```bash
# Add to crontab for daily backups
0 8 * * * ~/projects/backup-vscodium/backup-codium.sh --location ~/Dropbox/VSCodium_Backup --timestamp

# List recent backups
ls -lat ~/Dropbox/VSCodium_Backup_* | head -5
```

### Workflow 2: Test Changes Before Committing

```bash
# Backup current state
./backup-codium.sh --location ~/backup-before-test

# Try new extensions/settings
# ..experiment in VSCodium...

# If something breaks, restore
./restore-codium.sh --backup ~/backup-before-test

# Or keep the new changes and delete backup
rm -rf ~/backup-before-test
```

### Workflow 3: Move Between Machines

```bash
# On old machine: Backup to external drive
./backup-codium.sh --location /Volumes/USB-Drive/VSCodium_Backup

# Transfer USB drive to new machine

# On new machine: Restore
./restore-codium.sh --backup /Volumes/USB-Drive/VSCodium_Backup
```

### Workflow 4: Safe Upgrade Testing

```bash
# Before major VSCodium update
./backup-codium.sh --timestamp

# Upgrade VSCodium
brew upgrade vscodium  # macOS

# If issues occur
./restore-codium.sh --backup ~/Documents/VSCodium_Backup_YYYYMMDD_HHMMSS
```

## 💾 File Locations

### Backup Directory Structure

```
VSCodium_Backup/
├── User/
│   ├── settings.json
│   └── keybindings.json
├── snippets/
│   ├── python.json
│   ├── javascript.json
│   └── ...
├── extensions.txt
├── backup.sha256       (checksums)
├── manifest.txt        (metadata)
└── backup.log          (operation log)
```

### VSCodium Config Directory

**macOS:** `~/Library/Application Support/VSCodium`

**Linux:** `~/.config/VSCodium`

## 📚 More Information

- [Full README](../README.md) - Complete documentation
- [Contributing](../CONTRIBUTING.md) - How to contribute
- [Changelog](../CHANGELOG.md) - Version history
- [Issues](https://github.com/knowoneactual/backup-vscodium/issues) - Bug reports & features
