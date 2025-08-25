# Service Manager - Makefile
# Provides simple commands for common deployment tasks

# Load configuration if available
-include config/deployment.env.local
-include config/deployment.env

# Default values (fallbacks if config not loaded)
SERVER_IP ?= 192.168.1.130
SSH_HOST ?= service-manager
SSH_USER ?= service-manager
WEB_PORT ?= 5000
APP_DIR ?= /opt/service-manager
SERVICE_NAME ?= service-manager

.PHONY: help setup deploy rollback status discover clean config

# Default target
help:
	@echo "Service Manager - Available Commands"
	@echo "==================================="
	@echo ""
	@echo "🚀 Setup & Deployment:"
	@echo "  setup     - Complete initial server setup"
	@echo "  deploy    - Deploy application updates"
	@echo "  rollback  - Rollback to previous version"
	@echo ""
	@echo "📊 Monitoring & Management:"
	@echo "  status    - Check deployment and service status"
	@echo "  discover  - Discover and configure new services"
	@echo ""
	@echo "🧹 Maintenance:"
	@echo "  clean     - Clean up temporary files"
	@echo "  logs      - View service logs"
	@echo ""
	@echo "🔧 Development:"
	@echo "  test      - Test local application"
	@echo "  build     - Build Docker image (if using Docker)"
	@echo ""
	@echo "📖 Documentation:"
	@echo "  help      - Show this help message"

# Initial server setup
setup:
	@echo "🚀 Running initial server setup..."
	./scripts/initial-setup.sh

# Deploy application updates
deploy:
	@echo "📤 Deploying application updates..."
	./scripts/deploy.sh

# Rollback to previous version
rollback:
	@echo "🔄 Rolling back to previous version..."
	./scripts/rollback.sh

# Check status
status:
	@echo "📊 Checking deployment status..."
	./scripts/status.sh

# Discover new services
discover:
	@echo "🔍 Discovering new services..."
	./scripts/service-discovery.sh

# View service logs
logs:
	@echo "📝 Viewing service logs..."
	ssh $(SSH_HOST) "sudo journalctl -u $(SERVICE_NAME) -f"

# Test local application
test:
	@echo "🧪 Testing local application..."
	python3 -m flask --app app.py run --debug

# Build Docker image
build:
	@echo "🐳 Building Docker image..."
	docker build -t service-manager .

# Clean up temporary files
clean:
	@echo "🧹 Cleaning up temporary files..."
	find . -name "*.pyc" -delete
	find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.log" -delete
	@echo "✅ Cleanup complete"

# Quick deployment (setup + deploy)
quick: setup deploy

# Health check
health: status

# Configuration management
config:
	@echo "🔧 Configuration Management"
	@echo "=========================="
	@echo "  setup     - Run configuration setup wizard"
	@echo "  show      - Show current configuration"
	@echo "  validate  - Validate configuration"
	@echo "  test      - Test configuration"
	@echo ""
	@echo "Run: ./scripts/config-manager.sh <command>"

# Show server info
info:
	@echo "📋 Server Information"
	@echo "===================="
	@echo "Host: $(SSH_HOST) ($(SERVER_IP))"
	@echo "User: $(SSH_USER)"
	@echo "App Dir: $(APP_DIR)"
	@echo "Port: $(WEB_PORT)"
	@echo "URL: http://$(SERVER_IP):$(WEB_PORT)"
