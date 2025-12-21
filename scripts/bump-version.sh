#!/bin/bash

# bump-version.sh
# Automate semantic version bumping and git tagging
# Usage: ./scripts/bump-version.sh [major|minor|patch]

set -euo pipefail

readonly SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
readonly PROJECT_DIR=$(dirname "$SCRIPT_DIR")

# Color output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# ============================================================================
# FUNCTIONS
# ============================================================================

print_usage() {
    cat <<EOF
${GREEN}bump-version.sh${NC} - Semantic version bumping for backup-vscodium

USAGE:
    bump-version.sh [major|minor|patch]

EXAMPLES:
    # Bump patch version (2.0.0 -> 2.0.1)
    bump-version.sh patch

    # Bump minor version (2.0.0 -> 2.1.0)
    bump-version.sh minor

    # Bump major version (2.0.0 -> 3.0.0)
    bump-version.sh major

WHAT IT DOES:
    1. Validates current version
    2. Calculates new version
    3. Updates version in scripts
    4. Creates git commit
    5. Creates git tag
    6. Shows release checklist

NOTE:
    Make sure your working directory is clean before running this script.
    All changes will be committed and tagged.

EOF
}

error() {
    echo -e "${RED}✗ Error: $1${NC}" >&2
    exit 1
}

success() {
    echo -e "${GREEN}✓ $1${NC}"
}

info() {
    echo -e "${YELLOW}→ $1${NC}"
}

get_current_version() {
    grep -m 1 'SCRIPT_VERSION=' "$PROJECT_DIR/backup-codium.sh" | \
        sed 's/.*SCRIPT_VERSION="\([^"]*\)".*/\1/'
}

bump_version() {
    local version="$1"
    local bump_type="$2"
    
    local major minor patch
    major=$(echo "$version" | cut -d. -f1)
    minor=$(echo "$version" | cut -d. -f2)
    patch=$(echo "$version" | cut -d. -f3)
    
    case "$bump_type" in
        major)
            major=$((major + 1)) || true
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1)) || true
            patch=0
            ;;
        patch)
            patch=$((patch + 1)) || true
            ;;
        *)
            error "Invalid bump type: $bump_type. Use 'major', 'minor', or 'patch'."
            ;;
    esac
    
    echo "${major}.${minor}.${patch}"
}

update_version_in_file() {
    local file="$1"
    local old_version="$2"
    local new_version="$3"
    
    if grep -q "SCRIPT_VERSION=" "$file"; then
        sed -i.bak "s/SCRIPT_VERSION=\"${old_version}\"/SCRIPT_VERSION=\"${new_version}\"/g" "$file"
        rm -f "$file.bak"
        success "Updated version in $(basename "$file")"
    fi
}

check_git_clean() {
    if [ -n "$(git status --porcelain)" ]; then
        error "Git working directory is not clean. Please commit or stash changes first."
    fi
}

check_git_tag_exists() {
    local tag="$1"
    if git rev-parse "$tag" &> /dev/null; then
        return 0  # Tag exists
    else
        return 1  # Tag doesn't exist
    fi
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    if [ $# -eq 0 ]; then
        print_usage
        exit 0
    fi
    
    local bump_type="$1"
    
    # Validate input
    if [[ ! "$bump_type" =~ ^(major|minor|patch)$ ]]; then
        error "Invalid bump type: $bump_type. Use 'major', 'minor', or 'patch'."
    fi
    
    # Check we're in the right directory
    if [ ! -f "$PROJECT_DIR/backup-codium.sh" ]; then
        error "Could not find backup-codium.sh. Are you in the right directory?"
    fi
    
    # Check git is available
    if ! command -v git &> /dev/null; then
        error "git is not installed or not in PATH"
    fi
    
    # Check working directory is clean
    check_git_clean
    
    # Get current version
    local current_version
    current_version=$(get_current_version)
    
    if [ -z "$current_version" ]; then
        error "Could not determine current version"
    fi
    
    info "Current version: $current_version"
    
    # Calculate new version
    local new_version
    new_version=$(bump_version "$current_version" "$bump_type")
    
    info "New version: $new_version"
    
    # Check if tag already exists
    if check_git_tag_exists "v$new_version"; then
        error "Tag v$new_version already exists"
    fi
    
    echo ""
    info "Updating version in scripts..."
    
    # Update version in both scripts
    update_version_in_file "$PROJECT_DIR/backup-codium.sh" "$current_version" "$new_version"
    update_version_in_file "$PROJECT_DIR/restore-codium.sh" "$current_version" "$new_version"
    
    echo ""
    info "Creating git commit..."
    
    # Commit changes
    cd "$PROJECT_DIR"
    git add backup-codium.sh restore-codium.sh
    git commit -m "chore: Bump version from $current_version to $new_version"
    success "Committed version update"
    
    # Create git tag
    info "Creating git tag..."
    git tag -a "v$new_version" -m "Release version $new_version"
    success "Created tag v$new_version"
    
    echo ""
    echo "${GREEN}════════════════════════════════════════════════════════${NC}"
    echo "${GREEN}Version bump complete!${NC}"
    echo "${GREEN}════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Next steps:"
    echo ""
    echo "  1. Review the changes:"
    echo "     ${YELLOW}git log --oneline -1${NC}"
    echo ""
    echo "  2. Push the tag to GitHub:"
    echo "     ${YELLOW}git push origin main${NC}"
    echo "     ${YELLOW}git push origin v$new_version${NC}"
    echo ""
    echo "  3. GitHub Actions will automatically:"
    echo "     - Run tests"
    echo "     - Create a GitHub Release"
    echo "     - Generate release notes"
    echo ""
    echo "View releases at:"
    echo "  ${YELLOW}https://github.com/KnowOneActual/backup-vscodium/releases${NC}"
    echo ""
}

main "$@"
