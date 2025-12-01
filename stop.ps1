# Stop the Local-first Router (Windows)

Write-Host "Stopping Local-first Router..." -ForegroundColor Blue

# Stop backend using PID file
if (Test-Path ".backend.pid") {
    $backendPid = Get-Content ".backend.pid" -ErrorAction SilentlyContinue
    if ($backendPid) {
        try {
            Stop-Process -Id $backendPid -Force -ErrorAction SilentlyContinue
            Write-Host "✅ Backend stopped" -ForegroundColor Green
        } catch {
            # Process may already be stopped
        }
    }
    Remove-Item ".backend.pid" -ErrorAction SilentlyContinue
}

# Stop frontend using PID file
if (Test-Path ".frontend.pid") {
    $frontendPid = Get-Content ".frontend.pid" -ErrorAction SilentlyContinue
    if ($frontendPid) {
        try {
            Stop-Process -Id $frontendPid -Force -ErrorAction SilentlyContinue
            Write-Host "✅ Frontend stopped" -ForegroundColor Green
        } catch {
            # Process may already be stopped
        }
    }
    Remove-Item ".frontend.pid" -ErrorAction SilentlyContinue
}

# Also try to stop by process name and port (fallback)
# Stop processes using ports 8001 and 5173
$backendPort = Get-NetTCPConnection -LocalPort 8001 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess
$frontendPort = Get-NetTCPConnection -LocalPort 5173 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess

if ($backendPort) {
    Stop-Process -Id $backendPort -Force -ErrorAction SilentlyContinue
}
if ($frontendPort) {
    Stop-Process -Id $frontendPort -Force -ErrorAction SilentlyContinue
}

Write-Host "✅ Router stopped" -ForegroundColor Green

