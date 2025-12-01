#!/bin/bash
set -e

# Package builder script - creates ready-to-distribute package

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

VERSION=${1:-"1.0.0"}
PACKAGE_NAME="local-first-router-v${VERSION}"

echo -e "${BLUE}==================================${NC}"
echo -e "${BLUE}Building Package: ${PACKAGE_NAME}${NC}"
echo -e "${BLUE}==================================${NC}"
echo

# Step 1: Build frontend
echo -e "${BLUE}Step 1: Building frontend...${NC}"
cd frontend
if npm run build; then
    echo -e "${GREEN}✅ Frontend built${NC}"
else
    echo -e "${YELLOW}⚠️  Frontend build failed, continuing anyway...${NC}"
fi
cd ..

# Step 2: Create package directory
echo -e "${BLUE}Step 2: Creating package structure...${NC}"
rm -rf "${PACKAGE_NAME}"
mkdir -p "${PACKAGE_NAME}"

# Step 3: Copy essential files
echo -e "${BLUE}Step 3: Copying files...${NC}"

# Root files - use end-user README if available
if [ -f END_USER_README.md ]; then
    cp END_USER_README.md "${PACKAGE_NAME}/README.md"
else
    cp README.md "${PACKAGE_NAME}/"
fi
cp LICENSE "${PACKAGE_NAME}/" 2>/dev/null || true
cp Makefile "${PACKAGE_NAME}/"
# Unix scripts
cp install-full.sh "${PACKAGE_NAME}/install.sh"
cp start.sh "${PACKAGE_NAME}/"
cp stop.sh "${PACKAGE_NAME}/"
# Windows scripts
cp install.ps1 "${PACKAGE_NAME}/" 2>/dev/null || true
cp start.ps1 "${PACKAGE_NAME}/" 2>/dev/null || true
cp stop.ps1 "${PACKAGE_NAME}/" 2>/dev/null || true
cp WINDOWS_SUPPORT.md "${PACKAGE_NAME}/" 2>/dev/null || true
cp QUICK_START.txt "${PACKAGE_NAME}/" 2>/dev/null || echo "QUICK_START.txt not found, will create one"

# Backend
mkdir -p "${PACKAGE_NAME}/backend"
cp -r backend/app "${PACKAGE_NAME}/backend/"
cp backend/requirements.txt "${PACKAGE_NAME}/backend/"
cp backend/pyproject.toml "${PACKAGE_NAME}/backend/" 2>/dev/null || true
cp backend/Dockerfile "${PACKAGE_NAME}/backend/" 2>/dev/null || true

# Frontend (with built dist)
mkdir -p "${PACKAGE_NAME}/frontend"
cp -r frontend/dist "${PACKAGE_NAME}/frontend/" 2>/dev/null || true
cp frontend/package.json "${PACKAGE_NAME}/frontend/"
cp frontend/package-lock.json "${PACKAGE_NAME}/frontend/" 2>/dev/null || true
cp frontend/vite.config.ts "${PACKAGE_NAME}/frontend/"
cp frontend/tailwind.config.js "${PACKAGE_NAME}/frontend/"
cp frontend/tsconfig.json "${PACKAGE_NAME}/frontend/"
cp frontend/index.html "${PACKAGE_NAME}/frontend/"

# Docker files
cp docker-compose.yml "${PACKAGE_NAME}/" 2>/dev/null || true
cp docker-compose.full.yml "${PACKAGE_NAME}/" 2>/dev/null || true

# Create .env.example
cat > "${PACKAGE_NAME}/.env.example" << 'EOF'
# Local model
OLLAMA_BASE=http://localhost:11434
LOCAL_MODEL=llama3.1:8b-instruct-q4_K_M
LOCAL_TEMPERATURE=0.7

# Cloud model (optional - for fallback)
# Get your API key from: https://console.anthropic.com/
ANTHROPIC_BASE=https://api.anthropic.com
ANTHROPIC_API_KEY=your-key-here
CLOUD_MODEL=claude-3-haiku-20240307
CLOUD_MAX_TOKENS=1024

# Routing
CONFIDENCE_THRESHOLD=0.7

