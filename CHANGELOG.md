# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `backup-codium.sh`: Initial script to back up user settings, keybindings, snippets, and extension list.
- `restore-codium.sh`: Initial script to restore configuration and reinstall extensions from a backup.
- `README.md`: Added project description, badges, and usage warning.
- `.snyk`: Added config file to ignore project in Snyk security scans.
- Initial project setup (from original file).

### Fixed
- `backup-codium.sh` and `restore-codium.sh`: Scripts now auto-detect the operating system (macOS or Linux) to find the correct VSCodium configuration directory.
- `backup-codium.sh`: Added checks to prevent "No such file or directory" errors if a config file (like `keybindings.json`) doesn't exist.