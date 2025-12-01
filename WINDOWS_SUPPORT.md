# Windows Support

## Current Status

**Installer**: ❌ Not yet supported (bash script for macOS/Linux only)  
**Application**: ✅ Can work on Windows (with manual setup)

## Why the Installer Doesn't Work on Windows

The current `install.sh` is a bash script that:
- Uses Unix commands (`bash`, `curl`, etc.)
- Detects macOS/Linux only
- Uses package managers like `brew` and `apt-get`

## Windows Options

### Option 1: WSL (Windows Subsystem for Linux) - Recommended

Run the Linux version in WSL:

1. **Install WSL:**
   ```powershell
   wsl --install
   ```

2. **Follow Linux installation instructions:**
   - The installer will work in WSL
   - Ollama works in WSL
   - Everything runs in Linux environment

### Option 2: Manual Windows Setup

The application code itself works on Windows, but requires manual setup:

1. **Install Prerequisites:**
   - Python 3.11+ from https://www.python.org/downloads/
   - Node.js 18+ from https://nodejs.org/
   - Ollama from https://ollama.com/download/windows

2. **Install Ollama Model:**
   ```powershell
   ollama pull llama3.1:8b-instruct-q4_K_M
   ```

3. **Setup Project:**
   ```powershell
   # Install backend dependencies
   cd backend
   pip install -r requirements.txt
   
   # Install frontend dependencies
   cd ..\frontend
   npm install
   npm run build
   ```

4. **Run:**
   ```powershell
   # Terminal 1 - Backend
   cd backend
   python -m uvicorn app.main:app --reload --port 8001
   
   # Terminal 2 - Frontend (serve built files)
   cd frontend
   npx serve dist
   ```

### Option 3: Docker (Windows)

Use Docker Desktop for Windows:

```powershell
docker-compose up -d
```

## What Needs to Be Added for Full Windows Support

1. **PowerShell Installer** (`install.ps1`):
   - Detect Windows
   - Install Python/Node.js via Chocolatey or direct download
   - Install Ollama
   - Setup project

2. **Windows Batch Scripts**:
   - `start.bat` instead of `start.sh`
   - `stop.bat` instead of `stop.sh`

3. **Windows-Specific Paths**:
   - Handle Windows paths in Python code
   - Tesseract OCR path detection for Windows

## Current Limitations

- ❌ No Windows installer script
- ⚠️ OCR (Tesseract) needs manual Windows installation
- ⚠️ Shell scripts won't run natively (need WSL or Git Bash)

## Recommendation

For Windows users, **WSL is the easiest path** - it makes the Linux installer work perfectly.

