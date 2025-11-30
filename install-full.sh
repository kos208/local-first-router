#!/bin/bash
set -e

# Self-contained installer that installs EVERYTHING including Ollama
# Supports: macOS, Linux

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

OS=$(detect_os)

print_header() {
    echo -e "${BLUE}==================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}==================================${NC}"
    echo
}

print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
    fi
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

print_header "Local-first Router - Self-Contained Installer"

# ============================================================
# Step 1: Install Python
# ============================================================
print_header "Step 1: Checking Python"

if command_exists python3; then
    PYTHON_VERSION=$(python3 --version)
    print_status 0 "$PYTHON_VERSION"
    
    if ! command_exists pip3; then
        print_warning "pip3 not found, installing..."
        if [ "$OS" == "macos" ]; then
            python3 -m ensurepip --upgrade
        elif [ "$OS" == "linux" ]; then
            sudo apt-get update && sudo apt-get install -y python3-pip || true
        fi
    fi
else
    print_status 1 "Python 3 not found"
    if [ "$OS" == "macos" ]; then
        print_info "Installing Python via Homebrew..."
        if command_exists brew; then
            brew install python3
        else
            print_warning "Please install Python 3 from https://www.python.org/downloads/"
            exit 1
        fi
    elif [ "$OS" == "linux" ]; then
        print_info "Installing Python..."
        sudo apt-get update && sudo apt-get install -y python3 python3-pip || \
        sudo yum install -y python3 python3-pip || true
    fi
fi

# ============================================================
# Step 2: Install Node.js
# ============================================================
print_header "Step 2: Checking Node.js"

if command_exists node; then
    NODE_VERSION=$(node --version)
    print_status 0 "Node.js $NODE_VERSION"
else
    print_warning "Node.js not found, installing..."
    
    if [ "$OS" == "macos" ]; then
        if command_exists brew; then
            print_info "Installing Node.js via Homebrew..."
            brew install node
        else
            print_warning "Please install Node.js from https://nodejs.org/"
            print_info "Or install Homebrew first: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            exit 1
        fi
    elif [ "$OS" == "linux" ]; then
        print_info "Installing Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt-get install -y nodejs || true
    fi
    
    # Verify installation
    if command_exists node; then
        print_status 0 "Node.js installed successfully"
    else
        print_status 1 "Failed to install Node.js"
        print_warning "Please install Node.js manually from https://nodejs.org/"
        exit 1
    fi
fi

# ============================================================
# Step 3: Install Ollama
# ============================================================
print_header "Step 3: Installing Ollama"

OLLAMA_INSTALLED=0
if command_exists ollama; then
    print_status 0 "Ollama is already installed"
    OLLAMA_INSTALLED=1
else
    print_info "Ollama not found, installing..."
    
    if [ "$OS" == "macos" ]; then
        if command_exists brew; then
            print_info "Installing Ollama via Homebrew..."
            brew install ollama
            OLLAMA_INSTALLED=1
        else
            print_info "Downloading Ollama installer for macOS..."
            curl -L https://ollama.ai/download/Ollama-darwin.zip -o /tmp/ollama.zip
            unzip -o /tmp/ollama.zip -d /tmp/
            sudo mv /tmp/Ollama.app/Contents/Resources/ollama /usr/local/bin/ollama
            sudo chmod +x /usr/local/bin/ollama
            rm -rf /tmp/ollama.zip /tmp/Ollama.app
            OLLAMA_INSTALLED=1
        fi
    elif [ "$OS" == "linux" ]; then
        print_info "Installing Ollama for Linux..."
        curl -fsSL https://ollama.ai/install.sh | sh
        OLLAMA_INSTALLED=1
    fi
    
    if command_exists ollama; then
        print_status 0 "Ollama installed successfully"
    else
        print_status 1 "Failed to install Ollama"
        print_warning "Please install Ollama manually from https://ollama.ai"
        exit 1
    fi
fi

