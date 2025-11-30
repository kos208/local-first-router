#!/bin/bash

# Stop script for the router

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Stopping Local-first Router...${NC}"

# Kill processes by PID if files exist
if [ -f .backend.pid ]; then
    PID=$(cat .backend.pid)
    if ps -p $PID > /dev/null 2>&1; then
        kill $PID 2>/dev/null
        echo -e "${GREEN}✅ Backend stopped${NC}"
    fi
    rm -f .backend.pid
fi

if [ -f .frontend.pid ]; then
    PID=$(cat .frontend.pid)
    if ps -p $PID > /dev/null 2>&1; then
        kill $PID 2>/dev/null
        echo -e "${GREEN}✅ Frontend stopped${NC}"
    fi
    rm -f .frontend.pid
fi

# Also kill by process name
pkill -f "uvicorn app.main:app" 2>/dev/null && echo -e "${GREEN}✅ Backend processes stopped${NC}"
pkill -f "npm run dev" 2>/dev/null
pkill -f "vite" 2>/dev/null && echo -e "${GREEN}✅ Frontend processes stopped${NC}"
pkill -f "serve -s" 2>/dev/null

echo -e "${GREEN}✅ Router stopped${NC}"

