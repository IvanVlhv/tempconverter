#!/usr/bin/env bash
# Creates a REAL 3-node Docker Swarm inside a single VM:
#   - manager  = the Docker engine of this VM (zavrsni)
#   - worker1, worker2 = Docker-in-Docker (dind) containers acting as nodes
# No nested virtualization and no extra VMs are needed.
set -euo pipefail

MANAGER_IP=$(hostname -I | awk '{print $1}')
echo "==> Initialising swarm (manager advertise address: $MANAGER_IP)"
docker swarm init --advertise-addr "$MANAGER_IP" 2>/dev/null || echo "    swarm already initialised, continuing"

TOKEN=$(docker swarm join-token -q worker)

for i in 1 2; do
  NAME="swarm-worker$i"
  echo "==> Starting dind node $NAME"
  docker rm -f "$NAME" >/dev/null 2>&1 || true
  docker run -d --privileged --name "$NAME" --hostname "$NAME" \
    -e DOCKER_TLS_CERTDIR="" docker:27-dind >/dev/null

  echo "    waiting for Docker daemon inside $NAME ..."
  until docker exec "$NAME" docker info >/dev/null 2>&1; do sleep 2; done

  echo "    joining $NAME to the swarm"
  docker exec "$NAME" docker swarm join --token "$TOKEN" "$MANAGER_IP:2377"
done

echo
echo "==> Swarm nodes:"
docker node ls
