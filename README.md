# Local-First AI Router

**Smart routing between local and cloud AI models with automatic web search and OCR.**

## 🚀 Quick Start

### One-Command Installation

**macOS/Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/local-first-router/main/install.sh | bash
```

Or download and run:
```bash
./install.sh
```

**Windows:**
```powershell
# Download the package, extract it, then:
.\install.ps1
```

This automatically installs:
- ✅ Python (if needed)
- ✅ Node.js (if needed)
- ✅ Ollama (if needed)
- ✅ The llama model (if needed)
- ✅ All dependencies

### Start the Router

**macOS/Linux:**
```bash
./start.sh
```

**Windows:**
```powershell
.\start.ps1
```

Then open your browser to: **http://localhost:5173**

### Stop the Router

**macOS/Linux:**
```bash
./stop.sh
```

**Windows:**
```powershell
.\stop.ps1
```

## ✨ Features

- **Local-First**: Tries local models first, falls back to cloud only when needed
- **Smart Routing**: Automatically routes based on confidence scores
- **Web Search**: Always-on web search for current information
- **OCR Support**: Upload images and extract text automatically
- **Cost Tracking**: See how much you're saving by using local models
- **Privacy Control**: Use `#no_cloud` tag to force local-only processing

## 📋 Requirements

- **macOS, Linux, or Windows**: Full support with one-command installer
- 8GB+ RAM (for Ollama)
- Internet connection (for initial setup and cloud fallback)

**Windows users**: Run `.\install.ps1` in PowerShell. The installer uses `winget` (Windows Package Manager) if available, otherwise it will guide you to install dependencies manually.

## ⚙️ Configuration

Edit `.env` to customize:

```bash
# Cloud API (optional - for fallback)
ANTHROPIC_API_KEY=sk-ant-...

# Local Model
LOCAL_MODEL=llama3.1:8b-instruct-q4_K_M

# Web Search (enabled by default)
ENABLE_WEB_SEARCH=true
```

## 🎯 Usage

1. **Start the router**: 
   - macOS/Linux: `./start.sh`
   - Windows: `.\start.ps1`
2. **Open browser**: http://localhost:5173
3. **Chat**: Ask questions, upload images, get answers
4. **Web search**: Happens automatically for current information
5. **OCR**: Click 📷 to upload images with text

## 📖 Documentation

- **Quick Start**: See `QUICK_START.txt`
- **Troubleshooting**: See `TROUBLESHOOT.md`
- **Deployment**: See `DEPLOYMENT.md`

## 🆘 Support

If you encounter issues:
1. Check `TROUBLESHOOT.md`
2. Ensure Ollama is running:
   - macOS/Linux: `ollama serve`
   - Windows: Ollama should start automatically, or run `ollama serve` manually
3. Check backend logs for errors
4. **Windows users**: See `WINDOWS_SUPPORT.md` for Windows-specific help

## 📝 License

See `LICENSE` file.

