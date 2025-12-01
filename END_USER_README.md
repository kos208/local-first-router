# Local-First AI Router

**Smart routing between local and cloud AI models with automatic web search and OCR.**

## 🚀 Quick Start

### One-Command Installation

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/local-first-router/main/install.sh | bash
```

Or download and run:

```bash
./install.sh
```

This automatically installs:
- ✅ Python (if needed)
- ✅ Node.js (if needed)
- ✅ Ollama (if needed)
- ✅ The llama model (if needed)
- ✅ All dependencies

### Start the Router

```bash
./start.sh
```

Then open your browser to: **http://localhost:5173**

### Stop the Router

```bash
./stop.sh
```

## ✨ Features

- **Local-First**: Tries local models first, falls back to cloud only when needed
- **Smart Routing**: Automatically routes based on confidence scores
- **Web Search**: Always-on web search for current information
- **OCR Support**: Upload images and extract text automatically
- **Cost Tracking**: See how much you're saving by using local models
- **Privacy Control**: Use `#no_cloud` tag to force local-only processing

## 📋 Requirements

- macOS or Linux
- 8GB+ RAM (for Ollama)
- Internet connection (for initial setup and cloud fallback)

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

1. **Start the router**: `./start.sh`
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
2. Ensure Ollama is running: `ollama serve`
3. Check backend logs for errors

## 📝 License

See `LICENSE` file.

