#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR/.."

echo "Syncing latest code..."
git fetch origin
git reset --hard origin/main

cd "$ROOT_DIR"

if [[ ! -f .env ]]; then
  echo "Missing deploy/.env. Create it before updating."
  exit 1
fi

echo "Pulling latest image and restarting containers..."
docker compose --env-file .env -f docker-compose.yml pull app
docker compose --env-file .env -f docker-compose.yml up -d

echo "Running migrations (if any)..."
docker compose --env-file .env -f docker-compose.yml exec -T app npm run prisma:migrate

echo "Update complete."
