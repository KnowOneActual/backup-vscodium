#!/bin/bash

# backup-codium.sh
# A robust script to back up VSCodium settings, keybindings, snippets, and extensions.
# Supports custom backup locations, selective backups, dry-run mode, and comprehensive logging.

set -euo pipefail

# ============================================================================
# CONFIGURATION & DEFAULTS
# ============================================================================

readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_NAME="$(basename "$0")"

# Default backup location
DEFAULT_BACKUP_DIR="$HOME/Documents/VSCodium_Backup"
BACKUP_DIR="$DEFAULT_BACKUP_DIR"

# Logging
LOG_FILE=""
VERBOSE=false
DRY_RUN=false

# Backup options
BACKUP_SETTINGS=true
BACKUP_KEYBINDINGS=true
BACKUP_SNIPPETS=true
BACKUP_EXTENSIONS=true
CREATE_CHECKSUMS=true
CREATE_MANIFEST=true
INCLUDE_TIMESTAMP=false

# Detected OS
OS_NAME=""
CONFIG_DIR=""

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

print_help() {
    cat <<EOF
$SCRIPT_NAME v$SCRIPT_VERSION - Back up your VSCodium configuration

USAGE:
    $SCRIPT_NAME [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    -v, --version           Show script version
    --verbose               Enable verbose output
    --dry-run               Preview what would be backed up without copying
    -l, --location PATH     Custom backup location (default: $DEFAULT_BACKUP_DIR)
    -t, --timestamp         Add timestamp to backup folder name
    
SELECTIVE BACKUP OPTIONS:
    --only-settings         Backup only settings.json
    --only-keybindings      Backup only keybindings.json
    --only-snippets         Backup only snippets directory
    --only-extensions       Backup only extensions list
    --no-settings           Exclude settings.json
    --no-keybindings        Exclude keybindings.json
    --no-snippets           Exclude snippets directory
    --no-extensions         Exclude extensions list
    --no-checksums          Don't create SHA256 checksums
    --no-manifest           Don't create manifest file

EXAMPLES:
    # Backup everything to default location
    $SCRIPT_NAME

    # Backup to custom location
    $SCRIPT_NAME --location ~/Dropbox/VSCodium_Backup

    # Backup with timestamp
    $SCRIPT_NAME --timestamp

    # Dry run to preview what would be backed up
    $SCRIPT_NAME --dry-run

    # Backup only settings and extensions
    $SCRIPT_NAME --no-keybindings --no-snippets

    # Verbose output with timestamp
    $SCRIPT_NAME --verbose --timestamp

EOF
}

log() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [ -n "$LOG_FILE" ]; then
        echo "[$timestamp] $message" >> "$LOG_FILE"
    fi
    
    if [ "$VERBOSE" = true ]; then
        echo "[INFO] $message"
    fi
}

log_error() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [ -n "$LOG_FILE" ]; then
        echo "[$timestamp] ERROR: $message" >> "$LOG_FILE"
    fi
    
    echo "✗ ERROR: $message" >&2
}

log_success() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [ -n "$LOG_FILE" ]; then
        echo "[$timestamp] SUCCESS: $message" >> "$LOG_FILE"
    fi
    
    if [ "$VERBOSE" = true ]; then
        echo "✓ $message"
    fi
}

log_warning() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
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
    
    if [ ! -d "$CONFIG_DIR" ]; then
        log_error "VSCodium config directory not found at: $CONFIG_DIR"
        log_error "Is VSCodium installed correctly?"
        exit 1
    fi
}

check_codium_command() {
    if ! command -v codium &> /dev/null; then
        log_warning "'codium' command not found in PATH"
        log_warning "Extension backup will be skipped"
        BACKUP_EXTENSIONS=false
        return 1
    fi
    return 0
}

