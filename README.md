# RocRail Docker Server

A production-ready Docker container for running RocRail as a headless server, supporting both x86_64 and ARM64 architectures.

## Quick Start

### Using Docker Hub

```bash
# Pull and run the latest image
docker run -d \
  --name rocrail-server \
  -p 4303:4303 \
  -p 8051:8051 \
  -p 8088:8088 \
  -v rocrail_data:/rocrail \
  docker.io/boostvolt/rocrail:latest
```

### Using Docker Compose

1. **Clone and configure**:

```bash
git clone <repository-url>
cd rocrail-docker
cp env.example .env
```

2. **Deploy**:

```bash
# For x86_64 systems (default)
docker-compose up -d

# For ARM64 systems, edit .env first:
# PLATFORM=linux/arm64
docker-compose up -d
```

3. **Access**:
   - Web interface: `http://your-server-ip:8088`
   - RocRail server: `your-server-ip:8051`

## Configuration

### Environment Variables

Edit the `.env` file:

```bash
# RocRail version
ROCRAIL_VERSION=5854

# Timezone
TZ=Europe/Berlin

# Architecture (linux/amd64 or linux/arm64)
PLATFORM=linux/amd64

# Ports (optional)
SRCP_PORT=4303
ROCRAIL_PORT=8051
ROCWEB_PORT=8088
SNMP_PORT=161

# Resource limits (optional)
DOCKER_MEMORY_LIMIT=1G
DOCKER_CPU_LIMIT=1.0
```

## Ports

| Port | Protocol | Service | Description            |
| ---- | -------- | ------- | ---------------------- |
| 4303 | TCP      | SRCP    | Train control protocol |
| 8051 | TCP/UDP  | RocRail | Main server            |
| 8088 | TCP      | RocWeb  | Web interface          |
| 161  | TCP/UDP  | SNMP    | Network monitoring     |

## Management

### Docker Compose Commands

```bash
docker-compose up -d          # Start
docker-compose down           # Stop
docker-compose logs -f        # View logs
docker-compose ps             # Show status
docker-compose restart        # Restart
```

## Docker Hub Images

### Available Tags

- `latest` - Latest stable version
- `5854` - Specific version
- `5854-linux/amd64` - x86_64 architecture
- `5854-linux/arm64` - ARM64 architecture

### Pull Commands

```bash
# Latest version
docker pull docker.io/boostvolt/rocrail:latest

# Specific version
docker pull docker.io/boostvolt/rocrail:5854

# Architecture specific
docker pull docker.io/boostvolt/rocrail:5854-linux/arm64  # ARM64
docker pull docker.io/boostvolt/rocrail:5854-linux/amd64  # x86_64
```

## Client Configuration

### RocView Desktop Client

1. Download RocView for your platform
2. Configure connection:
   - Server: Your server IP address
   - Port: 8051
   - Protocol: TCP

### Mobile Apps

- **RocView Mobile**: Available on iOS and Android
- **RocWeb**: Access via browser at `http://your-server-ip:8088`

### Third-party Clients

Any SRCP-compatible client can connect to port 4303.

## Troubleshooting

### Common Issues

1. **Container won't start**:

   ```bash
   docker-compose logs rocrail
   ```

2. **Can't connect from clients**:

   - Check if ports are exposed: `docker-compose ps`
   - Verify firewall settings
   - Test connectivity: `telnet your-server-ip 8051`

3. **High memory usage**:
   - Adjust memory limits in `.env`
   - Check for memory leaks in logs

### Log Locations

- Container logs: `docker-compose logs rocrail`
- Application logs: `/rocrail/logs/` (inside container)

## Support

- **Documentation**: [RocRail Wiki](https://wiki.rocrail.net)
- **Community**: [RocRail Forum](https://forum.rocrail.net)
- **Issues**: Create an issue in this repository
- **Docker Hub**: [boostvolt/rocrail](https://hub.docker.com/r/boostvolt/rocrail)

## License

This project is licensed under the same license as RocRail itself.
