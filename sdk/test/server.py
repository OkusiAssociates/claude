#!/usr/bin/env python3
"""
Simple Python Web Server
"""
from http.server import HTTPServer, SimpleHTTPRequestHandler
import sys

def run_server(port=8000):
    """Start the web server on the specified port."""
    server_address = ('', port)
    httpd = HTTPServer(server_address, SimpleHTTPRequestHandler)

    print(f"Server running on http://localhost:{port}")
    print("Press Ctrl+C to stop the server")

    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nServer stopped.")
        sys.exit(0)

if __name__ == "__main__":
    port = 8000
    if len(sys.argv) > 1:
        try:
            port = int(sys.argv[1])
        except ValueError:
            print("Invalid port number. Using default port 8000.")

    run_server(port)
