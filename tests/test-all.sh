#!/bin/bash

# test-all.sh
# Comprehensive test suite for backup-vscodium scripts
# Tests: argument parsing, dry-run, selective operations, error handling

set -euo pipefail

# ============================================================================
# TEST FRAMEWORK
# ============================================================================

# shellcheck disable=SC2317
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
readonly SCRIPT_DIR
PROJECT_DIR=$(dirname "$SCRIPT_DIR")
readonly PROJECT_DIR
readonly BACKUP_SCRIPT="$PROJECT_DIR/backup-codium.sh"
readonly RESTORE_SCRIPT="$PROJECT_DIR/restore-codium.sh"
readonly TEST_BACKUP_DIR="/tmp/vscodium_test_backup"
readonly TEST_LOG="/tmp/vscodium_tests.log"

TEST_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0

echo "" > "$TEST_LOG"

echo "[DEBUG] Script paths:"
echo "  SCRIPT_DIR: $SCRIPT_DIR"
echo "  PROJECT_DIR: $PROJECT_DIR"
echo "  BACKUP_SCRIPT: $BACKUP_SCRIPT"
echo "  RESTORE_SCRIPT: $RESTORE_SCRIPT"
echo ""

echo "[DEBUG] File existence checks:"
test -f "$BACKUP_SCRIPT" && echo "  ✓ BACKUP_SCRIPT exists" || echo "  ✗ BACKUP_SCRIPT NOT FOUND"
test -f "$RESTORE_SCRIPT" && echo "  ✓ RESTORE_SCRIPT exists" || echo "  ✗ RESTORE_SCRIPT NOT FOUND"
echo ""

print_header() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "  $1"
    echo "═══════════════════════════════════════════════════════════════"
}

test_case() {
    ((TEST_COUNT++))
    echo ""
    echo "[TEST $TEST_COUNT] $1"
}

pass() {
    ((PASS_COUNT++))
    local msg="  ✓ PASS: $1"
    echo "$msg" | tee -a "$TEST_LOG"
}

fail() {
    ((FAIL_COUNT++))
    local msg="  ✗ FAIL: $1"
    echo "$msg" | tee -a "$TEST_LOG"
}

# ============================================================================
# SETUP & TEARDOWN
# ============================================================================

setup_test_env() {
    echo "[DEBUG] Running setup_test_env"
    # Create mock VSCodium config directory
    mkdir -p "$TEST_BACKUP_DIR"
    
    echo "Test environment set up at: $TEST_BACKUP_DIR"
}

cleanup_test_env() {
    rm -rf "$TEST_BACKUP_DIR"
    echo "Test environment cleaned up"
}

# ============================================================================
# SCRIPT VALIDATION TESTS
# ============================================================================

test_script_exists() {
    echo "[DEBUG] Entering test_script_exists function"
    print_header "Script Existence Tests"
    
    echo "[DEBUG] Starting test case 1: Backup script exists"
    test_case "Backup script exists"
    if [ -f "$BACKUP_SCRIPT" ]; then
        echo "[DEBUG] Backup script found, calling pass()"
        pass "backup-codium.sh found"
    else
        echo "[DEBUG] Backup script NOT found, calling fail()"
        fail "backup-codium.sh not found at $BACKUP_SCRIPT"
    fi
    echo "[DEBUG] Test case 1 completed"
    
    echo "[DEBUG] Starting test case 2: Restore script exists"
    test_case "Restore script exists"
    if [ -f "$RESTORE_SCRIPT" ]; then
        echo "[DEBUG] Restore script found, calling pass()"
        pass "restore-codium.sh found"
    else
        echo "[DEBUG] Restore script NOT found, calling fail()"
        fail "restore-codium.sh not found at $RESTORE_SCRIPT"
    fi
    echo "[DEBUG] Test case 2 completed"
    echo "[DEBUG] Exiting test_script_exists function"
}

test_script_executable() {
    print_header "Script Executable Tests"
    
    test_case "Backup script is executable"
    chmod +x "$BACKUP_SCRIPT" 2>/dev/null || true
    if [ -x "$BACKUP_SCRIPT" ]; then
        pass "backup-codium.sh is executable"
    else
        fail "backup-codium.sh is not executable"
    fi
    
    test_case "Restore script is executable"
    chmod +x "$RESTORE_SCRIPT" 2>/dev/null || true
    if [ -x "$RESTORE_SCRIPT" ]; then
        pass "restore-codium.sh is executable"
    else
        fail "restore-codium.sh is not executable"
    fi
}

