# Quick Install Guide (No Homebrew Required)

## The Easiest Way to Get Started

### Step 1: Install Node.js (5 minutes)

1. **Open your web browser and go to:**
   ```
   https://nodejs.org/
   ```

2. **Click the big green button** that says **"20.x.x LTS"** (or similar)
   - This downloads the recommended version
   - The file will be named something like `node-v20.x.x.pkg`

3. **Open the downloaded file** (probably in your Downloads folder)
   - Double-click the `.pkg` file
   - Click "Continue" → "Continue" → "Agree" → "Install"
   - Enter your Mac password when asked
   - Click "Close" when done

4. **Close your current terminal and open a NEW one**
   - This is important! The old terminal won't see Node.js

5. **Verify it worked:**
   ```bash
   node --version
   npm --version
   ```
   
   You should see something like:
   ```
   v20.10.0
   10.2.3
   ```

### Step 2: Install Ollama Model (2 minutes)

Since Ollama is already running, just pull the model:

```bash
ollama pull llama3.2:latest
# optional:
# ollama pull llama3.1:8b-instruct-q4_K_M
```

Wait for it to download (about 4.7GB). You'll see progress bars.

### Step 3: Setup Project (3 minutes)

```bash
cd /Users/elias/local-first-router

# Copy environment file
cp .env.example .env

# Install backend dependencies
cd backend
pip3 install -r requirements.txt

# Install frontend dependencies
cd ../frontend
npm install
```

If `pip3 install` gives you permission errors, use:
```bash
pip3 install --user -r requirements.txt
```

### Step 4: Run the Application

**Terminal 1 - Backend:**
```bash
cd /Users/elias/local-first-router/backend
python3 -m uvicorn app.main:app --reload --port 8001
```

Wait until you see:
```
INFO:     Uvicorn running on http://127.0.0.1:8001 (Press CTRL+C to quit)
```

**Terminal 2 - Frontend (open a NEW terminal tab):**
```bash
cd /Users/elias/local-first-router/frontend
npm run dev
```

Wait until you see:
```
  VITE v5.x.x  ready in XXX ms

  ➜  Local:   http://localhost:5173/
```

**Open your browser:**
```bash
open http://localhost:5173
```

## 🎉 That's It!

You should now see the Local-first Router dashboard.

Try asking it: "What is 2+2?" and watch it route to the local model!

## 🆘 Troubleshooting

### "node: command not found" after installing

**Solution:** Close your terminal completely and open a new one. The old terminal doesn't know about the new installation.

### "npm install" gives errors

**Solution 1:** Make sure you closed and reopened terminal after installing Node.js

**Solution 2:** Check Node.js version:
```bash
node --version
```
Should be v18 or higher. If not, reinstall from nodejs.org

### "pip3: command not found"

**Solution:** Try using Python's built-in pip:
```bash
python3 -m pip install -r requirements.txt
```

### Ollama model won't download

**Solution:** Check if Ollama is running:
```bash
ps aux | grep ollama
```

If not running:
```bash
ollama serve &
```

Then try pulling again:
```bash
ollama pull llama3.2:latest
```

### Backend gives "ModuleNotFoundError"

**Solution:** Install dependencies in a virtual environment:
```bash
cd /Users/elias/local-first-router/backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8001
```

### Port 8001 already in use

**Solution:** Kill the process:
```bash
lsof -ti:8001 | xargs kill -9
```

Then try running backend again.

## ✅ Success Checklist

Before running the app, make sure:

- [ ] You can run `node --version` and see v18+
- [ ] You can run `npm --version` and see 9+
- [ ] You ran `ollama pull llama3.2:latest` successfully
- [ ] You ran `pip3 install -r requirements.txt` without errors
- [ ] You ran `npm install` in the frontend folder without errors
- [ ] You have TWO terminal windows/tabs open

## 📊 Expected Results

When you open http://localhost:5173:

1. You'll see a clean dashboard with:
   - Chat box on the left
   - "How it works" info on the right
   - Request logs table at the bottom

2. Type a simple question like "What is 2+2?"
   - Should route to LOCAL (green badge)
   - Shows confidence score
   - Shows latency
   - Shows $0 cost (local is free!)

3. Check the logs table
   - Your request appears
   - Shows which route was used
   - Shows metrics

## 🔗 Quick Links

- Main docs: [README.md](README.md)
- Detailed troubleshooting: [FIX_SETUP.md](FIX_SETUP.md)
- Build info: [BUILD_SUMMARY.md](BUILD_SUMMARY.md)

## Need More Help?

If you're still stuck, tell me:
1. What command you ran
2. What error you got (full text)
3. What shows when you run: `node --version` and `python3 --version`