validate_backup_location() {
    # Check if backup location is writable
    local parent_dir=$(dirname "$BACKUP_DIR")
    
    if [ ! -d "$parent_dir" ]; then
        log_error "Parent directory does not exist: $parent_dir"
        exit 1
    fi
    
    if [ ! -w "$parent_dir" ]; then
        log_error "No write permission for: $parent_dir"
        exit 1
    fi
    
    log "Backup location validated: $BACKUP_DIR"
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
            -l|--location)
                BACKUP_DIR="$2"
                shift 2
                ;;
            -t|--timestamp)
                INCLUDE_TIMESTAMP=true
                shift
                ;;
            --only-settings)
                BACKUP_KEYBINDINGS=false
                BACKUP_SNIPPETS=false
                BACKUP_EXTENSIONS=false
                shift
                ;;
            --only-keybindings)
                BACKUP_SETTINGS=false
                BACKUP_SNIPPETS=false
                BACKUP_EXTENSIONS=false
                shift
                ;;
            --only-snippets)
                BACKUP_SETTINGS=false
                BACKUP_KEYBINDINGS=false
                BACKUP_EXTENSIONS=false
                shift
                ;;
            --only-extensions)
                BACKUP_SETTINGS=false
                BACKUP_KEYBINDINGS=false
                BACKUP_SNIPPETS=false
                shift
                ;;
            --no-settings)
                BACKUP_SETTINGS=false
                shift
                ;;
            --no-keybindings)
                BACKUP_KEYBINDINGS=false
                shift
                ;;
            --no-snippets)
                BACKUP_SNIPPETS=false
                shift
                ;;
            --no-extensions)
                BACKUP_EXTENSIONS=false
                shift
                ;;
            --no-checksums)
                CREATE_CHECKSUMS=false
                shift
                ;;
            --no-manifest)
                CREATE_MANIFEST=false
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
# BACKUP OPERATIONS
# ============================================================================

backup_file() {
    local source_file="$1"
    local dest_dir="$2"
    local file_name=$(basename "$source_file")
    
    if [ ! -f "$source_file" ]; then
        log_warning "File not found, skipping: $source_file"
        return 1
    fi
    
    if [ "$DRY_RUN" = true ]; then
        log "[DRY-RUN] Would backup: $source_file -> $dest_dir/"
        return 0
    fi
    
    mkdir -p "$dest_dir"
    cp "$source_file" "$dest_dir/" 2>/dev/null || {
        log_error "Failed to backup: $file_name"
        return 1
    }
    
    log_success "Backed up: $file_name"
    return 0
}

backup_directory() {
    local source_dir="$1"
    local dest_dir="$2"
    local dir_name=$(basename "$source_dir")
    
    if [ ! -d "$source_dir" ]; then
        log_warning "Directory not found, skipping: $source_dir"
        return 1
    fi
    
    if [ "$DRY_RUN" = true ]; then
        local file_count=$(find "$source_dir" -type f | wc -l)
        log "[DRY-RUN] Would backup $dir_name ($file_count files) -> $dest_dir/"
        return 0
    fi
    
    mkdir -p "$dest_dir"
    cp -r "$source_dir/." "$dest_dir/" 2>/dev/null || {
        log_error "Failed to backup directory: $dir_name"
        return 1
    }
    
    log_success "Backed up directory: $dir_name"
    return 0
}

backup_extensions() {
    local extensions_file="$BACKUP_DIR/extensions.txt"
    
    if [ ! -f "$(command -v codium)" ]; then
        log_warning "codium command not available, skipping extensions"
        return 1
    fi
    
    if [ "$DRY_RUN" = true ]; then
        log "[DRY-RUN] Would backup extension list to: $extensions_file"
        return 0
    fi
    
    mkdir -p "$BACKUP_DIR"
    
    if codium --list-extensions > "$extensions_file" 2>/dev/null; then
        local ext_count=$(wc -l < "$extensions_file")
        log_success "Backed up extension list ($ext_count extensions)"
        return 0
    else
        log_error "Failed to backup extensions"
        return 1
    fi
}

create_checksums() {
    local checksums_file="$BACKUP_DIR/backup.sha256"
    
    if [ "$DRY_RUN" = true ]; then
        log "[DRY-RUN] Would create checksums at: $checksums_file"
        return 0
    fi
    
    if ! command -v sha256sum &> /dev/null; then
        log_warning "sha256sum not available, skipping checksum generation"
        return 1
    fi
    
    cd "$BACKUP_DIR" || return 1
    find . -type f ! -name "backup.sha256" ! -name "manifest.txt" -print0 | \
        xargs -0 sha256sum > "$checksums_file" 2>/dev/null || {
        log_error "Failed to create checksums"
        return 1
    }
    
    log_success "Created checksums file: backup.sha256"
    cd - > /dev/null
    return 0
}

