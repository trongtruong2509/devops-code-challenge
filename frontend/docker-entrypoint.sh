#!/bin/sh
set -e

# Debug information
echo "Starting docker-entrypoint.sh"
echo "BACKEND_URL=$BACKEND_URL"

RUNTIME_BACKEND_URL=${BACKEND_URL:-http://localhost:8080/}

# Create a runtime config with the correct backend URL
echo "window.API_URL = '${RUNTIME_BACKEND_URL}';" > /app/build/config.js
echo "Runtime configuration created with BACKEND_URL=$RUNTIME_BACKEND_URL"

# Start the server
exec npx serve -s build -l 3000