# Start the Local-first Router (Windows)

Write-Host "Starting Local-first Router..." -ForegroundColor Blue

# Check if Ollama is running
try {
    $response = Invoke-WebRequest -Uri "http://localhost:11434/api/tags" -TimeoutSec 2 -ErrorAction Stop
    Write-Host "✅ Ollama is running" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Ollama is not running. Starting it..." -ForegroundColor Yellow
    Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Hidden
    Start-Sleep -Seconds 3
}

# Start backend
Write-Host "Starting backend..." -ForegroundColor Cyan
$backendProcess = Start-Process -FilePath "python" -ArgumentList "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8001" -WorkingDirectory "backend" -WindowStyle Hidden -PassThru

Start-Sleep -Seconds 2

# Start frontend (serve built files)
Write-Host "Starting frontend..." -ForegroundColor Cyan
if (Test-Path "frontend\dist") {
    if (Get-Command npx -ErrorAction SilentlyContinue) {
        $frontendProcess = Start-Process -FilePath "npx" -ArgumentList "serve", "-s", "dist", "-l", "5173" -WorkingDirectory "frontend" -WindowStyle Hidden -PassThru
    } elseif (Get-Command serve -ErrorAction SilentlyContinue) {
        $frontendProcess = Start-Process -FilePath "serve" -ArgumentList "-s", "dist", "-l", "5173" -WorkingDirectory "frontend" -WindowStyle Hidden -PassThru
    } else {
        Write-Host "⚠️  npx/serve not found. Installing serve..." -ForegroundColor Yellow
        npm install -g serve
        if (Get-Command serve -ErrorAction SilentlyContinue) {
            $frontendProcess = Start-Process -FilePath "serve" -ArgumentList "-s", "dist", "-l", "5173" -WorkingDirectory "frontend" -WindowStyle Hidden -PassThru
        } else {
            Write-Host "⚠️  Could not start frontend server. Install serve manually: npm install -g serve" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "⚠️  Frontend not built. Building now..." -ForegroundColor Yellow
    Set-Location frontend
    npm run build
    Set-Location ..
    if (Test-Path "frontend\dist") {
        if (Get-Command npx -ErrorAction SilentlyContinue) {
            $frontendProcess = Start-Process -FilePath "npx" -ArgumentList "serve", "-s", "dist", "-l", "5173" -WorkingDirectory "frontend" -WindowStyle Hidden -PassThru
        }
    } else {
        Write-Host "⚠️  Frontend build failed. Please build manually: cd frontend && npm run build" -ForegroundColor Yellow
    }
}

# Save process IDs
$backendProcess.Id | Out-File -FilePath ".backend.pid" -Encoding ASCII
if ($frontendProcess) {
    $frontendProcess.Id | Out-File -FilePath ".frontend.pid" -Encoding ASCII
}

Start-Sleep -Seconds 2

Write-Host ""
Write-Host "✅ Router started!" -ForegroundColor Green
Write-Host "   Backend: http://localhost:8001" -ForegroundColor Cyan
Write-Host "   Frontend: http://localhost:5173" -ForegroundColor Cyan
Write-Host ""
Write-Host "To stop: .\stop.ps1" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to exit (processes will continue in background)" -ForegroundColor Gray

