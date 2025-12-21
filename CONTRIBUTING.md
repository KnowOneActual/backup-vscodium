# Contributing to backup-vscodium

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to the project.

---

## 🙋 Getting Started

### Prerequisites

- Bash 4.0 or higher
- Git
- ShellCheck (for linting)
- A fork of the repository

### Setup Development Environment

```bash
# 1. Fork the repository on GitHub
# 2. Clone your fork
git clone https://github.com/YOUR_USERNAME/backup-vscodium.git
cd backup-vscodium

# 3. Add upstream remote
git remote add upstream https://github.com/KnowOneActual/backup-vscodium.git

# 4. Create a feature branch
git checkout -b feature/my-feature

# 5. Install ShellCheck (optional but recommended)
# Ubuntu/Debian
sudo apt-get install shellcheck
# macOS
brew install shellcheck
```

---

## 📝 Making Changes

### Code Style

1. **Bash Style Guide:**
   - Use `#!/bin/bash` shebang
   - Set `set -euo pipefail` at the start
   - Use functions for organization
   - Use readonly for constants
   - Comment complex logic

2. **Naming Conventions:**
   - Function names: `function_name_with_underscores`
   - Variable names: `UPPERCASE_FOR_CONSTANTS`, `lowercase_for_variables`
   - Private functions: `_prefix_private_function`

3. **Documentation:**
   - Add comments explaining "why" not "what"
   - Include usage examples in function comments
   - Document edge cases and assumptions

### Example Function

```bash
# backup_file - Copy a file to backup directory
# Arguments:
#   $1 - Source file path
#   $2 - Destination directory
# Returns:
#   0 if successful, 1 if file not found
# Example:
#   backup_file "$CONFIG_DIR/settings.json" "$BACKUP_DIR/User"
backup_file() {
    local source_file="$1"
    local dest_dir="$2"
    local file_name
    file_name=$(basename "$source_file")
    
    # Handle missing source gracefully
    if [ ! -f "$source_file" ]; then
        log_warning "File not found: $source_file"
        return 1
    fi
    
    # Create directory if needed
    mkdir -p "$dest_dir"
    
    # Copy with error handling
    cp "$source_file" "$dest_dir/" 2>/dev/null || {
        log_error "Failed to backup: $file_name"
        return 1
    }
    
    log_success "Backed up: $file_name"
    return 0
}
```

---

## 🧹 Testing Your Changes

### Run All Tests

```bash
# Unit tests
bash tests/test-all.sh

# Integration tests (real backup/restore)
bash tests/integration-tests.sh

# ShellCheck linting
shellcheck -x backup-codium.sh
shellcheck -x restore-codium.sh
shellcheck -x tests/test-all.sh

# Bash syntax check
bash -n backup-codium.sh
bash -n restore-codium.sh
```

### Manual Testing

```bash
# Test with verbose output
./backup-codium.sh --verbose --dry-run

# Test help
./backup-codium.sh --help
./restore-codium.sh --help

# Test with custom location
./backup-codium.sh --location ~/test_backup

# Test dry-run
./restore-codium.sh --dry-run --backup ~/test_backup
```

### Write Tests for New Features

Add tests to `tests/integration-tests.sh`:

```bash
test_my_new_feature() {
    test_case "My new feature description"
    
    export HOME="$TEST_ROOT/home"
    export CONFIG_DIR="$MOCK_VSCODIUM"
    
    # Run your feature
    bash "$BACKUP_SCRIPT" --my-new-flag 2>/dev/null || true
    
    # Check results
    if [ /* condition */ ]; then
        pass "Feature works as expected"
    else
        fail "Feature didn't work"
    fi
}
```

---

## 📄 Commit Messages

Use clear, descriptive commit messages following this format:

```
<type>: <subject>

<body>

<footer>
```

### Types
- **feat:** New feature
- **fix:** Bug fix
- **docs:** Documentation changes
- **refactor:** Code refactoring without feature changes
- **test:** Adding or updating tests
- **chore:** Maintenance tasks
- **ci:** CI/CD changes

### Examples

```
feat: Add --only-extensions flag for selective backup

Adds ability to backup only extensions list without other files.
Useful for quick extension reinstall on new machines.

Fixes #42
```

