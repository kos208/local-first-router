# Local-first LLM Router

A production-lean skeleton for routing LLM requests between local (Ollama) and cloud (Claude via Anthropic) models based on confidence scoring. Save costs while maintaining quality.

## Features

- **Local-first routing**: Tries local model first, falls back to cloud if confidence is low
- **Model selector**: Switch between local models or force cloud with one click
- **OpenAI-compatible API**: Drop-in replacement for existing OpenAI clients
- **Cost tracking**: Logs actual costs and estimated savings
- **Policy controls**: Use `#no_cloud` tag to force local-only processing
- **Web dashboard**: Real-time view of requests, routes, latency, and costs
- **Caching**: Built-in response cache to reduce duplicate processing
- **SQLite logging**: Persistent request history
- **Persistent chat history**: Auto-titled conversations stored locally with quick switching like ChatGPT

## Architecture

```
┌─────────────┐
│   Client    │
│  (OpenAI    │
│ compatible) │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────┐
│  FastAPI Backend            │
│  - Routing Logic            │
│  - Confidence Scoring       │
│  - Policy Enforcement       │
│  - Cost Tracking            │
└──┬────────────────────────┬─┘
   │                        │
   ▼                        ▼
┌──────────┐          ┌──────────┐
│  Ollama  │          │  Claude  │
│  (Local) │          │ (Cloud)  │
└──────────┘          └──────────┘
```

## Quick Start

### Option 1: One-Command Installer (Easiest) ⭐

```bash
git clone <your-repo-url> local-first-router
cd local-first-router
chmod +x install.sh
./install.sh
```

Then start services:
```bash
make start  # Starts backend + frontend in background
```

Open http://localhost:5173

### Option 2: Docker Compose (Recommended for Production)

```bash
# Full setup including Ollama
docker-compose -f docker-compose.full.yml up -d

# Or use host Ollama
docker-compose up -d
```

### Option 3: Manual Setup

1. **Prerequisites**: Python 3.11+, Node.js 18+, Ollama

2. **Install Ollama and Pull Model**:
```bash
# macOS
brew install ollama
ollama serve &
ollama pull llama3.2:latest
```

3. **Install dependencies**:
```bash
make install
```

4. **Configure**:
```bash
cp .env.example .env
# Edit .env and add your ANTHROPIC_API_KEY
```

5. **Run**:
```bash
# Terminal 1: Backend
make dev

# Terminal 2: Frontend
make dev-frontend
```

6. **Open**: http://localhost:5173

📖 **For detailed deployment options, see [DEPLOYMENT.md](DEPLOYMENT.md)**

## Usage

### As OpenAI Client

The router exposes an OpenAI-compatible endpoint. Use it like this:

```python
import openai

client = openai.OpenAI(
    base_url="http://localhost:8001/v1",
    api_key="not-needed"  # API key not required for router itself
)

response = client.chat.completions.create(
    model="gpt-4",  # Model name is ignored; routing is automatic
    messages=[{"role": "user", "content": "What is 2+2?"}]
)

print(response.choices[0].message.content)
```

### Force Local-Only

Add `#no_cloud` to any message to prevent cloud routing:

```python
response = client.chat.completions.create(
    model="gpt-4",
    messages=[{"role": "user", "content": "Secret data #no_cloud"}]
)
```

### Switch Models on the Fly

Open the model selector above the chat input to pick which local model to try first or to force cloud routing.  
- **Local models** (default: `llama3.2:latest`) run on your machine and fall back to cloud automatically if confidence drops.  
- **Cloud (Claude)** routes straight to Anthropic—useful when you know you want the highest quality answer.  
To expose additional locals, pull them with `ollama pull`, add them to `LOCAL_MODELS` in your `.env` (JSON list), and restart the backend.

### cURL Example

```bash
curl http://localhost:8001/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{"role": "user", "content": "Hello!"}],
    "temperature": 0.2
  }'
```

## Configuration

Edit `.env` to customize:

```bash
# Local model
OLLAMA_BASE=http://localhost:11434
LOCAL_MODEL=llama3.2:latest
# LOCAL_MODELS=["llama3.2:latest","llama3.1:8b-instruct-q4_K_M"]
LOCAL_TEMPERATURE=0.7
LOCAL_MAX_TOKENS=

# Cloud model
ANTHROPIC_BASE=https://api.anthropic.com
ANTHROPIC_API_KEY=sk-ant-...
# Optional: required beta flag for preview models
# ANTHROPIC_BETA=messages-2024-10-24
CLOUD_MODEL=claude-3-haiku-20240307
CLOUD_MAX_TOKENS=1024

# Routing threshold (0-1)
CONFIDENCE_THRESHOLD=0.7

# Cost estimates (USD per 1K tokens)
PRICE_PER_1K_INPUT=0.005
PRICE_PER_1K_OUTPUT=0.015
```

