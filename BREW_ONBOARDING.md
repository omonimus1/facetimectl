# Homebrew Onboarding Checklist

This is your quick-start checklist to get facetimectl published on Homebrew.

## ✅ Pre-Flight Check (Current Status)

- [x] Formula file created: `Formula/facetimectl.rb`
- [x] GitHub Actions workflow: `.github/workflows/release.yml`
- [x] LICENSE file added (MIT)
- [x] README updated with Homebrew instructions
- [x] Documentation: `brew-release.md`

## 📋 What You Need to Do Now

### Step 1: Commit and Push to GitHub

```bash
# Stage all the Homebrew-related files
git add .github/ Formula/ LICENSE brew-release.md CHANGELOG.md README.md

# Commit
git commit -m "Add Homebrew release infrastructure"

# Push to GitHub (if remote already exists)
git push origin master

# OR if this is your first push:
git remote add origin https://github.com/omonimus1/facetimectl.git
git branch -M master
git push -u origin master
```

### Step 2: Create Your First Release

```bash
# Tag version 1.0.0
git tag -a v1.0.0 -m "Release v1.0.0 - Initial Homebrew release"

# Push the tag (this triggers GitHub Actions)
git push origin v1.0.0
```

### Step 3: Wait for GitHub Actions

1. Go to: https://github.com/omonimus1/facetimectl/actions
2. Wait for the "Release" workflow to complete (~2-5 minutes)
3. Verify it created a release at: https://github.com/omonimus1/facetimectl/releases

### Step 4: Get the SHA256

After the release is created:

**Option A: From Terminal**
```bash
curl -sL https://github.com/omonimus1/facetimectl/archive/refs/tags/v1.0.0.tar.gz | shasum -a 256
```

**Option B: From GitHub Release Page**
- Go to: https://github.com/omonimus1/facetimectl/releases/tag/v1.0.0
- Look for the tarball download link
- Download and calculate: `shasum -a 256 v1.0.0.tar.gz`

**You'll get something like:**
```
a1b2c3d4e5f6789...long string...xyz  (stdin)
```

Copy this hash!

### Step 5: Update the Formula

Edit `Formula/facetimectl.rb` and replace:
```ruby
sha256 "REPLACE_WITH_ACTUAL_SHA256"
```

With:
```ruby
sha256 "a1b2c3d4e5f6789...paste your actual hash here...xyz"
```

Then commit:
```bash
git add Formula/facetimectl.rb
git commit -m "Add SHA256 for v1.0.0 release"
git push origin master
```

### Step 6: Create Your Homebrew Tap Repository

1. **Go to GitHub:** https://github.com/new
2. **Repository name:** `homebrew-facetimectl` (must start with `homebrew-`)
3. **Description:** "Homebrew tap for facetimectl"
4. **Visibility:** Public
5. **Initialize:** Check "Add a README file"
6. **Click:** Create repository

### Step 7: Set Up the Tap

```bash
# Clone your new tap repository
cd ~/Desktop/projects
git clone https://github.com/omonimus1/homebrew-facetimectl.git
cd homebrew-facetimectl

# Create Formula directory
mkdir -p Formula

# Copy your formula from main repo
cp ../facetimectl/Formula/facetimectl.rb Formula/

# Update the README
cat > README.md << 'EOF'
# Homebrew Tap for facetimectl

Fast CLI for FaceTime on macOS

## Installation

```bash
brew tap omonimus1/facetimectl
brew install facetimectl
```

## Documentation

See the [main repository](https://github.com/omonimus1/facetimectl) for usage and documentation.
EOF

# Commit and push
git add Formula/facetimectl.rb README.md
git commit -m "Add facetimectl formula v1.0.0"
git push origin main
```

### Step 8: Test Your Formula

```bash
# Tap your repository
brew tap omonimus1/facetimectl

# Install from your tap
brew install facetimectl

# Test it works
facetimectl --help

# Check version
facetimectl status
```

### Step 9: Verify Everything Works

```bash
# Audit your formula
brew audit --strict --online omonimus1/facetimectl/facetimectl

# Test the formula
brew test facetimectl

# Check info
brew info facetimectl
```

### Step 10: Celebrate! 🎉

Your package is now available via Homebrew! Others can install it with:
```bash
brew tap omonimus1/facetimectl
brew install facetimectl
```

---

## 🔄 Future Releases (After Initial Setup)

For each new version:

1. **Update code and commit changes**
2. **Tag new version:**
   ```bash
   git tag -a v1.1.0 -m "Release v1.1.0"
   git push origin v1.1.0
   ```
3. **Wait for GitHub Actions to create release**
4. **Get new SHA256:**
   ```bash
   curl -sL https://github.com/omonimus1/facetimectl/archive/refs/tags/v1.1.0.tar.gz | shasum -a 256
   ```
5. **Update formula in tap repository:**
   ```bash
   cd homebrew-facetimectl
   # Edit Formula/facetimectl.rb - update url and sha256
   git add Formula/facetimectl.rb
   git commit -m "Update to v1.1.0"
   git push origin main
   ```
6. **Users upgrade with:**
   ```bash
   brew update
   brew upgrade facetimectl
   ```

---

## 🆘 Troubleshooting

### "Formula not found"
```bash
brew untap omonimus1/facetimectl
brew tap omonimus1/facetimectl
```

### "Checksum mismatch"
- Recalculate the SHA256 and update the formula
- Make sure you're using the tarball from GitHub releases, not the source zip

### "Build failed"
- Test locally first: `make build`
- Check the formula's `install` method matches your build process
- Run with verbose output: `brew install --verbose --build-from-source facetimectl`

---

## 📚 Key Concepts Explained

### What is the SHA256?
- **Security hash** of your release tarball
- **NOT a secret** - anyone can calculate it from public release
- **Purpose:** Ensures downloaded file hasn't been tampered with
- **Safe to share** - provides no account access

### How SHA256 Works:
```
Your Release File → SHA256 Algorithm → Unique Fingerprint
(any change to file = completely different fingerprint)
```

### Example:
```bash
# Calculate SHA256 of your release
curl -sL https://github.com/omonimus1/facetimectl/archive/refs/tags/v1.0.0.tar.gz | shasum -a 256

# Output: a1b2c3d4e5... ← This is the SHA256
# This exact string goes in your formula
```

---

## ✅ Final Checklist

- [ ] Code pushed to GitHub
- [ ] First release tagged (v1.0.0)
- [ ] GitHub Actions workflow completed
- [ ] SHA256 calculated and added to formula
- [ ] Tap repository created (`homebrew-facetimectl`)
- [ ] Formula copied to tap repository
- [ ] Tested installation: `brew install facetimectl`
- [ ] Formula passes audit: `brew audit --strict facetimectl`
- [ ] Announced on README/social media

---

## 🚀 You're Ready!

Once you complete these steps, facetimectl will be installable via Homebrew!

For detailed explanations, see [brew-release.md](brew-release.md).

**Need help?** The brew-release.md file has troubleshooting tips and detailed explanations.
