#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

if [[ ! -f .env ]]; then
  echo "Missing deploy/.env. Copy from deploy/.env.example and set POSTGRES_PASSWORD."
  exit 1
fi

echo "Building and starting containers..."
docker compose --env-file .env -f docker-compose.yml up -d --build

echo "Running migrations..."
docker compose --env-file .env -f docker-compose.yml exec -T app npm run prisma:migrate

echo "Done."
