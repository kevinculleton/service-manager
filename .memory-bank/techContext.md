# Technical Context

## Technology Stack

### Backend
- **Framework**: Python 3.13 with Flask 2.3.3
- **Dependencies**: PyYAML 6.0.1 for configuration management
- **Architecture**: RESTful API with permission-based access control
- **Integration**: Direct systemd integration via subprocess

### Frontend
- **HTML**: Semantic HTML5 with modern template system
- **CSS**: Modern CSS with variables, Grid, Flexbox, and responsive design
- **JavaScript**: ES6+ class-based architecture with modern async/await
- **Design System**: Professional UI with CSS variables and consistent theming
- **Icons**: Font Awesome 6.4.0 for professional iconography
- **Typography**: Inter font family for excellent readability

### System Integration
- **Service Management**: Direct systemd integration via subprocess
- **Permission System**: Granular sudo permission management
- **Status Monitoring**: Real-time service status checking
- **Command Execution**: Secure systemd command execution

### Deployment & Infrastructure
- **Server**: Arch Linux with systemd
- **User Management**: Dedicated `service-manager` user account
- **SSH Access**: Key-based authentication for secure deployment
- **Service Management**: Systemd service for the Service Manager itself
- **Port Management**: Port 5000 for web interface, 8090 for sample service

## Development Environment

### Local Development
- **Python**: Python 3.13+ with virtual environment support
- **Dependencies**: Flask, PyYAML, and development tools
- **Version Control**: Git with comprehensive deployment scripts
- **Testing**: Local testing with mock systemd services

### Server Environment
- **Operating System**: Arch Linux (tested and configured)
- **Python**: Python 3.13 with virtual environment
- **Systemd**: Full systemd integration for service management
- **User Permissions**: Dedicated user with limited sudo access

## Technical Constraints

### System Requirements
- **Linux Distribution**: Systemd-based distributions (Arch Linux tested)
- **Python Version**: Python 3.13+ for modern language features
- **User Permissions**: Appropriate sudo permissions for service management
- **Port Availability**: Available ports for web interface and managed services

### Performance Constraints
- **Lightweight**: Minimal system resource usage
- **Fast Response**: Quick service operations and status updates
- **Real-time Updates**: Background status monitoring every 30 seconds
- **Scalable**: Support for multiple services without performance degradation

### Security Constraints
- **Limited Permissions**: Minimal required sudo access for operations
- **Service Isolation**: Services run with appropriate user permissions
- **Input Validation**: Comprehensive validation of all user inputs
- **Audit Logging**: Track all service operations and changes

## Dependencies

### Python Dependencies
- **Flask 2.3.3**: Web framework for the service management interface
- **PyYAML 6.0.1**: YAML configuration file parsing
- **Werkzeug 3.1.3**: WSGI utilities (Flask dependency)
- **Jinja2 3.1.6**: Template engine (Flask dependency)

### System Dependencies
- **systemd**: System and service manager
- **sudo**: Privilege escalation for service operations
- **SSH**: Secure remote access and deployment
- **Python 3.13**: Runtime environment

### Frontend Dependencies
- **Font Awesome 6.4.0**: Professional icon library
- **Inter Font**: Modern, readable typography
- **Modern CSS**: CSS Grid, Flexbox, and custom properties support

## Security Considerations

### Authentication & Authorization
- **SSH Key-based Access**: Secure, passwordless server access
- **Sudo Permission Management**: Limited, specific command permissions
- **Service-level Permissions**: Granular control over service operations
- **Status Check Permissions**: Separate control for read-only operations

### Input Validation & Sanitization
- **Service Name Validation**: Whitelist-based service name checking
- **Action Validation**: Valid action type verification
- **Permission Checking**: Server-side permission validation
- **Command Sanitization**: Safe execution of system commands

### System Security
- **Dedicated User**: Service manager runs under dedicated user account
- **Limited Sudo Access**: Minimal required permissions for operations
- **Service Isolation**: Services run with appropriate user permissions
- **Audit Logging**: Track all service operations and changes

## Deployment Architecture

### Server Setup
- **Dedicated User**: `service-manager` user with limited permissions
- **Application Directory**: `/opt/service-manager/` for application files
- **Virtual Environment**: Python virtual environment for dependencies
- **Systemd Service**: Service Manager runs as systemd service

### Deployment Process
- **Automated Scripts**: One-command deployment with rollback capability
- **SSH Key Management**: Secure, passwordless deployment access
- **File Synchronization**: SCP-based file deployment
- **Health Checks**: Post-deployment verification and testing

### Service Management
- **Permission Scripts**: Custom sudo permission management scripts
- **Service Discovery**: Automated service detection and configuration
- **Health Monitoring**: Real-time service status monitoring
- **Error Handling**: Comprehensive error handling and user feedback

## Performance & Scalability

### Frontend Performance
- **Lazy Loading**: Load service data on demand
- **Auto-refresh**: Background status updates every 30 seconds
- **Efficient DOM Updates**: Minimal DOM manipulation for updates
- **Responsive Design**: Optimized for all device sizes

### Backend Performance
- **Async Operations**: Non-blocking service operations
- **Efficient Commands**: Optimized systemd command execution
- **Status Monitoring**: Efficient service status checking
- **Resource Management**: Proper cleanup of system resources

### System Performance
- **Lightweight Operations**: Minimal system resource usage
- **Efficient Commands**: Optimized systemd command execution
- **Status Monitoring**: Efficient service status checking
- **Resource Management**: Proper cleanup of system resources
