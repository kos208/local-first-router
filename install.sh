#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==================================${NC}"
echo -e "${BLUE}Local-first Router - Installer${NC}"
echo -e "${BLUE}==================================${NC}"
echo

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
    fi
}

# Check prerequisites
echo -e "${BLUE}📋 Checking prerequisites...${NC}"
echo

MISSING_DEPS=0

# Python
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    print_status 0 "$PYTHON_VERSION"
else
    print_status 1 "Python 3 not found"
    MISSING_DEPS=1
fi

# pip3
if command -v pip3 &> /dev/null; then
    print_status 0 "pip3 available"
else
    print_status 1 "pip3 not found"
    MISSING_DEPS=1
fi

# Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    print_status 0 "Node.js $NODE_VERSION"
else
    print_status 1 "Node.js not found"
    echo -e "${YELLOW}   Install: brew install node (macOS) or visit https://nodejs.org/${NC}"
    MISSING_DEPS=1
fi

# npm
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    print_status 0 "npm $NPM_VERSION"
else
    print_status 1 "npm not found"
    MISSING_DEPS=1
fi

# Ollama
OLLAMA_INSTALLED=0
if command -v ollama &> /dev/null; then
    print_status 0 "Ollama installed"
    OLLAMA_INSTALLED=1
else
    print_status 1 "Ollama not found"
    echo -e "${YELLOW}   Install: brew install ollama (macOS) or visit https://ollama.ai${NC}"
    echo -e "${YELLOW}   You can continue, but Ollama must be installed before running${NC}"
fi

if [ $MISSING_DEPS -eq 1 ]; then
    echo
    echo -e "${RED}Please install missing dependencies and run this script again.${NC}"
    exit 1
fi

echo
echo -e "${BLUE}==================================${NC}"
echo -e "${BLUE}📦 Installing dependencies...${NC}"
echo -e "${BLUE}==================================${NC}"
echo

# Create .env if not exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating .env from .env.example...${NC}"
    if [ -f .env.example ]; then
        cp .env.example .env
        echo -e "${YELLOW}⚠️  Please edit .env and add your ANTHROPIC_API_KEY${NC}"
    else
        echo -e "${YELLOW}⚠️  .env.example not found, creating basic .env...${NC}"
        cat > .env << EOF
# Local model
OLLAMA_BASE=http://localhost:11434
LOCAL_MODEL=llama3.2:latest
LOCAL_TEMPERATURE=0.7

# Cloud model
ANTHROPIC_BASE=https://api.anthropic.com
ANTHROPIC_API_KEY=your-key-here
CLOUD_MODEL=claude-3-haiku-20240307
CLOUD_MAX_TOKENS=1024

# Routing
CONFIDENCE_THRESHOLD=0.7
EOF
        echo -e "${YELLOW}⚠️  Please edit .env and add your ANTHROPIC_API_KEY${NC}"
    fi
    echo
fi

# Backend dependencies
echo -e "${BLUE}Installing backend dependencies...${NC}"
cd backend
if python3 -m pip install --user -r requirements.txt 2>/dev/null || \
   python3 -m pip install -r requirements.txt; then
    print_status 0 "Backend dependencies installed"
else
    print_status 1 "Failed to install backend dependencies"
    echo -e "${RED}Try: python3 -m pip install --user -r requirements.txt${NC}"
    exit 1
fi
cd ..

# Frontend dependencies
echo
echo -e "${BLUE}Installing frontend dependencies...${NC}"
cd frontend
if npm install; then
    print_status 0 "Frontend dependencies installed"
else
    print_status 1 "Failed to install frontend dependencies"
    exit 1
fi
cd ..

# Check if Ollama is running
echo
echo -e "${BLUE}Checking Ollama...${NC}"
if [ $OLLAMA_INSTALLED -eq 1 ]; then
    if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
        print_status 0 "Ollama is running"
    else
        echo -e "${YELLOW}⚠️  Ollama is not running${NC}"
        echo -e "${YELLOW}   Start it with: ollama serve${NC}"
    fi
    
    # Check for default model
    if ollama list | grep -q "llama3.2:latest"; then
        print_status 0 "Default model (llama3.2:latest) is available"
    else
        echo -e "${YELLOW}⚠️  Default model not found${NC}"
        echo -e "${YELLOW}   Pull it with: ollama pull llama3.2:latest${NC}"
    fi
fi

echo
echo -e "${BLUE}==================================${NC}"
echo -e "${GREEN}🎉 Installation Complete!${NC}"
echo -e "${BLUE}==================================${NC}"
echo
echo -e "${BLUE}Next steps:${NC}"
echo
echo -e "1. ${YELLOW}Configure .env:${NC}"
echo -e "   ${BLUE}nano .env${NC}  # or ${BLUE}code .env${NC}"
echo -e "   Add your ${BLUE}ANTHROPIC_API_KEY${NC}"
echo
if [ $OLLAMA_INSTALLED -eq 0 ]; then
    echo -e "2. ${YELLOW}Install Ollama:${NC}"
    echo -e "   ${BLUE}brew install ollama${NC}  # macOS"
    echo -e "   or visit ${BLUE}https://ollama.ai${NC}"
    echo
fi
echo -e "3. ${YELLOW}Start Ollama (if not running):${NC}"
echo -e "   ${BLUE}ollama serve &${NC}"
echo
echo -e "4. ${YELLOW}Pull a model (if not done):${NC}"
echo -e "   ${BLUE}ollama pull llama3.2:latest${NC}"
echo
echo -e "5. ${YELLOW}Start the router:${NC}"
echo -e "   ${BLUE}make start${NC}  # or run ${BLUE}make dev${NC} and ${BLUE}make dev-frontend${NC} separately"
echo
echo -e "6. ${YELLOW}Open in browser:${NC}"
echo -e "   ${BLUE}http://localhost:5173${NC}"
echo
echo -e "${BLUE}For more help, see DEPLOYMENT.md${NC}"
echo

