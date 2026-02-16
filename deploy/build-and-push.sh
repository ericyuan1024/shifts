#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR/.."

IMAGE="ghcr.io/ericyuan1024/shifts:latest"

echo "Building image..."
BUILD_TIMESTAMP="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"
DOCKER_BUILDKIT=1 docker build -f deploy/Dockerfile -t "$IMAGE" \
  --build-arg BUILD_TIMESTAMP="$BUILD_TIMESTAMP" .

echo "Pushing image..."
docker push "$IMAGE"

echo "Done: $IMAGE"
