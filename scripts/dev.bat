@echo off
REM Development helper script for Docker environment on Windows
setlocal

echo 🔧 Nextcloud Forgejo Integration - Development Helper

if "%1"=="start" (
    echo Starting development environment...
    docker-compose -f docker-compose.dev.yml up -d
    echo ✅ Development environment started
    echo    - App dev server: http://localhost:3001
    goto :end
)

if "%1"=="stop" (
    echo Stopping development environment...
    docker-compose -f docker-compose.dev.yml down
    echo ✅ Development environment stopped
    goto :end
)

if "%1"=="build" (
    echo Building app assets...
    docker-compose -f docker-compose.dev.yml run --rm build
    echo ✅ Build complete
    goto :end
)

if "%1"=="watch" (
    echo Starting file watcher for development...
    docker-compose -f docker-compose.dev.yml up app-dev
    goto :end
)

if "%1"=="logs" (
    echo Showing logs...
    docker-compose -f docker-compose.dev.yml logs -f
    goto :end
)

if "%1"=="shell" (
    echo Opening shell in development container...
    docker-compose -f docker-compose.dev.yml exec app-dev sh
    goto :end
)

if "%1"=="clean" (
    echo Cleaning up Docker resources...
    docker-compose -f docker-compose.dev.yml down -v
    docker system prune -f
    echo ✅ Cleanup complete
    goto :end
)

if "%1"=="install" (
    echo Installing dependencies...
    docker-compose -f docker-compose.dev.yml run --rm app-dev npm install --legacy-peer-deps
    echo ✅ Dependencies installed
    goto :end
)

if "%1"=="lint" (
    echo Running linter...
    docker-compose -f docker-compose.dev.yml run --rm app-dev npm run lint
    goto :end
)

if "%1"=="lint:fix" (
    echo Running linter with auto-fix...
    docker-compose -f docker-compose.dev.yml run --rm app-dev npm run lint:fix
    goto :end
)

REM Default case - show usage
echo Usage: %0 {start^|stop^|build^|watch^|logs^|shell^|clean^|install^|lint^|lint:fix}
echo.
echo Commands:
echo   start       Start development environment
echo   stop        Stop development environment
echo   build       Build app assets
echo   watch       Start file watcher for live development
echo   logs        Show container logs
echo   shell       Open shell in development container
echo   clean       Clean up Docker resources
echo   install     Install npm dependencies
echo   lint        Run linter
echo   lint:fix    Run linter with auto-fix

:end
endlocal
