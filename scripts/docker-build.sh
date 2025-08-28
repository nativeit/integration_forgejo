#!/bin/bash

# Build script for Docker environment
set -e

echo "🚀 Building Nextcloud Forgejo Integration App..."

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -e, --env ENV        Environment (dev, prod) [default: dev]"
    echo "  -c, --clean         Clean build (remove containers and volumes)"
    echo "  -b, --build-only    Build only, don't run"
    echo "  -h, --help          Show this help message"
    exit 1
}

# Default values
ENV="dev"
CLEAN=false
BUILD_ONLY=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--env)
            ENV="$2"
            shift 2
            ;;
        -c|--clean)
            CLEAN=true
            shift
            ;;
        -b|--build-only)
            BUILD_ONLY=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option $1"
            usage
            ;;
    esac
done

# Clean up if requested
if [ "$CLEAN" = true ]; then
    echo "🧹 Cleaning up existing containers and volumes..."
    docker-compose down -v --remove-orphans
    docker system prune -f
fi

# Choose the right docker-compose file
if [ "$ENV" = "dev" ]; then
    COMPOSE_FILE="docker-compose.dev.yml"
    echo "🔧 Building development environment..."
else
    COMPOSE_FILE="docker-compose.yml"
    echo "📦 Building production environment..."
fi

# Build the Docker images
echo "🔨 Building Docker images..."
docker-compose -f $COMPOSE_FILE build --no-cache

if [ "$BUILD_ONLY" = false ]; then
    # Start the services
    if [ "$ENV" = "dev" ]; then
        echo "🚀 Starting development environment..."
        echo "   - App development server will be available at: http://localhost:3001"
        echo "   - File watching enabled for live reload"
        docker-compose -f $COMPOSE_FILE up
    else
        echo "🚀 Starting production environment..."
        echo "   - Nextcloud will be available at: http://localhost:8081"
        echo "   - App server available at: http://localhost:8000"
        docker-compose -f $COMPOSE_FILE up -d
        echo "✅ Services started in background"
    fi
else
    echo "✅ Build complete. Use 'docker-compose -f $COMPOSE_FILE up' to start services."
fi
