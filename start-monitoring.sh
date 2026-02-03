#!/bin/bash
# Quick start script for CarryConnect monitoring stack

set -e

echo "==============================================="
echo "CarryConnect Monitoring Stack - Quick Start"
echo "==============================================="
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker first."
    exit 1
fi

# Check if ports are available
echo "Checking if required ports are available..."
for port in 3000 3306 8081 9090; do
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        echo "Warning: Port $port is already in use. Please free the port before continuing."
        echo "You can find the process using: lsof -i :$port"
        exit 1
    fi
done

echo "All required ports are available."
echo ""

# Start the stack
echo "Starting the monitoring stack..."
echo "This may take a few minutes on first run..."
docker compose up -d

echo ""
echo "Waiting for services to be healthy..."
echo "This usually takes 30-60 seconds..."

# Wait for services
MAX_ATTEMPTS=30
ATTEMPT=0
while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    ATTEMPT=$((ATTEMPT+1))
    
    # Check if API is healthy
    if curl -sf http://localhost:8081/actuator/health > /dev/null 2>&1; then
        echo ""
        echo "✓ All services are up and running!"
        echo ""
        echo "==============================================="
        echo "Access the services:"
        echo "==============================================="
        echo "• Application API:    http://localhost:8081"
        echo "• Health Check:       http://localhost:8081/actuator/health"
        echo "• Metrics Endpoint:   http://localhost:8081/actuator/prometheus"
        echo "• Prometheus:         http://localhost:9090"
        echo "• Grafana:            http://localhost:3000"
        echo "  - Username: admin"
        echo "  - Password: admin"
        echo ""
        echo "Dashboard: Navigate to Dashboards → CarryConnect API Monitoring Dashboard"
        echo ""
        echo "To stop all services, run: docker compose down"
        echo "To view logs, run: docker compose logs -f"
        echo "==============================================="
        exit 0
    fi
    
    echo -n "."
    sleep 2
done

echo ""
echo "Warning: Services took longer than expected to start."
echo "Check the logs with: docker compose logs"
echo ""
echo "You can still try accessing the services at:"
echo "• Grafana: http://localhost:3000 (admin/admin)"
echo "• Prometheus: http://localhost:9090"
echo "• Application: http://localhost:8081/actuator/health"
