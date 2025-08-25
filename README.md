# Service Manager

A professional, lightweight web interface for managing systemd services with granular permissions and modern UI.

## Features

- 🚀 **Multi-Service Management**: Manage multiple systemd services with granular permissions
- 📊 **Real-Time Status**: Live display of all configured services
- 🎨 **Professional Interface**: Modern, responsive design with enterprise-grade appearance
- 🚀 **SSH-Based Deployment**: Secure, automated deployment system
- 🔒 **Secure**: Non-root container with minimal privileges
- 🔐 **Permission-Based Access**: Control who can start/stop/restart each service

## Screenshots

The interface features:
- Multi-service management dashboard with status cards
- Action buttons (start/stop/restart) based on permissions
- Real-time service status display with visual indicators
- Clean, modern design with professional appearance
- Responsive layout for all devices

## Prerequisites

- SSH access to your server
- Systemd services configured for management
- Port 5000 available on the host

## Quick Start

### Option 1: Automated Deployment (Recommended)

```bash
# Complete initial setup and deployment
make setup

# Deploy updates
make deploy

# Check status
make status
```



### Access the Interface

Open your browser and navigate to:
```
http://YOUR_SERVER_IP:5000  # After deployment
```



## Usage

### Manage Services
1. View all configured services and their current status
2. Use action buttons (start/stop/restart) based on your permissions
3. Wait for confirmation message
4. Service status will automatically update

### Check Status
- Current status of all services is displayed
- Status auto-refreshes every 30 seconds
- Click "Refresh Status" for immediate update

### Status Indicators
- 🟢 **Running**: Service is active and running
- 🔴 **Inactive**: Service is stopped
- 🟡 **Failed**: Service failed to start
- ⚪ **Checking**: Status is being determined

## API Endpoints

### GET /api/services
Returns all configured services with their current status and permissions.

**Response:**
```json
{
  "status": "success",
  "data": {
    "sample-service": {
      "name": "sample-service",
      "display_name": "Sample HTTP Service",
      "description": "Simple HTTP server for demonstration",
      "status": "running",
      "permissions": "all"
    }
  }
}
```

### GET /api/service/<service_name>/status
Returns the current status of a specific service.

**Response:**
```json
{
  "status": "success",
  "data": "running"
}
```

### POST /api/service/<service_name>/<action>
Executes an action (start/stop/restart) on a specific service.

**Response:**
```json
{
  "status": "success",
  "message": "Service restart initiated successfully"
}
```

## Configuration

### Service Configuration
Services are configured in `config/services.yaml`:

```yaml
services:
  sample-service:
    display_name: "Sample HTTP Service"
    description: "Simple HTTP server for demonstration"
    permissions_required: "all"
    status_check_allowed: true
```

### Permission Levels
- **restart**: Can only restart the service
- **start**: Can start, stop, and restart the service
- **stop**: Can stop and restart the service
- **all**: Full control over the service

### Deployment Configuration
The deployment configuration is managed through environment variables:

1. **Copy the template**: Copy `config/deployment.env.example` to `config/deployment.env`
2. **Customize settings**: Edit `config/deployment.env` with your server details
3. **Keep private**: The `deployment.env` file is excluded from git for security

```bash
# Copy and customize the configuration
cp config/deployment.env.example config/deployment.env
# Edit deployment.env with your actual server details
```

### Environment Variables
- `PYTHONUNBUFFERED=1`: Ensures Python output is not buffered

### Port Configuration
The default port is 5000. To change this:

1. Update the `app.py` file with your desired port
2. Ensure the port is available on your server

## Troubleshooting

### Service Not Found
If you get "Service not found" errors:

1. Verify the service exists in your system:
```bash
systemctl list-units --type=service | grep <service-name>
```

2. Check service name spelling in `config/services.yaml`

### Permission Denied
If restart operations fail:

1. Verify host systemd socket access:
```bash
ls -la /run/systemd/system/
```

2. Check sudo permissions for the service-manager user



### Status Not Updating
1. Check if the service-manager can access systemd:
```bash
ssh YOUR_USER@YOUR_SERVER "sudo systemctl is-active <service-name>"
```

2. Verify the service-manager service is running on the server

## Deployment

### Automated Deployment System

The project includes a comprehensive automated deployment system:

- **SSH Key Authentication**: Secure, passwordless server access
- **One-Command Setup**: Complete server environment setup
- **Automated Deployment**: Deploy updates with a single command
- **Rollback Capability**: Quick recovery to previous versions
- **Service Discovery**: Automatically find and configure new services
- **Health Monitoring**: Built-in status checking and monitoring

For detailed deployment instructions, see [README-DEPLOYMENT.md](README-DEPLOYMENT.md).

### Quick Commands

```bash
make setup      # Initial server setup
make deploy     # Deploy updates
make status     # Check status
make rollback   # Rollback changes
make discover   # Find new services
make help       # Show all commands
```

## Development

### Local Development

1. Install Python dependencies:
```bash
pip install -r requirements.txt
```

2. Run the application:
```bash
python app.py
```

3. Access at `http://localhost:5000`

### Project Structure
```
service-manager/
├── app.py              # Main Flask application
├── requirements.txt    # Python dependencies
├── config/            # Configuration files
│   ├── services.yaml  # Service definitions and permissions
│   └── deployment.env.example # Deployment configuration template
├── scripts/           # Deployment and management scripts
│   ├── deploy.sh      # Main deployment script
│   ├── setup-server-user.sh # Server user setup
│   └── service-discovery.sh # Service discovery automation
├── templates/         # HTML templates
│   └── index.html    # Main page template
├── static/           # Static assets
│   ├── css/         # Stylesheets
│   │   └── style.css
│   └── js/          # JavaScript
│       └── script.js
├── sample-service.py  # Example service for demonstration
├── sample-service.service # Systemd service file for sample
├── Makefile          # Convenient make commands
└── README.md         # This file
```

## Security Considerations

- Container runs as non-root user
- Minimal required capabilities (SYS_ADMIN only)
- No new privileges escalation
- Host systemd access is read-only where possible

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is open source and available under the [MIT License](LICENSE).

## Support

For issues and questions:
1. Check the troubleshooting section above
2. Review systemd logs
3. Open an issue in the repository

---

**Happy Service Management! 🚀**

