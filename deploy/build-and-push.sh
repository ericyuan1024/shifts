#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR/.."

IMAGE="ghcr.io/ericyuan1024/shifts:latest"

echo "Building and pushing image for linux/amd64..."
BUILD_TIMESTAMP="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"
docker buildx build --platform linux/amd64 \
  -f deploy/Dockerfile \
  -t "$IMAGE" \
  --build-arg BUILD_TIMESTAMP="$BUILD_TIMESTAMP" \
  --push .

echo "Done: $IMAGE"
