# Local-first Router - Frontend

React + Vite + Tailwind dashboard for the local-first LLM router.

## Features

- Chat interface to test the router
- Real-time request logs table
- Visual indicators for route (local/cloud), confidence, latency
- Auto-refresh logs every 5 seconds
- Cost savings display
- Persistent chat sidebar with auto-titled conversations saved in localStorage

## Development

```bash
npm install
npm run dev
```

Opens at http://localhost:5173

## Build

```bash
npm run build
```

Output in `dist/` directory.

## Configuration

The frontend proxies API requests to the backend via Vite's dev server (see `vite.config.ts`):

- `/v1/*` → `http://localhost:8001/v1/*`
- `/api/*` → `http://localhost:8001/api/*`

For production, use nginx or similar to proxy these paths.

