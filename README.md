# CarryConnect API - Monitoring Setup

A Spring Boot application with integrated Prometheus and Grafana monitoring for effective performance tracking and debugging.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Architecture](#architecture)
- [Monitoring Stack](#monitoring-stack)
- [Available Metrics](#available-metrics)
- [Accessing the Services](#accessing-the-services)
- [Dashboard Usage](#dashboard-usage)
- [Development](#development)
- [Troubleshooting](#troubleshooting)

## Overview

CarryConnect API is a travel and package delivery coordination platform built with Spring Boot. This repository includes a complete monitoring stack using Prometheus for metrics collection and Grafana for visualization.

## Prerequisites

Before you begin, ensure you have the following installed:

- Docker (20.10 or higher)
- Docker Compose (2.0 or higher)
- Java 17 (for local development)
- Maven 3.9+ (for local development)

## Quick Start

### Using Docker Compose (Recommended)

#### Option 1: Using the Quick Start Script

The easiest way to get started:

```bash
./start-monitoring.sh
```

This script will:
- Check if Docker is running
- Verify required ports are available
- Start all services with docker compose
- Wait for services to be healthy
- Display access URLs and credentials

**Note:** For production use, copy `.env.example` to `.env` and update with secure credentials:

```bash
cp .env.example .env
# Edit .env with your secure passwords
./start-monitoring.sh
```

To stop all services:

```bash
./stop-monitoring.sh
```

#### Option 2: Manual Docker Compose

1. **Clone the repository:**
   ```bash
   git clone https://github.com/wedhazo/carryconnect.git
   cd carryconnect
   ```

2. **Start all services:**
   ```bash
   docker compose up -d
   ```

   This will start:
   - MySQL database (port 3306)
   - CarryConnect API (port 8081)
   - Prometheus (port 9090)
   - Grafana (port 3000)

3. **Wait for services to be ready:**
   ```bash
   docker compose ps
   ```

   All services should show "healthy" status.

4. **Access the services:**
   - **Application API**: http://localhost:8081
   - **Prometheus**: http://localhost:9090
   - **Grafana**: http://localhost:3000 (admin/admin)
   - **Metrics Endpoint**: http://localhost:8081/actuator/prometheus
   - **Health Check**: http://localhost:8081/actuator/health

### Local Development (Without Docker)

1. **Start MySQL database:**
   ```bash
   # Using Docker
   docker run -d --name mysql \
     -e MYSQL_ROOT_PASSWORD=your_secure_password \
     -e MYSQL_DATABASE=carryconnect \
     -p 3306:3306 \
     mysql:8.0
   ```

2. **Build and run the application:**
   ```bash
   # Set database password
   export SPRING_DATASOURCE_PASSWORD=your_secure_password
   
   ./mvnw clean package
   ./mvnw spring-boot:run
   ```

3. **Access the metrics endpoint:**
   ```bash
   curl http://localhost:8081/actuator/prometheus
   ```

## Architecture

```
┌─────────────────┐
│ CarryConnect    │
│ API (8081)      │──┐
└─────────────────┘  │
                     │ Scrapes metrics every 15s
                     ▼
              ┌─────────────────┐
              │  Prometheus     │
              │  (9090)         │
              └─────────────────┘
                     │
                     │ Data source
                     ▼
              ┌─────────────────┐
              │   Grafana       │
              │   (3000)        │
              └─────────────────┘
```

## Monitoring Stack

### Prometheus Configuration

Prometheus is configured to scrape metrics from the CarryConnect API every 15 seconds. The configuration is in `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: 'carryconnect-api'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['carryconnect-api:8081']
```

### Grafana Dashboards

The application comes with a pre-configured dashboard that includes:

1. **HTTP Request Response Time**: Average response time per endpoint
2. **HTTP Request Rate**: Number of requests per second by status code
3. **Application Error Rate**: 5xx error rate gauge
4. **JVM Heap Memory Usage**: Real-time memory consumption
5. **CPU Usage**: Application CPU utilization

## Available Metrics

The application exposes the following metric categories through the `/actuator/prometheus` endpoint:

### Application Metrics
- `http_server_requests_seconds_count`: Total HTTP requests
- `http_server_requests_seconds_sum`: Total time spent processing requests
- `http_server_requests_seconds_max`: Maximum request processing time

### JVM Metrics
- `jvm_memory_used_bytes`: JVM memory usage by area (heap/non-heap)
- `jvm_memory_max_bytes`: Maximum JVM memory
- `jvm_gc_pause_seconds_count`: Garbage collection pause count
- `jvm_threads_live_threads`: Number of live threads

### System Metrics
- `process_cpu_usage`: Process CPU usage
- `system_cpu_usage`: System CPU usage
- `process_uptime_seconds`: Application uptime

### Custom Business Metrics (Extensible)

You can add custom metrics by creating a configuration class. Example:

```java
@Configuration
public class MetricsConfig {
    @Bean
    public MeterRegistryCustomizer<MeterRegistry> metricsCommonTags() {
        return registry -> registry.config().commonTags("application", "CarryConnect API");
    }
}
```

## Accessing the Services

### CarryConnect API

- **Base URL**: http://localhost:8081
- **Health Check**: http://localhost:8081/actuator/health
- **Metrics**: http://localhost:8081/actuator/prometheus
- **All Actuator Endpoints**: http://localhost:8081/actuator

### Prometheus

- **URL**: http://localhost:9090
- **Targets Status**: http://localhost:9090/targets
- **Query Interface**: Use the expression browser to run PromQL queries

Example queries:
```promql
# Average response time
rate(http_server_requests_seconds_sum[5m]) / rate(http_server_requests_seconds_count[5m])

# Request rate
rate(http_server_requests_seconds_count[5m])

# Error rate
sum(rate(http_server_requests_seconds_count{status=~"5.."}[5m]))
```

### Grafana

- **URL**: http://localhost:3000
- **Default Credentials**: 
  - Username: `admin`
  - Password: `admin` (you'll be prompted to change on first login)

#### Accessing the Dashboard

1. Login to Grafana
2. Navigate to **Dashboards** → **Browse**
3. Open **"CarryConnect API Monitoring Dashboard"**
4. The dashboard will auto-refresh every 5 seconds

## Dashboard Usage

### Understanding the Panels

1. **HTTP Request Response Time (ms)**
   - Shows average response time per endpoint
   - Lower is better; spikes indicate performance issues
   - Use to identify slow endpoints

2. **HTTP Request Rate**
   - Displays requests per second by status code and endpoint
   - Monitor traffic patterns and endpoint usage
   - Identify popular or problematic endpoints

3. **Application Error Rate (5xx)**
   - Real-time gauge showing server error rate
   - Green = healthy, Red = errors present
   - Should stay at or near 0

4. **JVM Heap Memory Usage**
   - Current heap memory consumption
   - Watch for steady growth (potential memory leak)
   - Compare against max heap size

5. **CPU Usage**
   - Application CPU utilization
   - Sustained high usage may indicate performance issues
   - Correlate with request rate for capacity planning

### Customizing Dashboards

You can modify the dashboard by:
1. Clicking the gear icon (⚙️) in the top right
2. Adjusting time ranges using the time picker
3. Adding new panels with the "Add panel" button
4. Editing panel queries by clicking the panel title → Edit

## Development

### Building the Application

```bash
# Clean and package
./mvnw clean package

# Run tests
./mvnw test

# Run locally
./mvnw spring-boot:run
```

### Adding Custom Metrics

To add custom application metrics, inject `MeterRegistry` into your service:

```java
@Service
public class TripService {
    private final Counter tripSearchCounter;
    
    public TripService(TripRepository repository, MeterRegistry registry) {
        this.tripRepository = repository;
        this.tripSearchCounter = registry.counter("trips.search.count");
    }
    
    public List<Trip> searchTrips(String from, String to) {
        tripSearchCounter.increment();
        return tripRepository.findByOriginCityAndDestinationCity(from, to);
    }
}
```

### Docker Compose Commands

```bash
# Start all services
docker compose up -d

# Stop all services
docker compose down

# View logs
docker compose logs -f [service-name]

# Restart a specific service
docker compose restart [service-name]

# Rebuild and restart
docker compose up -d --build

# Remove all containers and volumes
docker compose down -v
```

## Troubleshooting

### Services Not Starting

**Problem**: Services fail to start or show unhealthy status

**Solutions**:
1. Check logs: `docker compose logs [service-name]`
2. Ensure ports are not already in use: `netstat -tuln | grep -E '3000|8081|9090|3306'`
3. Verify Docker has enough resources (at least 4GB RAM recommended)

### No Metrics Showing in Grafana

**Problem**: Dashboard panels show "No Data"

**Solutions**:
1. Verify API is running: `curl http://localhost:8081/actuator/health`
2. Check Prometheus targets: http://localhost:9090/targets
3. Ensure Prometheus is scraping: Look for "carryconnect-api" target in UP state
4. Verify datasource in Grafana: Configuration → Data Sources → Prometheus

### Cannot Access Services

**Problem**: Cannot reach services at expected URLs

**Solutions**:
1. Check if containers are running: `docker compose ps`
2. Verify port mappings: `docker compose port [service-name] [port]`
3. Check firewall rules if running on a remote server
4. For Windows/Mac, ensure Docker Desktop is running

### Database Connection Issues

**Problem**: Application fails to connect to MySQL

**Solutions**:
1. Wait for MySQL to fully initialize (check logs: `docker compose logs mysql`)
2. Verify database credentials in docker-compose.yml match application.properties
3. Ensure MySQL container is healthy: `docker compose ps mysql`

### High Memory Usage

**Problem**: Application consuming excessive memory

**Solutions**:
1. Monitor JVM heap in Grafana dashboard
2. Adjust JVM settings in Dockerfile:
   ```dockerfile
   ENTRYPOINT ["java", "-Xmx512m", "-Xms256m", "-jar", "app.jar"]
   ```
3. Check for memory leaks using VisualVM or similar tools

## Configuration Reference

### Environment Variables

The monitoring stack can be configured using environment variables. Copy `.env.example` to `.env` and customize:

```bash
cp .env.example .env
```

Available environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `MYSQL_ROOT_PASSWORD` | `Home2022` | MySQL root password (change in production) |
| `MYSQL_DATABASE` | `carryconnect` | MySQL database name |
| `MYSQL_USER` | `root` | MySQL username |
| `GRAFANA_ADMIN_USER` | `admin` | Grafana admin username |
| `GRAFANA_ADMIN_PASSWORD` | `admin` | Grafana admin password (change in production) |

**Security Best Practices:**
- Never commit `.env` files to version control
- Use strong, unique passwords for production
- Consider using Docker secrets for sensitive data
- Rotate credentials regularly
- Limit network exposure of services in production

### Application Properties

Key configuration options in `src/main/resources/application.properties`:

```properties
# Server port
server.port=8081

# Actuator endpoints
management.endpoints.web.exposure.include=health,info,prometheus,metrics
management.endpoint.prometheus.enabled=true
management.metrics.export.prometheus.enabled=true

# Database (use environment variables for credentials)
spring.datasource.url=jdbc:mysql://localhost:3306/carryconnect
spring.datasource.username=root
spring.datasource.password=${SPRING_DATASOURCE_PASSWORD:Home2022}
```

### Environment Variables

Override configuration using environment variables in docker-compose.yml:

```yaml
environment:
  - SPRING_DATASOURCE_URL=jdbc:mysql://mysql:3306/carryconnect
  - SPRING_DATASOURCE_USERNAME=root
  - SPRING_DATASOURCE_PASSWORD=${MYSQL_ROOT_PASSWORD:-Home2022}
  - MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE=health,prometheus
```

Or use a `.env` file for better security (see `.env.example`).

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
- Create an issue in the GitHub repository
- Check existing issues for solutions
- Review the troubleshooting section above

---

**Note**: This setup is configured for development environments. For production use, ensure you:
- Change default passwords using `.env` file
- Configure proper authentication for Grafana
- Set up persistent storage for Prometheus data
- Implement proper security measures (TLS, network policies, etc.)
- Use environment-specific configuration
- Consider using Docker secrets or a secrets manager
- Enable authentication for Prometheus if exposed publicly
- Configure firewall rules appropriately