# ============================================================
# Step 4: Start Ollama and Pull Model
# ============================================================
print_header "Step 4: Setting up Ollama Model"

# Check if Ollama is running
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    print_status 0 "Ollama is running"
else
    print_info "Starting Ollama server..."
    ollama serve > /dev/null 2>&1 &
    OLLAMA_PID=$!
    sleep 3
    
    # Check if it started
    if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
        print_status 0 "Ollama started successfully (PID: $OLLAMA_PID)"
    else
        print_warning "Ollama may need to be started manually: ollama serve"
    fi
fi

# Check if model exists
MODEL_NAME="llama3.2:latest"
if ollama list 2>/dev/null | grep -q "$MODEL_NAME"; then
    print_status 0 "Model $MODEL_NAME is already installed"
else
    print_info "Model not found, downloading $MODEL_NAME (this may take a while ~2-5GB)..."
    print_warning "This is a large download. Please be patient..."
    ollama pull "$MODEL_NAME"
    
    if ollama list 2>/dev/null | grep -q "$MODEL_NAME"; then
        print_status 0 "Model $MODEL_NAME downloaded successfully"
    else
        print_status 1 "Failed to download model"
        print_warning "You can download it later with: ollama pull $MODEL_NAME"
    fi
fi

# ============================================================
# Step 5: Install Application Dependencies
# ============================================================
print_header "Step 5: Installing Application Dependencies"

# Create .env if not exists
if [ ! -f .env ]; then
    print_info "Creating .env file..."
    if [ -f .env.example ]; then
        cp .env.example .env
    else
        cat > .env << 'EOF'
# Local model
OLLAMA_BASE=http://localhost:11434
LOCAL_MODEL=llama3.2:latest
LOCAL_TEMPERATURE=0.7

# Cloud model (optional - for fallback)
ANTHROPIC_BASE=https://api.anthropic.com
ANTHROPIC_API_KEY=your-key-here
CLOUD_MODEL=claude-3-haiku-20240307
CLOUD_MAX_TOKENS=1024

# Routing
CONFIDENCE_THRESHOLD=0.7
EOF
    fi
    print_warning "Created .env file. You can add your ANTHROPIC_API_KEY later if you want cloud fallback."
fi

# Backend dependencies
print_info "Installing backend dependencies..."
cd backend
if python3 -m pip install --user -r requirements.txt 2>/dev/null || \
   python3 -m pip install -r requirements.txt 2>/dev/null; then
    print_status 0 "Backend dependencies installed"
else
    print_status 1 "Failed to install backend dependencies"
    exit 1
fi
cd ..

# Frontend dependencies
print_info "Installing frontend dependencies..."
cd frontend
if npm install --silent; then
    print_status 0 "Frontend dependencies installed"
else
    print_status 1 "Failed to install frontend dependencies"
    exit 1
fi
cd ..

# ============================================================
# Step 6: Build Frontend
# ============================================================
print_header "Step 6: Building Frontend"

cd frontend
if npm run build --silent; then
    print_status 0 "Frontend built successfully"
else
    print_status 1 "Failed to build frontend"
    exit 1
fi
cd ..

# ============================================================
# Installation Complete
# ============================================================
print_header "🎉 Installation Complete!"

echo -e "${GREEN}Everything is set up and ready to go!${NC}"
echo
echo -e "${BLUE}To start the router:${NC}"
echo -e "   ${CYAN}./start.sh${NC}"
echo
echo -e "${BLUE}Or manually:${NC}"
echo -e "   ${CYAN}make start${NC}"
echo
echo -e "${BLUE}Then open in browser:${NC}"
echo -e "   ${CYAN}http://localhost:5173${NC}"
echo
echo -e "${BLUE}To stop:${NC}"
echo -e "   ${CYAN}make stop${NC}  or  ${CYAN}./stop.sh${NC}"
echo
echo -e "${YELLOW}Note:${NC} Ollama is running in the background. If you restart your computer,"
echo -e "you may need to start it again with: ${CYAN}ollama serve &${NC}"
echo

