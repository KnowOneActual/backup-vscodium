# 🧪 Testing Guide: backup-vscodium

Complete guide to testing backup-vscodium v2.0 locally and with automated CI/CD.

---

## 🌟 Quick Start

### Run All Tests Locally

```bash
# Make test script executable
chmod +x tests/test-all.sh

# Run all tests
bash tests/test-all.sh

# Expected output: All tests passed! ✓
```

### GitHub Actions (Automatic)

- Every push automatically runs tests
- Every pull request runs tests
- Results visible in Actions tab
- No manual action needed

---

## 🚠 Local Testing

### 1. Manual Script Testing

```bash
# Make scripts executable
chmod +x backup-codium.sh restore-codium.sh

# Test help system
./backup-codium.sh --help
./restore-codium.sh --help

# Test version
./backup-codium.sh --version
./restore-codium.sh --version

# Test dry-run (safe, no modifications)
./backup-codium.sh --dry-run --verbose
./restore-codium.sh --dry-run --verbose

# Test syntax
bash -n backup-codium.sh
bash -n restore-codium.sh
```

### 2. Run Test Suite

```bash
# Execute full test suite
bash tests/test-all.sh

# With detailed output
bash tests/test-all.sh 2>&1 | tee results.log

# Check specific test
bash tests/test-all.sh | grep "Syntax Check"
```

### 3. ShellCheck Linting

```bash
# Install ShellCheck (if needed)
brew install shellcheck      # macOS
sudo apt install shellcheck  # Linux

# Run linting
shellcheck backup-codium.sh
shellcheck restore-codium.sh
shellcheck tests/test-all.sh

# Quiet mode (only show errors)
shellcheck -S warning backup-codium.sh
```

### 4. Syntax Validation

```bash
# Test each script
bash -n backup-codium.sh
bash -n restore-codium.sh
bash -n tests/test-all.sh

# All at once
for f in *.sh tests/*.sh; do bash -n "$f" && echo "✓ $f"; done
```

---

## 🤖 Automated Testing (GitHub Actions)

### How It Works

```
You push code
    ↓
GitHub detects push
    ↓
Triggers workflow: .github/workflows/test.yml
    ↓
Runs 7 jobs in parallel
    ├─ ShellCheck (code quality)
    ├─ Syntax Check (bash validation)
    ├─ Unit Tests (test suite)
    ├─ Help Check (CLI interface)
    ├─ Dry-Run Test (functionality)
    ├─ Code Quality (linting)
    └─ Summary (overall status)
    ↓
Reports results
    ├─ ✓ All pass → Green checkmark
    └─ ✗ Any fail → Red X + details
```

### Workflow File Location

```
.github/workflows/test.yml
```

### Jobs That Run

#### 1. ShellCheck Linting
- **Purpose:** Find code quality issues
- **Tool:** ShellCheck
- **What it checks:** Potential bugs, security issues, style problems
- **Pass criteria:** No warnings

#### 2. Syntax Check
- **Purpose:** Validate bash syntax
- **Tool:** bash -n
- **What it checks:** Syntax errors, missing quotes, etc.
- **Pass criteria:** Clean compilation

#### 3. Unit Tests
- **Purpose:** Run full test suite
- **Tool:** tests/test-all.sh
- **What it checks:** Functionality, arguments, features
- **Pass criteria:** All 20+ tests pass

#### 4. Help Check
- **Purpose:** Verify CLI interface
- **Tool:** bash
- **What it checks:** --help output, --version info
- **Pass criteria:** Help text present

#### 5. Dry-Run Test
- **Purpose:** Test preview functionality
- **Tool:** Script execution
- **What it checks:** Dry-run mode works
- **Pass criteria:** No errors

#### 6. Code Quality
- **Purpose:** Look for problematic patterns
- **Tool:** grep search
- **What it checks:** TODO, FIXME, XXX comments
- **Pass criteria:** Optional (informational)

#### 7. Test Summary
- **Purpose:** Report overall status
- **Tool:** Reporting
- **What it shows:** Pass/fail summary
- **Pass criteria:** All jobs pass

