# Fix Setup Issues

## Issues Found

✅ Python 3.9.6 - Installed  
✅ pip3 - Available  
❌ Node.js - NOT installed  
❌ npm - NOT installed  
⚠️  Ollama - Already running on port 11434 (good!)  

## Step-by-Step Fix

### Step 1: Install Node.js and npm

**Option A: Direct Download (Easiest - No Homebrew needed)**

1. **Download Node.js installer:**
   - Visit: https://nodejs.org/
   - Click the **LTS** (Long Term Support) button - currently v20.x
   - Download will start automatically (`.pkg` file for macOS)

2. **Run the installer:**
   - Open the downloaded `.pkg` file
   - Follow the installation wizard (click Continue/Agree/Install)
   - Enter your Mac password when prompted
   - Click Close when done

3. **Verify installation:**
   ```bash
   # Close and reopen your terminal, then run:
   node --version
   npm --version
   ```
   You should see version numbers like `v20.x.x` and `10.x.x`

**Option B: Using Homebrew (If you want to install it)**
```bash
# Install Homebrew first
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Then install Node.js
brew install node

# Verify
node --version
npm --version
```

**Option C: Using nvm (Node Version Manager)**
```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Close and reopen terminal, then:
nvm install --lts
nvm use --lts

# Verify
node --version
npm --version
```

### Step 2: Verify Ollama Model

Since Ollama is already running, just pull the model:

```bash
ollama pull llama3.2:latest
# Optional
ollama pull llama3.1:8b-instruct-q4_K_M
```

If you get an error, check available models:
```bash
ollama list
```

### Step 3: Configure Environment

```bash
cd /Users/elias/local-first-router
cp .env.example .env
```

Then edit `.env` with your Anthropic API key (optional):
```bash
nano .env
# or
open -e .env
```

Add:
```
ANTHROPIC_API_KEY=sk-ant-your-key-here
```

### Step 4: Install Backend Dependencies

```bash
cd /Users/elias/local-first-router/backend
pip3 install -r requirements.txt
```

If you get permission errors, use:
```bash
pip3 install --user -r requirements.txt
```

Or create a virtual environment (recommended):
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Step 5: Install Frontend Dependencies

**After installing Node.js:**

```bash
cd /Users/elias/local-first-router/frontend
npm install
```

### Step 6: Run the Application

**Terminal 1 - Backend:**
```bash
cd /Users/elias/local-first-router/backend
python3 -m uvicorn app.main:app --reload --port 8001
```

**Terminal 2 - Frontend:**
```bash
cd /Users/elias/local-first-router/frontend
npm run dev
```

### Step 7: Open Browser

```bash
open http://localhost:5173
```

## Quick Commands (Copy ONE at a time)

```bash
# 1. Install Node.js (if you have Homebrew)
brew install node

# 2. Go to project directory
cd /Users/elias/local-first-router

# 3. Configure environment
cp .env.example .env

# 4. Install backend dependencies
cd backend
pip3 install -r requirements.txt

# 5. Install frontend dependencies (new terminal tab)
cd /Users/elias/local-first-router/frontend
npm install

# 6. Run backend (Terminal 1)
cd /Users/elias/local-first-router/backend
python3 -m uvicorn app.main:app --reload --port 8001

# 7. Run frontend (Terminal 2)
cd /Users/elias/local-first-router/frontend
npm run dev
```

## Alternative: Use Virtual Environment (Recommended)

```bash
# Create virtual environment
cd /Users/elias/local-first-router/backend
python3 -m venv venv

# Activate it
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run backend
uvicorn app.main:app --reload --port 8001
```

## Troubleshooting

### Ollama Issues

If Ollama commands don't work:
```bash
# Check if running
ps aux | grep ollama

# If not running, start it
ollama serve &

# Pull model
ollama pull llama3.2:latest

# Test it
ollama run llama3.2:latest "What is 2+2?"
```

### Python Module Not Found

If you get "ModuleNotFoundError":
```bash
cd /Users/elias/local-first-router/backend
pip3 install --upgrade pip
pip3 install -r requirements.txt
```

### Port Already in Use

If port 8001 is busy:
```bash
# Kill process on port 8001
lsof -ti:8001 | xargs kill -9

# Or use different port
python3 -m uvicorn app.main:app --reload --port 8002
```

If port 5173 is busy:
```bash
# Kill process on port 5173
lsof -ti:5173 | xargs kill -9
```

## Testing Backend Without Frontend

```bash
# Start backend
cd /Users/elias/local-first-router/backend
python3 -m uvicorn app.main:app --reload --port 8001

# In another terminal, test with curl:
curl http://localhost:8001/

# Should return: {"status":"ok","service":"local-first-router"}

# Test chat endpoint:
curl -X POST http://localhost:8001/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{"role": "user", "content": "What is 2+2?"}]
  }'
```

## Success Checklist

- [ ] Node.js installed (`node --version` works)
- [ ] npm installed (`npm --version` works)
- [ ] Ollama running and model pulled
- [ ] Backend dependencies installed
- [ ] Frontend dependencies installed
- [ ] Backend starts on port 8001
- [ ] Frontend starts on port 5173
- [ ] Can send test request via curl
- [ ] Dashboard loads in browser

## Next Steps

Once everything is running:
1. Open http://localhost:5173
2. Type a question in the chat
3. Click "Send"
4. Watch the routing decision
5. Check the logs table below

The router will try local first, then fall back to cloud if confidence is low!

