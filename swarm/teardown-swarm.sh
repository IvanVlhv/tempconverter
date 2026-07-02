#!/usr/bin/env bash
docker stack rm tempconverter 2>/dev/null
sleep 5
docker rm -f swarm-worker1 swarm-worker2 2>/dev/null
docker node rm swarm-worker1 swarm-worker2 --force 2>/dev/null
docker swarm leave --force 2>/dev/null
echo "Swarm environment removed."
