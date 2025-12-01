# Self-contained installer for Windows
# Installs Python, Node.js, Ollama, and all dependencies

$ErrorActionPreference = "Stop"

# Colors for output
function Write-Header {
    param([string]$Message)
    Write-Host "==================================" -ForegroundColor Blue
    Write-Host $Message -ForegroundColor Blue
    Write-Host "==================================" -ForegroundColor Blue
    Write-Host ""
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Cyan
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

Write-Header "Local-first Router - Windows Installer"

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warning "Some installations may require administrator privileges."
    Write-Info "If you encounter permission errors, run PowerShell as Administrator."
}

# ============================================================
# Step 1: Check/Install Python
# ============================================================
Write-Header "Step 1: Checking Python"

$pythonInstalled = $false
if (Get-Command python -ErrorAction SilentlyContinue) {
    $pythonVersion = python --version 2>&1
    Write-Success $pythonVersion
    $pythonInstalled = $true
} elseif (Get-Command python3 -ErrorAction SilentlyContinue) {
    $pythonVersion = python3 --version 2>&1
    Write-Success $pythonVersion
    $pythonInstalled = $true
}

if (-not $pythonInstalled) {
    Write-Info "Python not found. Installing..."
    
    # Try using winget (Windows Package Manager)
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Info "Installing Python via winget..."
        winget install Python.Python.3.11 --silent --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Python installed via winget"
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            $pythonInstalled = $true
        }
    }
    
    if (-not $pythonInstalled) {
        Write-Warning "Please install Python 3.11+ manually:"
        Write-Info "1. Download from: https://www.python.org/downloads/"
        Write-Info "2. Run the installer"
        Write-Info "3. Make sure to check 'Add Python to PATH'"
        Write-Info "4. Restart this PowerShell window and run the installer again"
        exit 1
    }
}

# Check pip
if (-not (Get-Command pip -ErrorAction SilentlyContinue) -and -not (Get-Command pip3 -ErrorAction SilentlyContinue)) {
    Write-Info "Installing pip..."
    python -m ensurepip --upgrade
}

# ============================================================
# Step 2: Check/Install Node.js
# ============================================================
Write-Header "Step 2: Checking Node.js"

$nodeInstalled = $false
if (Get-Command node -ErrorAction SilentlyContinue) {
    $nodeVersion = node --version
    Write-Success "Node.js $nodeVersion"
    $nodeInstalled = $true
}

if (-not $nodeInstalled) {
    Write-Info "Node.js not found. Installing..."
    
    # Try using winget
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Info "Installing Node.js via winget..."
        winget install OpenJS.NodeJS.LTS --silent --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Node.js installed via winget"
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            $nodeInstalled = $true
        }
    }
    
    if (-not $nodeInstalled) {
        Write-Warning "Please install Node.js manually:"
        Write-Info "1. Download from: https://nodejs.org/"
        Write-Info "2. Run the installer (LTS version recommended)"
        Write-Info "3. Restart this PowerShell window and run the installer again"
        exit 1
    }
}

# ============================================================
# Step 3: Check/Install Ollama
# ============================================================
Write-Header "Step 3: Checking Ollama"

$ollamaInstalled = $false
if (Get-Command ollama -ErrorAction SilentlyContinue) {
    Write-Success "Ollama is installed"
    $ollamaInstalled = $true
} else {
    Write-Info "Ollama not found. Installing..."
    
    # Try using winget
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Info "Installing Ollama via winget..."
        winget install Ollama.Ollama --silent --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Ollama installed via winget"
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            $ollamaInstalled = $true
        }
    }
    
    if (-not $ollamaInstalled) {
        Write-Warning "Please install Ollama manually:"
        Write-Info "1. Download from: https://ollama.com/download/windows"
        Write-Info "2. Run the installer"
        Write-Info "3. Restart this PowerShell window and run the installer again"
        exit 1
    }
}

# Start Ollama service
Write-Info "Starting Ollama service..."
Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Hidden -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

# Check if Ollama is running
try {
    $response = Invoke-WebRequest -Uri "http://localhost:11434/api/tags" -TimeoutSec 2 -ErrorAction Stop
    Write-Success "Ollama is running"
} catch {
    Write-Warning "Ollama may not be running. You may need to start it manually:"
    Write-Info "  ollama serve"
}

# ============================================================
# Step 4: Pull Ollama Model
# ============================================================
Write-Header "Step 4: Downloading Ollama Model"

$MODEL_NAME = "llama3.1:8b-instruct-q4_K_M"
Write-Info "Pulling model: $MODEL_NAME"
Write-Info "This may take a few minutes (model is ~4.7GB)..."

