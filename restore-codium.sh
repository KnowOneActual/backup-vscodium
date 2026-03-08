#!/bin/bash

# restore-codium.sh
# A robust script to restore VSCodium settings from a backup.
# Includes validation via checksums, dry-run mode, selective restore, safety prompts, and archive support.

set -euo pipefail

# ============================================================================
# CONFIGURATION & DEFAULTS
# ============================================================================

SCRIPT_VERSION="2.1.0"
readonly SCRIPT_VERSION
SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_NAME

# Default backup location
DEFAULT_BACKUP_DIR="$HOME/Documents/VSCodium_Backup"
BACKUP_DIR="$DEFAULT_BACKUP_DIR"

# Logging
LOG_FILE=""
VERBOSE=false
DRY_RUN=false
FORCE=false
IS_ARCHIVE=false
TEMP_DIR=""

# Restore options
RESTORE_SETTINGS=true
RESTORE_KEYBINDINGS=true
RESTORE_SNIPPETS=true
RESTORE_EXTENSIONS=true
VERIFY_CHECKSUMS=true

# Detected OS
OS_NAME=""
CONFIG_DIR=""

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

print_help() {
    cat <<EOF
$SCRIPT_NAME v$SCRIPT_VERSION - Restore your VSCodium configuration from backup

USAGE:
    $SCRIPT_NAME [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    -v, --version           Show script version
    --verbose               Enable verbose output
    --dry-run               Preview what would be restored without copying
    -b, --backup PATH       Path to backup folder OR .tar.gz/.zip archive
    -f, --force             Skip confirmation prompts
    --skip-verify           Don't verify checksums before restoring
    
SELECTIVE RESTORE OPTIONS:
    --only-settings         Restore only settings.json
    --only-keybindings      Restore only keybindings.json
    --only-snippets         Restore only snippets directory
    --only-extensions       Restore only extensions list
    --no-settings           Exclude settings.json
    --no-keybindings        Exclude keybindings.json
    --no-snippets           Exclude snippets directory
    --no-extensions         Exclude extensions list

EXAMPLES:
    # Restore everything from default location (interactive)
    $SCRIPT_NAME

    # Restore from a compressed archive (Easy Mode)
    $SCRIPT_NAME --backup ~/Downloads/VSCodium_Backup.tar.gz

    # Restore from custom backup folder
    $SCRIPT_NAME --backup ~/Dropbox/VSCodium_Backup

    # Dry run to preview restore
    $SCRIPT_NAME --dry-run
EOF
}

log() {
    local message="$1"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    
    if [ -n "$LOG_FILE" ]; then
        echo "[$timestamp] $message" >> "$LOG_FILE"
    fi
    
    if [ "$VERBOSE" = true ]; then
        echo "[INFO] $message"
    fi
}

log_error() {
    local message="$1"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    
    if [ -n "$LOG_FILE" ]; then
        echo "[$timestamp] ERROR: $message" >> "$LOG_FILE"
    fi
    
    echo "✗ ERROR: $message" >&2
}

log_success() {
    local message="$1"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    
    if [ -n "$LOG_FILE" ]; then
        echo "[$timestamp] SUCCESS: $message" >> "$LOG_FILE"
    fi
    
    if [ "$VERBOSE" = true ]; then
        echo "✓ $message"
    fi
}

log_warning() {
    local message="$1"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    
    if [ -n "$LOG_FILE" ]; then
        echo "[$timestamp] WARNING: $message" >> "$LOG_FILE"
    fi
    
    echo "⚠ WARNING: $message"
}

detect_os() {
    OS_NAME=$(uname -s)
    
    case "$OS_NAME" in
        Darwin)
            CONFIG_DIR="$HOME/Library/Application Support/VSCodium"
            log "Detected macOS. Config path: $CONFIG_DIR"
            ;;
        Linux)
            CONFIG_DIR="$HOME/.config/VSCodium"
            log "Detected Linux. Config path: $CONFIG_DIR"
            ;;
        *)
            log_error "Unsupported OS: $OS_NAME"
            log_error "Currently supported: macOS, Linux"
            exit 1
            ;;
    esac
}

