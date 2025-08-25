#!/bin/bash

# Service Manager - Service Discovery Script
# This script helps discover and configure systemd services for management

set -e

# Configuration
SERVER_HOST="service-manager"
CONFIG_FILE="config/services.yaml"

echo "🔍 Service Discovery and Configuration Script"

# Step 1: Check if we can connect to the server
echo "🔍 Testing SSH connection..."
if ! ssh -o ConnectTimeout=10 -o BatchMode=yes $SERVER_HOST "echo 'SSH connection successful'" > /dev/null 2>&1; then
    echo "❌ Cannot connect to server"
    exit 1
fi

# Step 2: Discover available systemd services
echo "📋 Discovering available systemd services..."
echo ""

# Get all systemd services
ssh $SERVER_HOST "systemctl list-units --type=service --all --no-pager" | grep "\.service" | awk '{print $1}' | sed 's/\.service$//' > /tmp/available_services.txt

# Get running services
ssh $SERVER_HOST "systemctl list-units --type=service --state=running --no-pager" | grep "\.service" | awk '{print $1}' | sed 's/\.service$//' > /tmp/running_services.txt

echo "📊 Found $(wc -l < /tmp/available_services.txt) total services"
echo "🟢 $(wc -l < /tmp/running_services.txt) services are currently running"
echo ""

# Step 3: Show currently configured services
echo "⚙️  Currently configured services in $CONFIG_FILE:"
if [ -f "$CONFIG_FILE" ]; then
    grep -A 1 "display_name:" "$CONFIG_FILE" | grep -v "^--$" | sed 's/^  /  /'
else
    echo "  No configuration file found"
fi

echo ""

# Step 4: Show running services that might be useful
echo "🚀 Running services that might be useful to manage:"
echo ""

# Filter for common services that are typically managed
ssh $SERVER_HOST "systemctl list-units --type=service --state=running --no-pager" | grep "\.service" | awk '{print $1}' | sed 's/\.service$//' | grep -E "(nginx|apache|mysql|postgres|redis|docker|kube|pzserver|game|minecraft|valheim)" | head -20

echo ""

# Step 5: Interactive service addition
echo "➕ Add a new service to the configuration?"
read -p "Enter service name to add (or press Enter to skip): " NEW_SERVICE

if [ -n "$NEW_SERVICE" ]; then
    # Check if service exists
    if ssh $SERVER_HOST "systemctl list-unit-files | grep -q '^$NEW_SERVICE.service'"; then
        echo "✅ Service '$NEW_SERVICE' found"
        
        # Get service description
        read -p "Enter display name for '$NEW_SERVICE': " DISPLAY_NAME
        read -p "Enter description: " DESCRIPTION
        
        # Get permissions
        echo "Select permissions level:"
        echo "1) restart only"
        echo "2) start/stop/restart"
        echo "3) full control (all actions)"
        read -p "Enter choice (1-3): " PERM_CHOICE
        
        case $PERM_CHOICE in
            1) PERMISSIONS="restart" ;;
            2) PERMISSIONS="start" ;;
            3) PERMISSIONS="all" ;;
            *) PERMISSIONS="restart" ;;
        esac
        
        # Get status check permission
        echo "Allow status checking for this service?"
        echo "1) Yes (recommended)"
        echo "2) No (restrictive)"
        read -p "Enter choice (1-2): " STATUS_CHOICE
        
        case $STATUS_CHOICE in
            1) STATUS_CHECK="true" ;;
            2) STATUS_CHECK="false" ;;
            *) STATUS_CHECK="true" ;;
        esac
        
        # Add to configuration
        if [ ! -f "$CONFIG_FILE" ]; then
            mkdir -p config
            cat > "$CONFIG_FILE" << EOF
# Service Configuration
# Each service defines what operations are allowed
services:
EOF
        fi
        
        # Add the new service
        cat >> "$CONFIG_FILE" << EOF

  $NEW_SERVICE:
    display_name: "$DISPLAY_NAME"
    permissions_required: "$PERMISSIONS"
    status_check_allowed: $STATUS_CHECK
    description: "$DESCRIPTION"
EOF
        
        echo "✅ Service '$NEW_SERVICE' added to configuration"
        echo "📝 Updated $CONFIG_FILE"
        
    else
        echo "❌ Service '$NEW_SERVICE' not found"
    fi
fi

# Step 6: Show final configuration
echo ""
echo "📋 Current configuration:"
if [ -f "$CONFIG_FILE" ]; then
    cat "$CONFIG_FILE"
else
    echo "No configuration file found"
fi

echo ""
echo "🎯 Next steps:"
echo "1. Review the configuration above"
echo "2. Deploy the updated configuration: ./scripts/deploy.sh"
echo "3. Test the new service management in the web interface"
echo ""
echo "💡 Tip: You can manually edit $CONFIG_FILE to fine-tune service configurations"

# Cleanup
rm -f /tmp/available_services.txt /tmp/running_services.txt
