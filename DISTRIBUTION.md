# Distribution Guide

## Overview

This guide covers how to:
1. **Create a downloadable package** that's completely self-contained
2. **Host the router online** for users to try before downloading

---

## Part 1: Creating the Download Package

### Quick Build

```bash
# Build and package everything
./package.sh 1.0.0
```

This creates:
- `local-first-router-v1.0.0/` - Full directory
- `local-first-router-v1.0.0.zip` - ZIP archive
- `local-first-router-v1.0.0.tar.gz` - TAR.GZ archive
- `local-first-router-v1.0.0.sha256` - Checksums

### Package Contents

The package includes:
- ✅ Pre-built frontend (`frontend/dist/`)
- ✅ All source code
- ✅ `install.sh` - Self-contained installer that installs EVERYTHING:
  - Python (if missing)
  - Node.js (if missing)
  - Ollama (if missing)
  - The llama model (if missing)
  - All dependencies
- ✅ `start.sh` - Simple start script
- ✅ `stop.sh` - Simple stop script
- ✅ `QUICK_START.txt` - Instructions
- ✅ `START_HERE.txt` - First-time user guide

### User Experience

1. **Download** the zip/tar.gz
2. **Extract** it
3. **Run** `./install.sh` (one command)
4. **Run** `./start.sh` (one command)
5. **Open** http://localhost:5173

That's it! Everything is automatic.

---

## Part 2: Hosting Online

### Option A: Demo Site (Cloud-only Mode)

Host a demo where users can try the router without installing anything.

**Setup:**
1. Deploy frontend to Vercel/Netlify
2. Deploy backend to Railway/Render
3. Configure for cloud-only mode (no Ollama)

**Benefits:**
- Users can try it immediately
- No installation required
- Good for showcasing

### Option B: Full Online Router

Host the complete router with Ollama on a VPS.

**Requirements:**
- VPS with 8GB+ RAM (for Ollama)
- Docker installed
- Domain name (optional)

**Setup:**
```bash
# On your VPS
git clone <repo> local-first-router
cd local-first-router
cp .env.example .env
# Edit .env with your settings

# Start everything
docker-compose -f docker-compose.full.yml up -d

# Pull model
docker exec local-first-router-ollama ollama pull llama3.2:latest

# Set up nginx reverse proxy with SSL
sudo apt install nginx certbot
# Configure nginx to proxy to localhost:5173
sudo certbot --nginx -d router.yourdomain.com
```

---

## Part 3: Distribution Channels

### GitHub Releases

1. Create a new release on GitHub
2. Upload the zip and tar.gz files
3. Add release notes

**Example workflow:**
```bash
# Build package
./package.sh 1.0.0

# Tag and push
git tag v1.0.0
git push origin v1.0.0

# Create GitHub release and upload:
# - local-first-router-v1.0.0.zip
# - local-first-router-v1.0.0.tar.gz
# - local-first-router-v1.0.0.sha256
```

### Your Own Website

1. Create a download page
2. Host the zip/tar.gz files
3. Provide checksums for verification
4. Link to documentation

### Package Managers

#### Homebrew (macOS)
Create a Homebrew formula:
```ruby
class LocalFirstRouter < Formula
  desc "Local-first LLM router"
  homepage "https://your-site.com"
  url "https://github.com/yourusername/local-first-router/releases/download/v1.0.0/local-first-router-v1.0.0.tar.gz"
  sha256 "<checksum>"
  
  depends_on "python@3.11"
  depends_on "node"
  depends_on "ollama"
  
  def install
    # Installation logic
  end
end
```

---

## Part 4: Landing Page Template

Create a simple landing page:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Local-first Router - Download</title>
</head>
<body>
    <h1>Local-first Router</h1>
    <p>Smart routing between local and cloud LLMs</p>
    
    <h2>Try Online</h2>
    <a href="https://router.yourdomain.com">Demo Site</a>
    
    <h2>Download</h2>
    <p>Self-contained package - installs everything automatically</p>
    <ul>
        <li><a href="local-first-router-v1.0.0.zip">Download ZIP (macOS/Linux/Windows)</a></li>
        <li><a href="local-first-router-v1.0.0.tar.gz">Download TAR.GZ (Linux/macOS)</a></li>
    </ul>
    
    <h3>Installation</h3>
    <pre>
# 1. Extract the archive
unzip local-first-router-v1.0.0.zip
cd local-first-router-v1.0.0

# 2. Run installer (installs everything automatically)
./install.sh

# 3. Start the router
./start.sh

# 4. Open http://localhost:5173
    </pre>
    
    <h3>Checksums</h3>
    <pre>See local-first-router-v1.0.0.sha256</pre>
</body>
</html>
```

---

## Testing the Package

Before distributing:

1. **Test on clean system:**
   ```bash
   # Create a test VM or use a different machine
   # Extract package
   # Run install.sh
   # Verify everything works
   ```

2. **Test all platforms:**
   - macOS
   - Linux (Ubuntu, Debian, etc.)
   - Windows (via WSL or native)

3. **Verify:**
   - ✅ Installer works
   - ✅ Ollama installs automatically
   - ✅ Model downloads automatically
   - ✅ Application starts correctly
   - ✅ Frontend loads
   - ✅ Backend responds

---

## Automation

### GitHub Actions

Create `.github/workflows/package.yml`:

```yaml
name: Build Package

on:
  release:
    types: [created]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - uses: actions/setup-python@v4
      
      - name: Build frontend
        run: |
          cd frontend
          npm install
          npm run build
      
      - name: Create package
        run: ./package.sh ${{ github.event.release.tag_name }}
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: package
          path: local-first-router-*.{zip,tar.gz,sha256}
```

---

## Checklist Before Distribution

- [ ] Package builds successfully
- [ ] Installer script works on clean system
- [ ] All dependencies are automatically installed
- [ ] Ollama installs automatically
- [ ] Model downloads automatically
- [ ] Application starts correctly
- [ ] Frontend is pre-built
- [ ] Documentation is included
- [ ] Checksums are generated
- [ ] Tested on target platforms
- [ ] Release notes are written
- [ ] Landing page is ready

---

## Next Steps

1. **Build the package:**
   ```bash
   ./package.sh 1.0.0
   ```

2. **Test it:**
   - Extract to a clean directory
   - Run `./install.sh`
   - Verify everything works

3. **Host online:**
   - Deploy demo site (optional)
   - Create landing page
   - Host download files

4. **Distribute:**
   - Upload to GitHub Releases
   - Share download link
   - Create documentation

---

Ready to distribute! 🚀