```
fix: Correct checksum verification failure message

The error message was misleading when checksums didn't match.
Now shows which files failed verification.
```

```
docs: Add examples for backup to cloud storage

Added section to README showing how to use with Dropbox,
Google Drive, and OneDrive locations.
```

---

## 🚀 Creating a Pull Request

1. **Push your changes:**
   ```bash
   git push origin feature/my-feature
   ```

2. **Create PR on GitHub:**
   - Go to https://github.com/KnowOneActual/backup-vscodium
   - Click "Compare & pull request"
   - Fill in description
   - Reference any related issues

3. **PR Template:**
   ```markdown
   ## Description
   Brief description of changes
   
   ## Type of Change
   - [ ] New feature
   - [ ] Bug fix
   - [ ] Documentation update
   - [ ] Breaking change
   
   ## Testing
   How you tested the changes
   
   ## Checklist
   - [ ] Tests pass locally
   - [ ] ShellCheck clean
   - [ ] Documentation updated
   - [ ] No breaking changes (unless major version bump)
   ```

4. **Wait for review:**
   - Maintainer will review
   - May request changes
   - Push updates to same branch

---

## 📅 Documentation

### When to Update Documentation

- **New feature** → Update README.md with examples
- **New flag** → Add to command reference
- **Breaking change** → Add migration guide
- **Bug fix** → Update CHANGELOG.md

### README Structure

```markdown
# Project Name

## Features

## Installation

## Quick Start

## Examples

## Command Reference

## Troubleshooting
```

### CHANGELOG Format

Use [Keep a Changelog](https://keepachangelog.com/) format:

```markdown
## [Unreleased]
### Added
- New feature description

### Fixed
- Bug fix description

## [2.0.1] - 2025-12-21
### Added
- Feature X
```

---

## 🔍 Code Review

### What Reviewers Look For

1. **Correctness**
   - Does the code work as intended?
   - Are error cases handled?
   - Is error handling robust?

2. **Quality**
   - Is code readable and maintainable?
   - Are there obvious inefficiencies?
   - Are there potential bugs?

3. **Tests**
   - Are changes covered by tests?
   - Do tests pass?
   - Are edge cases tested?

4. **Documentation**
   - Is the change documented?
   - Are examples clear?
   - Is the README updated?

5. **Style**
   - Does code follow project conventions?
   - Are there ShellCheck warnings?
   - Is formatting consistent?

### Responding to Feedback

1. **Understand the feedback** - Ask clarifying questions
2. **Make changes** - Push to same branch
3. **Re-request review** - Comment on PR when ready
4. **Don't take it personally** - It's about the code!

---

## 🌟 Report Bugs

### Before Filing

1. Check existing issues
2. Try reproducing with latest code
3. Gather debugging information

### What to Include

```markdown
## Description
Clear description of the issue

## Steps to Reproduce
1. Run command X
2. Observe behavior Y
3. Expected behavior Z

## Environment
- OS: macOS 14.0
- Bash version: 5.2.0
- Script version: 2.0.0

## Logs
```bash
./backup-codium.sh --verbose --dry-run
# Output here
```

## Screenshots
If applicable
```

---

## 🚅 Request Features

### Before Requesting

1. Check if feature already exists
2. Check existing issues/discussions
3. Think about use cases

### What to Include

```markdown
## Feature Request

### Problem
What problem does this solve?

### Proposed Solution
How should it work?

### Examples
```bash
# How would users use this?
./backup-codium.sh --new-feature
```

### Alternatives
Other approaches considered?
```

---

## 🂧 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

## 🗑️ Maintainers

- **Beau Bremer** - [@KnowOneActual](https://github.com/KnowOneActual)

---

## 🙏 Thank You!

Thank you for contributing to backup-vscodium! Your help makes this project better for everyone.

---

## 🔗 Resources

- [GitHub Flow Guide](https://guides.github.com/introduction/flow/)
- [Bash Best Practices](https://mywiki.wooledge.org/BashGuide)
- [ShellCheck](https://www.shellcheck.net/)
- [Keep a Changelog](https://keepachangelog.com/)
- [Semantic Versioning](https://semver.org/)

---

**Questions?** Open an issue or start a discussion!
