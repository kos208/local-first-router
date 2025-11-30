#!/bin/bash
set -e

echo "=================================="
echo "Local-first Router - Setup Script"
echo "=================================="
echo

# Check prerequisites
echo "📋 Checking prerequisites..."
echo

# Python
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo "✅ $PYTHON_VERSION"
else
    echo "❌ Python 3 not found"
    exit 1
fi

# pip3
if command -v pip3 &> /dev/null; then
    echo "✅ pip3 available"
else
    echo "❌ pip3 not found"
    exit 1
fi

# Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo "✅ Node.js $NODE_VERSION"
else
    echo "❌ Node.js not found"
    echo ""
    echo "Please install Node.js first:"
    echo "  brew install node"
    echo "  or download from https://nodejs.org/"
    exit 1
fi

# npm
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo "✅ npm $NPM_VERSION"
else
    echo "❌ npm not found"
    exit 1
fi

# Ollama
if command -v ollama &> /dev/null; then
    echo "✅ Ollama installed"
else
    echo "⚠️  Ollama not found"
    echo ""
    echo "Please install Ollama first:"
    echo "  brew install ollama"
    echo "  or visit https://ollama.ai"
fi

echo
echo "=================================="
echo "📦 Installing dependencies..."
echo "=================================="
echo

# Copy .env if not exists
if [ ! -f .env ]; then
    echo "Creating .env from .env.example..."
    cp .env.example .env
    echo "⚠️  Please edit .env and add your ANTHROPIC_API_KEY"
fi

# Backend dependencies
echo
echo "Installing backend dependencies..."
cd backend
if pip3 install -r requirements.txt; then
    echo "✅ Backend dependencies installed"
else
    echo "❌ Failed to install backend dependencies"
    echo "Try: pip3 install --user -r requirements.txt"
    exit 1
fi
cd ..

# Frontend dependencies
echo
echo "Installing frontend dependencies..."
cd frontend
if npm install; then
    echo "✅ Frontend dependencies installed"
else
    echo "❌ Failed to install frontend dependencies"
    exit 1
fi
cd ..

echo
echo "=================================="
echo "🎉 Setup Complete!"
echo "=================================="
echo
echo "Next steps:"
echo
echo "1. Make sure Ollama is running:"
echo "   ollama serve &"
echo
echo "2. Pull a model:"
echo "   ollama pull llama3.2:latest"
echo "   # optional: ollama pull llama3.1:8b-instruct-q4_K_M"
echo
echo "3. Run the backend (Terminal 1):"
echo "   cd /Users/elias/local-first-router/backend"
echo "   python3 -m uvicorn app.main:app --reload --port 8001"
echo
echo "4. Run the frontend (Terminal 2):"
echo "   cd /Users/elias/local-first-router/frontend"
echo "   npm run dev"
echo
echo "5. Open http://localhost:5173 in your browser"
echo
echo "For more help, see FIX_SETUP.md"
echo

