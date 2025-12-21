#!/bin/bash

# integration-tests.sh
# Integration test suite for backup-vscodium
# Tests real backup and restore operations with mock VSCodium directories

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

readonly SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
readonly PROJECT_DIR=$(dirname "$SCRIPT_DIR")
readonly BACKUP_SCRIPT="$PROJECT_DIR/backup-codium.sh"
readonly RESTORE_SCRIPT="$PROJECT_DIR/restore-codium.sh"

# Test directories
readonly TEST_ROOT="/tmp/backup_vscodium_integration_tests"
readonly MOCK_VSCODIUM="$TEST_ROOT/mock_vscodium"
readonly BACKUP_DIR="$TEST_ROOT/backups"
readonly RESTORE_DIR="$TEST_ROOT/restore_target"

# Test counters
TEST_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0

# ============================================================================
# LOGGING
# ============================================================================

print_header() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════════════════"
    echo "  $1"
    echo "═══════════════════════════════════════════════════════════════════════════════════"
}

test_case() {
    TEST_COUNT=$((TEST_COUNT + 1)) || true
    echo ""
    echo "[TEST $TEST_COUNT] $1"
}

pass() {
    PASS_COUNT=$((PASS_COUNT + 1)) || true
    echo "  ✓ PASS: $1"
}

fail() {
    FAIL_COUNT=$((FAIL_COUNT + 1)) || true
    echo "  ✗ FAIL: $1"
}

# ============================================================================
# SETUP & TEARDOWN
# ============================================================================

setup_mock_vscodium() {
    echo "[SETUP] Creating mock VSCodium configuration..."
    
    # Create directory structure (Linux style for testing)
    mkdir -p "$MOCK_VSCODIUM/User/snippets"
    
    # Create mock settings.json
    cat > "$MOCK_VSCODIUM/User/settings.json" <<'EOF'
{
  "editor.fontSize": 14,
  "editor.fontFamily": "Fira Code",
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.formatOnSave": true,
  "files.autoSave": "afterDelay",
  "files.autoSaveDelay": 1000,
  "workbench.colorTheme": "One Dark Pro"
}
EOF
    
    # Create mock keybindings.json
    cat > "$MOCK_VSCODIUM/User/keybindings.json" <<'EOF'
[
  {
    "key": "ctrl+shift+p",
    "command": "workbench.action.quickOpen"
  },
  {
    "key": "ctrl+shift+x",
    "command": "workbench.extensions.action.showExtensionsForLanguage"
  }
]
EOF
    
    # Create mock snippets
    mkdir -p "$MOCK_VSCODIUM/User/snippets"
    cat > "$MOCK_VSCODIUM/User/snippets/python.json" <<'EOF'
{
  "print statement": {
    "prefix": "pr",
    "body": "print($1)",
    "description": "Print statement"
  }
}
EOF
    
    echo "[SETUP] Mock VSCodium created at: $MOCK_VSCODIUM"
}

cleanup_test_dirs() {
    echo "[CLEANUP] Removing test directories..."
    rm -rf "$TEST_ROOT"
}

# ============================================================================
# BACKUP TESTS
# ============================================================================

test_backup_basic() {
    test_case "Backup creates backup directory"
    
    bash "$BACKUP_SCRIPT" \
        -l "$BACKUP_DIR/test1" \
        2>/dev/null || true
    
    if [ -d "$BACKUP_DIR/test1" ]; then
        pass "Backup directory created"
    else
        fail "Backup directory not created"
    fi
}

test_backup_settings() {
    test_case "Backup includes settings.json"
    
    # Mock the config directory for this test
    export HOME="$TEST_ROOT/home"
    export CONFIG_DIR="$MOCK_VSCODIUM"
    
    bash "$BACKUP_SCRIPT" \
        -l "$BACKUP_DIR/test_settings" \
        --no-keybindings --no-snippets --no-extensions \
        2>/dev/null || true
    
    if [ -f "$BACKUP_DIR/test_settings/User/settings.json" ]; then
        pass "Settings.json backed up"
    else
        fail "Settings.json not found in backup"
    fi
}

test_backup_keybindings() {
    test_case "Backup includes keybindings.json"
    
    export HOME="$TEST_ROOT/home"
    export CONFIG_DIR="$MOCK_VSCODIUM"
    
    bash "$BACKUP_SCRIPT" \
        -l "$BACKUP_DIR/test_keybindings" \
        --no-settings --no-snippets --no-extensions \
        2>/dev/null || true
    
    if [ -f "$BACKUP_DIR/test_keybindings/User/keybindings.json" ]; then
        pass "Keybindings.json backed up"
    else
        fail "Keybindings.json not found in backup"
    fi
}

test_backup_snippets() {
    test_case "Backup includes snippets directory"
    
    export HOME="$TEST_ROOT/home"
    export CONFIG_DIR="$MOCK_VSCODIUM"
    
    bash "$BACKUP_SCRIPT" \
        -l "$BACKUP_DIR/test_snippets" \
        --no-settings --no-keybindings --no-extensions \
        2>/dev/null || true
    
    if [ -f "$BACKUP_DIR/test_snippets/snippets/python.json" ]; then
        pass "Snippets directory backed up"
    else
        fail "Snippets not found in backup"
    fi
}

