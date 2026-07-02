#!/usr/bin/env bash
# Task 4 - local deployment with podman: MySQL container + app container on a
# shared network. The app connects as the NON-ROOT MySQL user "tempuser".
set -euo pipefail

IMAGE="docker.io/ivan123895okr/tempconverter:latest"

echo "==> Creating network and volume"
podman network exists tempnet || podman network create tempnet
podman volume create tempconverter-dbdata 2>/dev/null || true

echo "==> Starting MySQL 8 container"
podman run -d --name tempconverter-db \
  --network tempnet \
  -e MYSQL_ROOT_PASSWORD=RootPass123 \
  -e MYSQL_DATABASE=tempconverter \
  -e MYSQL_USER=tempuser \
  -e MYSQL_PASSWORD=TempUserPass123 \
  -v tempconverter-dbdata:/var/lib/mysql \
  --health-cmd 'mysqladmin ping -h 127.0.0.1 -uroot -pRootPass123' \
  --health-interval 5s \
  --health-retries 30 \
  docker.io/library/mysql:8

echo "==> Waiting for MySQL to become healthy"
until [ "$(podman inspect -f '{{.State.Health.Status}}' tempconverter-db)" = "healthy" ]; do
  sleep 2
  printf '.'
done
echo " healthy!"

echo "==> Starting tempconverter application container"
podman run -d --name tempconverter-app \
  --network tempnet \
  -p 8080:5000 \
  -e DB_USER=tempuser \
  -e DB_PASS=TempUserPass123 \
  -e DB_HOST=tempconverter-db \
  -e DB_NAME=tempconverter \
  -e STUDENT="Ivan" \
  -e COLLEGE="Algebra Bernays University" \
  "$IMAGE"

echo
echo "Done. Open:  http://localhost:8080"
echo "Check with: podman ps"
