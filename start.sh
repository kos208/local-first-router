#!/bin/bash

# Simple start script for the router

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Starting Local-first Router...${NC}"
echo

# Check if Ollama is running
if ! curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Ollama is not running. Starting it...${NC}"
    ollama serve > /tmp/ollama.log 2>&1 &
    sleep 3
    
    if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Ollama started${NC}"
    else
        echo -e "${YELLOW}⚠️  Ollama may need manual start: ollama serve${NC}"
    fi
fi

# Start backend
echo -e "${BLUE}Starting backend...${NC}"
cd backend
python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8001 > ../backend.log 2>&1 &
BACKEND_PID=$!
echo "Backend PID: $BACKEND_PID"
cd ..

# Wait a moment for backend to start
sleep 2

# Start frontend (using built files if available, else dev server)
echo -e "${BLUE}Starting frontend...${NC}"
if [ -d "frontend/dist" ] && [ -n "$(ls -A frontend/dist)" ]; then
    # Serve built files
    cd frontend
    if command -v npx >/dev/null 2>&1; then
        npx serve -s dist -l 5173 > ../frontend.log 2>&1 &
    else
        echo -e "${YELLOW}⚠️  'serve' not found. Installing...${NC}"
        npm install -g serve
        npx serve -s dist -l 5173 > ../frontend.log 2>&1 &
    fi
    FRONTEND_PID=$!
    echo "Frontend PID: $FRONTEND_PID"
    cd ..
else
    # Use dev server
    cd frontend
    npm run dev > ../frontend.log 2>&1 &
    FRONTEND_PID=$!
    echo "Frontend PID: $FRONTEND_PID"
    cd ..
fi

# Save PIDs
echo $BACKEND_PID > .backend.pid
echo $FRONTEND_PID > .frontend.pid

echo
echo -e "${GREEN}✅ Router started!${NC}"
echo
echo -e "${CYAN}Frontend:${NC} http://localhost:5173"
echo -e "${CYAN}Backend:${NC}  http://localhost:8001"
echo
echo -e "${BLUE}Logs:${NC}"
echo -e "   Backend:  tail -f backend.log"
echo -e "   Frontend: tail -f frontend.log"
echo
echo -e "${BLUE}To stop:${NC} ./stop.sh or make stop"
echo

