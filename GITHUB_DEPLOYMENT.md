# GitHub Deployment Checklist

## Pre-Deployment Steps

### Step 1: Test Everything Locally ✅

```bash
# 1. Test the self-contained installer
./install-full.sh

# 2. Test starting the app
./start.sh

# 3. Verify it works
# Open http://localhost:5173 and test a query

# 4. Stop it
./stop.sh
```

**Expected:** Everything installs and runs without errors.

---

### Step 2: Build the Package ✅

```bash
# Build the distribution package
./package.sh 1.0.0
```

This creates:
- `local-first-router-v1.0.0/` directory
- `local-first-router-v1.0.0.zip`
- `local-first-router-v1.0.0.tar.gz`
- `local-first-router-v1.0.0.sha256` (checksums)

**Verify:** Check that all files were created.

---

### Step 3: Test the Package on Clean System ✅

**Important:** Test the package as a new user would:

```bash
# Create a test directory
mkdir -p /tmp/test-package
cd /tmp/test-package

# Copy your package
cp /Users/elias/local-first-router/local-first-router-v1.0.0.zip .

# Extract it
unzip local-first-router-v1.0.0.zip
cd local-first-router-v1.0.0

# Test installation (this should install everything)
./install.sh

# Test starting
./start.sh

# Verify it works
# Open http://localhost:5173

# Clean up
./stop.sh
cd /tmp
rm -rf test-package
```

**Expected:** Package installs and runs successfully from scratch.

---

### Step 4: Prepare GitHub Repository ✅

#### 4a. Initialize Git (if not already done)

```bash
cd /Users/elias/local-first-router

# Check if git is initialized
git status

# If not, initialize:
git init
git add .
git commit -m "Initial commit: Local-first Router"
```

#### 4b. Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `local-first-router` (or your choice)
3. Description: "Local-first LLM router with automatic Ollama installation"
4. Choose: Public or Private
5. **Don't** initialize with README (you already have one)
6. Click "Create repository"

#### 4c. Connect and Push

```bash
# Add remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/local-first-router.git

# Push to GitHub
git branch -M main
git push -u origin main
```

---

### Step 5: Clean Up Before Committing ✅

Make sure you don't commit:
- `.env` file (contains API keys)
- `node_modules/`
- `__pycache__/`
- `*.db` files
- Build artifacts

**Check `.gitignore`:**

```bash
cat .gitignore
```

Should include:
- `.env`
- `node_modules/`
- `__pycache__/`
- `*.db`
- `*.log`
- `frontend/dist/` (optional - you might want to include pre-built)

**If needed, update `.gitignore`:**

```bash
# Add to .gitignore if missing
echo ".env" >> .gitignore
echo "*.log" >> .gitignore
echo ".backend.pid" >> .gitignore
echo ".frontend.pid" >> .gitignore
echo "local-first-router-v*.zip" >> .gitignore
echo "local-first-router-v*.tar.gz" >> .gitignore
```

---

### Step 6: Final Commit ✅

```bash
# Stage all files
git add .

# Commit
git commit -m "Add self-contained installer and package builder

- Added install-full.sh: automatically installs Python, Node.js, Ollama, and model
- Added start.sh and stop.sh: simple service management
- Added package.sh: creates ready-to-distribute packages
- Added comprehensive documentation for distribution"

# Push
git push origin main
```

---

### Step 7: Create GitHub Release ✅

#### 7a. Tag the Release

```bash
# Create a version tag
git tag -a v1.0.0 -m "Release version 1.0.0: Self-contained installer"

# Push tag to GitHub
git push origin v1.0.0
```

#### 7b. Create Release on GitHub

1. Go to your repository on GitHub
2. Click "Releases" (right sidebar)
3. Click "Create a new release"
4. **Tag:** Select `v1.0.0` (or create new)
5. **Title:** `v1.0.0 - Self-Contained Installer`
6. **Description:** Copy from template below
7. **Attach binaries:**
   - Click "Attach binaries"
   - Upload `local-first-router-v1.0.0.zip`
   - Upload `local-first-router-v1.0.0.tar.gz`
   - Upload `local-first-router-v1.0.0.sha256` (optional)
8. Click "Publish release"

---

### Step 8: Release Notes Template

Use this for your GitHub release description:

```markdown
# Local-first Router v1.0.0

## 🎉 Self-Contained Installer

This release includes a **completely self-contained installer** that automatically sets up everything you need!

## ✨ What's New

- **One-command installation** - `./install.sh` installs everything automatically:
  - Python (if missing)
  - Node.js (if missing)
  - Ollama (if missing)
  - llama3.2:latest model (if missing)
  - All dependencies
- **Simple start/stop scripts** - `./start.sh` and `./stop.sh`
- **Pre-built frontend** - No build step required
- **Complete documentation** - Everything you need to get started

## 📦 Installation

1. Download the zip or tar.gz file
2. Extract it
3. Run `./install.sh` (installs everything automatically)
4. Run `./start.sh`
5. Open http://localhost:5173

That's it! No manual configuration needed.

## 📋 Requirements

- macOS or Linux
- Internet connection (for first-time installation)
- ~5GB free space (for Ollama and model)

## 🚀 Features

- Local-first routing with confidence scoring
- Automatic fallback to Claude (Anthropic) API
- Cost tracking and savings estimation
- Persistent chat history
- Model selector (switch between local models or cloud)
- Privacy controls (`#no_cloud` tag)

## 📖 Documentation

- [README.md](README.md) - Full documentation
- [QUICK_START.txt](QUICK_START.txt) - Quick start guide
- [DISTRIBUTION.md](DISTRIBUTION.md) - Distribution guide

## 🔍 Checksums

See `local-first-router-v1.0.0.sha256` for file checksums.

## 🐛 Issues

Found a bug? Please open an issue on GitHub.

## 🙏 Thanks

Thank you for using Local-first Router!
```

---

### Step 9: Create Download Page (Optional) ✅

Create a simple `index.html` in a `docs/` folder for GitHub Pages:

```bash
mkdir -p docs
# Create a simple landing page
cat > docs/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Local-first Router</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
        h1 { color: #333; }
        .download { background: #f5f5f5; padding: 20px; border-radius: 8px; margin: 20px 0; }
        code { background: #eee; padding: 2px 6px; border-radius: 3px; }
    </style>
</head>
<body>
    <h1>🚀 Local-first Router</h1>
    <p>Smart routing between local and cloud LLMs with automatic setup.</p>
    
    <div class="download">
        <h2>📥 Download</h2>
        <p>Self-contained package - installs everything automatically!</p>
        <ul>
            <li><a href="https://github.com/YOUR_USERNAME/local-first-router/releases/latest">Latest Release on GitHub</a></li>
        </ul>
    </div>
    
    <h2>⚡ Quick Start</h2>
    <pre><code># 1. Extract
unzip local-first-router-v1.0.0.zip
cd local-first-router-v1.0.0

# 2. Install (automatic!)
./install.sh

# 3. Start
./start.sh

# 4. Open http://localhost:5173</code></pre>
    
    <h2>📖 Documentation</h2>
    <ul>
        <li><a href="https://github.com/YOUR_USERNAME/local-first-router/blob/main/README.md">README</a></li>
        <li><a href="https://github.com/YOUR_USERNAME/local-first-router/releases">Releases</a></li>
    </ul>
</body>
</html>
EOF

git add docs/
git commit -m "Add GitHub Pages landing page"
git push
```

Then enable GitHub Pages:
1. Go to repository Settings → Pages
2. Source: Deploy from branch `main` / `docs` folder
3. Your site will be at: `https://YOUR_USERNAME.github.io/local-first-router/`

---

## Quick Checklist

Before deploying to GitHub:

- [ ] Test `./install-full.sh` works
- [ ] Test `./start.sh` works
- [ ] Build package with `./package.sh 1.0.0`
- [ ] Test package on clean system
- [ ] Verify `.gitignore` excludes sensitive files
- [ ] Initialize git repository (if needed)
- [ ] Create GitHub repository
- [ ] Push code to GitHub
- [ ] Create version tag
- [ ] Build final package
- [ ] Create GitHub release
- [ ] Upload zip and tar.gz files
- [ ] Write release notes
- [ ] (Optional) Set up GitHub Pages

---

## Commands Summary

```bash
# 1. Test locally
./install-full.sh
./start.sh
# Test in browser
./stop.sh

# 2. Build package
./package.sh 1.0.0

# 3. Test package
cd /tmp
unzip local-first-router-v1.0.0.zip
cd local-first-router-v1.0.0
./install.sh
./start.sh
# Test, then cleanup

# 4. Git setup (if needed)
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/local-first-router.git
git push -u origin main

# 5. Create release
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
# Then create release on GitHub web interface and upload files
```

---

## After Deployment

Once deployed:

1. **Share the release link** with users
2. **Monitor issues** on GitHub
3. **Update documentation** based on feedback
4. **Plan next version** with improvements

---

## Troubleshooting

**Package too large for GitHub?**
- GitHub allows up to 100MB per file
- If model is included, consider hosting separately
- Or use Git LFS for large files

**Installation fails on some systems?**
- Check OS compatibility
- Add more error handling to installer
- Document system requirements

**Users report issues?**
- Create FAQ in README
- Add troubleshooting section
- Respond to GitHub issues

---

Ready to deploy! 🚀

