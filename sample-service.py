#!/usr/bin/env python3
"""
Sample Service - Simple HTTP Server
A basic service for demonstrating Service Manager capabilities
"""

import http.server
import socketserver
import time
import signal
import sys
import os

# Configuration
PORT = 8090
HOST = '0.0.0.0'

class SampleHTTPServer(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            
            html_content = """
<!DOCTYPE html>
<html>
<head>
    <title>Sample Service</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f0f0f0; }
        .container { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #2563eb; }
        .status { background: #dcfce7; color: #16a34a; padding: 10px; border-radius: 5px; margin: 20px 0; }
        .info { background: #f1f5f9; padding: 15px; border-radius: 5px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Sample Service</h1>
        <div class="status">
            <strong>Status:</strong> Running successfully!
        </div>
        <div class="info">
            <h3>Service Information:</h3>
            <p><strong>Port:</strong> {port}</p>
            <p><strong>Started:</strong> {start_time}</p>
            <p><strong>Uptime:</strong> {uptime}</p>
            <p><strong>Requests:</strong> {requests}</p>
        </div>
        <p>This is a simple sample service managed by your Service Manager!</p>
    </div>
</body>
</html>
            """.format(
                port=PORT,
                start_time=time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(start_time)),
                uptime=f"{int(time.time() - start_time)} seconds",
                requests=request_count
            )
            
            self.wfile.write(html_content.encode())
        else:
            self.send_response(404)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write(b'Not Found')
    
    def log_message(self, format, *args):
        global request_count
        request_count += 1
        print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Sample Service: {format % args}")

def signal_handler(signum, frame):
    print(f"\n[{time.strftime('%Y-%m-%d %H:%M:%S')}] Sample Service: Shutting down gracefully...")
    sys.exit(0)

def main():
    global start_time, request_count
    start_time = time.time()
    request_count = 0
    
    # Set up signal handlers for graceful shutdown
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    try:
        with socketserver.TCPServer((HOST, PORT), SampleHTTPServer) as httpd:
            print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Sample Service: Starting on {HOST}:{PORT}")
            print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Sample Service: Access at http://localhost:{PORT}")
            print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Sample Service: Press Ctrl+C to stop")
            
            # Allow reuse of the port
            httpd.allow_reuse_address = True
            
            # Start the server
            httpd.serve_forever()
            
    except OSError as e:
        if e.errno == 48:  # Address already in use
            print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Sample Service: Error - Port {PORT} is already in use")
            print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Sample Service: Please stop any other service using port {PORT}")
            sys.exit(1)
        else:
            print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Sample Service: Error starting server: {e}")
            sys.exit(1)
    except KeyboardInterrupt:
        print(f"\n[{time.strftime('%Y-%m-%d %H:%M:%S')}] Sample Service: Interrupted by user")
    except Exception as e:
        print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Sample Service: Unexpected error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
