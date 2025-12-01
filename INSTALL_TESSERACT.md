# Install Tesseract OCR

## Quick Install (Recommended)

Run this command in your terminal:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then install Tesseract:

```bash
brew install tesseract
```

## Alternative: If Homebrew is Already Installed

If Homebrew is installed but not in your PATH, try:

```bash
# For Apple Silicon Macs:
/opt/homebrew/bin/brew install tesseract

# For Intel Macs:
/usr/local/bin/brew install tesseract
```

## Verify Installation

After installation, verify it works:

```bash
tesseract --version
```

## Restart Backend

After installing Tesseract, restart the backend:

```bash
cd /Users/elias/local-first-router
pkill -f "uvicorn app.main:app"
make dev
```

## Status

✅ Python packages installed (pytesseract, Pillow)
⏳ Tesseract OCR needs to be installed manually (requires sudo/admin access)

Once Tesseract is installed, OCR functionality will be fully enabled!

