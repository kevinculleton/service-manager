# Database Schema & Data Management

## Overview
The Service Manager uses a **file-based configuration system** rather than a traditional database, providing simplicity, version control, and easy backup/restore capabilities.

## Data Architecture

### **Configuration-Driven Design**
- **Primary Storage**: YAML configuration files
- **Service Definitions**: `config/services.yaml`
- **Runtime State**: In-memory service status tracking
- **Persistence**: File-based configuration with real-time updates

### **Data Flow Architecture**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   YAML Config  │    │   Flask App     │    │   Systemd       │
│                 │◄──►│                 │◄──►│   Services      │
│   - Services   │    │   - In-Memory   │    │   - Status      │
│   - Permissions│    │   - Status      │    │   - Operations  │
│   - Metadata   │    │   - Cache       │    │   - Health      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Configuration Schema

### **Services Configuration (`config/services.yaml`)**

```yaml
# Service Manager Configuration
services:
  service-name:
    display_name: "Human Readable Name"
    description: "Service description and purpose"
    permissions_required: "restart|start|stop|all"
    status_check_allowed: true|false
```

#### **Field Definitions**

| Field | Type | Required | Description | Example |
|-------|------|----------|-------------|---------|
| `service-name` | string | ✅ | Systemd service identifier | `pzserver` |
| `display_name` | string | ✅ | Human-readable service name | `"PZServer Game Server"` |
| `description` | string | ✅ | Service description | `"Project Zomboid dedicated game server"` |
| `permissions_required` | string | ✅ | Access level required | `"restart"`, `"all"` |
| `status_check_allowed` | boolean | ✅ | Can check service status | `true`, `false` |

#### **Permission Levels**

| Level | Description | Allowed Operations |
|-------|-------------|-------------------|
| `"restart"` | Restart only | Restart service |
| `"start"` | Start and restart | Start, restart service |
| `"stop"` | Stop and restart | Stop, restart service |
| `"all"` | Full control | Start, stop, restart service |

### **Current Service Configuration**

```yaml
services:
  pzserver:
    display_name: "PZServer Game Server"
    description: "Project Zomboid dedicated game server"
    permissions_required: "restart"
    status_check_allowed: true
    
  sample-service:
    display_name: "Sample HTTP Service"
    description: "Simple HTTP server for demonstration purposes"
    permissions_required: "all"
    status_check_allowed: true
```

## Runtime Data Structures

### **In-Memory Service Status**

```python
# Service status structure in Flask app
services = {
    "pzserver": {
        "name": "pzserver",
        "display_name": "PZServer Game Server",
        "description": "Project Zomboid dedicated game server",
        "status": "active|inactive|failed|error",
        "permissions": "restart",
        "last_check": "2025-08-23T21:46:00Z"
    }
}
```

### **Status Values**

| Status | Description | Visual Indicator |
|--------|-------------|------------------|
| `"active"` | Service running normally | Green border, success badge |
| `"inactive"` | Service stopped | Yellow border, warning badge |
| `"failed"` | Service failed to start | Red border, error badge |
| `"error"` | Status check error | Red border, error badge |
| `"checking"` | Status check in progress | Loading indicator |

## Data Management Patterns

### **Configuration Loading**

```python
# Load service configuration from YAML
def load_services_config():
    with open('config/services.yaml', 'r') as file:
        config = yaml.safe_load(file)
    return config.get('services', {})
```

### **Status Synchronization**

```python
# Real-time status updates
def update_service_status(service_name):
    status = check_systemd_status(service_name)
    services[service_name]['status'] = status
    services[service_name]['last_check'] = datetime.utcnow()
```

### **Permission Validation**

```python
# Check user permissions for service actions
def check_permission(service_name, action):
    service_config = services_config.get(service_name, {})
    permissions = service_config.get('permissions_required', '')
    
    if action == 'restart':
        return permissions in ['restart', 'start', 'stop', 'all']
    elif action == 'start':
        return permissions in ['start', 'all']
    elif action == 'stop':
        return permissions in ['stop', 'all']
    
    return False
```

## Data Persistence Strategy

### **Configuration Persistence**
- **Primary**: YAML configuration files in version control
- **Backup**: Automated backup before each deployment
- **Versioning**: Git-based version control and rollback
- **Validation**: YAML schema validation and error checking

### **Runtime Persistence**
- **In-Memory**: Service status cached in Flask application
- **Real-time Updates**: Status refreshed every 30 seconds
- **Session Management**: No user sessions (stateless design)
- **State Recovery**: Automatic status refresh on application restart

### **Backup & Recovery**

```bash
# Automated backup creation
backup_dir="backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir"
cp -r /opt/service-manager/app/* "$backup_dir/"
```

## Data Validation & Security

### **Input Validation**

```python
# Service name validation
def validate_service_name(service_name):
    allowed_services = services_config.keys()
    return service_name in allowed_services

# Action validation
def validate_action(action):
    allowed_actions = ['start', 'stop', 'restart']
    return action in allowed_actions
```

### **Permission Security**

```python
# Server-side permission enforcement
def execute_service_action(service_name, action):
    if not check_permission(service_name, action):
        return {"status": "error", "message": "Insufficient permissions"}
    
    # Execute action with proper sudo permissions
    result = subprocess.run([
        '/usr/bin/sudo', 
        f'/usr/local/bin/service-manager-{action}', 
        service_name
    ], capture_output=True, text=True)
    
    return {"status": "success", "message": f"Action {action} executed"}
```

## Scalability Considerations

### **Current Architecture Benefits**
- **No Database Dependencies**: Simple file-based configuration
- **Easy Scaling**: Add services by updating YAML configuration
- **Version Control**: Full configuration history and rollback
- **Backup/Restore**: Simple file-based backup and recovery

### **Future Enhancement Options**
- **Database Integration**: PostgreSQL/MySQL for complex data relationships
- **Caching Layer**: Redis for high-performance status caching
- **Event Streaming**: Kafka for real-time service event processing
- **Metrics Storage**: Time-series database for performance metrics

## Data Migration & Evolution

### **Configuration Evolution**
- **Backward Compatibility**: Maintain support for existing configurations
- **Schema Versioning**: Version control for configuration format changes
- **Migration Scripts**: Automated migration of old configurations
- **Validation**: Schema validation for configuration integrity

### **Service Discovery Integration**
- **Automatic Detection**: Discover existing systemd services
- **Configuration Generation**: Auto-generate service configurations
- **Permission Assignment**: Default permission assignments for new services
- **Validation**: Ensure discovered services are properly configured

## Monitoring & Analytics

### **Data Collection**
- **Service Operations**: Track all start/stop/restart operations
- **Status Changes**: Monitor service status transitions
- **Performance Metrics**: Response times and operation success rates
- **Error Tracking**: Log and analyze service operation failures

### **Reporting & Insights**
- **Service Health**: Overall system health and status
- **Operation History**: Historical service operation logs
- **Performance Trends**: Service response time trends
- **Error Analysis**: Common failure patterns and resolutions

## Summary

The Service Manager uses a **file-based, configuration-driven architecture** that provides:

- **Simplicity**: Easy to understand and modify
- **Version Control**: Full configuration history and rollback
- **Scalability**: Easy to add new services and features
- **Reliability**: No database dependencies or connection issues
- **Security**: Proper permission validation and enforcement
- **Performance**: Fast, in-memory status tracking and updates

This architecture is ideal for service management use cases where configuration changes are infrequent but reliability and simplicity are critical.
