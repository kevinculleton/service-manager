# Product Context: Service Manager

## Why This Project Exists

### Original Problem
The project started as a solution to a simple need: restarting a Project Zomboid game server (pzserver) without SSH access. The original requirement was just a "big red button" to restart the service.

### Evolution to Service Management Platform
As development progressed, the scope expanded to address broader service management needs:
- **Multi-service support**: Managing multiple systemd services from one interface
- **Professional operations**: Providing enterprise-grade service management tools
- **User experience**: Creating intuitive interfaces for system administrators
- **Automation**: Reducing manual SSH work for routine service operations

## Problems It Solves

### For System Administrators
- **Remote Management**: Control services without direct server access
- **Visual Interface**: Replace command-line operations with intuitive web UI
- **Multi-service Control**: Manage multiple services from one dashboard
- **Status Monitoring**: Real-time visibility into service health

### For Development Teams
- **Quick Service Restarts**: Fast service management during development
- **Deployment Support**: Automated deployment with rollback capabilities
- **Service Discovery**: Easy addition of new services to the management system

### For Operations
- **Standardized Interface**: Consistent way to manage all services
- **Permission Control**: Granular access control for different user roles
- **Audit Trail**: Track service operations and changes
- **Health Monitoring**: Proactive service status monitoring

## How It Should Work

### User Experience
1. **Access**: Navigate to web interface (http://server:5000)
2. **Overview**: See dashboard with all managed services and their status
3. **Service Management**: Use action buttons (Start/Stop/Restart) based on permissions
4. **Real-time Updates**: Status automatically refreshes every 30 seconds
5. **Feedback**: Clear notifications for all operations

### Service Management
- **Status Checking**: Real-time service status with visual indicators
- **Action Execution**: Secure service operations through sudo permissions
- **Permission Enforcement**: Role-based access control for different operations
- **Error Handling**: Graceful handling of service failures and errors

### Technical Architecture
- **Flask Backend**: Lightweight Python web server
- **Systemd Integration**: Direct systemd service management
- **Permission System**: Configurable access levels per service
- **Responsive Design**: Works on desktop, tablet, and mobile devices

## Target Users

### Primary Users
- **System Administrators**: Managing server services and infrastructure
- **DevOps Engineers**: Service deployment and monitoring
- **Game Server Operators**: Managing game services like PZServer

### Secondary Users
- **Development Teams**: Quick service restarts during development
- **Support Staff**: Basic service status monitoring and restarts
- **Operations Teams**: Service health monitoring and management

## Success Metrics

### User Adoption
- **Daily Active Users**: Regular usage of the service management interface
- **Service Operations**: Number of start/stop/restart operations performed
- **User Satisfaction**: Feedback on interface usability and reliability

### Technical Performance
- **Service Response Time**: Fast service operations and status updates
- **System Reliability**: Uptime and error-free operation
- **Deployment Success**: Successful automated deployments and rollbacks

### Operational Efficiency
- **Reduced SSH Usage**: Fewer manual command-line operations
- **Faster Service Management**: Quicker service operations through UI
- **Improved Visibility**: Better awareness of service status across the system
