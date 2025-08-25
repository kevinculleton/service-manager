#!/usr/bin/env python3
"""
Generic Service Manager - Flask Web Application
Manages multiple systemd services with configurable permissions
"""

import os
import yaml
import subprocess
from flask import Flask, render_template, jsonify, request

# Load configuration
def load_config():
    """Load configuration from environment or config file"""
    config = {
        'web_port': int(os.environ.get('WEB_PORT', 5000)),
        'debug': os.environ.get('FLASK_DEBUG', 'false').lower() == 'true'
    }
    return config

app = Flask(__name__)
config = load_config()

# Load service configuration
def load_services_config():
    """Load services configuration from YAML file"""
    config_path = os.path.join(os.path.dirname(__file__), 'config', 'services.yaml')
    try:
        with open(config_path, 'r') as file:
            config = yaml.safe_load(file)
            return config.get('services', {})
    except Exception as e:
        print(f"Error loading services config: {e}")
        # Fallback to default pzserver service
        return {
            'pzserver': {
                'display_name': 'PZServer Game Server',
                'permissions_required': 'restart',
                'description': 'Project Zomboid dedicated game server'
            }
        }

def get_service_status(service_name):
    """Get the status of a specific service"""
    try:
        print(f"DEBUG: Getting status for service: {service_name}")
        
        # Check if status checking is allowed for this service
        services = load_services_config()
        if service_name in services:
            status_check_allowed = services[service_name].get('status_check_allowed', True)
            print(f"DEBUG: status_check_allowed = {status_check_allowed}")
            if not status_check_allowed:
                print(f"DEBUG: Status checking disabled for {service_name}")
                return 'status_check_disabled'
        
        # Use the service management script with sudo (full path)
        print(f"DEBUG: Running service-manager-status for {service_name}")
        result = subprocess.run(
            ['/usr/bin/sudo', '/usr/local/bin/service-manager-status', service_name],
            capture_output=True,
            text=True,
            timeout=10
        )
        print(f"DEBUG: Command result: returncode={result.returncode}, stdout='{result.stdout.strip()}', stderr='{result.stderr.strip()}'")
        
        if result.returncode == 0:
            status = result.stdout.strip()
            print(f"DEBUG: Returning status: {status}")
            return status
        else:
            print(f"DEBUG: Command failed, returning 'inactive'")
            return 'inactive'
    except subprocess.TimeoutExpired:
        print(f"DEBUG: Timeout occurred")
        return 'timeout'
    except Exception as e:
        print(f"DEBUG: Exception occurred: {e}")
        print(f"Error checking service {service_name} status: {e}")
        return 'error'

def execute_service_action(service_name, action):
    """Execute a service action (start/stop/restart)"""
    try:
        if action == 'restart':
            result = subprocess.run(
                ['/usr/bin/sudo', '/usr/local/bin/service-manager-restart', service_name],
                capture_output=True,
                text=True,
                timeout=30
            )
        elif action == 'start':
            result = subprocess.run(
                ['/usr/bin/sudo', '/usr/local/bin/service-manager-start', service_name],
                capture_output=True,
                text=True,
                timeout=30
            )
        elif action == 'stop':
            result = subprocess.run(
                ['/usr/bin/sudo', '/usr/local/bin/service-manager-stop', service_name],
                capture_output=True,
                text=True,
                timeout=30
            )
        else:
            return False, f"Invalid action: {action}"
        
        if result.returncode == 0:
            return True, f"Service {action} initiated successfully"
        else:
            return False, f"Failed to {action} service: {result.stderr}"
            
    except subprocess.TimeoutExpired:
        return False, f"Timeout while {action}ing service"
    except Exception as e:
        return False, f"Error {action}ing service: {e}"

def check_permission(service_name, action):
    """Check if the requested action is allowed for the service"""
    services = load_services_config()
    if service_name not in services:
        return False
    
    permissions = services[service_name].get('permissions_required', 'restart')
    
    # Status checking is always allowed if explicitly enabled
    if action == 'status':
        return services[service_name].get('status_check_allowed', True)
    
    # Action permissions
    if permissions == 'all':
        return True
    elif permissions == 'restart' and action == 'restart':
        return True
    elif permissions == 'stop' and action in ['stop', 'restart']:
        return True
    elif permissions == 'start' and action in ['start', 'restart']:
        return True
    
    return False

@app.route('/')
def index():
    """Main page showing all services"""
    services = load_services_config()
    return render_template('index.html', services=services)

@app.route('/api/services')
def get_services():
    """Get all services with their current status"""
    print("DEBUG: get_services() called")
    services = load_services_config()
    print(f"DEBUG: Loaded services config: {services}")
    service_statuses = {}
    
    for service_name in services:
        print(f"DEBUG: Processing service: {service_name}")
        status = get_service_status(service_name)
        print(f"DEBUG: Service {service_name} status: {status}")
        service_statuses[service_name] = {
            'name': service_name,
            'display_name': services[service_name]['display_name'],
            'description': services[service_name]['description'],
            'status': status,
            'permissions': services[service_name]['permissions_required']
        }
    
    print(f"DEBUG: Final service_statuses: {service_statuses}")
    return jsonify({
        'status': 'success',
        'data': service_statuses
    })

@app.route('/api/service/<service_name>/status')
def get_service_status_api(service_name):
    """Get status of a specific service"""
    if service_name not in load_services_config():
        return jsonify({
            'status': 'error',
            'message': 'Service not found'
        }), 404
    
    status = get_service_status(service_name)
    return jsonify({
        'status': 'success',
        'data': status
    })

@app.route('/api/service/<service_name>/<action>', methods=['POST'])
def service_action(service_name, action):
    """Execute an action on a service (start/stop/restart)"""
    if action not in ['start', 'stop', 'restart']:
        return jsonify({
            'status': 'error',
            'message': 'Invalid action'
        }), 400
    
    if not check_permission(service_name, action):
        return jsonify({
            'status': 'error',
            'message': 'Action not permitted for this service'
        }), 403
    
    success, message = execute_service_action(service_name, action)
    
    if success:
        return jsonify({
            'status': 'success',
            'message': message
        })
    else:
        return jsonify({
            'status': 'error',
            'message': message
        }), 500

# Legacy endpoints for backward compatibility
@app.route('/api/status')
def legacy_status():
    """Legacy endpoint for pzserver status"""
    status = get_service_status('pzserver')
    return jsonify({
        'status': 'success',
        'data': status
    })

@app.route('/api/restart', methods=['POST'])
def legacy_restart():
    """Legacy endpoint for pzserver restart"""
    success, message = execute_service_action('pzserver', 'restart')
    
    if success:
        return jsonify({
            'status': 'success',
            'message': message
        })
    else:
        return jsonify({
            'status': 'error',
            'message': message
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=config['web_port'], debug=config['debug'])
