#!/bin/bash

# Service Manager - Rollback Script
# This script allows rolling back to a previous deployment

set -e

# Configuration
SERVER_HOST="service-manager"
APP_DIR="/opt/service-manager"
SERVICE_NAME="service-manager"
BACKUP_DIR="/opt/service-manager/backups"

echo "🔄 Service Manager Rollback Script"

# Step 1: Check if we can connect to the server
echo "🔍 Testing SSH connection..."
if ! ssh -o ConnectTimeout=10 -o BatchMode=yes $SERVER_HOST "echo 'SSH connection successful'" > /dev/null 2>&1; then
    echo "❌ Cannot connect to server"
    exit 1
fi

# Step 2: List available backups
echo "📋 Available backups:"
ssh $SERVER_HOST "ls -la $BACKUP_DIR" | grep "^d" | awk '{print $9}' | grep -v "^\.$" | sort -r

# Step 3: Get user input for backup to restore
echo ""
read -p "Enter backup name to restore (or 'latest' for most recent): " BACKUP_NAME

if [ "$BACKUP_NAME" = "latest" ]; then
    BACKUP_NAME=$(ssh $SERVER_HOST "ls -t $BACKUP_DIR | grep -v '^\.$' | head -1")
    echo "🔄 Using latest backup: $BACKUP_NAME"
fi

# Step 4: Verify backup exists
if ! ssh $SERVER_HOST "[ -d $BACKUP_DIR/$BACKUP_NAME ]"; then
    echo "❌ Backup '$BACKUP_NAME' not found"
    exit 1
fi

# Step 5: Confirm rollback
echo ""
echo "⚠️  WARNING: This will overwrite the current deployment with backup: $BACKUP_NAME"
read -p "Are you sure you want to proceed? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "❌ Rollback cancelled"
    exit 0
fi

# Step 6: Stop the service
echo "🛑 Stopping service..."
ssh $SERVER_HOST "sudo systemctl stop $SERVICE_NAME"

# Step 7: Create backup of current deployment before rollback
echo "💾 Creating backup of current deployment..."
CURRENT_BACKUP="pre-rollback-$(date +%Y%m%d-%H%M%S)"
ssh $SERVER_HOST "cp -r $APP_DIR/app $BACKUP_DIR/$CURRENT_BACKUP"
echo "✅ Current deployment backed up as: $CURRENT_BACKUP"

# Step 8: Restore from backup
echo "🔄 Restoring from backup: $BACKUP_NAME"
ssh $SERVER_HOST "rm -rf $APP_DIR/app"
ssh $SERVER_HOST "cp -r $BACKUP_DIR/$BACKUP_NAME $APP_DIR/app"

# Step 9: Set proper permissions
echo "🔐 Setting file permissions..."
ssh $SERVER_HOST "chown -R $SERVICE_NAME:$SERVICE_NAME $APP_DIR/app"
ssh $SERVER_HOST "chmod -R 755 $APP_DIR/app"

# Step 10: Start the service
echo "🚀 Starting service..."
ssh $SERVER_HOST "sudo systemctl start $SERVICE_NAME"

# Step 11: Wait for service to be ready
echo "⏳ Waiting for service to be ready..."
sleep 5

# Step 12: Check service status
echo "📊 Checking service status..."
if ssh $SERVER_HOST "sudo systemctl is-active $SERVICE_NAME" | grep -q "active"; then
    echo "✅ Service is running successfully"
else
    echo "❌ Service failed to start. Checking logs..."
    ssh $SERVER_HOST "sudo journalctl -u $SERVICE_NAME -n 20 --no-pager"
    echo "⚠️  Rollback completed but service failed to start"
    exit 1
fi

# Step 13: Test the application
echo "🧪 Testing application..."
if curl -s -f "http://192.168.1.130:5000/api/services" > /dev/null; then
    echo "✅ Application is responding correctly"
else
    echo "⚠️  Application may not be fully ready yet. Please check manually."
fi

echo ""
echo "🎉 Rollback completed successfully!"
echo ""
echo "📱 Access your Service Manager at:"
echo "   http://192.168.1.130:5000"
echo ""
echo "📋 Rollback details:"
echo "   From: $BACKUP_NAME"
echo "   Current backup: $CURRENT_BACKUP"
echo ""
echo "🔧 To manage the service:"
echo "   ssh $SERVER_HOST"
echo "   sudo systemctl status $SERVICE_NAME"
