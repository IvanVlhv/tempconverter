#!/usr/bin/env bash
# Removes everything created by deploy-local.sh (keeps the pulled images).
podman rm -f tempconverter-app tempconverter-db 2>/dev/null
podman network rm tempnet 2>/dev/null
podman volume rm tempconverter-dbdata 2>/dev/null
echo "Local podman deployment removed."
