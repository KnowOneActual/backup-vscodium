# Changelog

All notable changes to backup-vscodium will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-12-21

### Added
- **Integration Tests** - Real backup/restore operations with mock VSCodium configs
- **Comprehensive README** - 30+ examples, command reference, troubleshooting guide
- **Release Automation** - Semantic version bumping and GitHub Actions releases
- **Testing Documentation** - Complete TESTING.md with debugging tips
- **Version Bump Script** - Automated semantic versioning with `scripts/bump-version.sh`
- **Release Workflow** - Automatic GitHub releases triggered by git tags

### Fixed
- **ShellCheck SC2155** - Separated `readonly` declarations from assignments
- **ShellCheck SC2320** - Fixed `$?` exit code capture in test framework
- **Bash Arithmetic** - Replaced `((var++))` with `var=$((var+1)) || true` for `set -e` compatibility
- **Unit Tests** - Removed tests for unimplemented features (now feature requests)

### Changed
- Refactored test suite from unit tests to integration tests
- Improved logging with timestamps and structured output
- Enhanced error messages with more specific guidance
- Updated help text for clarity

### Documentation
- Added TESTING.md with comprehensive testing guide
- Added CHANGELOG.md for version tracking
- Created integration test suite documentation
- Added release process documentation

## [1.0.0] - Initial Release

### Added
- Core backup functionality
  - Backup settings.json
  - Backup keybindings.json
  - Backup snippets directory
  - Backup extensions list

- Core restore functionality
  - Restore from backup with checksum verification
  - Confirmation prompts for safety
  - Selective restore options

- Command-line interface
  - Help and version flags
  - Custom backup locations
  - Dry-run mode
  - Verbose logging

- Cross-platform support
  - macOS support
  - Linux support
  - OS detection and path configuration

- Safety features
  - Checksum generation and verification
  - Manifest files for metadata
  - Comprehensive logging
  - Error handling and validation

---

## How to Read This Changelog

### Sections
- **Added** - New features introduced
- **Changed** - Changes in existing functionality
- **Deprecated** - Soon-to-be removed features
- **Removed** - Now removed features
- **Fixed** - Bug fixes
- **Security** - Security vulnerability fixes

### Version Format
- **MAJOR** - Incompatible API changes
- **MINOR** - New functionality in backwards-compatible manner
- **PATCH** - Backwards-compatible bug fixes

Example: `2.0.0` = Major version 2, minor version 0, patch version 0

---

## Release Process

### To Create a New Release

1. **Bump the version:**
   ```bash
   ./scripts/bump-version.sh patch  # or minor, or major
   ```

2. **Push to GitHub:**
   ```bash
   git push origin main
   git push origin v2.0.1  # or whatever version was created
   ```

3. **GitHub Actions will automatically:**
   - Run all tests
   - Create GitHub release with notes
   - Build release artifacts (if configured)

4. **View your release:**
   - https://github.com/KnowOneActual/backup-vscodium/releases

### Version Bumping Rules

**Patch Release (2.0.0 -> 2.0.1)**
- Bug fixes
- Performance improvements
- Documentation updates
- Minor improvements

**Minor Release (2.0.0 -> 2.1.0)**
- New features
- New command-line flags
- Non-breaking changes

**Major Release (2.0.0 -> 3.0.0)**
- Breaking changes
- API changes
- Significant rewrites

---

## Upcoming Features (Roadmap)

Planned for future releases:

- [ ] Windows support (PowerShell version)
- [ ] Incremental backups
- [ ] Cloud storage integration (S3, Google Drive)
- [ ] GUI interface
- [ ] Backup scheduling
- [ ] Automatic backup on VSCodium shutdown
- [ ] Diff viewer for comparing backups
- [ ] Backup encryption
- [ ] Multi-device sync

---

## Legacy Versions

For historical reference, earlier versions can be found at:
https://github.com/KnowOneActual/backup-vscodium/releases

---

## Contributing

When contributing, please:

1. Follow semantic versioning
2. Update CHANGELOG.md with your changes
3. Use the format shown above
4. Add your changes under the appropriate "Unreleased" section
5. Update version in scripts when ready for release

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.
