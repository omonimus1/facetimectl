# Homebrew Release Guide

This document provides step-by-step instructions for publishing `facetimectl` to Homebrew.

## Overview
There are two ways to distribute via Homebrew:
1. **Homebrew Tap** (Recommended) - Your own repository for formulas
2. **Homebrew Core** - Official Homebrew repository (requires 30+ stars/forks)

We'll focus on creating a Homebrew Tap for this project.

## Prerequisites
### Required Accounts & Access
1. **GitHub Account** (you already have this)
   - Used for hosting your code and tap repository
   - No special Homebrew account needed!
2. **GitHub Personal Access Token** (optional, for automation)
   - Go to: https://github.com/settings/tokens
   - Create a token with `repo` and `workflow` scopes
   - Save it securely

### Required Tools
```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install gh CLI (optional, for easier release management)
brew install gh
gh auth login
```

---
## Step 1: Prepare Your Main Repository

### 1.1 Push Your Code to GitHub
```bash
# If not already on GitHub, create a new repository at:
# https://github.com/new
# Name it: facetimectl

# Then push your code
git remote add origin https://github.com/YOUR_USERNAME/facetimectl.git
git branch -M master
git push -u origin master
```

### 1.2 Update the Formula Template

Edit `Formula/facetimectl.rb` and replace:
- `YOUR_USERNAME` with your actual GitHub username
- Keep `REPLACE_WITH_ACTUAL_SHA256` for now (we'll update it after creating a release)

---

## Step 2: Create Your First Release

### 2.1 Create a Git Tag

```bash
# Choose a version number (use semantic versioning)
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

### 2.2 GitHub Actions Will Automatically:
- Build the project
- Run tests
- Create a GitHub Release
- Generate a tarball
- Calculate the SHA256 checksum

### 2.3 Get the SHA256 Checksum

After the GitHub Action completes:

**Option A: From GitHub Release Page**
1. Go to: https://github.com/YOUR_USERNAME/facetimectl/releases
2. Find the SHA256 in the release notes

**Option B: Manually Calculate**
```bash
curl -L https://github.com/YOUR_USERNAME/facetimectl/archive/refs/tags/v1.0.0.tar.gz | shasum -a 256
```

### 2.4 Update the Formula

Edit `Formula/facetimectl.rb` and replace `REPLACE_WITH_ACTUAL_SHA256` with the actual checksum.

```bash
git add Formula/facetimectl.rb
git commit -m "Update formula with v1.0.0 SHA256"
git push origin master
```

---

## Step 3: Create Your Homebrew Tap Repository

### 3.1 Create a New GitHub Repository

1. Go to: https://github.com/new
2. Repository name: **`homebrew-facetimectl`** (must start with `homebrew-`)
3. Description: "Homebrew tap for facetimectl"
4. Public repository
5. Initialize with README
6. Create repository

### 3.2 Clone and Set Up the Tap

```bash
# Clone your tap repository
git clone https://github.com/YOUR_USERNAME/homebrew-facetimectl.git
cd homebrew-facetimectl

# Create the Formula directory
mkdir -p Formula

# Copy the formula from your main repository
cp /path/to/facetimectl/Formula/facetimectl.rb Formula/

# Commit and push
git add Formula/facetimectl.rb
git commit -m "Add facetimectl formula v1.0.0"
git push origin master
```

### 3.3 Update the Tap README

Edit `homebrew-facetimectl/README.md`:

```markdown
# Homebrew Tap for facetimectl

Fast CLI for FaceTime on macOS

## Installation

```bash
brew tap YOUR_USERNAME/facetimectl
brew install facetimectl
```

## Usage

See the [main repository](https://github.com/YOUR_USERNAME/facetimectl) for documentation.
```

Commit and push:
```bash
git add README.md
git commit -m "Update README with installation instructions"
git push origin master
```

---

## Step 4: Test Your Formula

### 4.1 Test Locally

```bash
# Tap your repository
brew tap YOUR_USERNAME/facetimectl

# Install from tap
brew install facetimectl

# Test it works
facetimectl --help

# Uninstall for clean testing
brew uninstall facetimectl
brew untap YOUR_USERNAME/facetimectl
```

### 4.2 Test Formula Validation

```bash
# Audit the formula
brew audit --strict --online Formula/facetimectl.rb

# Test installation from scratch
brew install --build-from-source Formula/facetimectl.rb

# Run formula tests
brew test facetimectl
```

---

## Step 5: Update Your Main Repository README

Update the Installation section in your main `facetimectl` README.md:

```markdown
## Install

### Homebrew (Recommended)
```bash
brew tap YOUR_USERNAME/facetimectl
brew install facetimectl
```

### From source
```bash
git clone https://github.com/YOUR_USERNAME/facetimectl.git
cd facetimectl
make build
# binary at ./bin/facetimectl
```
```

---

## Releasing New Versions

### Process for Each New Release

1. **Update your code** and commit changes
2. **Tag a new version:**
   ```bash
   git tag -a v1.1.0 -m "Release v1.1.0"
   git push origin v1.1.0
   ```
3. **Wait for GitHub Actions** to create the release
4. **Get the new SHA256** from the release page
5. **Update the formula** in your tap repository:
   ```ruby
   url "https://github.com/YOUR_USERNAME/facetimectl/archive/refs/tags/v1.1.0.tar.gz"
   sha256 "NEW_SHA256_HERE"
   ```
6. **Test the update:**
   ```bash
   brew upgrade facetimectl
   ```
7. **Commit and push** the tap repository:
   ```bash
   git add Formula/facetimectl.rb
   git commit -m "Update to v1.1.0"
   git push origin master
   ```

---

## Advanced: Automate Formula Updates

You can automate step 5-7 with a GitHub Action in your **main repository**.

Create `.github/workflows/update-tap.yml`:

```yaml
name: Update Homebrew Tap

on:
  release:
    types: [published]

jobs:
  update-tap:
    runs-on: ubuntu-latest
    steps:
      - name: Update Homebrew formula
        uses: mislav/bump-homebrew-formula-action@v3
        with:
          formula-name: facetimectl
          homebrew-tap: YOUR_USERNAME/homebrew-facetimectl
          download-url: https://github.com/YOUR_USERNAME/facetimectl/archive/refs/tags/${{ github.event.release.tag_name }}.tar.gz
        env:
          COMMITTER_TOKEN: ${{ secrets.COMMITTER_TOKEN }}
```

Note: You'll need to create a Personal Access Token with `repo` scope and add it as `COMMITTER_TOKEN` secret.

---

## Troubleshooting

### Formula fails `brew audit`

```bash
# Run audit to see issues
brew audit --strict --online Formula/facetimectl.rb

# Common issues:
# - Wrong SHA256 (recalculate)
# - Invalid URL (check GitHub release)
# - Missing license (add LICENSE file to main repo)
```

### Installation fails

```bash
# Check formula syntax
ruby -c Formula/facetimectl.rb

# Try installing with verbose output
brew install --build-from-source --verbose Formula/facetimectl.rb

# Check build logs
cat ~/Library/Logs/Homebrew/facetimectl/
```

### Users report old version

```bash
# Users need to update their tap
brew update
brew upgrade facetimectl
```

---

## Submitting to Homebrew Core (Optional)
Once your project gains traction (30+ stars/forks), you can submit to official Homebrew:
### Requirements:
- ✅ Stable, actively maintained project
- ✅ 30+ GitHub stars or forks
- ✅ No proprietary dependencies
- ✅ Passes `brew audit --strict --online`
- ✅ Well-documented
- ✅ Responds to issues

### Process:
1. Fork [homebrew-core](https://github.com/Homebrew/homebrew-core)
2. Add your formula to `Formula/`
3. Run `brew audit --strict --online facetimectl`
4. Submit a Pull Request
5. Respond to maintainer feedback

**Note:** Homebrew Core is not necessary for most projects. Your tap is sufficient!

---

## Summary Checklist
- [ ] Push code to GitHub
- [ ] Update `Formula/facetimectl.rb` with your username
- [ ] Create a git tag (v1.0.0)
- [ ] Wait for GitHub Actions to create release
- [ ] Get SHA256 from release
- [ ] Update formula with SHA256
- [ ] Create `homebrew-facetimectl` repository
- [ ] Copy formula to tap repository
- [ ] Test installation: `brew tap YOUR_USERNAME/facetimectl && brew install facetimectl`
- [ ] Update main README with brew instructions
- [ ] Document the release process for future versions

---

## Resources
- [Homebrew Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [Homebrew Taps](https://docs.brew.sh/Taps)
- [GitHub Releases](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository)
- [Semantic Versioning](https://semver.org/)

---

## Questions?
If you encounter issues:
1. Check the [Homebrew troubleshooting guide](https://docs.brew.sh/Troubleshooting)
2. Search [Homebrew discussions](https://github.com/Homebrew/brew/discussions)
3. Review other tap examples on GitHub

**Good luck with your release! 🎉**
