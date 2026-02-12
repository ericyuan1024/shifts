#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR/.."

echo "Pulling latest code..."
git pull

cd "$ROOT_DIR"

if [[ ! -f .env ]]; then
  echo "Missing deploy/.env. Create it before updating."
  exit 1
fi

echo "Rebuilding and restarting containers..."
DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1 \
  docker compose --env-file .env -f docker-compose.yml up -d --build

echo "Running migrations (if any)..."
docker compose --env-file .env -f docker-compose.yml exec -T app npm run prisma:migrate

echo "Update complete."
