# Quick Deployment Guide

Choose the deployment method that fits your needs:

## 🚀 Fastest: One-Command Installer

**For**: Local development, quick testing

```bash
git clone <repo-url> local-first-router
cd local-first-router
./install.sh
make start
```

Open http://localhost:5173

---

## 🐳 Production: Docker Compose

**For**: Production, consistent environments, teams

### Full Docker (includes Ollama)

```bash
# 1. Clone and configure
git clone <repo-url> local-first-router
cd local-first-router
cp .env.example .env
nano .env  # Add ANTHROPIC_API_KEY

# 2. Start everything
docker-compose -f docker-compose.full.yml up -d

# 3. Pull model (first time only)
docker exec local-first-router-ollama ollama pull llama3.2:latest

# 4. Access
# Frontend: http://localhost:5173
# Backend: http://localhost:8001
```

### Docker (Ollama on host - better performance)

```bash
# 1. Install Ollama on host
brew install ollama  # macOS
# or: curl -fsSL https://ollama.ai/install.sh | sh  # Linux

# 2. Start Ollama
ollama serve &
ollama pull llama3.2:latest

# 3. Start router
git clone <repo-url> local-first-router
cd local-first-router
cp .env.example .env
nano .env  # Add ANTHROPIC_API_KEY
docker-compose up -d
```

---

## 📦 Platform-Specific

### macOS (Homebrew - future)

```bash
brew install yourusername/tap/local-first-router
local-first-router start
```

### Linux (systemd service)

```bash
# Install
./install.sh

# Create systemd service
sudo cp local-first-router.service /etc/systemd/system/
sudo systemctl enable local-first-router
sudo systemctl start local-first-router
```

---

## ☁️ Cloud Deployment

### VPS (DigitalOcean, AWS, etc.)

```bash
# On your server
git clone <repo-url> local-first-router
cd local-first-router

# Install Docker
curl -fsSL https://get.docker.com | sh

# Configure
cp .env.example .env
nano .env

# Start
docker-compose -f docker-compose.full.yml up -d

# Set up nginx reverse proxy with SSL
sudo apt install nginx certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com
```

---

## Comparison

| Method | Time | Complexity | Best For |
|--------|------|------------|----------|
| Installer script | 2 min | ⭐ Easy | Local dev |
| Docker (full) | 5 min | ⭐⭐ Medium | Production |
| Docker (host Ollama) | 3 min | ⭐⭐ Medium | Better performance |
| Cloud VPS | 15 min | ⭐⭐⭐ Hard | Remote access |

---

## Troubleshooting

**Port conflicts?**
```bash
# Kill processes on ports
lsof -ti:8001 | xargs kill -9
lsof -ti:5173 | xargs kill -9
lsof -ti:11434 | xargs kill -9
```

**Docker issues?**
```bash
# Check logs
docker-compose -f docker-compose.full.yml logs

# Restart
docker-compose -f docker-compose.full.yml restart
```

**Ollama not responding?**
```bash
# Check if running
curl http://localhost:11434/api/tags

# Restart Ollama
docker restart local-first-router-ollama
# or if on host:
pkill ollama && ollama serve &
```

---

For more details, see [DEPLOYMENT.md](DEPLOYMENT.md)

