# Service Manager - Deployment Guide

This guide covers the complete deployment process for the Service Manager application, including SSH key setup, server configuration, and automated deployment.

## 🚀 Quick Start

### 1. Initial Setup (One-time)
```bash
# Run the complete initial setup
./scripts/initial-setup.sh
```

### 2. Deploy Updates
```bash
# Deploy application updates
./scripts/deploy.sh
```

### 3. Rollback if Needed
```bash
# Rollback to previous version
./scripts/rollback.sh
```

## 🔑 SSH Key Setup

The deployment system uses SSH key authentication for secure, passwordless access to your server.

### Generate SSH Key
```bash
ssh-keygen -t ed25519 -f ~/.ssh/service-manager-deploy -C "service-manager-deploy@$(hostname)" -N ""
```

### SSH Configuration
The deployment scripts automatically configure SSH for easy access:
- **Host alias**: `service-manager`
- **Server**: 192.168.1.130
- **User**: service-manager
- **Key**: ~/.ssh/service-manager-deploy

## 📋 Deployment Scripts

### `scripts/initial-setup.sh`
Complete initial server setup including:
- Server user creation
- Environment setup
- Python installation
- Service configuration
- SSH key setup
- Initial deployment

**Usage**: Run once to set up a new server
```bash
./scripts/initial-setup.sh
```

### `scripts/deploy.sh`
Deploy application updates to the server:
- Backup current deployment
- Deploy new files
- Install dependencies
- Restart service
- Health checks

**Usage**: Run for each deployment
```bash
./scripts/deploy.sh
```

### `scripts/rollback.sh`
Rollback to a previous deployment:
- List available backups
- Restore selected backup
- Restart service
- Verify functionality

**Usage**: Run when you need to revert changes
```bash
./scripts/rollback.sh
```

### `scripts/service-discovery.sh`
Discover and configure new services:
- Scan for available systemd services
- Interactive service configuration
- Update services.yaml
- Suggest useful services

**Usage**: Run to add new services to manage
```bash
./scripts/service-discovery.sh
```

### `scripts/setup-server-user.sh`
Server-side setup script (run automatically):
- Create dedicated user
- Install dependencies
- Configure permissions
- Set up systemd service

## 🏗️ Server Architecture

### User Structure
- **service-manager**: Dedicated user for the application
- **Permissions**: Limited sudo access for service management only
- **Security**: No root access, minimal privileges

### Directory Structure
```
/opt/service-manager/
├── app/                    # Application files
├── venv/                  # Python virtual environment
└── backups/               # Deployment backups
```

### Service Management
- **systemd service**: `service-manager.service`
- **Port**: 5000
- **Auto-restart**: Enabled
- **Logs**: journalctl -u service-manager

## 🔒 Security Features

### SSH Key Authentication
- Dedicated SSH key for deployment
- No password authentication
- Limited user permissions

### Service Permissions
- Granular control over service operations
- Configurable permission levels:
  - `restart`: Can only restart
  - `start`: Can start/stop/restart
  - `all`: Full control

### File Permissions
- Proper ownership and permissions
- Read-only access where possible
- Secure configuration files

## 📊 Service Configuration

### services.yaml
```yaml
services:
  pzserver:
    display_name: "PZServer Game Server"
    permissions_required: "restart"
    description: "Project Zomboid dedicated game server"
  
  nginx:
    display_name: "Nginx Web Server"
    permissions_required: "all"
    description: "Web server and reverse proxy"
```

### Permission Levels
- **restart**: Limited to restart operations
- **start**: Can start, stop, and restart
- **all**: Full control over the service

## 🚨 Troubleshooting

### SSH Connection Issues
```bash
# Test connection
ssh -v service-manager

# Check key permissions
chmod 600 ~/.ssh/service-manager-deploy
chmod 644 ~/.ssh/service-manager-deploy.pub

# Verify server accessibility
ping 192.168.1.130
```

### Service Issues
```bash
# Check service status
ssh service-manager "sudo systemctl status service-manager"

# View logs
ssh service-manager "sudo journalctl -u service-manager -f"

# Restart service
ssh service-manager "sudo systemctl restart service-manager"
```

### Deployment Issues
```bash
# Check deployment logs
./scripts/deploy.sh

# Verify file permissions
ssh service-manager "ls -la /opt/service-manager/app/"

# Test application manually
curl http://192.168.1.130:5000/api/services
```

## 🔄 Deployment Workflow

### 1. Development
- Make changes to your code
- Test locally if possible
- Commit changes to version control

### 2. Deployment
```bash
# Deploy to server
./scripts/deploy.sh

# Verify deployment
curl http://192.168.1.130:5000/api/services
```

### 3. Monitoring
- Check service status
- Monitor application logs
- Verify functionality

### 4. Rollback (if needed)
```bash
# Rollback to previous version
./scripts/rollback.sh
```

## 📈 Advanced Features

### Automated Backups
- Every deployment creates a backup
- Automatic backup naming with timestamps
- Easy rollback to any previous version

### Health Checks
- Service status verification
- Application response testing
- Automatic failure detection

### Service Discovery
- Automatic systemd service scanning
- Interactive service configuration
- Permission level suggestions

## 🎯 Best Practices

### Security
- Keep SSH keys secure
- Regularly rotate keys
- Monitor access logs
- Use minimal required permissions

### Deployment
- Test changes locally first
- Deploy during low-traffic periods
- Monitor after deployment
- Keep deployment logs

### Maintenance
- Regular service updates
- Monitor system resources
- Backup important configurations
- Document customizations

## 📞 Support

### Common Issues
1. **Permission denied**: Check SSH key setup and user permissions
2. **Service won't start**: Check logs and dependencies
3. **Deployment fails**: Verify server connectivity and file permissions

### Getting Help
1. Check the troubleshooting section above
2. Review deployment logs
3. Verify server configuration
4. Check service status and logs

---

**Happy Service Management! 🎮**
