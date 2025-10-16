#!/usr/bin/env bash
set -euo pipefail

echo "Starting DB container..."
docker compose up -d db

echo "Generating Prisma client for workspace..."
pnpm -w -r run prisma:generate

echo "Starting web + api dev servers..."
# runs concurrently; use pnpm dev root script which uses concurrently
pnpm --silent dev