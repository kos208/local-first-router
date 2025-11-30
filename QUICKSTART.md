# Quick Start Guide

Get the local-first router running in 5 minutes.

## Prerequisites

1. **Python 3.11+** - Check: `python3 --version`
2. **Node.js 18+** - Check: `node --version`
3. **Ollama** - Running locally

## Step 1: Install Ollama

### macOS
```bash
brew install ollama
```

### Linux
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

### Start Ollama and pull model
```bash
# Start Ollama server
ollama serve &

# Pull the default fast local model (≈2GB download)
ollama pull llama3.2:latest

# Optional: add an additional instruct model
ollama pull llama3.1:8b-instruct-q4_K_M

# Verify it works
ollama run llama3.2:latest "What is 2+2?"
```

## Step 2: Configure Environment

```bash
cd local-first-router

# Copy environment template
cp .env.example .env

# Edit .env and add your Anthropic API key
# (Optional: Router works without it, but will always use local model)
nano .env
# or
code .env
```

Add your Anthropic API key:
```bash
ANTHROPIC_API_KEY=sk-ant-your-key-here
# Optional: required beta header for some preview models
# ANTHROPIC_BETA=messages-2024-10-24
# Optional: expose multiple local models (JSON list)
# LOCAL_MODELS=["llama3.2:latest","llama3.1:8b-instruct-q4_K_M"]
```

## Step 3: Install Dependencies

### Backend
```bash
cd backend
pip install -r requirements.txt
cd ..
```

### Frontend
```bash
cd frontend
npm install
cd ..
```

## Step 4: Run the Application

### Terminal 1 - Backend
```bash
make dev
# or manually:
# cd backend && uvicorn app.main:app --reload --port 8001
```

Wait for: `Uvicorn running on http://127.0.0.1:8001`

### Terminal 2 - Frontend
```bash
make dev-frontend
# or manually:
# cd frontend && npm run dev
```

Wait for: `Local: http://localhost:5173/`

## Step 5: Test It!

### Option A: Web Dashboard
1. Open http://localhost:5173
2. Type a question in the chat box
3. Click "Send"
4. Watch the routing decision and logs
5. Use the model selector to swap between local models or force cloud responses

### Option B: cURL
```bash
curl http://localhost:8001/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{"role": "user", "content": "What is the capital of France?"}]
  }'
```

### Option C: Python Client
```python
import openai

client = openai.OpenAI(
    base_url="http://localhost:8001/v1",
    api_key="not-needed"
)

response = client.chat.completions.create(
    model="gpt-4",
    messages=[{"role": "user", "content": "What is 2+2?"}]
)

print(response.choices[0].message.content)
print(f"Route: {response.route}")
print(f"Confidence: {response.confidence}")
```

## Test Scenarios

### 1. Easy Question (Should route LOCAL)
```bash
curl http://localhost:8001/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages": [{"role": "user", "content": "What is 2+2?"}]}'
```

### 2. Complex Question (May route CLOUD)
```bash
curl http://localhost:8001/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages": [{"role": "user", "content": "Explain quantum entanglement in detail"}]}'
```

### 3. Force Local-Only (Always LOCAL)
```bash
curl http://localhost:8001/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages": [{"role": "user", "content": "Secret data here #no_cloud"}]}'
```

## Verify Everything Works

### Check Backend Health
```bash
curl http://localhost:8001/
```

Expected: `{"status":"ok","service":"local-first-router"}`

### Check Logs
```bash
curl http://localhost:8001/api/logs
```

Expected: JSON array of recent requests

### Run Tests
```bash
cd backend
pytest -v
```

Expected: All tests pass

## Troubleshooting

### Backend won't start
- **Error: "ModuleNotFoundError"** → Run `pip install -r backend/requirements.txt`
- **Error: "Address already in use"** → Kill process on port 8001: `lsof -ti:8001 | xargs kill`

### Ollama connection refused
- **Error: "Connection refused"** → Start Ollama: `ollama serve`
- **Error: "Model not found"** → Pull model: `ollama pull llama3.2:latest`

### All requests route to cloud
- Lower confidence threshold in `.env`: `CONFIDENCE_THRESHOLD=0.5`
- Check local model is responding: `curl http://localhost:11434/api/tags`

### Frontend CORS errors
- Verify backend is running on port 8001
- Check `vite.config.ts` proxy settings

## Next Steps

1. **Adjust threshold**: Edit `.env` and change `CONFIDENCE_THRESHOLD` (0-1)
2. **Try different models**: `ollama pull mistral` and update `LOCAL_MODEL` in `.env`
3. **Monitor costs**: Check the dashboard for savings vs cloud-only
4. **Integrate**: Point your existing OpenAI client to `http://localhost:8001/v1`

## Docker Alternative

If you prefer Docker:

```bash
# Build and run
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

**Note**: Ollama must run on host machine. Docker backend connects via `host.docker.internal`.

## Success Criteria

✅ Backend responds to health check  
✅ Frontend loads at http://localhost:5173  
✅ Chat sends messages and receives responses  
✅ Logs table shows request history  
✅ Route indicator shows "local" or "cloud"  
✅ Confidence score is displayed  
✅ Cost savings are tracked  

## Getting Help

- Check the main [README.md](README.md) for detailed documentation
- Review logs: Backend terminal shows request details
- Enable debug: Set `LOG_LEVEL=DEBUG` in `.env`
- Test Ollama directly: `ollama run llama3.2:latest "test"`

## Quick Commands Reference

```bash
# Start everything
make dev              # Terminal 1: Backend
make dev-frontend     # Terminal 2: Frontend

# Run tests
make test

# Install dependencies
make install

# Build for production
make build

# Docker
make docker-up
make docker-down

# Cleanup
make clean
```

Happy routing! 🚀

