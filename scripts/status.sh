#!/bin/bash

# Service Manager - Status Script
# This script provides a quick overview of deployment status and service health

set -e

# Configuration
SERVER_HOST="service-manager"
APP_DIR="/opt/service-manager"
SERVICE_NAME="service-manager"

echo "📊 Service Manager - Status Overview"
echo "===================================="

# Step 1: Check SSH connection
echo "🔍 SSH Connection Status..."
if ssh -o ConnectTimeout=5 -o BatchMode=yes $SERVER_HOST "echo 'Connected'" > /dev/null 2>&1; then
    echo "✅ SSH connection: OK"
else
    echo "❌ SSH connection: FAILED"
    echo "   Run: ./scripts/initial-setup.sh"
    exit 1
fi

# Step 2: Check service status
echo ""
echo "⚙️  Service Status..."
SERVICE_STATUS=$(ssh $SERVER_HOST "sudo systemctl is-active $SERVICE_NAME" 2>/dev/null || echo "unknown")
case $SERVICE_STATUS in
    "active")
        echo "✅ Service Manager: RUNNING"
        ;;
    "inactive")
        echo "🔴 Service Manager: STOPPED"
        ;;
    "failed")
        echo "❌ Service Manager: FAILED"
        ;;
    *)
        echo "⚠️  Service Manager: $SERVICE_STATUS"
        ;;
esac

# Step 3: Check application health
echo ""
echo "🌐 Application Health..."
if curl -s -f "http://192.168.1.130:5000/api/services" > /dev/null 2>&1; then
    echo "✅ Web Interface: RESPONDING"
    
    # Get service count
    SERVICE_COUNT=$(curl -s "http://192.168.1.130:5000/api/services" | grep -o '"name"' | wc -l)
    echo "📊 Managed Services: $SERVICE_COUNT"
else
    echo "❌ Web Interface: NOT RESPONDING"
fi

# Step 4: Check deployment status
echo ""
echo "📦 Deployment Status..."
if ssh $SERVER_HOST "[ -d $APP_DIR/app ]"; then
    DEPLOYMENT_DATE=$(ssh $SERVER_HOST "stat -c %y $APP_DIR/app" | cut -d' ' -f1)
    echo "✅ Application: DEPLOYED ($DEPLOYMENT_DATE)"
    
    # Check backup count
    BACKUP_COUNT=$(ssh $SERVER_HOST "ls -1 $APP_DIR/backups 2>/dev/null | wc -l" || echo "0")
    echo "💾 Backups Available: $BACKUP_COUNT"
else
    echo "❌ Application: NOT DEPLOYED"
fi

# Step 5: Check system resources
echo ""
echo "💻 System Resources..."
ssh $SERVER_HOST "echo 'CPU Load:' && uptime | awk -F'load average:' '{print \$2}'"
ssh $SERVER_HOST "echo 'Memory:' && free -h | grep '^Mem:' | awk '{print \$3 \"/\" \$2}'"
ssh $SERVER_HOST "echo 'Disk Usage:' && df -h $APP_DIR | tail -1 | awk '{print \$5}'"

# Step 6: Check recent logs
echo ""
echo "📝 Recent Logs..."
ssh $SERVER_HOST "sudo journalctl -u $SERVICE_NAME -n 5 --no-pager --no-hostname" | while read line; do
    echo "   $line"
done

# Step 7: Quick actions
echo ""
echo "🎯 Quick Actions..."
echo "   Deploy updates: ./scripts/deploy.sh"
echo "   Rollback: ./scripts/rollback.sh"
echo "   Discover services: ./scripts/service-discovery.sh"
echo "   SSH to server: ssh $SERVER_HOST"
echo "   View logs: ssh $SERVER_HOST 'sudo journalctl -u $SERVICE_NAME -f'"

echo ""
echo "📱 Access: http://192.168.1.130:5000"
