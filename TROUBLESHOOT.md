# Troubleshooting Guide

## Error: "The string did not match the expected pattern"

This error means the backend couldn't connect to Ollama. Here's how to fix it:

### Step 1: Check if Ollama is Running

```bash
# Check if Ollama process is running
ps aux | grep ollama
```

If you see a process, Ollama is running. If not, start it:

```bash
ollama serve &
```

### Step 2: Check if Model is Downloaded

```bash
# List installed models
ollama list
```

You should see `llama3.2:latest` (and any extras you added) in the list. If not, download it:

```bash
ollama pull llama3.2:latest
```

This will download about 4.7GB. Wait for it to complete.

### Step 3: Test Ollama Directly

```bash
# Test if Ollama responds
curl http://localhost:11434/api/tags

# Test the model directly
ollama run llama3.2:latest "What is 2+2?"
```

If these work, Ollama is fine!

### Step 4: Restart Backend

After fixing Ollama, restart your backend:

```bash
# Stop backend (Ctrl+C in the terminal running it)
# Then start again:
cd /Users/elias/local-first-router/backend
python3 -m uvicorn app.main:app --reload --port 8001
```

### Step 5: Test Again

Refresh the frontend page and try sending a message again.

## Other Common Errors

### "Network error: Failed to fetch"

**Cause:** Backend isn't running

**Fix:**
```bash
cd /Users/elias/local-first-router/backend
python3 -m uvicorn app.main:app --reload --port 8001
```

### "ModuleNotFoundError: No module named 'fastapi'"

**Cause:** Dependencies not installed

**Fix:**
```bash
cd /Users/elias/local-first-router/backend
pip3 install -r requirements.txt
```

### Port 8001 Already in Use

**Cause:** Another process is using port 8001

**Fix:**
```bash
# Kill the process on port 8001
lsof -ti:8001 | xargs kill -9

# Then start backend again
python3 -m uvicorn app.main:app --reload --port 8001
```

### Frontend Shows Blank Page

**Cause:** Frontend not running or wrong URL

**Fix:**
```bash
# Make sure frontend is running
cd /Users/elias/local-first-router/frontend
npm run dev

# Open the correct URL
open http://localhost:5173
```

### "Connection refused to localhost:11434"

**Cause:** Ollama not running

**Fix:**
```bash
# Start Ollama
ollama serve &

# Wait a few seconds, then test
curl http://localhost:11434/api/tags
```

## Quick Diagnosis Commands

Run these to check your system status:

```bash
echo "=== System Check ==="
echo

echo "1. Ollama Status:"
ps aux | grep ollama | grep -v grep && echo "✅ Running" || echo "❌ Not running"

echo
echo "2. Ollama Models:"
ollama list 2>&1 | head -5

echo
echo "3. Backend Port 8001:"
lsof -i:8001 && echo "✅ Backend running" || echo "❌ Backend not running"

echo
echo "4. Frontend Port 5173:"
lsof -i:5173 && echo "✅ Frontend running" || echo "❌ Frontend not running"

echo
echo "5. Python Dependencies:"
python3 -c "import fastapi, uvicorn" 2>&1 && echo "✅ Installed" || echo "❌ Missing"

echo
echo "6. Node/npm:"
node --version && npm --version && echo "✅ Installed" || echo "❌ Missing"
```

## Step-by-Step Recovery

If nothing works, start fresh:

### 1. Stop Everything

```bash
# Kill all running processes
pkill -f ollama
pkill -f uvicorn
pkill -f "npm run dev"
```

### 2. Start Ollama

```bash
ollama serve &
sleep 5
ollama pull llama3.2:latest
```

### 3. Test Ollama

```bash
ollama run llama3.2:latest "Hello"
```

Should respond with a greeting. Press Ctrl+D to exit.

### 4. Start Backend

```bash
cd /Users/elias/local-first-router/backend
python3 -m uvicorn app.main:app --reload --port 8001
```

Wait for: `Uvicorn running on http://127.0.0.1:8001`

### 5. Test Backend

Open new terminal:

```bash
curl http://localhost:8001/
```

Should return: `{"status":"ok","service":"local-first-router"}`

### 6. Start Frontend

```bash
cd /Users/elias/local-first-router/frontend
npm run dev
```

### 7. Open Browser

```bash
open http://localhost:5173
```

## Still Not Working?

### Check Logs

**Backend logs** (in terminal running uvicorn):
- Look for error messages
- Check if requests are reaching the backend

**Ollama logs:**
```bash
# Check Ollama service logs
tail -f ~/.ollama/logs/server.log
```

**Browser console:**
- Open browser DevTools (F12 or Cmd+Option+I)
- Go to Console tab
- Look for JavaScript errors

### Get Help

If you're still stuck, provide:

1. **What you see:**
   - Exact error message
   - Screenshot if possible

2. **Run this diagnostic:**
   ```bash
   cd /Users/elias/local-first-router
   
   echo "=== Environment ==="
   python3 --version
   node --version
   npm --version
   
   echo -e "\n=== Ollama ==="
   ollama list
   
   echo -e "\n=== Backend Dependencies ==="
   cd backend
   pip3 list | grep -E "fastapi|uvicorn|pydantic"
   
   echo -e "\n=== Ports ==="
   lsof -i:8001
   lsof -i:5173
   lsof -i:11434
   ```

3. **Describe what you tried:**
   - Commands you ran
   - In what order
   - What happened

## Success Checklist

✅ Ollama running: `ps aux | grep ollama`  
✅ Model downloaded: `ollama list` shows llama3.2
✅ Backend running: `curl http://localhost:8001/` returns JSON  
✅ Frontend running: Browser shows dashboard at http://localhost:5173  
✅ Test message: Sends and gets response  

If all checked, you're good to go! 🎉

