@echo off
REM Build script for Docker environment on Windows
setlocal enabledelayedexpansion

echo 🚀 Building Nextcloud Forgejo Integration App...

REM Default values
set ENV=dev
set CLEAN=false
set BUILD_ONLY=false

REM Parse command line arguments
:parse
if "%~1"=="" goto :start
if "%~1"=="-e" (
    set ENV=%~2
    shift
    shift
    goto :parse
)
if "%~1"=="--env" (
    set ENV=%~2
    shift
    shift
    goto :parse
)
if "%~1"=="-c" (
    set CLEAN=true
    shift
    goto :parse
)
if "%~1"=="--clean" (
    set CLEAN=true
    shift
    goto :parse
)
if "%~1"=="-b" (
    set BUILD_ONLY=true
    shift
    goto :parse
)
if "%~1"=="--build-only" (
    set BUILD_ONLY=true
    shift
    goto :parse
)
if "%~1"=="-h" goto :usage
if "%~1"=="--help" goto :usage
echo Unknown option %~1
goto :usage

:usage
echo Usage: %0 [OPTIONS]
echo Options:
echo   -e, --env ENV        Environment (dev, prod) [default: dev]
echo   -c, --clean         Clean build (remove containers and volumes)
echo   -b, --build-only    Build only, don't run
echo   -h, --help          Show this help message
exit /b 1

:start

REM Clean up if requested
if "%CLEAN%"=="true" (
    echo 🧹 Cleaning up existing containers and volumes...
    docker-compose down -v --remove-orphans
    docker system prune -f
)

REM Choose the right docker-compose file
if "%ENV%"=="dev" (
    set COMPOSE_FILE=docker-compose.dev.yml
    echo 🔧 Building development environment...
) else (
    set COMPOSE_FILE=docker-compose.yml
    echo 📦 Building production environment...
)

REM Build the Docker images
echo 🔨 Building Docker images...
docker-compose -f %COMPOSE_FILE% build --no-cache

if "%BUILD_ONLY%"=="false" (
    REM Start the services
    if "%ENV%"=="dev" (
        echo 🚀 Starting development environment...
        echo    - App development server will be available at: http://localhost:3001
        echo    - File watching enabled for live reload
        docker-compose -f %COMPOSE_FILE% up
    ) else (
        echo 🚀 Starting production environment...
        echo    - Nextcloud will be available at: http://localhost:8081
        echo    - App server available at: http://localhost:8000
        docker-compose -f %COMPOSE_FILE% up -d
        echo ✅ Services started in background
    )
) else (
    echo ✅ Build complete. Use 'docker-compose -f %COMPOSE_FILE% up' to start services.
)

endlocal