### View Results

#### In GitHub Web Interface

1. Go to: `https://github.com/KnowOneActual/backup-vscodium`
2. Click **Actions** tab
3. Click any workflow run
4. See detailed results for each job
5. Expand failed jobs for error details

#### Example Result View

```
Workflow: Tests
Commit: abc123... "feat: Add new feature"
Status: ✓ All checks passed (7/7)

Jobs:
  ✓ ShellCheck Linting (completed)
  ✓ Syntax Check (completed)
  ✓ Unit Tests (completed)
  ✓ Help Check (completed)
  ✓ Dry-Run Test (completed)
  ✓ Code Quality (completed)
  ✓ Test Summary (completed)
```

---

## 📄 Pre-Commit Hook

### Automatic Local Testing

Set up to run tests before each commit:

```bash
# Create pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
set -euo pipefail

echo "🧪 Running pre-commit tests..."

# Syntax check
bash -n backup-codium.sh || exit 1
bash -n restore-codium.sh || exit 1

# ShellCheck
shellcheck backup-codium.sh || exit 1
shellcheck restore-codium.sh || exit 1

echo "✓ All pre-commit tests passed!"
EOF

# Make executable
chmod +x .git/hooks/pre-commit
```

### How It Works

```bash
# Now when you try to commit
git add .
git commit -m "fix: Something"

# Hook runs automatically
# 🧪 Running pre-commit tests...
# ✓ All pre-commit tests passed!
# [main abc123] fix: Something

# If tests fail, commit is blocked
# ✗ ERROR: Syntax error in backup-codium.sh
# Fix error and try again
```

---

## 📈 Development Workflow

### Step-by-Step Workflow

```bash
# 1. Create feature branch
git checkout -b feature/my-feature

# 2. Make changes
nano backup-codium.sh

# 3. Run tests locally
bash tests/test-all.sh

# 4. If all pass, commit
git add backup-codium.sh
git commit -m "feat: Add new feature"
# Pre-commit hook runs automatically

# 5. Push to GitHub
git push origin feature/my-feature

# 6. GitHub Actions runs (automatic)
# Check: https://github.com/.../actions

# 7. If all pass, create/merge PR
git checkout main
git pull origin main
git merge feature/my-feature
git push origin main

# 8. GitHub Actions runs again on main
# (Double-checks everything)

✓ Done! Feature is tested and merged!
```

---

## 💡 Common Testing Scenarios

### Scenario 1: Before Committing

```bash
# Quick validation before commit
bash tests/test-all.sh

# If fails, fix and retry
# bash -n script.sh          # Check syntax
# shellcheck script.sh       # Check linting
```

### Scenario 2: Before Pushing

```bash
# Final check before push
bash tests/test-all.sh && git push origin main

# Only pushes if all tests pass
```

### Scenario 3: After Adding Feature

```bash
# 1. Add feature
nano backup-codium.sh

# 2. Add tests if applicable
nano tests/test-all.sh

# 3. Run all tests
bash tests/test-all.sh

# 4. If pass, commit
git add .
git commit -m "feat: New feature"

# 5. Push and verify on GitHub Actions
git push origin feature
# Check https://github.com/.../actions
```

### Scenario 4: Debugging Failed Test

```bash
# Run test with verbose output
bash tests/test-all.sh 2>&1 | tee results.log

# Find failing test
grep "FAIL" results.log

# Validate syntax
bash -n backup-codium.sh

# Run ShellCheck
shellcheck backup-codium.sh

# Check specific command
./backup-codium.sh --help

# Fix and retry
bash tests/test-all.sh
```

---

## 📁 Test Output

### Successful Test Run

```
🧪 backup-vscodium Test Suite
===============================

==================================================
  Script Existence Tests
==================================================

[TEST 1] Backup script exists
  ✓ PASS: backup-codium.sh found

[TEST 2] Restore script exists
  ✓ PASS: restore-codium.sh found

==================================================
  Bash Syntax Tests
==================================================

[TEST 3] Backup script syntax validation
  ✓ PASS: backup-codium.sh has valid bash syntax

[TEST 4] Restore script syntax validation
  ✓ PASS: restore-codium.sh has valid bash syntax

... more tests ...

========================================
Test Summary
========================================
Total Tests: 20
Passed: 20 ✓
Failed: 0 ✗

🎉 All tests passed!
```

