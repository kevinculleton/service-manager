// Professional Service Manager - Modern JavaScript

class ServiceManager {
    constructor() {
        this.services = {};
        this.isLoading = false;
        this.refreshInterval = null;
        this.init();
    }

    init() {
        this.loadServices();
        this.startAutoRefresh();
        this.setupEventListeners();
    }

    setupEventListeners() {
        // Add any additional event listeners here
        document.addEventListener('keydown', (e) => {
            if (e.key === 'r' && (e.ctrlKey || e.metaKey)) {
                e.preventDefault();
                this.refreshAllServices();
            }
        });
    }

    async loadServices() {
        try {
            this.showLoading();
            const response = await fetch('/api/services');
            const data = await response.json();
            
            if (data.status === 'success') {
                this.services = data.data;
                this.renderServices();
                this.updateOverview();
            } else {
                this.showNotification('Failed to load services', 'error');
            }
        } catch (error) {
            console.error('Error loading services:', error);
            this.showNotification('Network error while loading services', 'error');
        } finally {
            this.hideLoading();
        }
    }

    renderServices() {
        const servicesGrid = document.getElementById('services-grid');
        servicesGrid.innerHTML = '';

        Object.values(this.services).forEach(service => {
            const serviceCard = this.createServiceCard(service);
            servicesGrid.appendChild(serviceCard);
        });
    }

    createServiceCard(service) {
        const template = document.getElementById('service-template');
        const clone = template.content.cloneNode(true);
        
        // Set service information
        clone.querySelector('.service-name').textContent = service.display_name;
        clone.querySelector('.service-description').textContent = service.description;
        
        // Set status with appropriate styling
        const statusElement = clone.querySelector('.service-status');
        statusElement.textContent = this.formatStatus(service.status);
        statusElement.className = `service-status status-${this.getStatusClass(service.status)}`;
        
        // Add status class to card for border color
        const card = clone.querySelector('.service-card');
        card.classList.add(`status-${this.getStatusClass(service.status)}`);
        
        // Create action buttons
        const actionsContainer = clone.querySelector('.service-actions');
        this.createActionButtons(actionsContainer, service);
        
        return clone;
    }

    createActionButtons(container, service) {
        const permissions = service.permissions;
        
        // Start button
        if (permissions === 'all' || permissions === 'start') {
            const startBtn = this.createButton('Start', 'btn-success', () => {
                this.executeServiceAction(service.name, 'start');
            });
            container.appendChild(startBtn);
        }
        
        // Stop button
        if (permissions === 'all' || permissions === 'stop') {
            const stopBtn = this.createButton('Stop', 'btn-danger', () => {
                this.executeServiceAction(service.name, 'stop');
            });
            container.appendChild(stopBtn);
        }
        
        // Restart button (always available for restart permission)
        if (permissions === 'all' || permissions === 'restart' || permissions === 'start') {
            const restartBtn = this.createButton('Restart', 'btn-warning', () => {
                this.executeServiceAction(service.name, 'restart');
            });
            container.appendChild(restartBtn);
        }
        
        // Status refresh button
        const refreshBtn = this.createButton('Refresh', 'btn-outline', () => {
            this.refreshServiceStatus(service.name);
        });
        container.appendChild(refreshBtn);
    }

    createButton(text, className, onClick) {
        const button = document.createElement('button');
        button.className = `btn ${className}`;
        button.textContent = text;
        button.addEventListener('click', onClick);
        return button;
    }

    formatStatus(status) {
        const statusMap = {
            'active': 'Active',
            'inactive': 'Inactive',
            'failed': 'Failed',
            'error': 'Error',
            'timeout': 'Timeout',
            'checking': 'Checking'
        };
        return statusMap[status] || status;
    }

    getStatusClass(status) {
        if (status === 'active') return 'active';
        if (status === 'inactive' || status === 'failed') return 'inactive';
        return 'error';
    }

    async executeServiceAction(serviceName, action) {
        try {
            this.showNotification(`Executing ${action} for ${serviceName}...`, 'info');
            
            const response = await fetch(`/api/service/${serviceName}/${action}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                }
            });
            
            const data = await response.json();
            
            if (data.status === 'success') {
                this.showNotification(`${action} executed successfully for ${serviceName}`, 'success');
                // Refresh the service status
                setTimeout(() => this.refreshServiceStatus(serviceName), 1000);
            } else {
                this.showNotification(`Failed to ${action} ${serviceName}: ${data.message}`, 'error');
            }
        } catch (error) {
            console.error(`Error executing ${action} for ${serviceName}:`, error);
            this.showNotification(`Network error while executing ${action}`, 'error');
        }
    }

    async refreshServiceStatus(serviceName) {
        try {
            const response = await fetch(`/api/service/${serviceName}/status`);
            const data = await response.json();
            
            if (data.status === 'success') {
                // Update the service status in our data
                if (this.services[serviceName]) {
                    this.services[serviceName].status = data.data;
                    this.renderServices();
                    this.updateOverview();
                }
            }
        } catch (error) {
            console.error(`Error refreshing status for ${serviceName}:`, error);
        }
    }

    async refreshAllServices() {
        if (this.isLoading) return;
        
        this.isLoading = true;
        const refreshBtn = document.querySelector('.refresh-btn');
        refreshBtn.classList.add('loading');
        
        try {
            await this.loadServices();
            this.showNotification('All services refreshed successfully', 'success');
        } catch (error) {
            this.showNotification('Failed to refresh services', 'error');
        } finally {
            this.isLoading = false;
            refreshBtn.classList.remove('loading');
        }
    }

    updateOverview() {
        const total = Object.keys(this.services).length;
        const active = Object.values(this.services).filter(s => s.status === 'active').length;
        const inactive = Object.values(this.services).filter(s => s.status === 'inactive').length;
        const error = Object.values(this.services).filter(s => s.status === 'error' || s.status === 'failed').length;
        
        document.getElementById('total-services').textContent = total;
        document.getElementById('active-services').textContent = active;
        document.getElementById('inactive-services').textContent = inactive;
        document.getElementById('error-services').textContent = error;
    }

    showLoading() {
        const servicesGrid = document.getElementById('services-grid');
        const template = document.getElementById('loading-template');
        const loadingElement = template.content.cloneNode(true);
        servicesGrid.appendChild(loadingElement);
    }

    hideLoading() {
        const loadingElement = document.querySelector('.loading');
        if (loadingElement) {
            loadingElement.remove();
        }
    }

    showNotification(message, type = 'info') {
        const container = document.getElementById('notification-container');
        const notification = document.createElement('div');
        notification.className = `notification ${type}`;
        notification.textContent = message;
        
        container.appendChild(notification);
        
        // Show notification
        setTimeout(() => notification.classList.add('show'), 100);
        
        // Auto-hide after 5 seconds
        setTimeout(() => {
            notification.classList.remove('show');
            setTimeout(() => notification.remove(), 300);
        }, 5000);
    }

    startAutoRefresh() {
        // Refresh every 30 seconds
        this.refreshInterval = setInterval(() => {
            this.loadServices();
        }, 30000);
    }

    stopAutoRefresh() {
        if (this.refreshInterval) {
            clearInterval(this.refreshInterval);
            this.refreshInterval = null;
        }
    }
}

// Initialize the service manager when the page loads
document.addEventListener('DOMContentLoaded', () => {
    window.serviceManager = new ServiceManager();
});

// Global function for refresh button
function refreshAllServices() {
    if (window.serviceManager) {
        window.serviceManager.refreshAllServices();
    }
}
