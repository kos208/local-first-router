# Deployment Guide

This guide covers multiple deployment options, from simplest to production-ready.

## Option 1: One-Command Installer (Simplest) ⭐

**Best for**: Quick local setup, developers, macOS/Linux users

### macOS/Linux

```bash
# Clone and run installer
git clone <your-repo-url> local-first-router
cd local-first-router
chmod +x install.sh
./install.sh
```

The installer will:
- ✅ Check prerequisites (Python, Node.js, Ollama)
- ✅ Install all dependencies
- ✅ Set up `.env` file
- ✅ Pull default Ollama model
- ✅ Start all services

**Start services:**
```bash
make start  # Starts backend + frontend
```

**Stop services:**
```bash
make stop
```

---

## Option 2: Docker Compose (Recommended) 🐳

**Best for**: Consistent deployment, production, cross-platform

### Full Docker Setup (includes Ollama)

```bash
# Clone repository
git clone <your-repo-url> local-first-router
cd local-first-router

# Copy and configure environment
cp .env.example .env
# Edit .env and add ANTHROPIC_API_KEY

# Start everything (including Ollama)
docker-compose -f docker-compose.full.yml up -d

# Check status
docker-compose -f docker-compose.full.yml ps

# View logs
docker-compose -f docker-compose.full.yml logs -f
```

**Access:**
- Frontend: http://localhost:5173
- Backend API: http://localhost:8001
- Ollama: http://localhost:11434

**Stop:**
```bash
docker-compose -f docker-compose.full.yml down
```

### Docker Compose (Ollama on host)

If you prefer Ollama running natively (better performance):

```bash
# 1. Install Ollama on host
# macOS: brew install ollama
# Linux: curl -fsSL https://ollama.ai/install.sh | sh

# 2. Start Ollama
ollama serve &

# 3. Pull model
ollama pull llama3.2:latest

# 4. Start router services
docker-compose up -d
```

---

## Option 3: Standalone Binary (Future)

**Best for**: Non-technical users, single executable

*Note: This would require packaging Python + Node.js into a single binary using tools like PyInstaller + Electron, or creating platform-specific installers.*

**Potential approaches:**
- **macOS**: Create `.dmg` installer with bundled dependencies
- **Windows**: Create `.exe` installer with NSIS/Inno Setup
- **Linux**: Create `.AppImage` or `.deb`/`.rpm` package

---

## Option 4: Cloud Deployment

### VPS Deployment (DigitalOcean, AWS EC2, etc.)

```bash
# On your VPS
git clone <your-repo-url> local-first-router
cd local-first-router

# Install Docker
curl -fsSL https://get.docker.com | sh

# Configure environment
cp .env.example .env
nano .env  # Add your API keys

# Start services
docker-compose -f docker-compose.full.yml up -d

# Set up reverse proxy (nginx)
sudo apt install nginx
# Configure nginx to proxy to localhost:5173
```

### Platform-as-a-Service

**Heroku/Railway/Render:**
- Deploy backend as Python service
- Deploy frontend as static site
- Use external Ollama service or cloud Ollama

**Note**: Ollama requires significant resources, so cloud Ollama services may be needed.

---

## Option 5: Homebrew Tap (macOS)

**Best for**: macOS users who want `brew install` simplicity

Create a Homebrew formula:

```ruby
# Formula file: local-first-router.rb
class LocalFirstRouter < Formula
  desc "Local-first LLM router"
  homepage "https://github.com/yourusername/local-first-router"
  url "https://github.com/yourusername/local-first-router/archive/v1.0.0.tar.gz"
  
  depends_on "python@3.11"
  depends_on "node"
  depends_on "ollama"
  
  def install
    # Installation logic
  end
end
```

Users install with:
```bash
brew install yourusername/tap/local-first-router
```

---

## Comparison Table

| Method | Complexity | Best For | Pros | Cons |
|--------|-----------|----------|------|------|
| **One-Command Installer** | ⭐ Easy | Developers, local use | Fast setup, flexible | Requires manual deps |
| **Docker Compose** | ⭐⭐ Medium | Production, teams | Isolated, consistent | Requires Docker |
| **Standalone Binary** | ⭐⭐⭐ Hard | End users | No deps needed | Large file size |
| **Cloud VPS** | ⭐⭐ Medium | Remote access | Accessible anywhere | Ongoing costs |
| **Homebrew Tap** | ⭐⭐⭐ Hard | macOS power users | Native feel | macOS only |

---

## Production Checklist

For production deployment, consider:

- [ ] Set up reverse proxy (nginx/Caddy) with SSL
- [ ] Configure environment variables securely
- [ ] Set up monitoring (health checks, logs)
- [ ] Configure backups for SQLite database
- [ ] Set resource limits for Docker containers
- [ ] Enable rate limiting on API
- [ ] Set up log rotation
- [ ] Configure firewall rules
- [ ] Use process manager (systemd/supervisor) for non-Docker
- [ ] Set up CI/CD for updates

---

## Troubleshooting Deployment

### Docker Issues

**Port already in use:**
```bash
# Find and kill process
lsof -ti:8001 | xargs kill -9
lsof -ti:5173 | xargs kill -9
```

**Ollama not accessible from Docker:**
```bash
# On Linux, use host network mode
# On macOS/Windows, use host.docker.internal
```

### Permission Issues

```bash
# Fix Docker permissions (Linux)
sudo usermod -aG docker $USER
# Log out and back in
```

### Resource Limits

Ollama needs significant RAM. For Docker:
```yaml
# In docker-compose.yml
services:
  ollama:
    deploy:
      resources:
        limits:
          memory: 8G
```

---

## Next Steps

1. Choose your deployment method
2. Follow the specific instructions above
3. Test the installation
4. Configure your `.env` file
5. Start using the router!

For help, see `TROUBLESHOOT.md` or open an issue.