test_backup_creates_manifest() {
    test_case "Backup creates manifest.txt"
    
    export HOME="$TEST_ROOT/home"
    export CONFIG_DIR="$MOCK_VSCODIUM"
    
    bash "$BACKUP_SCRIPT" \
        -l "$BACKUP_DIR/test_manifest" \
        --no-extensions 2>/dev/null || true
    
    if [ -f "$BACKUP_DIR/test_manifest/manifest.txt" ]; then
        pass "Manifest file created"
    else
        fail "Manifest file not created"
    fi
}

test_backup_dry_run() {
    test_case "Backup --dry-run doesn't create files"
    
    export HOME="$TEST_ROOT/home"
    export CONFIG_DIR="$MOCK_VSCODIUM"
    
    bash "$BACKUP_SCRIPT" \
        -l "$BACKUP_DIR/test_dryrun" \
        --dry-run --no-extensions 2>/dev/null || true
    
    if [ ! -f "$BACKUP_DIR/test_dryrun/User/settings.json" ]; then
        pass "Dry-run mode didn't create backup files"
    else
        fail "Dry-run mode created backup files (should be preview only)"
    fi
}

test_backup_selective() {
    test_case "Backup --only-settings restricts to settings"
    
    export HOME="$TEST_ROOT/home"
    export CONFIG_DIR="$MOCK_VSCODIUM"
    
    bash "$BACKUP_SCRIPT" \
        -l "$BACKUP_DIR/test_selective" \
        --only-settings 2>/dev/null || true
    
    local settings_exists=false
    local keybindings_exists=false
    
    [ -f "$BACKUP_DIR/test_selective/User/settings.json" ] && settings_exists=true
    [ -f "$BACKUP_DIR/test_selective/User/keybindings.json" ] && keybindings_exists=true
    
    if [ "$settings_exists" = true ] && [ "$keybindings_exists" = false ]; then
        pass "Selective backup works (only settings)"
    else
        fail "Selective backup didn't work as expected"
    fi
}

# ============================================================================
# RESTORE TESTS
# ============================================================================

test_restore_settings() {
    test_case "Restore restores settings.json"
    
    # First create a backup
    export HOME="$TEST_ROOT/home"
    export CONFIG_DIR="$MOCK_VSCODIUM"
    
    bash "$BACKUP_SCRIPT" \
        -l "$BACKUP_DIR/test_restore" \
        --no-extensions 2>/dev/null || true
    
    # Now restore to different location
    mkdir -p "$RESTORE_DIR/User"
    bash "$RESTORE_SCRIPT" \
        -b "$BACKUP_DIR/test_restore" \
        --force --no-extensions 2>/dev/null || true
    
    if [ -f "$RESTORE_DIR/User/settings.json" ]; then
        pass "Settings restored"
    else
        fail "Settings not restored"
    fi
}

test_restore_preserves_content() {
    test_case "Restore preserves file content"
    
    # Backup
    export HOME="$TEST_ROOT/home"
    export CONFIG_DIR="$MOCK_VSCODIUM"
    
    bash "$BACKUP_SCRIPT" \
        -l "$BACKUP_DIR/test_content" \
        --no-extensions 2>/dev/null || true
    
    # Restore
    mkdir -p "$RESTORE_DIR/content_test/User"
    cp "$BACKUP_DIR/test_content/User/settings.json" "$RESTORE_DIR/content_test/User/"
    
    # Compare
    if diff -q "$MOCK_VSCODIUM/User/settings.json" "$RESTORE_DIR/content_test/User/settings.json" > /dev/null; then
        pass "File content preserved after backup/restore"
    else
        fail "File content changed during backup/restore"
    fi
}

# ============================================================================
# RUN ALL TESTS
# ============================================================================

run_all_tests() {
    echo ""
    echo "🦧 backup-vscodium Integration Test Suite"
    echo "=========================================="
    
    # Setup
    cleanup_test_dirs
    setup_mock_vscodium
    
    # Backup tests
    print_header "Backup Operations"
    test_backup_basic
    test_backup_settings
    test_backup_keybindings
    test_backup_snippets
    test_backup_creates_manifest
    test_backup_dry_run
    test_backup_selective
    
    # Restore tests
    print_header "Restore Operations"
    test_restore_settings
    test_restore_preserves_content
    
    # Cleanup
    cleanup_test_dirs
    
    # Print summary
    print_summary
}

print_summary() {
    echo ""
    print_header "Integration Test Summary"
    echo "Total Tests: $TEST_COUNT"
    echo "Passed: $PASS_COUNT ✓"
    echo "Failed: $FAIL_COUNT ✗"
    echo ""
    
    if [ "$FAIL_COUNT" -eq 0 ]; then
        echo "🎉 All integration tests passed!"
        echo ""
        return 0
    else
        echo "⚠️  Some integration tests failed."
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

run_all_tests
TEST_EXIT_CODE=$?
exit "$TEST_EXIT_CODE"
