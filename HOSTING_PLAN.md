# Hosting & Distribution Plan

## Goal
1. **Host online**: Users can access router via URL (e.g., `https://router.yoursite.com`)
2. **Download package**: Users download a ready-to-run package for local installation

---

## Part 1: Online Hosting

### Architecture Options

#### Option A: Cloud Platform (Recommended)
- **Frontend**: Static hosting (Vercel, Netlify, Cloudflare Pages)
- **Backend**: Server hosting (Railway, Render, Fly.io, DigitalOcean App Platform)
- **Ollama**: Cannot run on most platforms (8GB+ RAM needed)
  - **Solution**: Run Ollama separately on user's machine OR use cloud Ollama service

#### Option B: VPS/Server
- **Full stack on one server** (DigitalOcean Droplet, AWS EC2, etc.)
- All services together
- Requires server management

#### Option C: Hybrid
- **Online demo**: Cloud-hosted backend (no Ollama, cloud-only mode)
- **Local download**: Full package with Ollama support

### Recommended Setup: Hybrid Approach

**Online Demo Site:**
- Frontend: Vercel/Netlify (free tier)
- Backend: Railway/Render (free/paid tier)
- Mode: Cloud-only (Claude API only, no local Ollama)
- Purpose: Demo, try before download

**Local Download:**
- Full package with all files
- Includes setup scripts
- Users run Ollama locally

---

## Part 2: Downloadable Package

### Package Contents

```
local-first-router-v1.0.0/
├── README.md                    # Quick start guide
├── START_HERE.txt              # Simple instructions
├── install.sh                   # Automated installer
├── start.sh                     # Simple start script
├── .env.example                 # Environment template
├── backend/                     # Full backend code
│   ├── app/
│   ├── requirements.txt
│   └── ...
├── frontend/                    # Frontend code + pre-built dist/
│   ├── dist/                    # Pre-built static files
│   ├── src/
│   └── ...
├── docker-compose.yml           # Docker option
├── docker-compose.full.yml      # Docker with Ollama
└── QUICK_START.txt             # Step-by-step guide
```

### Package Creation Script

A script that:
1. Builds frontend (`npm run build`)
2. Creates clean package (excludes node_modules, .git, etc.)
3. Includes pre-built frontend
4. Creates zip/tar.gz archive
5. Generates checksums

---

## Implementation Steps

### Step 1: Create Package Builder Script
- Script to build and package everything
- Outputs: `local-first-router-v1.0.0.zip` and `.tar.gz`

### Step 2: Create Simple Start Script
- `start.sh` / `start.bat` for cross-platform
- Detects platform, starts services

### Step 3: Online Hosting Setup
- Deploy frontend to static host
- Deploy backend to cloud platform
- Configure cloud-only mode
- Set up domain/URL

### Step 4: Download Page
- Create landing page
- Host download package
- Include installation instructions

---

## File Structure for Download Package

### Minimal Download (Recommended)
- Source code
- Pre-built frontend (`dist/`)
- Scripts (install.sh, start.sh)
- Documentation

### User Runs:
```bash
# Download and extract
unzip local-first-router-v1.0.0.zip
cd local-first-router-v1.0.0

# Install dependencies
./install.sh

# Start
./start.sh
```

---

## Online Hosting Details

### Frontend Deployment
**Platform**: Vercel / Netlify / Cloudflare Pages
- Build command: `cd frontend && npm run build`
- Output: `frontend/dist`
- Environment: Point API to backend URL

### Backend Deployment
**Platform**: Railway / Render / Fly.io
- Build: Docker or direct Python
- Environment variables from `.env`
- Port: 8001 (or configured)

### Configuration for Cloud Mode
- Set `OLLAMA_BASE` to empty or disable local routing
- Force cloud-only mode
- Or allow local Ollama if user configures it

---

## Next Steps

1. ✅ Create package builder script
2. ✅ Create simple start scripts
3. ✅ Prepare online hosting configuration
4. ✅ Create download landing page
5. ✅ Set up hosting infrastructure

Would you like me to proceed with implementing these?

