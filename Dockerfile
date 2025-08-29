# Multi-stage Dockerfile for Nextcloud Forgejo Integration App
# Stage 1: Build environment with Node.js
FROM composer:2.8.11 AS builder
ARG NODE_VERSION="16.20.2"
ENV NVM_VERSION="v0.40.3"
ENV NVM_DIR=/root/.nvm

LABEL maintainer="Nextcloud Forgejo Integration"
LABEL description="Build environment for Nextcloud Forgejo integration app"

# Install system dependencies needed for building
RUN set -eux ; \
  apk add --no-cache --virtual .composer-rundeps \
    7zip \
    bash \
    build-base \
    coreutils \
    curl \
    git \
    make \
    mercurial \
    openssh-client \
    patch \
    python3 \
    py3-pip \
    rsync \
    subversion \
    tini \
    unzip \
    zip

# Use bash for the shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Create a script file sourced by both interactive and non-interactive bash shells
ENV BASH_ENV /home/user/.bash_env
RUN touch "${BASH_ENV}"
RUN echo '. "${BASH_ENV}"' >> ~/.bashrc

# Download and install nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | PROFILE="${BASH_ENV}" bash
RUN echo node > .nvmrc
RUN nvm install ${NODE_VERSION:-'--lts=gallium'}
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"

# Set working directory
WORKDIR /app

# Copy package files first (for better Docker layer caching)
COPY package*.json ./

# Install npm dependencies with legacy peer deps to handle version conflicts
RUN npm install --deps
RUN npm install --legacy-peer-deps

# Copy build configuration files
COPY webpack.config.js ./
COPY .eslintrc.js ./
COPY stylelint.config.js ./
COPY makefile ./
COPY docker.makefile ./

# Copy source code and other necessary files
COPY src/ ./src/
COPY css/ ./css/
COPY img/ ./img/
COPY lib/ ./lib/
COPY templates/ ./templates/
COPY appinfo/ ./appinfo/
COPY l10n/ ./l10n/

# Build the application
RUN npm run build

# Stage 2: Development environment
FROM composer:2.8.11 AS development
ARG NODE_VERSION="16.20.2"
ENV NVM_VERSION="v0.40.3"
ENV NVM_DIR=/root/.nvm
    
# Install system dependencies for development
RUN apk add --no-cache \
    build-base \
    coreutils \
    curl \
    git \
    make \
    mercurial \
    openssh-client \
    patch \
    python3 \
    py3-pip \
    rsync \
    subversion \
    tini \
    unzip \
    zip

# Use bash for the shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Create a script file sourced by both interactive and non-interactive bash shells
ENV BASH_ENV /home/user/.bash_env
RUN touch "${BASH_ENV}"
RUN echo '. "${BASH_ENV}"' >> ~/.bashrc

# Download and install nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | PROFILE="${BASH_ENV}" bash
RUN echo node > .nvmrc
RUN nvm install ${NODE_VERSION:-'--lts=gallium'}
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"

# Set working directory
WORKDIR /app

# Copy package files first (for better Docker layer caching)
COPY package*.json ./

# Install npm dependencies with legacy peer deps to handle version conflicts  
RUN npm install --legacy-peer-deps

# Copy build configuration files
COPY webpack.config.js ./
COPY .eslintrc.js ./
COPY stylelint.config.js ./
COPY makefile ./
COPY docker.makefile ./

# Copy source code and other necessary files
COPY src/ ./src/
COPY css/ ./css/
COPY img/ ./img/
COPY lib/ ./lib/
COPY templates/ ./templates/
COPY appinfo/ ./appinfo/
COPY l10n/ ./l10n/

# Expose port for development server (if needed)
EXPOSE 3000

# Default command for development - use npm directly since deps are installed
CMD ["npm", "run", "watch"]

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
