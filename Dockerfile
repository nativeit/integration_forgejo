# Multi-stage Dockerfile for Nextcloud Forgejo Integration App
# Stage 1: Build environment with Node.js and PHP
FROM node:16-alpine AS builder

LABEL maintainer="Nextcloud Forgejo Integration"
LABEL description="Build environment for Nextcloud Forgejo integration app"

# Install system dependencies
RUN apk add --no-cache \
    git \
    make \
    python3 \
    py3-pip \
    build-base \
    curl \
    php81 \
    php81-phar \
    php81-json \
    php81-curl \
    php81-openssl \
    php81-zip

# Create symlink for PHP
RUN ln -sf /usr/bin/php81 /usr/bin/php

# Set working directory
WORKDIR /app

# Copy package files first (for better Docker layer caching)
COPY package*.json ./

# Install npm dependencies
RUN npm ci --legacy-peer-deps

# Copy source code
COPY . .

# Install Composer (if needed)
RUN if [ -f "composer.json" ]; then \
        curl -sS https://getcomposer.org/installer | php && \
        mv composer.phar /usr/local/bin/composer && \
        chmod +x /usr/local/bin/composer && \
        composer install --prefer-dist --no-dev --optimize-autoloader; \
    fi

# Build the application
RUN npm run build

# Stage 2: Development environment
FROM node:16-alpine AS development

# Install system dependencies for development
RUN apk add --no-cache \
    git \
    make \
    python3 \
    py3-pip \
    build-base \
    curl \
    php81 \
    php81-phar \
    php81-json \
    php81-curl \
    php81-openssl \
    php81-zip \
    bash

# Create symlink for PHP
RUN ln -sf /usr/bin/php81 /usr/bin/php

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev dependencies)
RUN npm install --legacy-peer-deps

# Install Composer dependencies if composer.json exists
COPY composer.json* ./
RUN if [ -f "composer.json" ]; then composer install --prefer-dist; fi

# Copy source code
COPY . .

# Expose port for development server (if needed)
EXPOSE 3000

# Default command for development
CMD ["npm", "run", "watch"]

# Stage 3: Production build (lightweight)
FROM alpine:latest AS production

# Install minimal dependencies
RUN apk add --no-cache \
    php81 \
    php81-json \
    php81-curl \
    php81-openssl

# Create symlink for PHP
RUN ln -sf /usr/bin/php81 /usr/bin/php

# Create app directory
WORKDIR /app

# Copy only the built application from builder stage
COPY --from=builder /app .

# Remove development files
RUN rm -rf \
    node_modules \
    src \
    package*.json \
    webpack.config.js \
    .eslintrc.js \
    stylelint.config.js \
    composer.json \
    composer.lock

# Set proper permissions
RUN chmod -R 644 . && \
    find . -type d -exec chmod 755 {} \;

# Default command
CMD ["php", "-S", "0.0.0.0:8000"]
