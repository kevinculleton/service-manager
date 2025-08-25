#!/bin/bash

# Deploy Sample Service Script
# Sets up and deploys the sample HTTP service to the server

set -e

# Configuration
SSH_ALIAS="service-manager"
SERVICE_NAME="sample-service"
SERVICE_DIR="/opt/service-manager/sample-service"
SERVICE_FILE="sample-service.service"

echo "🚀 Deploying Sample Service to ${SERVER_USER}@${SERVER_HOST}..."

# Test SSH connection
echo "🔍 Testing SSH connection..."
if ! ssh -o ConnectTimeout=10 -o BatchMode=yes ${SSH_ALIAS} "echo 'SSH connection successful'" > /dev/null 2>&1; then
    echo "❌ SSH connection failed. Please check your SSH configuration."
    exit 1
fi
echo "✅ SSH connection successful"

# Create service directory on server
echo "📁 Setting up service directory..."
ssh -t ${SSH_ALIAS} "sudo mkdir -p ${SERVICE_DIR} && sudo chown service-manager:service-manager ${SERVICE_DIR}"

# Copy service files
echo "📤 Deploying service files..."
scp sample-service/sample-service.py ${SSH_ALIAS}:${SERVICE_DIR}/
scp sample-service/${SERVICE_FILE} ${SSH_ALIAS}:${SERVICE_DIR}/

# Set permissions
echo "🔐 Setting file permissions..."
ssh ${SSH_ALIAS} "chmod +x ${SERVICE_DIR}/sample-service.py"

# Install systemd service
echo "🔧 Installing systemd service..."
ssh -t ${SSH_ALIAS} "sudo cp ${SERVICE_DIR}/${SERVICE_FILE} /etc/systemd/system/ && sudo systemctl daemon-reload"

# Enable and start the service
echo "🚀 Starting sample service..."
ssh -t ${SSH_ALIAS} "sudo systemctl enable ${SERVICE_NAME} && sudo systemctl start ${SERVICE_NAME}"

# Wait a moment for service to start
echo "⏳ Waiting for service to start..."
sleep 3

# Check service status
echo "📊 Checking service status..."
ssh -t ${SSH_ALIAS} "sudo systemctl status ${SERVICE_NAME} --no-pager"

# Test the service
echo "🧪 Testing sample service..."
if curl -s "http://192.168.1.130:8080" > /dev/null; then
    echo "✅ Sample service is responding correctly"
    echo ""
    echo "🌐 Access your Sample Service at:"
    echo "   http://192.168.1.130:8080"
    echo ""
    echo "🔧 To manage the service:"
    echo "   ssh ${SSH_ALIAS}"
    echo "   sudo systemctl status ${SERVICE_NAME}"
    echo "   sudo systemctl restart ${SERVICE_NAME}"
    echo ""
    echo "📋 Service is now managed by your Service Manager!"
else
    echo "⚠️  Service may still be starting up. Please check manually:"
    echo "   ssh ${SSH_ALIAS}"
    echo "   sudo systemctl status ${SERVICE_NAME}"
fi

echo ""
echo "🎉 Sample service deployment completed!"
