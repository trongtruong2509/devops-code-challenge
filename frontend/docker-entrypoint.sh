#!/bin/sh
set -e

# Debug information
echo "Starting docker-entrypoint.sh"
echo "BACKEND_URL=$BACKEND_URL"

RUNTIME_BACKEND_URL=${BACKEND_URL:-http://localhost:8080/}

# Create a runtime config with the frontend-relative API path
echo "window.API_URL = '/api/';" > /app/build/config.js
echo "Runtime configuration created using API proxy path: /api/"
echo "Actual backend URL that will be used by proxy: $RUNTIME_BACKEND_URL"

# Start the server with our proxy that will handle API requests
exec node proxy-server.js