validate_backup_location() {
    # Handle Archives
    if [ -f "$BACKUP_DIR" ]; then
        if [[ "$BACKUP_DIR" == *.tar.gz ]] || [[ "$BACKUP_DIR" == *.tgz ]] || [[ "$BACKUP_DIR" == *.zip ]]; then
            IS_ARCHIVE=true
            log "Detected backup archive: $BACKUP_DIR"
            return 0
        else
            log_error "File found at backup path, but not a recognized archive format (.tar.gz, .tgz, .zip)"
            exit 1
        fi
    fi

    # Handle Directories
    if [ ! -d "$BACKUP_DIR" ]; then
        log_error "Backup directory/file not found: $BACKUP_DIR"
        exit 1
    fi
    
    # Check if this looks like a valid backup
    if [ ! -f "$BACKUP_DIR/extensions.txt" ] && [ ! -f "$BACKUP_DIR/User/settings.json" ]; then
        log_warning "Backup directory may be invalid - no typical backup files found"
    fi
    
    log "Backup location validated: $BACKUP_DIR"
}

extract_archive() {
    if [ "$DRY_RUN" = true ]; then
        log "[DRY-RUN] Would extract archive: $BACKUP_DIR"
        return 0
    fi
    
    TEMP_DIR=$(mktemp -d)
    log "Extracting archive to temporary location: $TEMP_DIR"
    
    if [[ "$BACKUP_DIR" == *.zip ]]; then
        if ! command -v unzip &> /dev/null; then
            log_error "'unzip' command not found, cannot extract .zip archive"
            rm -rf "$TEMP_DIR"
            exit 1
        fi
        unzip -q "$BACKUP_DIR" -d "$TEMP_DIR"
    else
        tar -xzf "$BACKUP_DIR" -C "$TEMP_DIR"
    fi
    
    # Handle archives that contain a root folder (e.g. VSCodium_Backup_...)
    # We look for the first directory that looks like a backup, or just use the extraction root
    local extracted_root
    extracted_root=$(find "$TEMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1)
    
    if [ -z "$extracted_root" ]; then
        # No subdirectory, assume flat archive
        extracted_root="$TEMP_DIR"
    fi
    
    # Point BACKUP_DIR to the extracted content
    BACKUP_DIR="$extracted_root"
    log "Backup extracted to: $BACKUP_DIR"
}

cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        log "Cleaning up temporary files..."
        rm -rf "$TEMP_DIR"
    fi
}

check_codium_command() {
    if ! command -v codium &> /dev/null; then
        log_warning "'codium' command not found in PATH"
        log_warning "Extension restore will be skipped"
        RESTORE_EXTENSIONS=false
        return 1
    fi
    return 0
}

verify_checksums() {
    local checksums_file="$BACKUP_DIR/backup.sha256"
    
    if [ ! -f "$checksums_file" ]; then
        log_warning "No checksum file found, skipping verification"
        return 0
    fi
    
    if ! command -v sha256sum &> /dev/null; then
        log_warning "sha256sum not available, skipping verification"
        return 0
    fi
    
    echo "Verifying backup integrity..."
    
    cd "$BACKUP_DIR" || return 1
    
    if sha256sum -c "$checksums_file" &> /dev/null; then
        log_success "All files verified successfully"
        echo "✓ Backup integrity verified"
        cd - > /dev/null
        return 0
    else
        log_error "Checksum verification failed - backup may be corrupted"
        echo "✗ WARNING: Backup integrity check FAILED"
        cd - > /dev/null
        return 1
    fi
}

prompt_confirmation() {
    local message="$1"
    
    if [ "$FORCE" = true ]; then
        log "Skipping confirmation (--force enabled)"
        return 0
    fi
    
    read -p "$message (yes/no): " -r response
    
    if [[ "$response" == "yes" ]] || [[ "$response" == "y" ]]; then
        return 0
    else
        return 1
    fi
}

