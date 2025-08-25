#!/bin/bash

# Service Manager Configuration Manager
# Handles loading, validation, and setup of deployment configuration

set -e

# Configuration file paths
CONFIG_FILE="config/deployment.env"
LOCAL_CONFIG_FILE="config/deployment.env.local"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ️${NC} $1"
}

# Function to load configuration
load_config() {
    local config_file="$1"
    
    if [[ -f "$config_file" ]]; then
        print_info "Loading configuration from: $config_file"
        
        # Source the configuration file
        set -a  # Export all variables
        source "$config_file"
        set +a  # Stop exporting
        
        print_status "Configuration loaded successfully"
        return 0
    else
        print_error "Configuration file not found: $config_file"
        return 1
    fi
}

# Function to validate configuration
validate_config() {
    local errors=0
    
    print_info "Validating configuration..."
    
    # Required variables
    local required_vars=(
        "SERVER_IP"
        "SSH_HOST"
        "SSH_USER"
        "SSH_KEY"
        "WEB_PORT"
        "SAMPLE_SERVICE_PORT"
        "APP_DIR"
        "SERVICE_NAME"
    )
    
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            print_error "Missing required configuration: $var"
            ((errors++))
        else
            print_status "✓ $var = ${!var}"
        fi
    done
    
    # Validate IP address format
    if [[ ! "$SERVER_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_error "Invalid IP address format: $SERVER_IP"
        ((errors++))
    fi
    
    # Validate port numbers
    if [[ ! "$WEB_PORT" =~ ^[0-9]+$ ]] || [[ "$WEB_PORT" -lt 1 ]] || [[ "$WEB_PORT" -gt 65535 ]]; then
        print_error "Invalid web port: $WEB_PORT"
        ((errors++))
    fi
    
    if [[ ! "$SAMPLE_SERVICE_PORT" =~ ^[0-9]+$ ]] || [[ "$SAMPLE_SERVICE_PORT" -lt 1 ]] || [[ "$SAMPLE_SERVICE_PORT" -gt 65535 ]]; then
        print_error "Invalid sample service port: $SAMPLE_SERVICE_PORT"
        ((errors++))
    fi
    
    # Check for port conflicts
    if [[ "$WEB_PORT" == "$SAMPLE_SERVICE_PORT" ]]; then
        print_error "Web port and sample service port cannot be the same"
        ((errors++))
    fi
    
    if [[ $errors -eq 0 ]]; then
        print_status "Configuration validation passed"
        return 0
    else
        print_error "Configuration validation failed with $errors error(s)"
        return 1
    fi
}

# Function to create local configuration
create_local_config() {
    print_info "Creating local configuration file..."
    
    if [[ -f "$LOCAL_CONFIG_FILE" ]]; then
        print_warning "Local configuration file already exists: $LOCAL_CONFIG_FILE"
        read -p "Do you want to overwrite it? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Keeping existing local configuration"
            return 0
        fi
    fi
    
    # Copy template configuration
    cp "$CONFIG_FILE" "$LOCAL_CONFIG_FILE"
    
    print_status "Local configuration file created: $LOCAL_CONFIG_FILE"
    print_info "Please edit this file with your specific values"
    
    # Open in editor if available
    if command -v nano >/dev/null 2>&1; then
        read -p "Open configuration in nano editor? (Y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            print_info "You can edit the configuration file manually: $LOCAL_CONFIG_FILE"
        else
            nano "$LOCAL_CONFIG_FILE"
        fi
    elif command -v vim >/dev/null 2>&1; then
        read -p "Open configuration in vim editor? (Y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            print_info "You can edit the configuration file manually: $LOCAL_CONFIG_FILE"
        else
            vim "$LOCAL_CONFIG_FILE"
        fi
    else
        print_info "Please edit the configuration file manually: $LOCAL_CONFIG_FILE"
    fi
}

# Function to show configuration
show_config() {
    print_info "Current configuration:"
    echo
    
    echo "Server Configuration:"
    echo "  SERVER_IP: ${SERVER_IP:-NOT SET}"
    echo "  SSH_HOST: ${SSH_HOST:-NOT SET}"
    echo "  SSH_USER: ${SSH_USER:-NOT SET}"
    echo "  SSH_KEY: ${SSH_KEY:-NOT SET}"
    echo
    
    echo "Port Configuration:"
    echo "  WEB_PORT: ${WEB_PORT:-NOT SET}"
    echo "  SAMPLE_SERVICE_PORT: ${SAMPLE_SERVICE_PORT:-NOT SET}"
    echo
    
    echo "Application Configuration:"
    echo "  APP_DIR: ${APP_DIR:-NOT SET}"
    echo "  SERVICE_NAME: ${SERVICE_NAME:-NOT SET}"
    echo
    
    echo "SSH Configuration:"
    echo "  SSH_PORT: ${SSH_PORT:-22}"
    echo "  SSH_TIMEOUT: ${SSH_TIMEOUT:-10}"
    echo
    
    echo "Deployment Configuration:"
    echo "  BACKUP_DIR: ${BACKUP_DIR:-NOT SET}"
    echo "  LOG_DIR: ${LOG_DIR:-NOT SET}"
}

# Function to test configuration
test_config() {
    print_info "Testing configuration..."
    
    # Test SSH connection
    print_info "Testing SSH connection to $SSH_USER@$SERVER_IP..."
    if ssh -o ConnectTimeout="${SSH_TIMEOUT:-10}" -o BatchMode=yes "$SSH_USER@$SERVER_IP" "echo 'SSH connection successful'" >/dev/null 2>&1; then
        print_status "SSH connection successful"
    else
        print_error "SSH connection failed"
        return 1
    fi
    
    # Test web port
    print_info "Testing web port $WEB_PORT..."
    if curl -s -f "http://$SERVER_IP:$WEB_PORT/api/services" >/dev/null 2>&1; then
        print_status "Web port $WEB_PORT is accessible"
    else
        print_warning "Web port $WEB_PORT is not accessible (service may not be running)"
    fi
    
    print_status "Configuration test completed"
}

# Main function
main() {
    echo "🔧 Service Manager Configuration Manager"
    echo "======================================"
    echo
    
    # Change to project root
    cd "$PROJECT_ROOT"
    
    case "${1:-help}" in
        "load")
            if load_config "$LOCAL_CONFIG_FILE" || load_config "$CONFIG_FILE"; then
                validate_config
            else
                print_error "No configuration file found"
                exit 1
            fi
            ;;
        "create")
            create_local_config
            ;;
        "show")
            if load_config "$LOCAL_CONFIG_FILE" || load_config "$CONFIG_FILE"; then
                show_config
            else
                print_error "No configuration file found"
                exit 1
            fi
            ;;
        "validate")
            if load_config "$LOCAL_CONFIG_FILE" || load_config "$CONFIG_FILE"; then
                validate_config
            else
                print_error "No configuration file found"
                exit 1
            fi
            ;;
        "test")
            if load_config "$LOCAL_CONFIG_FILE" || load_config "$CONFIG_FILE"; then
                validate_config && test_config
            else
                print_error "No configuration file found"
                exit 1
            fi
            ;;
        "setup"|"wizard")
            print_info "Starting configuration setup wizard..."
            
            # Create local config if it doesn't exist
            if [[ ! -f "$LOCAL_CONFIG_FILE" ]]; then
                create_local_config
            fi
            
            # Load and validate
            if load_config "$LOCAL_CONFIG_FILE"; then
                if validate_config; then
                    print_status "Configuration setup completed successfully!"
                    echo
                    print_info "You can now run deployment scripts"
                    print_info "Use './scripts/config-manager.sh show' to view configuration"
                    print_info "Use './scripts/config-manager.sh test' to test configuration"
                else
                    print_error "Configuration validation failed. Please fix the errors and run setup again."
                    exit 1
                fi
            else
                print_error "Failed to load configuration"
                exit 1
            fi
            ;;
        "help"|*)
            echo "Usage: $0 {load|create|show|validate|test|setup|wizard|help}"
            echo
            echo "Commands:"
            echo "  load      - Load and validate configuration"
            echo "  create    - Create local configuration file"
            echo "  show      - Display current configuration"
            echo "  validate  - Validate configuration values"
            echo "  test      - Test configuration (SSH, ports)"
            echo "  setup     - Interactive setup wizard"
            echo "  wizard    - Alias for setup"
            echo "  help      - Show this help message"
            echo
            echo "Configuration files:"
            echo "  Template: $CONFIG_FILE"
            echo "  Local:    $LOCAL_CONFIG_FILE (customize this one)"
            echo
            echo "Example:"
            echo "  $0 setup    # Run setup wizard"
            echo "  $0 show     # Show current configuration"
            echo "  $0 test     # Test configuration"
            ;;
    esac
}

# Run main function
main "$@"
