# Release Process Guide

How to create and publish new releases for backup-vscodium.

---

## Quick Start

```bash
# 1. Bump version (choose one)
./scripts/bump-version.sh patch  # For bug fixes (2.0.0 -> 2.0.1)
./scripts/bump-version.sh minor  # For new features (2.0.0 -> 2.1.0)
./scripts/bump-version.sh major  # For breaking changes (2.0.0 -> 3.0.0)

# 2. Push to GitHub
git push origin main
git push origin v2.0.1  # Replace with your version

# 3. Done! GitHub Actions will:
#    - Run all tests
#    - Create GitHub release
#    - Generate release notes
```

---

## Detailed Release Steps

### Step 1: Prepare Changes

```bash
# Make sure all changes are committed
git status

# Ensure you're on main branch
git checkout main

# Update to latest
git pull origin main
```

### Step 2: Bump Version

The `scripts/bump-version.sh` script will:
- Validate your working directory is clean
- Calculate new version number
- Update version in both scripts
- Create git commit
- Create git tag

```bash
# For a patch release (bug fix)
./scripts/bump-version.sh patch

# For a minor release (new feature)
./scripts/bump-version.sh minor

# For a major release (breaking change)
./scripts/bump-version.sh major
```

### Step 3: Verify Changes

```bash
# Review the commit
git log --oneline -1

# Review the tag
git tag -l v*.*.* | tail -1

# Check what files were changed
git show --stat
```

Example output:
```
commit abc123def456
Author: Your Name <email@example.com>
Date:   Sun Dec 21 21:30:00 2025 +0000

    chore: Bump version from 2.0.0 to 2.0.1

 backup-codium.sh | 2 +-
 restore-codium.sh | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)
```

### Step 4: Push to GitHub

```bash
# Push commits
git push origin main

# Push tags (this triggers the release workflow)
git push origin --tags

# Or push specific tag
TAG=$(git describe --tags --abbrev=0)
git push origin $TAG
```

### Step 5: Monitor Workflow

Go to: https://github.com/KnowOneActual/backup-vscodium/actions

Watch for the "Create Release" workflow:
1. **test** job - Runs all tests ✅
2. **create-release** job - Creates GitHub release ✅

Both must pass for release to be created.

### Step 6: Verify Release

Once workflow completes, verify at:
https://github.com/KnowOneActual/backup-vscodium/releases

You should see:
- New release with version tag
- Automated release notes
- Source code archives (auto-generated)

---

## Version Numbering

We use [Semantic Versioning](https://semver.org/): `MAJOR.MINOR.PATCH`

### When to Bump Each Number

**PATCH** (2.0.0 -> 2.0.1)
- Bug fixes
- Performance improvements
- Internal refactoring
- Documentation updates
- Non-user-facing changes

**MINOR** (2.0.0 -> 2.1.0)
- New features
- New command-line flags
- New options or capabilities
- Backwards compatible

**MAJOR** (2.0.0 -> 3.0.0)
- Breaking changes
- Changed behavior of existing flags
- Changed output format
- Changed default locations
- Removed features

### Decision Tree

```
What changed?
├─ Bug fix only?
│  └─ PATCH (2.0.0 -> 2.0.1)
├─ New feature?
│  ├─ Backwards compatible?
│  │  └─ MINOR (2.0.0 -> 2.1.0)
│  └─ Breaking change?
│     └─ MAJOR (2.0.0 -> 3.0.0)
└─ Documentation/internal?
   └─ PATCH (2.0.0 -> 2.0.1)
```

---

## What Happens in GitHub Actions

When you push a tag, the `.github/workflows/release.yml` workflow:

### Test Job
1. ✅ Runs ShellCheck linting
2. ✅ Validates Bash syntax
3. ✅ Runs all unit tests
4. ✅ Runs integration tests

### Release Job (only if tests pass)
1. ✅ Extracts version from tag
2. ✅ Generates release notes
3. ✅ Creates GitHub release
4. ✅ Publishes source archives

---

## Troubleshooting

### "Tag already exists"

```bash
# Check existing tags
git tag -l

# Delete local tag if needed
git tag -d v2.0.1

# Delete remote tag if needed
git push origin --delete v2.0.1
```

### "Working directory not clean"

```bash
# Stash uncommitted changes
git stash

# Or commit them
git add .
git commit -m "WIP: In progress"

# Then run bump-version.sh
```

### "Workflow failed - tests didn't pass"

1. Check workflow logs: https://github.com/KnowOneActual/backup-vscodium/actions
2. Review failed test output
3. Fix the issue locally
4. Delete the tag: `git push origin --delete v2.0.1`
5. Revert the commit: `git reset --hard HEAD~1`
6. Fix and try again

### "Release not showing up"

```bash
# Check if tag was pushed
git ls-remote origin | grep v2.0.1

# Re-push if needed
git push origin v2.0.1

# Check workflow status
# Visit: https://github.com/KnowOneActual/backup-vscodium/actions
```

---

## After Release

### Announce the Release

1. **GitHub Discussion** - Start a discussion post
2. **Social Media** - Tweet/post on Bluesky about it
3. **Email** - If you have subscribers
4. **Documentation** - Update getting started guides if needed

### Update Documentation

If release includes:
- New flags → Update README.md command reference
- New features → Add examples to README.md
- Bug fixes → Update CHANGELOG.md (if not auto-updated)

### Prepare for Next Release

```bash
# Create unreleased section in CHANGELOG.md
# (If using manual changelog management)

# Example:
# ## [Unreleased]
# ### Added
# - (nothing yet)
# ### Changed
# - (nothing yet)
```

---

## Release Checklist

- [ ] All commits pushed to main
- [ ] No uncommitted changes
- [ ] Tests passing locally
- [ ] Documentation updated
- [ ] Ran `./scripts/bump-version.sh [patch|minor|major]`
- [ ] Reviewed commit: `git log -1`
- [ ] Pushed commits: `git push origin main`
- [ ] Pushed tags: `git push origin --tags`
- [ ] Workflow running: Check GitHub Actions
- [ ] Workflow passed: Both test and create-release jobs green
- [ ] Release published: Check releases page
- [ ] Release notes look good

---

## FAQ

**Q: Can I undo a release?**
A: Yes, you can delete the tag and release on GitHub, then re-do it.

```bash
git push origin --delete v2.0.1
```

Then use the GitHub releases page to delete the release.

**Q: Can I edit the release notes after creation?**
A: Yes! GitHub allows editing release notes. Just click "Edit" on the release page.

**Q: How do I create a pre-release?**
A: Tag with `-alpha`, `-beta`, or `-rc` suffix:

```bash
./scripts/bump-version.sh patch  # Creates v2.0.1
# Edit release notes to mark as pre-release
# Or manually create release with pre-release checkbox
```

**Q: What if the workflow fails?**
A: See "Troubleshooting" section above. Common causes:
- Tests failing (fix them locally, delete tag, retry)
- Git permissions (check GitHub token)
- Working directory dirty (stash changes)

---

## Reference

- [Semantic Versioning](https://semver.org/)
- [GitHub Releases](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Keep a Changelog](https://keepachangelog.com/)

---

**Questions?** Check TESTING.md or open an issue on GitHub.