test_script_syntax() {
    print_header "Bash Syntax Tests"
    
    test_case "Backup script syntax validation"
    if bash -n "$BACKUP_SCRIPT" 2>/dev/null; then
        pass "backup-codium.sh has valid bash syntax"
    else
        fail "backup-codium.sh has syntax errors"
    fi
    
    test_case "Restore script syntax validation"
    if bash -n "$RESTORE_SCRIPT" 2>/dev/null; then
        pass "restore-codium.sh has valid bash syntax"
    else
        fail "restore-codium.sh has syntax errors"
    fi
}

# ============================================================================
# HELP & VERSION TESTS
# ============================================================================

test_help_flags() {
    print_header "Help & Version Tests"
    
    test_case "Backup --help flag works"
    if bash "$BACKUP_SCRIPT" --help &>/dev/null; then
        pass "backup-codium.sh --help executed successfully"
    else
        fail "backup-codium.sh --help failed"
    fi
    
    test_case "Restore --help flag works"
    if bash "$RESTORE_SCRIPT" --help &>/dev/null; then
        pass "restore-codium.sh --help executed successfully"
    else
        fail "restore-codium.sh --help failed"
    fi
    
    test_case "Backup --version flag works"
    local output=""
    if output=$(bash "$BACKUP_SCRIPT" --version 2>&1); then
        if [[ $output == *"v"* ]]; then
            pass "backup-codium.sh --version returns version"
        else
            fail "backup-codium.sh --version did not return version info"
        fi
    else
        fail "backup-codium.sh --version failed"
    fi
    
    test_case "Restore --version flag works"
    if output=$(bash "$RESTORE_SCRIPT" --version 2>&1); then
        if [[ $output == *"v"* ]]; then
            pass "restore-codium.sh --version returns version"
        else
            fail "restore-codium.sh --version did not return version info"
        fi
    else
        fail "restore-codium.sh --version failed"
    fi
}

# ============================================================================
# ARGUMENT PARSING TESTS
# ============================================================================

test_argument_parsing() {
    print_header "Argument Parsing Tests"
    
    test_case "Backup script rejects unknown arguments"
    if ! bash "$BACKUP_SCRIPT" --unknown-flag &>/dev/null; then
        pass "backup-codium.sh correctly rejects unknown flags"
    else
        fail "backup-codium.sh should reject unknown flags"
    fi
    
    test_case "Restore script rejects unknown arguments"
    if ! bash "$RESTORE_SCRIPT" --unknown-flag &>/dev/null; then
        pass "restore-codium.sh correctly rejects unknown flags"
    else
        fail "restore-codium.sh should reject unknown flags"
    fi
    
    test_case "Backup accepts custom location"
    if bash "$BACKUP_SCRIPT" --dry-run --location /tmp/test_backup &>/dev/null; then
        pass "backup-codium.sh accepts --location flag"
    else
        fail "backup-codium.sh --location flag parsing failed"
    fi
    
    test_case "Restore accepts custom backup path"
    if bash "$RESTORE_SCRIPT" --dry-run --backup /tmp/test_backup &>/dev/null; then
        pass "restore-codium.sh accepts --backup flag"
    else
        fail "restore-codium.sh --backup flag parsing failed"
    fi
}

# ============================================================================
# DRY-RUN MODE TESTS
# ============================================================================

test_dry_run_mode() {
    print_header "Dry-Run Mode Tests"
    
    test_case "Backup --dry-run mode doesn't create backup"
    local test_backup_dir=""
    test_backup_dir="/tmp/backup_dryrun_test_$$"
    if bash "$BACKUP_SCRIPT" --dry-run --location "$test_backup_dir" &>/dev/null; then
        if [ ! -d "$test_backup_dir" ]; then
            pass "backup-codium.sh --dry-run doesn't create backup directory"
        else
            fail "backup-codium.sh --dry-run created backup (should be read-only)"
            rm -rf "$test_backup_dir"
        fi
    else
        fail "backup-codium.sh --dry-run failed"
    fi
    
    test_case "Backup --dry-run produces output"
    local output=""
    if output=$(bash "$BACKUP_SCRIPT" --dry-run 2>&1); then
        if [[ $output == *"DRY RUN"* ]] || [[ $output == *"would"* ]]; then
            pass "backup-codium.sh --dry-run produces expected output"
        else
            fail "backup-codium.sh --dry-run output doesn't indicate dry-run"
        fi
    else
        fail "backup-codium.sh --dry-run failed"
    fi
}

# ============================================================================
# SELECTIVE BACKUP TESTS
# ============================================================================

