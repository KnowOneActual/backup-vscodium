# Quick Reference Card

**backup-vscodium** - Common Commands at a Glance

---

## 📋 Most Common Commands

### Backup

```bash
# Simple backup to default location
./backup-codium.sh

# Backup with verbose output to see what's happening
./backup-codium.sh --verbose

# Preview what would be backed up (dry-run)
./backup-codium.sh --dry-run

# Backup to custom location
./backup-codium.sh --location ~/Dropbox/VSCodium

# Backup with timestamp for versioning
./backup-codium.sh --timestamp

# Backup only settings (skip other stuff)
./backup-codium.sh --only-settings
```

### Restore

```bash
# Restore from default location (interactive)
./restore-codium.sh

# Restore from custom location
./restore-codium.sh --backup ~/Dropbox/VSCodium

# Preview restore without making changes
./restore-codium.sh --dry-run

# Restore without confirmation prompts
./restore-codium.sh --force

# Restore only settings
./restore-codium.sh --only-settings
```

---

## 🎯 By Use Case

### "I want to back up everything"
```bash
./backup-codium.sh --verbose
```

### "I want to back up to cloud storage"
```bash
./backup-codium.sh --location ~/Dropbox/VSCodium --timestamp
```

### "I want versioned backups (keep multiple)"
```bash
./backup-codium.sh --location ~/Backups/VSCodium --timestamp
```

### "I want to see what would happen before doing it"
```bash
./backup-codium.sh --dry-run --verbose
```

### "I'm setting up a new machine"
```bash
./restore-codium.sh --backup ~/Dropbox/VSCodium --verbose
```

### "I want to restore only settings (keep my extensions)"
```bash
./restore-codium.sh --no-extensions --force
```

### "I want to backup only extensions"
```bash
./backup-codium.sh --only-extensions --verbose
```

### "I want to restore only extensions"
```bash
./restore-codium.sh --only-extensions --force
```

### "I want automatic daily backups"
```bash
# Add to crontab (runs at 2 AM every day)
0 2 * * * /path/to/backup-codium.sh --location ~/Backups --timestamp
```

---

## 🚀 Installation

### First Time Setup

```bash
# 1. Clone
git clone https://github.com/KnowOneActual/backup-vscodium.git
cd backup-vscodium

# 2. Make executable
chmod +x backup-codium.sh restore-codium.sh

# 3. Create first backup
./backup-codium.sh --verbose
```

### (Optional) Add to PATH

```bash
# Copy to local bin
cp backup-codium.sh ~/.local/bin/
cp restore-codium.sh ~/.local/bin/

# Now you can use from anywhere
backup-codium.sh --verbose
restore-codium.sh --dry-run
```

---

## 🧪 Testing

### Run Unit Tests
```bash
bash tests/test-all.sh
```

### Run Integration Tests (with mock configs)
```bash
bash tests/integration-tests.sh
```

### Check Code Quality
```bash
shellcheck -x backup-codium.sh restore-codium.sh
```

---

## 🔄 Flag Combinations

### "Only Settings & Keybindings"
```bash
# Backup
./backup-codium.sh --no-snippets --no-extensions

# Restore
./restore-codium.sh --no-snippets --no-extensions
```

### "Everything Except Extensions"
```bash
# Backup
./backup-codium.sh --no-extensions

# Restore
./restore-codium.sh --no-extensions
```

### "With Custom Location + Verbose + Dry-Run"
```bash
./backup-codium.sh --location ~/test --verbose --dry-run
```

### "Restore with Verification + Force"
```bash
./restore-codium.sh --force --verbose
```

---

## 📂 Important Locations

### Where Backups Go By Default
```
~/Documents/VSCodium_Backup/
```

### Where VSCodium Config Is Stored

**macOS:**
```
~/Library/Application Support/VSCodium/
```

**Linux:**
```
~/.config/VSCodium/
```

### What Gets Backed Up
```
Backup Directory/
├── User/
│   ├── settings.json      # Your settings
│   └── keybindings.json   # Your keybindings
├── snippets/              # Your code snippets
├── extensions.txt         # List of extensions
├── manifest.txt           # Backup metadata
├── backup.sha256          # Checksum file
└── backup.log             # Operation log
```

---

## 🆘 Troubleshooting

### "Command not found"
```bash
# Make sure script is executable
chmod +x backup-codium.sh

# Use full path if not in PATH
./backup-codium.sh --verbose
```

### "VSCodium config not found"
```bash
# Verify VSCodium is installed
which codium

# Check config directory exists
ls ~/Library/Application\ Support/VSCodium  # macOS
ls ~/.config/VSCodium                       # Linux
```

### "No write permission"
```bash
# Check directory permissions
ls -ld ~/Documents/VSCodium_Backup

# Create with proper permissions
mkdir -p ~/Backups/VSCodium
```

### "Help not showing"
```bash
# View help
./backup-codium.sh --help
./restore-codium.sh --help

# View version
./backup-codium.sh --version
./restore-codium.sh --version
```

---

## 📖 Full Documentation

- **[README.md](README.md)** - Complete documentation with 30+ examples
- **[TESTING.md](TESTING.md)** - Testing guide and troubleshooting
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to contribute
- **[RELEASE_PROCESS.md](RELEASE_PROCESS.md)** - How to make releases
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - Project overview

---

## ⚡ Pro Tips

1. **Always use `--dry-run` first** - See what will happen before doing it
   ```bash
   ./restore-codium.sh --dry-run
   ```

2. **Use timestamps for versioning** - Keep multiple backups
   ```bash
   ./backup-codium.sh --timestamp
   ```

3. **Check the logs** - See what happened
   ```bash
   cat ~/Documents/VSCodium_Backup/backup.log
   ```

4. **Use verbose mode** - Understand what's happening
   ```bash
   ./backup-codium.sh --verbose
   ```

5. **Test restore before relying on it** - Preview first
   ```bash
   ./restore-codium.sh --dry-run --verbose
   ```

6. **Backup to cloud storage** - Keep it safe
   ```bash
   ./backup-codium.sh --location ~/Dropbox/VSCodium
   ```

7. **Automate with cron** - Never forget to backup
   ```bash
   0 2 * * * /path/to/backup-codium.sh --location ~/Backups --timestamp
   ```

---

## 📞 Need Help?

| Question | Answer |
|----------|--------|
| **How do I use this?** | See [README.md](README.md) |
| **How do I test it?** | See [TESTING.md](TESTING.md) |
| **How do I fix an error?** | See [TESTING.md#troubleshooting](TESTING.md) |
| **How do I contribute?** | See [CONTRIBUTING.md](CONTRIBUTING.md) |
| **How do I make a release?** | See [RELEASE_PROCESS.md](RELEASE_PROCESS.md) |
| **What's the roadmap?** | See [CHANGELOG.md](CHANGELOG.md) |

---

**Print this page or save as PDF for quick reference!** 🖥️