## How It Works

1. **Request arrives** at `/v1/chat/completions`
2. **Check cache** for duplicate requests
3. **Try local model** with confidence-aware system prompt
4. **Parse response** as JSON: `{answer: "...", confidence: 0.0-1.0}`
5. **Route decision**:
   - If confidence ≥ threshold → use local answer
   - If confidence < threshold → fallback to cloud
   - If `#no_cloud` tag present → force local
6. **Log everything**: route, latency, costs, confidence
7. **Cache response** for future requests

## Testing

```bash
make test
```

Tests cover:
- JSON parsing from model responses
- Policy enforcement (`#no_cloud` tag)
- Confidence threshold logic

## Docker Deployment

```bash
# Build and run with docker-compose
docker-compose up -d

# Backend: http://localhost:8001
# Frontend: http://localhost:5173
```

**Note**: Ollama should run on the host machine. The Docker backend connects via `host.docker.internal`.

## API Reference

### POST /v1/chat/completions

OpenAI-compatible chat endpoint.

**Request:**
```json
{
  "messages": [{"role": "user", "content": "Hello"}],
  "temperature": 0.2,
  "model": "gpt-4"  // ignored
}
```

**Response:**
```json
{
  "id": "abc123",
  "object": "chat.completion",
  "choices": [{
    "index": 0,
    "message": {"role": "assistant", "content": "Hi there!"}
  }],
  "route": "local",
  "confidence": 0.85,
  "latency_ms": 234,
  "estimated_cost_usd": 0.0,
  "estimated_cost_saved_usd": 0.00123,
  "usage": {"prompt_tokens": 10, "completion_tokens": 5}
}
```

### GET /api/logs

Returns last 100 requests with routing decisions.

**Response:**
```json
[
  {
    "id": 1,
    "route": "local",
    "confidence": 0.85,
    "latency_ms": 234,
    "estimated_cost_usd": 0.0,
    "estimated_cost_saved_usd": 0.00123,
    "created_at": "2024-11-06T12:34:56Z"
  }
]
```

## Project Structure

```
local-first-router/
├── backend/
│   ├── app/
│   │   ├── main.py              # FastAPI app & endpoints
│   │   ├── router_service.py    # Routing logic
│   │   ├── policy.py            # Policy enforcement
│   │   ├── cost.py              # Cost estimation
│   │   ├── cache.py             # Response cache
│   │   ├── clients/
│   │   │   ├── ollama_client.py
│   │   │   └── openai_client.py
│   │   ├── settings.py          # Configuration
│   │   ├── schemas.py           # Pydantic models
│   │   ├── db.py                # Database setup
│   │   └── models.py            # SQLAlchemy models
│   ├── tests/
│   │   ├── test_routing.py
│   │   └── test_policy.py
│   ├── requirements.txt
│   ├── pyproject.toml
│   └── Dockerfile
├── frontend/
│   ├── src/
│   │   ├── App.tsx              # Main component
│   │   ├── components/
│   │   │   ├── Chat.tsx         # Chat interface
│   │   │   └── Table.tsx        # Request logs table
│   │   └── main.tsx
│   ├── package.json
│   ├── vite.config.ts
│   ├── tailwind.config.js
│   └── Dockerfile
├── .env.example
├── config.yaml
├── docker-compose.yml
├── Makefile
└── README.md
```

## Development

### Backend

```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8001
```

### Frontend

```bash
cd frontend
npm install
npm run dev
```

### Run Tests

```bash
cd backend
pytest -v
```

## Roadmap / Stretch Goals

- [ ] `/config` endpoint to adjust threshold at runtime
- [ ] API keys management UI
- [ ] Eval runner to benchmark local success rate on CSV prompts
- [ ] Support for streaming responses
- [ ] Multi-model routing (try multiple local models)
- [ ] A/B testing framework
- [ ] Prometheus metrics export
- [ ] Redis cache backend option

## License

MIT

## Contributing

PRs welcome! Please add tests for new features.

## Troubleshooting

**Q: Backend returns "connection refused" errors**  
A: Make sure Ollama is running: `ollama serve`

**Q: All requests route to cloud**  
A: Check your `CONFIDENCE_THRESHOLD` setting. Lower it (e.g., 0.5) to keep more requests local.

**Q: Local model not returning JSON**  
A: The local model needs to support instruction following. Try `llama3.2:latest` (default) or an instruct-tuned variant like `llama3.1:8b-instruct-q4_K_M`.

**Q: Frontend shows CORS errors**  
A: Ensure backend is running on port 8001 and frontend proxy is configured in `vite.config.ts`.