# ============================================================================
# ARGUMENT PARSING
# ============================================================================

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                print_help
                exit 0
                ;;
            -v|--version)
                echo "$SCRIPT_NAME v$SCRIPT_VERSION"
                exit 0
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            -b|--backup)
                BACKUP_DIR="$2"
                shift 2
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            --skip-verify)
                VERIFY_CHECKSUMS=false
                shift
                ;;
            --only-settings)
                RESTORE_KEYBINDINGS=false
                RESTORE_SNIPPETS=false
                RESTORE_EXTENSIONS=false
                shift
                ;;
            --only-keybindings)
                RESTORE_SETTINGS=false
                RESTORE_SNIPPETS=false
                RESTORE_EXTENSIONS=false
                shift
                ;;
            --only-snippets)
                RESTORE_SETTINGS=false
                RESTORE_KEYBINDINGS=false
                RESTORE_EXTENSIONS=false
                shift
                ;;
            --only-extensions)
                RESTORE_SETTINGS=false
                RESTORE_KEYBINDINGS=false
                RESTORE_SNIPPETS=false
                shift
                ;;
            --no-settings)
                RESTORE_SETTINGS=false
                shift
                ;;
            --no-keybindings)
                RESTORE_KEYBINDINGS=false
                shift
                ;;
            --no-snippets)
                RESTORE_SNIPPETS=false
                shift
                ;;
            --no-extensions)
                RESTORE_EXTENSIONS=false
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

# ============================================================================
# RESTORE OPERATIONS
# ============================================================================

restore_file() {
    local source_file="$1"
    local dest_dir="$2"
    local file_name
    file_name="$(basename "$source_file")"
    
    if [ ! -f "$source_file" ]; then
        log_warning "File not found in backup, skipping: $file_name"
        return 1
    fi
    
    if [ "$DRY_RUN" = true ]; then
        log "[DRY-RUN] Would restore: $file_name -> $dest_dir/"
        return 0
    fi
    
    mkdir -p "$dest_dir"
    cp "$source_file" "$dest_dir/" 2>/dev/null || {
        log_error "Failed to restore: $file_name"
        return 1
    }
    
    log_success "Restored: $file_name"
    return 0
}

restore_directory() {
    local source_dir="$1"
    local dest_dir="$2"
    local dir_name
    dir_name="$(basename "$source_dir")"
    
    if [ ! -d "$source_dir" ]; then
        log_warning "Directory not found in backup, skipping: $dir_name"
        return 1
    fi
    
    if [ "$DRY_RUN" = true ]; then
        local file_count
        file_count=$(find "$source_dir" -type f | wc -l)
        log "[DRY-RUN] Would restore $dir_name ($file_count files) -> $dest_dir/"
        return 0
    fi
    
    mkdir -p "$dest_dir"
    cp -r "$source_dir/." "$dest_dir/" 2>/dev/null || {
        log_error "Failed to restore directory: $dir_name"
        return 1
    }
    
    log_success "Restored directory: $dir_name"
    return 0
}

restore_extensions() {
    local extensions_file="$BACKUP_DIR/extensions.txt"
    
    if [ ! -f "$extensions_file" ]; then
        log_warning "Extensions list not found in backup"
        return 1
    fi
    
    if ! command -v codium &> /dev/null; then
        log_warning "'codium' command not available, cannot restore extensions"
        return 1
    fi
    
    local ext_count
    ext_count=$(wc -l < "$extensions_file")
    
    if [ "$DRY_RUN" = true ]; then
        log "[DRY-RUN] Would install $ext_count extensions from backup"
        return 0
    fi
    
    echo "Installing extensions from backup..."
    
    local failed=0
    local installed=0
    
    while IFS= read -r extension; do
        if [ -z "$extension" ]; then
            continue
        fi
        
        if codium --install-extension "$extension" &> /dev/null; then
            log_success "Installed: $extension"
            ((installed++))
        else
            log_error "Failed to install: $extension"
            ((failed++))
        fi
    done < "$extensions_file"
    
    echo "Extension install complete: $installed installed, $failed failed"
    log "Extension installation summary: $installed installed, $failed failed"
    
    return 0
}

