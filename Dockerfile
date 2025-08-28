# Multi-stage Dockerfile for Nextcloud Forgejo Integration App
# Stage 1: Build environment with Node.js
FROM node:20-alpine AS builder

LABEL maintainer="Nextcloud Forgejo Integration"
LABEL description="Build environment for Nextcloud Forgejo integration app"

# Install system dependencies needed for building
RUN apk add --no-cache \
    git \
    make \
    python3 \
    py3-pip \
    build-base \
    curl \
    rsync

# Set working directory
WORKDIR /app

# Copy package files and makefile first (for better Docker layer caching)
COPY package*.json ./
COPY makefile ./

# Install npm dependencies (npm ci)
RUN npm ci --legacy-peer-deps

# Copy source code
COPY . .

# Build the application using makefile
RUN make build

# Stage 2: Development environment
FROM node:20-alpine AS development

# Install system dependencies for development
RUN apk add --no-cache \
    git \
    make \
    python3 \
    py3-pip \
    build-base \
    curl \
    rsync \
    bash

# Set working directory
WORKDIR /app

# Copy package files and makefile
COPY package*.json ./
COPY makefile ./

# Install all dependencies (development mode)
RUN npm install --legacy-peer-deps

# Copy source code
COPY . .

# Expose port for development server (if needed)
EXPOSE 3000

# Default command for development - use makefile's dev target for watch mode
CMD ["make", "npm-dev"]

# Stage 3: Production build (lightweight)
FROM alpine:latest AS production

# Install minimal web server if needed
RUN apk add --no-cache \
    nginx

# Create app directory
WORKDIR /app

# Copy only the built application from builder stage
COPY --from=builder /app/js ./js
COPY --from=builder /app/css ./css
COPY --from=builder /app/img ./img
COPY --from=builder /app/lib ./lib
COPY --from=builder /app/templates ./templates
COPY --from=builder /app/appinfo ./appinfo
COPY --from=builder /app/l10n ./l10n

# Set proper permissions
RUN chmod -R 644 . && \
    find . -type d -exec chmod 755 {} \;

# Default command
CMD ["nginx", "-g", "daemon off;"]
