#!/bin/bash

# Development helper script for Docker environment
set -e

echo "🔧 Nextcloud Forgejo Integration - Development Helper"

case "$1" in
    "start")
        echo "Starting development environment..."
        docker-compose -f docker-compose.dev.yml up -d
        echo "✅ Development environment started"
        echo "   - App dev server: http://localhost:3001"
        ;;
    "stop")
        echo "Stopping development environment..."
        docker-compose -f docker-compose.dev.yml down
        echo "✅ Development environment stopped"
        ;;
    "build")
        echo "Building app assets..."
        docker-compose -f docker-compose.dev.yml run --rm build
        echo "✅ Build complete"
        ;;
    "watch")
        echo "Starting file watcher for development..."
        docker-compose -f docker-compose.dev.yml up app-dev
        ;;
    "logs")
        echo "Showing logs..."
        docker-compose -f docker-compose.dev.yml logs -f
        ;;
    "shell")
        echo "Opening shell in development container..."
        docker-compose -f docker-compose.dev.yml exec app-dev sh
        ;;
    "clean")
        echo "Cleaning up Docker resources..."
        docker-compose -f docker-compose.dev.yml down -v
        docker system prune -f
        echo "✅ Cleanup complete"
        ;;
    "install")
        echo "Installing dependencies..."
        docker-compose -f docker-compose.dev.yml run --rm app-dev npm install --legacy-peer-deps
        echo "✅ Dependencies installed"
        ;;
    "lint")
        echo "Running linter..."
        docker-compose -f docker-compose.dev.yml run --rm app-dev npm run lint
        ;;
    "lint:fix")
        echo "Running linter with auto-fix..."
        docker-compose -f docker-compose.dev.yml run --rm app-dev npm run lint:fix
        ;;
    *)
        echo "Usage: $0 {start|stop|build|watch|logs|shell|clean|install|lint|lint:fix}"
        echo ""
        echo "Commands:"
        echo "  start       Start development environment"
        echo "  stop        Stop development environment"
        echo "  build       Build app assets"
        echo "  watch       Start file watcher for live development"
        echo "  logs        Show container logs"
        echo "  shell       Open shell in development container"
        echo "  clean       Clean up Docker resources"
        echo "  install     Install npm dependencies"
        echo "  lint        Run linter"
        echo "  lint:fix    Run linter with auto-fix"
        exit 1
        ;;
esac