# Web Search (enabled by default)
ENABLE_WEB_SEARCH=true
WEB_SEARCH_MAX_RESULTS=5
EOF

# Create QUICK_START.txt if it doesn't exist
if [ ! -f "${PACKAGE_NAME}/QUICK_START.txt" ]; then
    cat > "${PACKAGE_NAME}/QUICK_START.txt" << 'EOF'
# Quick Start Guide

## Installation (All-in-One)

Just run the installer - it will install everything automatically:

  macOS/Linux:
    ./install.sh

  Windows:
    .\install.ps1

This will:
  ✅ Install Python (if needed)
  ✅ Install Node.js (if needed)
  ✅ Install Ollama (if needed)
  ✅ Download the llama3.1:8b-instruct-q4_K_M model (if needed)
  ✅ Install all application dependencies
  ✅ Build the frontend

## Start the Router

  macOS/Linux:
    ./start.sh

  Windows:
    .\start.ps1

Then open: http://localhost:5173

## Stop the Router

  macOS/Linux:
    ./stop.sh

  Windows:
    .\stop.ps1

## Troubleshooting

- If Ollama isn't running: ollama serve (or start Ollama service on Windows)
- To check models: ollama list
- To pull model: ollama pull llama3.1:8b-instruct-q4_K_M

For more help, see README.md or WINDOWS_SUPPORT.md
EOF
fi

# Create START_HERE.txt
cat > "${PACKAGE_NAME}/START_HERE.txt" << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║          Local-first Router - Quick Start                    ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

🚀 INSTALLATION:

    macOS/Linux:
        ./install.sh

    Windows:
        .\install.ps1

    This will automatically install:
    • Python (if needed)
    • Node.js (if needed)  
    • Ollama (if needed)
    • The llama model (if needed)
    • All dependencies

🎬 START THE ROUTER:

    macOS/Linux:
        ./start.sh

    Windows:
        .\start.ps1

    Then open: http://localhost:5173

⏹️  STOP:

    macOS/Linux:
        ./stop.sh

    Windows:
        .\stop.ps1

📖 For detailed instructions, see QUICK_START.txt or README.md
EOF

# Make scripts executable
chmod +x "${PACKAGE_NAME}/install.sh"
chmod +x "${PACKAGE_NAME}/start.sh"
chmod +x "${PACKAGE_NAME}/stop.sh"

# Step 4: Create archives
echo -e "${BLUE}Step 4: Creating archives...${NC}"

# Create zip
if command -v zip >/dev/null 2>&1; then
    zip -r "${PACKAGE_NAME}.zip" "${PACKAGE_NAME}" -x "*.git*" "*.DS_Store*" "*/node_modules/*" "*/__pycache__/*"
    echo -e "${GREEN}✅ Created ${PACKAGE_NAME}.zip${NC}"
fi

# Create tar.gz
cd "${PACKAGE_NAME}"
tar -czf "../${PACKAGE_NAME}.tar.gz" . 2>/dev/null || tar -czf "../${PACKAGE_NAME}.tar.gz" *
cd ..
echo -e "${GREEN}✅ Created ${PACKAGE_NAME}.tar.gz${NC}"

# Calculate checksums
if command -v shasum >/dev/null 2>&1; then
    echo -e "${BLUE}Checksums:${NC}"
    shasum -a 256 "${PACKAGE_NAME}.zip" "${PACKAGE_NAME}.tar.gz" > "${PACKAGE_NAME}.sha256" 2>/dev/null || true
    cat "${PACKAGE_NAME}.sha256"
fi

echo
echo -e "${GREEN}==================================${NC}"
echo -e "${GREEN}✅ Package created successfully!${NC}"
echo -e "${GREEN}==================================${NC}"
echo
echo -e "Package directory: ${BLUE}${PACKAGE_NAME}${NC}"
echo -e "Archive files:"
echo -e "  • ${BLUE}${PACKAGE_NAME}.zip${NC}"
echo -e "  • ${BLUE}${PACKAGE_NAME}.tar.gz${NC}"
echo
echo -e "Ready to distribute! 🎉"

