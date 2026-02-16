#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR/.."

IMAGE="ghcr.io/ericyuan1024/shifts:latest"
SSH_HOST="${SSH_HOST:-45.33.50.146}"
SSH_USER="${SSH_USER:-root}"
SSH_PATH="${SSH_PATH:-/opt/shifts/deploy}"
COMMIT_MESSAGE="${COMMIT_MESSAGE:-Release $(date '+%Y-%m-%d %H:%M:%S')}"

if [[ -z "$SSH_HOST" ]]; then
  echo "Missing SSH_HOST. Example:"
  echo "  SSH_HOST=your.vps.ip SSH_USER=root SSH_PATH=/opt/shifts/deploy ./deploy/release.sh"
  exit 1
fi

echo "Building image..."
BUILD_TIMESTAMP="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"
DOCKER_BUILDKIT=1 docker build -f deploy/Dockerfile -t "$IMAGE" \
  --build-arg BUILD_TIMESTAMP="$BUILD_TIMESTAMP" .

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Committing changes..."
  git add -A
  git commit -m "$COMMIT_MESSAGE"
fi

echo "Pushing code..."
git push

echo "Pushing image..."
docker push "$IMAGE"

echo "Updating server..."
ssh "${SSH_USER}@${SSH_HOST}" "cd ${SSH_PATH} && ./update.sh"

echo "Release complete."