$ollamaProcess = Start-Process -FilePath "ollama" -ArgumentList "pull", $MODEL_NAME -NoNewWindow -PassThru -Wait
if ($ollamaProcess.ExitCode -eq 0) {
    Write-Success "Model $MODEL_NAME downloaded successfully"
} else {
    Write-Warning "Failed to download model. You can download it later with:"
    Write-Info "  ollama pull $MODEL_NAME"
}

# ============================================================
# Step 5: Install Application Dependencies
# ============================================================
Write-Header "Step 5: Installing Application Dependencies"

# Create .env if not exists
if (-not (Test-Path ".env")) {
    Write-Info "Creating .env file..."
    @"
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
"@ | Out-File -FilePath ".env" -Encoding UTF8
    
    Write-Warning "Created .env file. You can add your ANTHROPIC_API_KEY later if you want cloud fallback."
    Write-Info "To add your API key:"
    Write-Info "  1. Get a key from: https://console.anthropic.com/"
    Write-Info "  2. Edit .env and replace 'your-key-here' with your actual key"
    Write-Info "  3. Restart the router: .\stop.ps1 && .\start.ps1"
}

# Backend dependencies
Write-Info "Installing backend dependencies..."
Set-Location backend
try {
    python -m pip install --user -r requirements.txt
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Backend dependencies installed"
    } else {
        python -m pip install -r requirements.txt
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Backend dependencies installed"
        } else {
            Write-Error "Failed to install backend dependencies"
            Set-Location ..
            exit 1
        }
    }
} catch {
    Write-Error "Failed to install backend dependencies: $_"
    Set-Location ..
    exit 1
}
Set-Location ..

# Frontend dependencies
Write-Info "Installing frontend dependencies..."
Set-Location frontend
try {
    npm install
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Frontend dependencies installed"
    } else {
        Write-Error "Failed to install frontend dependencies"
        Set-Location ..
        exit 1
    }
} catch {
    Write-Error "Failed to install frontend dependencies: $_"
    Set-Location ..
    exit 1
}

# Build frontend
Write-Info "Building frontend..."
try {
    npm run build
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Frontend built successfully"
    } else {
        Write-Warning "Frontend build failed, but continuing..."
    }
} catch {
    Write-Warning "Frontend build failed: $_"
}
Set-Location ..

# ============================================================
# Step 6: Create Start/Stop Scripts
# ============================================================
Write-Header "Step 6: Creating Start/Stop Scripts"

# Create start.ps1
@"
# Start the Local-first Router

Write-Host "Starting Local-first Router..." -ForegroundColor Blue

# Start backend
Write-Host "Starting backend..." -ForegroundColor Cyan
Start-Process -FilePath "python" -ArgumentList "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8001" -WorkingDirectory "backend" -WindowStyle Hidden

Start-Sleep -Seconds 2

# Start frontend (serve built files)
Write-Host "Starting frontend..." -ForegroundColor Cyan
if (Get-Command npx -ErrorAction SilentlyContinue) {
    Start-Process -FilePath "npx" -ArgumentList "serve", "-s", "dist", "-l", "5173" -WorkingDirectory "frontend" -WindowStyle Hidden
} else {
    Write-Warning "npx not found. Install Node.js or use: npm install -g serve"
    Write-Info "Then run: serve -s frontend/dist -l 5173"
}

Write-Host ""
Write-Host "✅ Router started!" -ForegroundColor Green
Write-Host "   Backend: http://localhost:8001" -ForegroundColor Cyan
Write-Host "   Frontend: http://localhost:5173" -ForegroundColor Cyan
Write-Host ""
Write-Host "To stop: .\stop.ps1" -ForegroundColor Yellow
"@ | Out-File -FilePath "start.ps1" -Encoding UTF8

# Create stop.ps1
@"
# Stop the Local-first Router

Write-Host "Stopping Local-first Router..." -ForegroundColor Blue

# Stop backend (uvicorn)
Get-Process | Where-Object {$_.ProcessName -eq "python" -and $_.CommandLine -like "*uvicorn*"} | Stop-Process -Force -ErrorAction SilentlyContinue

# Stop frontend (serve/npx)
Get-Process | Where-Object {$_.ProcessName -eq "node" -and $_.CommandLine -like "*serve*"} | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host "✅ Router stopped" -ForegroundColor Green
"@ | Out-File -FilePath "stop.ps1" -Encoding UTF8

Write-Success "Start/stop scripts created"

# ============================================================
# Installation Complete
# ============================================================
Write-Header "Installation Complete!"

Write-Success "Everything is installed and ready!"
Write-Host ""
Write-Info "Next steps:"
Write-Host "  1. Start the router: .\start.ps1" -ForegroundColor Cyan
Write-Host "  2. Open your browser: http://localhost:5173" -ForegroundColor Cyan
Write-Host "  3. Stop the router: .\stop.ps1" -ForegroundColor Yellow
Write-Host ""
Write-Info "Optional: Add your Anthropic API key to .env for cloud fallback"
Write-Host ""

