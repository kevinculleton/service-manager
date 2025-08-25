# PZServer Restart Web Interface

A simple, lightweight web interface for restarting the pzserver systemd service with one click.

## Features

- 🚀 **One-Click Restart**: Large, prominent red button for easy service restart
- 📊 **Real-Time Status**: Live display of pzserver service status
- 🎨 **Clean Interface**: Modern, responsive design with visual feedback
- 🐳 **Docker Ready**: Easy deployment with Docker and docker-compose
- 🔒 **Secure**: Non-root container with minimal privileges

## Screenshots

The interface features:
- A large red restart button that's impossible to miss
- Real-time service status display
- Clean, modern design with gradient background
- Responsive layout for all devices

## Prerequisites

- Docker and docker-compose installed
- pzserver systemd service running on the host
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

### Option 2: Manual Docker Setup

```bash
# Clone or Download
git clone <repository-url>
cd pzserver-restart

# Build and start the container
docker-compose up -d

# Check logs
docker-compose logs -f
```

### Access the Interface

Open your browser and navigate to:
```
http://192.168.1.130:5000  # Automated deployment
http://localhost:5000       # Local Docker
```

## Manual Docker Commands

If you prefer not to use docker-compose:

```bash
# Build the image
docker build -t pzserver-restart .

# Run the container
docker run -d \
  --name pzserver-restart \
  --network host \
  --cap-add SYS_ADMIN \
  -v /run/systemd/system:/run/systemd/system:ro \
  -v /var/run/systemd/system:/var/run/systemd/system:ro \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  pzserver-restart
```

## Usage

### Restart Service
1. Click the large red "RESTART PZSERVER" button
2. Wait for confirmation message
3. Service status will automatically update

### Check Status
- Current service status is displayed at the top
- Status auto-refreshes every 30 seconds
- Click "Refresh Status" for immediate update

### Status Indicators
- 🟢 **Running**: Service is active and running
- 🔴 **Inactive**: Service is stopped
- 🟡 **Failed**: Service failed to start
- ⚪ **Checking**: Status is being determined

## API Endpoints

### GET /api/status
Returns the current status of the pzserver service.

**Response:**
```json
{
  "status": "success",
  "data": "running"
}
```

### POST /api/restart
Initiates a restart of the pzserver service.

**Response:**
```json
{
  "status": "success",
  "message": "Service restart initiated successfully"
}
```

## Configuration

### Environment Variables
- `PYTHONUNBUFFERED=1`: Ensures Python output is not buffered

### Port Configuration
The default port is 5000. To change this:

1. Modify `docker-compose.yml`:
```yaml
ports:
  - "YOUR_PORT:5000"
```

2. Update the `app.py` file if needed.

## Troubleshooting

### Service Not Found
If you get "Service not found" errors:

1. Verify pzserver service exists:
```bash
systemctl list-units --type=service | grep pzserver
```

2. Check service name spelling in `app.py`

### Permission Denied
If restart operations fail:

1. Ensure the container has proper capabilities:
```bash
docker inspect pzserver-restart | grep -A 10 "CapAdd"
```

2. Verify host systemd socket access:
```bash
ls -la /run/systemd/system/
```

### Container Won't Start
1. Check Docker logs:
```bash
docker-compose logs
```

2. Verify port 5000 is available:
```bash
netstat -tulpn | grep :5000
```

### Status Not Updating
1. Check if the container can access systemd:
```bash
docker exec pzserver-restart systemctl is-active pzserver
```

2. Verify network mode is set to host in docker-compose.yml

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

### Local Development (without Docker)

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
pzserver-restart/
├── app.py              # Main Flask application
├── requirements.txt    # Python dependencies
├── Dockerfile         # Container configuration
├── docker-compose.yml # Deployment configuration
├── templates/         # HTML templates
│   └── index.html    # Main page template
├── static/           # Static assets
│   ├── css/         # Stylesheets
│   │   └── style.css
│   └── js/          # JavaScript
│       └── script.js
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
2. Review Docker and systemd logs
3. Open an issue in the repository

---

**Happy PZServer management! 🎮**

