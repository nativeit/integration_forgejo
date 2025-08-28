# Docker Development Environment for Nextcloud Forgejo Integration

This directory contains Docker configuration files for developing and building the Nextcloud Forgejo Integration app.

## Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Git (to clone the repository)

### Development Environment

1. **Start development environment:**
   ```bash
   # Linux/macOS
   ./scripts/dev.sh start
   
   # Windows
   scripts\dev.bat start
   ```

2. **Start with file watching (live reload):**
   ```bash
   # Linux/macOS
   ./scripts/dev.sh watch
   
   # Windows  
   scripts\dev.bat watch
   ```

3. **Access the application:**
   - Development server: http://localhost:3001

### Building the App

1. **Build production assets:**
   ```bash
   # Linux/macOS
   ./scripts/dev.sh build
   
   # Windows
   scripts\dev.bat build
   ```

2. **Full Docker build:**
   ```bash
   # Linux/macOS
   ./scripts/docker-build.sh --env dev
   
   # Windows
   scripts\docker-build.bat --env dev
   ```

## Available Commands

### Development Helper Script

| Command | Description |
|---------|-------------|
| `start` | Start development environment |
| `stop` | Stop development environment |
| `build` | Build app assets |
| `watch` | Start file watcher for live development |
| `logs` | Show container logs |
| `shell` | Open shell in development container |
| `clean` | Clean up Docker resources |
| `install` | Install npm dependencies |
| `lint` | Run linter |
| `lint:fix` | Run linter with auto-fix |

### Docker Build Script

| Option | Description |
|--------|-------------|
| `-e, --env ENV` | Environment (dev, prod) [default: dev] |
| `-c, --clean` | Clean build (remove containers and volumes) |
| `-b, --build-only` | Build only, don't run |
| `-h, --help` | Show help message |

## Docker Services

### Development Services (docker-compose.dev.yml)
- **app-dev**: Development container with live reload
- **build**: Build service for creating production assets

### Full Environment Services (docker-compose.yml)
- **nextcloud-forgejo-dev**: Development environment
- **nextcloud-forgejo-build**: Build environment
- **nextcloud-forgejo-prod**: Production environment
- **nextcloud-dev**: Optional Nextcloud development server
- **mysql**: MySQL database for Nextcloud

## File Structure

```
scripts/
├── docker-build.sh      # Main build script (Linux/macOS)
├── docker-build.bat     # Main build script (Windows)
├── dev.sh              # Development helper (Linux/macOS)
├── dev.bat             # Development helper (Windows)
├── Dockerfile          # Multi-stage Docker build
├── docker-compose.yml  # Full environment
├── docker-compose.dev.yml # Development only
└── .env.docker         # Environment variables
```

## Environment Variables

See `.env.docker` for configurable environment variables:
- `NODE_ENV`: Node.js environment (development/production)
- `DEV_SERVER_PORT`: Development server port
- `NEXTCLOUD_DEV_PORT`: Nextcloud development port
- Database configuration for local Nextcloud instance

## Troubleshooting

### Common Issues

1. **Port conflicts**: Change ports in `docker-compose.yml` if needed
2. **Permission issues**: Ensure Docker has proper permissions
3. **Build failures**: Run with `--clean` flag to start fresh

### Getting Help

1. **View logs:**
   ```bash
   ./scripts/dev.sh logs
   ```

2. **Access container shell:**
   ```bash
   ./scripts/dev.sh shell
   ```

3. **Clean up everything:**
   ```bash
   ./scripts/dev.sh clean
   ```

## Integration with Nextcloud

The full environment includes a Nextcloud development instance:
- Nextcloud: http://localhost:8081
- Admin credentials: admin/admin123 (configurable in .env.docker)
- The app is automatically mounted as a custom app

## Production Deployment

For production builds, use:
```bash
./scripts/docker-build.sh --env prod
```

This creates optimized builds without development dependencies.
