# Quick Deployment Guide - Do This Now

## Step-by-Step: Deploy to GitHub in 10 Minutes

### Step 1: Test Everything (2 min)

```bash
# Make sure you're in the project directory
cd /Users/elias/local-first-router

# Test the installer (this will install everything if missing)
./install-full.sh

# Test starting
./start.sh

# Open http://localhost:5173 and test it works
# Then stop it:
./stop.sh
```

✅ **If this works, continue. If not, fix issues first.**

---

### Step 2: Build the Package (1 min)

```bash
# Build the distribution package
./package.sh 1.0.0
```

This creates:
- `local-first-router-v1.0.0.zip`
- `local-first-router-v1.0.0.tar.gz`

✅ **Check that these files exist.**

---

### Step 3: Initialize Git (if not done) (1 min)

```bash
# Initialize git repository
git init

# Add all files
git add .

# Make initial commit
git commit -m "Initial commit: Local-first Router with self-contained installer"
```

---

### Step 4: Create GitHub Repository (2 min)

1. Go to https://github.com/new
2. Repository name: `local-first-router`
3. Description: "Local-first LLM router with automatic Ollama installation"
4. Choose Public or Private
5. **Don't** check "Initialize with README"
6. Click "Create repository"

---

### Step 5: Connect and Push (1 min)

```bash
# Add remote (replace YOUR_USERNAME with your actual GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/local-first-router.git

# Push to GitHub
git branch -M main
git push -u origin main
```

**Note:** You'll need to authenticate. GitHub will prompt you.

---

### Step 6: Create Release (3 min)

#### 6a. Create Tag

```bash
# Create version tag
git tag -a v1.0.0 -m "Release v1.0.0: Self-contained installer"

# Push tag
git push origin v1.0.0
```

#### 6b. Create Release on GitHub

1. Go to: `https://github.com/YOUR_USERNAME/local-first-router/releases`
2. Click "Create a new release"
3. **Tag:** `v1.0.0`
4. **Title:** `v1.0.0 - Self-Contained Installer`
5. **Description:** Copy from below ⬇️
6. **Attach files:**
   - Drag and drop `local-first-router-v1.0.0.zip`
   - Drag and drop `local-first-router-v1.0.0.tar.gz`
7. Click "Publish release"

---

### Step 7: Release Description (Copy This)

```markdown
# Local-first Router v1.0.0

## 🎉 Self-Contained Installer

One-command installation that automatically sets up everything!

## ✨ Features

- **Automatic installation** - Installs Python, Node.js, Ollama, and the llama model
- **One-command start** - `./start.sh` starts everything
- **Pre-built frontend** - No build step required
- **Complete documentation** - Everything included

## 📦 Quick Install

```bash
# 1. Download and extract
unzip local-first-router-v1.0.0.zip
cd local-first-router-v1.0.0

# 2. Install (automatic!)
./install.sh

# 3. Start
./start.sh

# 4. Open http://localhost:5173
```

## 📋 Requirements

- macOS or Linux
- Internet connection (first time only)
- ~5GB free space

## 🚀 What It Does

- Routes LLM requests between local (Ollama) and cloud (Claude) models
- Uses confidence scoring to decide when to use cloud
- Tracks costs and savings
- Persistent chat history
- Model selector

## 📖 Documentation

See [README.md](README.md) for full documentation.

## 🐛 Issues

Found a bug? Please open an issue!
```

---

## ✅ Done!

Your router is now on GitHub! Users can:

1. Go to your repository
2. Click "Releases"
3. Download the zip or tar.gz
4. Follow the installation instructions

---

## Next Steps (Optional)

1. **Enable GitHub Pages** for a download page
2. **Add badges** to README (build status, version, etc.)
3. **Create a logo** and add it to README
4. **Set up CI/CD** to auto-build packages on release

---

## Troubleshooting

**"Permission denied" when pushing?**
- You may need to set up SSH keys or use a personal access token
- See: https://docs.github.com/en/authentication

**Package files too large?**
- GitHub allows 100MB per file
- If needed, host large files elsewhere or use Git LFS

**Installation fails for users?**
- Check GitHub Issues
- Add troubleshooting to README
- Update installer with better error messages

---

**That's it! You're ready to deploy.** 🚀

