# System Patterns

## Architecture Overview
Professional multi-service management platform with modern web interface, Flask backend, and comprehensive systemd integration.

## Component Structure
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Web Browser  │    │   Flask Server  │    │   Systemd       │
│                 │◄──►│                 │◄──►│   Services      │
│   - Modern UI  │    │   - REST API    │    │   - Multi-service│
│   - Responsive │    │   - Permission  │    │   - Management  │
│   - Real-time  │    │   - Management  │    │   - Monitoring  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │   Permission    │
                    │   System        │
                    │   - Role-based  │
                    │   - Granular    │
                    │   - Configurable│
                    └─────────────────┘
```

## Design Patterns

### Frontend Architecture
- **Component-based**: Modular service cards and UI components
- **Template-driven**: HTML templates for dynamic content generation
- **Responsive Design**: Mobile-first approach with CSS Grid and Flexbox
- **Modern CSS**: CSS variables, custom properties, and modern layout techniques

### Backend Architecture
- **RESTful API**: Clean HTTP endpoints for service operations
- **Permission-based Access**: Granular control over service operations
- **Service Abstraction**: Unified interface for different service types
- **Error Handling**: Comprehensive error handling with user feedback

### System Integration
- **Systemd Integration**: Direct systemd service management
- **Sudo Permission Management**: Secure execution of system commands
- **Service Discovery**: Dynamic service configuration and management
- **Health Monitoring**: Real-time service status checking

## Data Flow

### Service Management Flow
1. User accesses web interface
2. Frontend loads service configuration and status
3. User selects service action (start/stop/restart)
4. Frontend sends authenticated request to backend
5. Backend validates permissions and executes systemd command
6. Backend returns operation result to frontend
7. Frontend updates UI and shows user feedback
8. Real-time status updates continue automatically

### Permission System Flow
1. Service configuration loaded from YAML
2. Permission levels defined per service (restart, start, stop, all)
3. Status checking permissions controlled separately
4. Backend validates permissions before executing commands
5. Frontend shows/hides action buttons based on permissions

### Deployment Flow
1. Automated deployment script copies files to server
2. Python dependencies installed in virtual environment
3. Systemd service restarted with new code
4. Health checks verify successful deployment
5. Rollback capability available if needed

## Error Handling Patterns

### Frontend Error Handling
- **User-friendly Messages**: Clear, actionable error information
- **Loading States**: Visual feedback during operations
- **Graceful Degradation**: UI remains functional even with errors
- **Notification System**: Toast-style feedback for all operations

### Backend Error Handling
- **Permission Validation**: Check permissions before executing commands
- **Command Execution**: Proper error handling for systemd operations
- **Status Checking**: Fallback handling for service status failures
- **Logging**: Comprehensive logging for debugging and monitoring

### System Error Handling
- **Service Failures**: Graceful handling of service start/stop failures
- **Network Issues**: Timeout handling and retry logic
- **Permission Denials**: Clear feedback for insufficient permissions
- **System Errors**: Proper error codes and user feedback

## Security Patterns

### Authentication & Authorization
- **SSH Key-based Access**: Secure, passwordless server access
- **Sudo Permission Management**: Limited, specific command permissions
- **Service-level Permissions**: Granular control over service operations
- **Status Check Permissions**: Separate control for read-only operations

### Input Validation
- **Service Name Validation**: Whitelist-based service name checking
- **Action Validation**: Valid action type verification
- **Permission Checking**: Server-side permission validation
- **Command Sanitization**: Safe execution of system commands

### System Security
- **Dedicated User**: Service manager runs under dedicated user account
- **Limited Sudo Access**: Minimal required permissions for operations
- **Service Isolation**: Services run with appropriate user permissions
- **Audit Logging**: Track all service operations and changes

## Performance Patterns

### Frontend Performance
- **Lazy Loading**: Load service data on demand
- **Auto-refresh**: Background status updates every 30 seconds
- **Efficient DOM Updates**: Minimal DOM manipulation for updates
- **Responsive Design**: Optimized for all device sizes

### Backend Performance
- **Async Operations**: Non-blocking service operations
- **Caching**: Service status caching to reduce system calls
- **Connection Pooling**: Efficient database and system connections
- **Timeout Handling**: Proper timeouts for long-running operations

### System Performance
- **Lightweight Operations**: Minimal system resource usage
- **Efficient Commands**: Optimized systemd command execution
- **Status Monitoring**: Efficient service status checking
- **Resource Management**: Proper cleanup of system resources