print_summary() {
    local settings_status="[✓]"
    [ "$RESTORE_SETTINGS" != true ] && settings_status="[✗]"
    
    local keybindings_status="[✓]"
    [ "$RESTORE_KEYBINDINGS" != true ] && keybindings_status="[✗]"
    
    local snippets_status="[✓]"
    [ "$RESTORE_SNIPPETS" != true ] && snippets_status="[✗]"
    
    local extensions_status="[✓]"
    [ "$RESTORE_EXTENSIONS" != true ] && extensions_status="[✗]"
    
    echo ""
    echo "========================================"
    echo "         RESTORE SUMMARY"
    echo "========================================"
    echo "From: $BACKUP_DIR"
    echo "To: $CONFIG_DIR"
    echo ""
    echo "Components:"
    echo "  $settings_status Settings"
    echo "  $keybindings_status Keybindings"
    echo "  $snippets_status Snippets"
    echo "  $extensions_status Extensions"
    echo ""
    if [ -n "$LOG_FILE" ]; then
        echo "✓ Log file: $LOG_FILE"
    fi
    echo "========================================"
    echo ""
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    parse_arguments "$@"
    
    # Register cleanup trap
    trap cleanup EXIT
    
    # Setup logging
    # Note: If extracting from archive, this might be temporary
    # We'll set it correctly after extraction logic potentially runs
    
    # Detect OS and set paths
    detect_os
    check_codium_command || true
    
    # Validate backup location (handles archives)
    validate_backup_location
    
    # Extract archive if needed
    if [ "$IS_ARCHIVE" = true ]; then
        extract_archive
    fi
    
    # Now that we have a final directory, set log file
    LOG_FILE="$BACKUP_DIR/restore.log"
    
    # Print startup info
    if [ "$DRY_RUN" = true ]; then
        echo "🔍 DRY RUN MODE - No files will be modified"
    fi
    
    echo "Starting VSCodium restore..."
    log "Restore started with script v$SCRIPT_VERSION"
    
    # Verify checksums before restoring
    if [ "$VERIFY_CHECKSUMS" = true ] && [ "$DRY_RUN" = false ]; then
        if ! verify_checksums; then
            echo ""
            if ! prompt_confirmation "⚠ Continue anyway?"; then
                log "User cancelled restore due to checksum failure"
                echo "Restore cancelled."
                exit 1
            fi
        fi
    fi
    
    # Confirm before overwriting existing configuration
    if [ "$DRY_RUN" = false ]; then
        echo ""
        if ! prompt_confirmation "→ This will overwrite your current VSCodium configuration. Continue?"; then
            log "User cancelled restore"
            echo "Restore cancelled."
            exit 1
        fi
    fi
    
    # Create config directories
    if [ "$DRY_RUN" = false ]; then
        mkdir -p "$CONFIG_DIR/User"
        mkdir -p "$CONFIG_DIR/User/snippets"
    fi
    
    # Perform restores
    [ "$RESTORE_SETTINGS" = true ] && \
        restore_file "$BACKUP_DIR/User/settings.json" "$CONFIG_DIR/User"
    
    [ "$RESTORE_KEYBINDINGS" = true ] && \
        restore_file "$BACKUP_DIR/User/keybindings.json" "$CONFIG_DIR/User"
    
    [ "$RESTORE_SNIPPETS" = true ] && \
        restore_directory "$BACKUP_DIR/snippets" "$CONFIG_DIR/User/snippets"
    
    [ "$RESTORE_EXTENSIONS" = true ] && \
        restore_extensions
    
    # Print summary
    print_summary
    
    if [ "$DRY_RUN" = true ]; then
        log "Dry run completed - no files were modified"
        echo "Use the same command without --dry-run to perform the actual restore."
    else
        log_success "Restore completed successfully"
        echo "↓ Please restart VSCodium to apply restored settings."
    fi
}

# Run main function
main "$@"