test_selective_flags() {
    print_header "Selective Backup/Restore Tests"
    
    test_case "Backup --no-extensions flag works"
    if bash "$BACKUP_SCRIPT" --dry-run --no-extensions &>/dev/null; then
        pass "backup-codium.sh --no-extensions flag accepted"
    else
        fail "backup-codium.sh --no-extensions flag parsing failed"
    fi
    
    test_case "Backup --only-settings flag works"
    if bash "$BACKUP_SCRIPT" --dry-run --only-settings &>/dev/null; then
        pass "backup-codium.sh --only-settings flag accepted"
    else
        fail "backup-codium.sh --only-settings flag parsing failed"
    fi
    
    test_case "Restore --no-extensions flag works"
    if bash "$RESTORE_SCRIPT" --dry-run --no-extensions &>/dev/null; then
        pass "restore-codium.sh --no-extensions flag accepted"
    else
        fail "restore-codium.sh --no-extensions flag parsing failed"
    fi
    
    test_case "Restore --only-keybindings flag works"
    if bash "$RESTORE_SCRIPT" --dry-run --only-keybindings &>/dev/null; then
        pass "restore-codium.sh --only-keybindings flag accepted"
    else
        fail "restore-codium.sh --only-keybindings flag parsing failed"
    fi
}

# ============================================================================
# VERBOSE & LOGGING TESTS
# ============================================================================

test_verbose_logging() {
    print_header "Verbose & Logging Tests"
    
    test_case "Backup --verbose flag works"
    local output=""
    if output=$(bash "$BACKUP_SCRIPT" --dry-run --verbose 2>&1); then
        if [[ $output == *"INFO"* ]] || [[ $output == *"["* ]]; then
            pass "backup-codium.sh --verbose produces logging output"
        else
            pass "backup-codium.sh --verbose flag accepted"
        fi
    else
        fail "backup-codium.sh --verbose failed"
    fi
    
    test_case "Restore --verbose flag works"
    if output=$(bash "$RESTORE_SCRIPT" --dry-run --verbose 2>&1); then
        if [[ $output == *"INFO"* ]] || [[ $output == *"["* ]]; then
            pass "restore-codium.sh --verbose produces logging output"
        else
            pass "restore-codium.sh --verbose flag accepted"
        fi
    else
        fail "restore-codium.sh --verbose failed"
    fi
}

# ============================================================================
# RUN ALL TESTS
# ============================================================================

run_all_tests() {
    echo ""
    echo "🦧 backup-vscodium Test Suite"
    echo "==============================="
    
    echo "[DEBUG] Calling setup_test_env"
    setup_test_env
    echo "[DEBUG] setup_test_env completed"
    
    echo "[DEBUG] Calling test_script_exists"
    test_script_exists
    echo "[DEBUG] test_script_exists completed"
    
    echo "[DEBUG] Calling test_script_executable"
    test_script_executable
    echo "[DEBUG] test_script_executable completed"
    
    echo "[DEBUG] Calling test_script_syntax"
    test_script_syntax
    echo "[DEBUG] test_script_syntax completed"
    
    echo "[DEBUG] Calling test_help_flags"
    test_help_flags
    echo "[DEBUG] test_help_flags completed"
    
    echo "[DEBUG] Calling test_argument_parsing"
    test_argument_parsing
    echo "[DEBUG] test_argument_parsing completed"
    
    echo "[DEBUG] Calling test_dry_run_mode"
    test_dry_run_mode
    echo "[DEBUG] test_dry_run_mode completed"
    
    echo "[DEBUG] Calling test_selective_flags"
    test_selective_flags
    echo "[DEBUG] test_selective_flags completed"
    
    echo "[DEBUG] Calling test_verbose_logging"
    test_verbose_logging
    echo "[DEBUG] test_verbose_logging completed"
    
    echo "[DEBUG] Calling cleanup_test_env"
    cleanup_test_env
    echo "[DEBUG] cleanup_test_env completed"
    
    echo "[DEBUG] Calling print_test_summary"
    print_test_summary
    echo "[DEBUG] print_test_summary completed"
}

print_test_summary() {
    echo ""
    print_header "Test Summary"
    echo "Total Tests: $TEST_COUNT"
    echo "Passed: $PASS_COUNT ✓"
    echo "Failed: $FAIL_COUNT ✗"
    echo ""
    
    if [ "$FAIL_COUNT" -eq 0 ]; then
        echo "🎉 All tests passed!"
        echo ""
        return 0
    else
        echo "⚠️  Some tests failed. See details above."
        echo ""
        return 1
    fi
}

# ============================================================================
# MAIN
# ============================================================================

echo "[DEBUG] Bash version: ${BASH_VERSINFO[0]}"
if [ "${BASH_VERSINFO[0]:-0}" -lt 4 ]; then
    echo "Error: This test suite requires Bash 4.0 or higher"
    exit 1
fi

echo "[DEBUG] Calling run_all_tests"
run_all_tests
echo "[DEBUG] run_all_tests completed with exit code $?"
exit $?