### Failed Test Run

```
[TEST 5] Backup script help works
  ✗ FAIL: help flag parsing failed

[TEST 6] Restore script help works
  ✗ FAIL: help flag parsing failed

... details of failures ...

========================================
Test Summary
========================================
Total Tests: 20
Passed: 18 ✓
Failed: 2 ✗

⚠️ Some tests failed. See details above.
```

---

## 🔧 Troubleshooting Tests

### Issue: "command not found: shellcheck"

**Solution:**
```bash
# Install ShellCheck
brew install shellcheck      # macOS
sudo apt install shellcheck  # Linux
docker run koalaman/shellcheck-alpine script.sh  # Docker
```

### Issue: "Permission denied" on tests

**Solution:**
```bash
# Make scripts executable
chmod +x backup-codium.sh
chmod +x restore-codium.sh
chmod +x tests/test-all.sh
```

### Issue: "bash not found"

**Solution:**
```bash
# Check bash availability
which bash
bash --version

# Use absolute path if needed
/bin/bash tests/test-all.sh
```

### Issue: Tests pass locally but fail on GitHub Actions

**Solution:**
1. Check GitHub Actions logs (Actions tab)
2. Look for environment differences
3. Test in similar environment:
   ```bash
   docker run -it ubuntu:latest bash
   # Install dependencies and test
   ```

### Issue: One specific test keeps failing

**Solution:**
```bash
# Run test with verbose output
bash -x tests/test-all.sh 2>&1 | grep -A 5 "failing test name"

# Manually test the feature
./backup-codium.sh --that-flag

# Check for environment issues
echo $SHELL
echo $PATH
```

---

## 📊 Monitoring Tests Over Time

### GitHub Actions History

```
https://github.com/KnowOneActual/backup-vscodium/actions

Shows:
- All workflow runs
- Pass/fail status
- Execution time
- Commit messages
- Branch information
```

### Create Badge (Optional)

Add to README.md:

```markdown
[![Tests](https://github.com/KnowOneActual/backup-vscodium/actions/workflows/test.yml/badge.svg)](https://github.com/KnowOneActual/backup-vscodium/actions)
```

---

## ✅ Testing Checklist

### Before Each Commit

- [ ] Code written/modified
- [ ] Run `bash tests/test-all.sh`
- [ ] All tests pass ✓
- [ ] No ShellCheck warnings
- [ ] Syntax validates
- [ ] Commit with clear message

### Before Each Push

- [ ] All local tests pass
- [ ] Ready to be reviewed
- [ ] Documentation updated
- [ ] No debug code left
- [ ] Push to GitHub

### After Pushing

- [ ] Check GitHub Actions tab
- [ ] Verify all jobs pass ✓
- [ ] Create PR if needed
- [ ] Request review
- [ ] Merge when approved

---

## 📚 Additional Resources

### Documentation
- [README.md](README.md) - Main documentation
- [docs/index.md](docs/index.md) - Documentation index
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines

### Configuration Files
- [.github/workflows/test.yml](.github/workflows/test.yml) - CI/CD pipeline
- [.editorconfig](.editorconfig) - Editor configuration
- [.gitignore](.gitignore) - Git ignore rules

### Test Files
- [tests/test-all.sh](tests/test-all.sh) - Test suite

---

## 🎉 Summary

**Testing is easy and automated:**

1. ✅ **Local:** Run `bash tests/test-all.sh`
2. ✅ **Automatic:** GitHub Actions tests on push
3. ✅ **Pre-commit:** Hook prevents broken commits
4. ✅ **Comprehensive:** 20+ test cases
5. ✅ **Clear:** Detailed pass/fail reporting

**Your code is always tested and validated!** 🚀

---

*Last updated: December 21, 2025*
*Version: 2.0.0*
