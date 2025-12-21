#!/bin/bash

# test-all.sh
# Comprehensive test suite for backup-vscodium scripts
# Tests: basic functionality, help, version, error handling

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
    echo "═══════════════════════════════════════════════════════════════════════════════════"
    echo "  $1"
    echo "═══════════════════════════════════════════════════════════════════════════════════"
}

test_case() {
    # Increment counter safely
    TEST_COUNT=$((TEST_COUNT + 1)) || true
    echo ""
    echo "[TEST $TEST_COUNT] $1"
}

pass() {
    # Increment counter safely
    PASS_COUNT=$((PASS_COUNT + 1)) || true
    local msg="  ✓ PASS: $1"
    echo "$msg" | tee -a "$TEST_LOG"
}

fail() {
    # Increment counter safely
    FAIL_COUNT=$((FAIL_COUNT + 1)) || true
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
# ERROR HANDLING TESTS
# ============================================================================

test_argument_validation() {
    print_header "Error Handling Tests"
    
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
    
    echo "[DEBUG] Calling test_argument_validation"
    test_argument_validation
    echo "[DEBUG] test_argument_validation completed"
    
    echo "[DEBUG] Calling cleanup_test_env"
    cleanup_test_env
    echo "[DEBUG] cleanup_test_env completed"
    
    echo "[DEBUG] Calling print_test_summary"
    print_test_summary
    echo "[DEBUG] print_test_summary completed with exit code $?"
}

print_test_summary() {
    local exit_code=0
    
    echo ""
    print_header "Test Summary"
    echo "Total Tests: $TEST_COUNT"
    echo "Passed: $PASS_COUNT ✓"
    echo "Failed: $FAIL_COUNT ✗"
    echo ""
    
    if [ "$FAIL_COUNT" -eq 0 ]; then
        echo "🎉 All tests passed!"
        echo ""
        exit_code=0
    else
        echo "⚠️  Some tests failed. See details above."
        echo ""
        exit_code=1
    fi
    
    return "$exit_code"
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
TEST_EXIT_CODE=$?
echo "[DEBUG] run_all_tests completed with exit code $TEST_EXIT_CODE"
exit "$TEST_EXIT_CODE"
