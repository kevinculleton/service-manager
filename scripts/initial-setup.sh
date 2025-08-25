#!/bin/bash

# Service Manager - Initial Server Setup Script
# This script handles the complete initial setup process

set -e

# Configuration
SERVER_IP="192.168.1.130"
SERVER_USER="service-manager"
SSH_KEY="~/.ssh/service-manager-deploy.pub"

echo "🚀 Service Manager - Initial Server Setup"
echo "=========================================="

# Step 1: Check prerequisites
echo "🔍 Checking prerequisites..."

# Check if SSH key exists
if [ ! -f ~/.ssh/service-manager-deploy ]; then
    echo "❌ SSH key not found. Please run the SSH key generation first."
    echo "   ssh-keygen -t ed25519 -f ~/.ssh/service-manager-deploy"
    exit 1
fi

# Check if we can reach the server
echo "🌐 Testing server connectivity..."
if ! ping -c 1 -W 5 $SERVER_IP > /dev/null 2>&1; then
    echo "❌ Cannot reach server at $SERVER_IP"
    echo "   Please check:"
    echo "   - Server is running and accessible"
    echo "   - Network connectivity"
    echo "   - IP address is correct"
    exit 1
fi
echo "✅ Server is reachable"

# Step 2: Create the service-manager user on the server
echo ""
echo "👤 Setting up server user and environment..."
echo "   This will require sudo access on the server"

# Try to connect as root or existing user to set up the new user
read -p "Enter username with sudo access on server (default: root): " ADMIN_USER
ADMIN_USER=${ADMIN_USER:-root}

echo "🔑 Copying SSH key to server..."
if [ "$ADMIN_USER" = "root" ]; then
    ssh-copy-id -i ~/.ssh/service-manager-deploy.pub $ADMIN_USER@$SERVER_IP
else
    ssh-copy-id -i ~/.ssh/service-manager-deploy.pub $ADMIN_USER@$SERVER_IP
fi

# Step 3: Run the server setup script
echo ""
echo "🔧 Running server setup script..."
scp scripts/setup-server-user.sh $ADMIN_USER@$SERVER_IP:/tmp/
echo "⚠️  Note: You may be prompted for your sudo password on the server"
ssh -t $ADMIN_USER@$SERVER_IP "chmod +x /tmp/setup-server-user.sh && sudo /tmp/setup-server-user.sh"

# Step 4: Copy SSH key to the new service-manager user
echo ""
echo "🔑 Setting up SSH access for service-manager user..."
echo "⚠️  Setting up SSH access for the new user (may require sudo password)..."
ssh -t $ADMIN_USER@$SERVER_IP "sudo mkdir -p /home/$SERVER_USER/.ssh"
ssh -t $ADMIN_USER@$SERVER_IP "sudo cp ~/.ssh/authorized_keys /home/$SERVER_USER/.ssh/"
ssh -t $ADMIN_USER@$SERVER_IP "sudo chown -R $SERVER_USER:$SERVER_USER /home/$SERVER_USER/.ssh"
ssh -t $ADMIN_USER@$SERVER_IP "sudo chmod 700 /home/$SERVER_USER/.ssh"
ssh -t $ADMIN_USER@$SERVER_IP "sudo chmod 600 /home/$SERVER_USER/.ssh/authorized_keys"

# Step 5: Test connection as service-manager user
echo ""
echo "🧪 Testing SSH connection as service-manager user..."
if ssh -o ConnectTimeout=10 -o BatchMode=yes $SERVER_USER@$SERVER_IP "echo 'SSH connection successful'" > /dev/null 2>&1; then
    echo "✅ SSH connection successful"
else
    echo "❌ SSH connection failed. Please check the setup and try again."
    exit 1
fi

# Step 6: Deploy the application
echo ""
echo "📤 Deploying the application..."
./scripts/deploy.sh

# Step 7: Final verification
echo ""
echo "🎯 Final verification..."

# Check if service is running
if ssh $SERVER_USER@$SERVER_IP "sudo systemctl is-active service-manager" | grep -q "active"; then
    echo "✅ Service Manager service is running"
else
    echo "❌ Service Manager service is not running"
    echo "   Check logs: ssh $SERVER_USER@$SERVER_IP 'sudo journalctl -u service-manager -n 20'"
fi

# Test web interface
if curl -s -f "http://$SERVER_IP:5000/api/services" > /dev/null; then
    echo "✅ Web interface is responding"
else
    echo "⚠️  Web interface may not be ready yet"
fi

echo ""
echo "🎉 Initial setup completed successfully!"
echo ""
echo "📱 Access your Service Manager at:"
echo "   http://$SERVER_IP:5000"
echo ""
echo "🔧 Useful commands:"
echo "   Deploy updates: ./scripts/deploy.sh"
echo "   Rollback: ./scripts/rollback.sh"
echo "   Discover services: ./scripts/service-discovery.sh"
echo "   SSH to server: ssh $SERVER_USER@$SERVER_IP"
echo ""
echo "📋 Next steps:"
echo "1. Open the web interface and verify it's working"
echo "2. Use service-discovery.sh to add more services to manage"
echo "3. Customize the configuration as needed"
echo "4. Deploy any changes using deploy.sh"
