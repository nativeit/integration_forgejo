#!/bin/bash
# Quick test script for Docker build
echo "🔨 Testing Docker build (builder stage only)..."

# Build just the builder stage
docker build --target builder -t forgejo-integration:test . --progress=plain

echo "✅ Build test complete"