create_manifest() {
    local manifest_file="$BACKUP_DIR/manifest.txt"
    
    if [ "$DRY_RUN" = true ]; then
        log "[DRY-RUN] Would create manifest at: $manifest_file"
        return 0
    fi
    
    {
        echo "VSCodium Backup Manifest"
        echo "========================"
        echo "Created: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Hostname: $(hostname)"
        echo "OS: $OS_NAME"
        echo ""
        echo "Backed Up Components:"
        [ "$BACKUP_SETTINGS" = true ] && echo "  ✓ Settings"
        [ "$BACKUP_KEYBINDINGS" = true ] && echo "  ✓ Keybindings"
        [ "$BACKUP_SNIPPETS" = true ] && echo "  ✓ Snippets"
        [ "$BACKUP_EXTENSIONS" = true ] && echo "  ✓ Extensions"
        echo ""
        echo "File Listing:"
        find "$BACKUP_DIR" -type f -exec basename {} \; | sed 's/^/  - /'
    } > "$manifest_file"
    
    log_success "Created manifest file: manifest.txt"
    return 0
}

print_summary() {
    local settings_status="[$([ "$BACKUP_SETTINGS" = true ] && echo "✓" || echo "✗")]"
    local keybindings_status="[$([ "$BACKUP_KEYBINDINGS" = true ] && echo "✓" || echo "✗")]"
    local snippets_status="[$([ "$BACKUP_SNIPPETS" = true ] && echo "✓" || echo "✗")]"
    local extensions_status="[$([ "$BACKUP_EXTENSIONS" = true ] && echo "✓" || echo "✗")]"
    
    echo ""
    echo "========================================"
    echo "         BACKUP SUMMARY"
    echo "========================================"
    echo "Backup Location: $BACKUP_DIR"
    echo "Backup Size: $(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1)"
    echo ""
    echo "Components:"
    echo "  $settings_status Settings"
    echo "  $keybindings_status Keybindings"
    echo "  $snippets_status Snippets"
    echo "  $extensions_status Extensions"
    echo ""
    if [ "$CREATE_CHECKSUMS" = true ]; then
        echo "✓ Checksums created"
    fi
    if [ "$CREATE_MANIFEST" = true ]; then
        echo "✓ Manifest created"
    fi
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
    
    # Add timestamp to backup directory if requested
    if [ "$INCLUDE_TIMESTAMP" = true ]; then
        BACKUP_DIR="${BACKUP_DIR}_$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Setup logging
    LOG_FILE="$BACKUP_DIR/backup.log"
    
    # Detect OS and set paths
    detect_os
    check_codium_command || true
    
    # Validate backup location
    validate_backup_location
    
    # Print startup info
    if [ "$DRY_RUN" = true ]; then
        echo "🔍 DRY RUN MODE - No files will be modified"
    fi
    
    echo "Starting VSCodium backup..."
    log "Backup started with script v$SCRIPT_VERSION"
    
    # Create backup directories
    if [ "$DRY_RUN" = false ]; then
        mkdir -p "$BACKUP_DIR/User"
        mkdir -p "$BACKUP_DIR/snippets"
    fi
    
    # Perform backups
    [ "$BACKUP_SETTINGS" = true ] && \
        backup_file "$CONFIG_DIR/User/settings.json" "$BACKUP_DIR/User"
    
    [ "$BACKUP_KEYBINDINGS" = true ] && \
        backup_file "$CONFIG_DIR/User/keybindings.json" "$BACKUP_DIR/User"
    
    [ "$BACKUP_SNIPPETS" = true ] && \
        backup_directory "$CONFIG_DIR/User/snippets" "$BACKUP_DIR/snippets"
    
    [ "$BACKUP_EXTENSIONS" = true ] && \
        backup_extensions
    
    # Create metadata files
    [ "$CREATE_CHECKSUMS" = true ] && [ "$DRY_RUN" = false ] && \
        create_checksums
    
    [ "$CREATE_MANIFEST" = true ] && [ "$DRY_RUN" = false ] && \
        create_manifest
    
    # Print summary
    print_summary
    
    if [ "$DRY_RUN" = true ]; then
        log "Dry run completed - no files were modified"
        echo "Use the same command without --dry-run to perform the actual backup."
    else
        log_success "Backup completed successfully"
    fi
}

# Run main function
main "$@"
