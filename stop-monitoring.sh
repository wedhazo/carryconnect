#!/bin/bash
# Stop script for CarryConnect monitoring stack

echo "==============================================="
echo "Stopping CarryConnect Monitoring Stack"
echo "==============================================="
echo ""

# Stop all services
echo "Stopping all services..."
docker compose down

echo ""
echo "✓ All services have been stopped."
echo ""
echo "To remove all data volumes as well, run:"
echo "  docker compose down -v"
echo ""
echo "To start the services again, run:"
echo "  ./start-monitoring.sh"
echo "  or"
echo "  docker compose up -d"
echo "==============================================="
