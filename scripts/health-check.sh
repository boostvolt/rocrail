#!/bin/bash
set -euo pipefail

# Health check script for RocRail Docker container
# Checks if RocRail and RocWeb services are running and responding

# Configuration
ROCRAIL_PORT=${ROCRAIL_PORT:-8051}
ROCWEB_PORT=${ROCWEB_PORT:-8088}
HEALTH_TIMEOUT=${HEALTH_TIMEOUT:-10}

# Function to check if a port is listening
check_port() {
    local port=$1
    local service=$2
    
    if timeout "${HEALTH_TIMEOUT}" bash -c "</dev/tcp/localhost/${port}" 2>/dev/null; then
        echo "✓ ${service} is listening on port ${port}"
        return 0
    else
        echo "✗ ${service} is not responding on port ${port}"
        return 1
    fi
}

# Function to check HTTP endpoint
check_http() {
    local url=$1
    local service=$2
    
    if curl -f -s --max-time "${HEALTH_TIMEOUT}" "${url}" >/dev/null 2>&1; then
        echo "✓ ${service} HTTP endpoint is responding"
        return 0
    else
        echo "✗ ${service} HTTP endpoint is not responding"
        return 1
    fi
}

# Function to check if process is running
check_process() {
    local process=$1
    local service=$2
    
    if pgrep -f "${process}" >/dev/null; then
        echo "✓ ${service} process is running"
        return 0
    else
        echo "✗ ${service} process is not running"
        return 1
    fi
}

# Main health check
echo "Starting RocRail health check..."

# Check if processes are running
rocrail_running=false
rocweb_running=false

if check_process "rocrail" "RocRail"; then
    rocrail_running=true
fi

if check_process "rocweb" "RocWeb"; then
    rocweb_running=true
fi

# Check if ports are listening
rocrail_port_ok=false
rocweb_port_ok=false

if check_port "${ROCRAIL_PORT}" "RocRail"; then
    rocrail_port_ok=true
fi

if check_port "${ROCWEB_PORT}" "RocWeb"; then
    rocweb_port_ok=true
fi

# Check HTTP endpoints
rocweb_http_ok=false
if check_http "http://localhost:${ROCWEB_PORT}/" "RocWeb"; then
    rocweb_http_ok=true
fi

# Determine overall health
if [[ "${rocrail_running}" == "true" && "${rocrail_port_ok}" == "true" ]]; then
    echo "✓ RocRail service is healthy"
    exit 0
else
    echo "✗ RocRail service is unhealthy"
    exit 1
fi 