# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-12-21

### Added
- **Checksum Verification**: SHA256 checksums for all backed-up files
- **Manifest Files**: Detailed metadata about backups (date, OS, components)
- **Dry-Run Mode**: Preview backups/restores without modifying files (`--dry-run`)
- **Selective Operations**: Backup/restore only specific components with flags like `--only-settings`, `--no-extensions`
- **Comprehensive Logging**: Detailed logs of all operations saved to `backup.log` and `restore.log`
- **Safety Prompts**: Confirmation dialogs before overwriting existing configurations
- **Verbose Output**: Detailed status messages with `--verbose` flag
- **Timestamped Backups**: Automatic timestamping option (`--timestamp`)
- **Argument Parsing**: Full CLI with `--help` and `--version` support
- **Custom Locations**: Specify backup location with `--location` and `--backup` flags
- **Summary Reports**: Clear before/after status with file counts and sizes
- **Improved Error Handling**: Better detection and reporting of issues
- **Test Suite**: Comprehensive test suite in `tests/test-all.sh`
- **Quick Reference Guide**: Common commands and use cases in `docs/QUICK_REFERENCE.md`

### Changed
- **Complete Rewrite**: Scripts rewritten for robustness and feature completeness
- **Better OS Detection**: More reliable platform detection with error handling
- **Improved Logging**: All operations logged with timestamps
- **User Feedback**: Clear status messages and progress indicators
- **README**: Expanded with advanced usage, troubleshooting, and examples

### Fixed
- Script now validates backup location is writable before proceeding
- Better handling of missing optional files (keybindings.json, etc.)
- Improved error messages when `codium` command is not found
- Fixed potential race conditions in directory creation

### Security
- SHA256 checksums enable integrity verification
- Backup validation on restore
- Confirmation prompts prevent accidental overwrites

## [1.0.0] - 2024-XX-XX

### Added
- `backup-codium.sh`: Initial script to back up user settings, keybindings, snippets, and extension list
- `restore-codium.sh`: Initial script to restore configuration and reinstall extensions from a backup
- `README.md`: Project description, badges, and usage instructions
- `.snyk`: Snyk security scan configuration
- Auto-detection of operating system (macOS or Linux) for correct VSCodium config directory
- Error checks to prevent "No such file or directory" errors
- Clean, straightforward shell script implementation

[2.0.0]: https://github.com/knowoneactual/backup-vscodium/releases/tag/v2.0.0
[1.0.0]: https://github.com/knowoneactual/backup-vscodium/releases/tag/v1.0.0
