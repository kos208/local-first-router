# Local-first Router - Backend

FastAPI-based backend that routes requests to local Ollama or cloud Claude (Anthropic) based on confidence.

## Setup

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Configure environment (copy from root `.env.example` or set directly):
```bash
export ANTHROPIC_API_KEY=your-key-here
export OLLAMA_BASE=http://localhost:11434
```

3. Run the server:
```bash
uvicorn app.main:app --reload --port 8001
```

## Testing

```bash
pytest -v
```

## Docker

```bash
docker build -t local-first-router .
docker run -p 8001:8001 --env-file ../.env local-first-router
```

## API Endpoints

- `POST /v1/chat/completions` - OpenAI-compatible chat endpoint
- `GET /api/logs` - Retrieve recent request logs
- `GET /` - Health check

