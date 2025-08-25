#!/bin/bash

# Service Manager - Server User Setup Script
# This script sets up a dedicated user and environment for the service manager

set -e

# Configuration
SERVER_USER="service-manager"
APP_DIR="/opt/service-manager"
SERVICE_NAME="service-manager"

echo "🚀 Setting up Service Manager Server Environment..."

# Step 1: Create dedicated user
echo "👤 Creating dedicated user: $SERVER_USER"
if ! id "$SERVER_USER" &>/dev/null; then
    sudo useradd -m -s /bin/bash -d /home/$SERVER_USER $SERVER_USER
    echo "✅ User $SERVER_USER created"
else
    echo "ℹ️  User $SERVER_USER already exists"
fi

# Step 2: Create application directory
echo "📁 Creating application directory: $APP_DIR"
sudo mkdir -p $APP_DIR
sudo chown $SERVER_USER:$SERVER_USER $APP_DIR
sudo chmod 755 $APP_DIR

# Step 3: Install system dependencies
echo "📦 Installing system dependencies..."
# Detect package manager and install dependencies
if command -v pacman &> /dev/null; then
    # Arch Linux
    echo "🐧 Detected Arch Linux, using pacman..."
    sudo pacman -Sy --noconfirm python python-pip python-virtualenv python-yaml
elif command -v apt-get &> /dev/null; then
    # Debian/Ubuntu
    echo "🐧 Detected Debian/Ubuntu, using apt-get..."
    sudo apt-get update
    sudo apt-get install -y python3 python3-pip python3-venv python3-yaml
elif command -v yum &> /dev/null; then
    # CentOS/RHEL
    echo "🐧 Detected CentOS/RHEL, using yum..."
    sudo yum install -y python3 python3-pip python3-virtualenv python3-yaml
else
    echo "❌ Unsupported package manager. Please install Python manually."
    exit 1
fi

# Step 4: Create Python virtual environment
echo "🐍 Setting up Python virtual environment..."
# Detect Python command
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
else
    echo "❌ Python not found. Please install Python manually."
    exit 1
fi

sudo -u $SERVER_USER $PYTHON_CMD -m venv $APP_DIR/venv
sudo -u $SERVER_USER $APP_DIR/venv/bin/pip install --upgrade pip

# Step 5: Create service management scripts
echo "🔧 Creating service management scripts..."

# Create the main restart script
sudo tee /usr/local/bin/service-manager-restart > /dev/null << 'EOF'
#!/bin/bash
# Generic service restart script
SERVICE_NAME="$1"
if [ -z "$SERVICE_NAME" ]; then
    echo "Usage: $0 <service-name>"
    exit 1
fi
systemctl restart "$SERVICE_NAME"
EOF

# Create the service status script
sudo tee /usr/local/bin/service-manager-status > /dev/null << 'EOF'
#!/bin/bash
# Generic service status script
SERVICE_NAME="$1"
if [ -z "$SERVICE_NAME" ]; then
    echo "Usage: $0 <service-name>"
    exit 1
fi
systemctl is-active "$SERVICE_NAME"
EOF

# Create the service start script
sudo tee /usr/local/bin/service-manager-start > /dev/null << 'EOF'
#!/bin/bash
# Generic service start script
SERVICE_NAME="$1"
if [ -z "$SERVICE_NAME" ]; then
    echo "Usage: $0 <service-name>"
    exit 1
fi
systemctl start "$SERVICE_NAME"
EOF

# Create the service stop script
sudo tee /usr/local/bin/service-manager-stop > /dev/null << 'EOF'
#!/bin/bash
# Generic service stop script
SERVICE_NAME="$1"
if [ -z "$SERVICE_NAME" ]; then
    echo "Usage: $0 <service-name>"
    exit 1
fi
systemctl stop "$SERVICE_NAME"
EOF

# Make all scripts executable
sudo chmod +x /usr/local/bin/service-manager-*

# Step 6: Configure sudo permissions
echo "🔐 Configuring sudo permissions..."
sudo tee /etc/sudoers.d/service-manager > /dev/null << EOF
# Service Manager permissions
$SERVER_USER ALL=NOPASSWD: /usr/local/bin/service-manager-restart
$SERVER_USER ALL=NOPASSWD: /usr/local/bin/service-manager-status
$SERVER_USER ALL=NOPASSWD: /usr/local/bin/service-manager-start
$SERVER_USER ALL=NOPASSWD: /usr/local/bin/service-manager-stop
EOF

sudo chmod 440 /etc/sudoers.d/service-manager

# Step 7: Create systemd service
echo "⚙️  Creating systemd service..."
sudo tee /etc/systemd/system/$SERVICE_NAME.service > /dev/null << EOF
[Unit]
Description=Service Manager Web Interface
After=network.target

[Service]
Type=simple
User=$SERVER_USER
Group=$SERVER_USER
WorkingDirectory=$APP_DIR
Environment=PATH=$APP_DIR/venv/bin
ExecStart=$APP_DIR/venv/bin/python app.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Step 8: Enable and start the service
echo "🚀 Enabling and starting service..."
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME

# Step 9: Set up firewall (if ufw is available)
if command -v ufw &> /dev/null; then
    echo "🔥 Configuring firewall..."
    sudo ufw allow 5000/tcp
    echo "✅ Firewall configured for port 5000"
fi

echo ""
echo "🎉 Server setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Copy your SSH public key to the server:"
echo "   ssh-copy-id -i ~/.ssh/service-manager-deploy.pub $SERVER_USER@192.168.1.130"
echo ""
echo "2. Deploy the application using:"
echo "   ./scripts/deploy.sh"
echo ""
echo "3. The service will be available at:"
echo "   http://192.168.1.130:5000"
echo ""
echo "4. To manage the service:"
echo "   sudo systemctl start $SERVICE_NAME"
echo "   sudo systemctl stop $SERVICE_NAME"
echo "   sudo systemctl status $SERVICE_NAME"
echo "   sudo systemctl restart $SERVICE_NAME"
