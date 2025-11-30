.PHONY: dev test install build clean start stop

# Development
dev:
	cd backend && python3 -m uvicorn app.main:app --reload --port 8001

dev-frontend:
	cd frontend && npm run dev

# Start services (background)
start:
	@echo "Starting backend..."
	@cd backend && python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8001 > ../backend.log 2>&1 &
	@echo "Backend started (PID: $$!)"
	@sleep 2
	@echo "Starting frontend..."
	@cd frontend && npm run dev > ../frontend.log 2>&1 &
	@echo "Frontend started (PID: $$!)"
	@echo ""
	@echo "✅ Services started!"
	@echo "   Backend: http://localhost:8001"
	@echo "   Frontend: http://localhost:5173"
	@echo "   Logs: backend.log, frontend.log"

# Stop services
stop:
	@echo "Stopping services..."
	@pkill -f "uvicorn app.main:app" || true
	@pkill -f "npm run dev" || true
	@pkill -f "vite" || true
	@echo "✅ Services stopped"

# Testing
test:
	cd backend && pytest -v

# Installation
install:
	cd backend && pip install -r requirements.txt
	cd frontend && npm install

# Build
build:
	cd frontend && npm run build

# Docker
docker-build:
	docker-compose build

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down

# Cleanup
clean:
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	rm -rf backend/*.db
	rm -rf frontend/dist
	rm -rf frontend/node_modules

