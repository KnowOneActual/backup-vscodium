# Troubleshooting Guide - backup-vscodium Test Failures

## Issues Identified & Fixed

### Issue #1: ShellCheck SC2155 Warnings ✅ FIXED

**Problem:**  
All three scripts had `readonly` declarations with assignments on the same line, triggering SC2155: "Declare and assign separately to avoid masking return values"

**Root Cause:**  
ShellCheck wants variable declaration separate from assignment to prevent function return values from being masked if the command fails.

**Solution Applied:**  
All three scripts now use separated assignment and readonly:
```bash
VAR=$(command)
readonly VAR
```

**Files Fixed:**
- ✅ backup-codium.sh (lines 13-14)
- ✅ restore-codium.sh (lines 13-14)
- ✅ tests/test-all.sh (lines 13-19) - **JUST FIXED**

---

### Issue #2: Unit Tests Exit Code 1 - STILL FAILING ❌

**Symptom:**  
Test suite exits immediately with code 1 at "Script Existence Tests" stage without running any tests.

**Likely Root Cause:**  
The test script constructs paths that don't exist:
```bash
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)  # /home/runner/work/backup-vscodium/backup-vscodium/tests
PROJECT_DIR=$(dirname "$SCRIPT_DIR")                        # /home/runner/work/backup-vscodium/backup-vscodium
BACKUP_SCRIPT="$PROJECT_DIR/backup-codium.sh"             # Should exist here
RESTORE_SCRIPT="$PROJECT_DIR/restore-codium.sh"           # Should exist here
```

The test expects scripts at:
- `/home/runner/work/backup-vscodium/backup-vscodium/backup-codium.sh`
- `/home/runner/work/backup-vscodium/backup-vscodium/restore-codium.sh`

**Why it's happening:**  
One of the test functions is failing during setup or the first test, causing the whole suite to exit with `set -euo pipefail` enabled.

---

## Debugging Data Needed

### To Fix Unit Tests Issue

Add debug output to `tests/test-all.sh` right after `setup_test_env()` call (around line 105 in `run_all_tests()`):

```bash
echo "DEBUG: Environment Setup"
echo "  Working Directory: $(pwd)"
echo "  SCRIPT_DIR: $SCRIPT_DIR"
echo "  PROJECT_DIR: $PROJECT_DIR"
echo "  BACKUP_SCRIPT path: $BACKUP_SCRIPT"
echo "  RESTORE_SCRIPT path: $RESTORE_SCRIPT"
echo ""
echo "DEBUG: File Existence Checks"
test -f "$BACKUP_SCRIPT" && echo "  ✓ $BACKUP_SCRIPT exists" || echo "  ✗ $BACKUP_SCRIPT NOT FOUND"
test -f "$RESTORE_SCRIPT" && echo "  ✓ $RESTORE_SCRIPT exists" || echo "  ✗ $RESTORE_SCRIPT NOT FOUND"
echo ""
```

This will show **exactly** what paths are being constructed and whether the files exist.

---

## Current Status

| Check | Status | Details |
|-------|--------|----------|
| **ShellCheck** | ❌ FAILED | SC2155 in test-all.sh lines 14-15 (JUST FIXED) |
| **Unit Tests** | ❌ FAILED | Tests exit at "Script Existence Tests" |
| **Test Summary** | ⚠️ MISLEADING | Shows "Passed" but deps failed |

---

## Next Steps

1. **Push latest fixes** (test-all.sh SC2155 fix)
2. **Run GitHub Actions** to trigger new workflow
3. **Review ShellCheck results** - should now PASS ✓
4. **Check Unit Tests output** - look for path construction issues
5. **Add debug output** if needed and re-run

---

## Expected Success Output

When all tests pass:

```
✓ All checks completed
✓ ShellCheck: Passed
✓ Syntax Check: Passed
✓ Unit Tests: Passed
✓ Help Output: Passed
✓ Dry-Run: Completed
✓ Code Quality: Checked
```

---

## Questions for Next Debug Session

When you run the next workflow, answer these:

1. **Does ShellCheck now PASS?** (SC2155 should be gone)
2. **At what exact line does Unit Tests fail?**
3. **What's the exact error message?**
4. **Do you see any DEBUG output if we add it?**
5. **Are the file paths being constructed correctly?**

Share the full workflow log and we'll pinpoint the exact issue! 🚀
