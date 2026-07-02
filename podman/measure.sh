#!/usr/bin/env bash
# LO1 helper - prints the CONTAINER side of the container-vs-VM comparison.
# Run it while deploy-local.sh containers are up. VM-side commands are in STEPS.md.
set -u

echo "===== 1) Image sizes ====="
podman images | grep -E 'REPOSITORY|tempconverter|mysql'

echo
echo "===== 2) Live CPU / RAM usage of running containers ====="
podman stats --no-stream

echo
echo "===== 3) Cold start -> first successful HTTP response ====="
podman rm -f tc-timing >/dev/null 2>&1
START=$(date +%s.%N)
podman run -d --name tc-timing --network tempnet -p 8090:5000 \
  -e DB_USER=tempuser -e DB_PASS=TempUserPass123 \
  -e DB_HOST=tempconverter-db -e DB_NAME=tempconverter \
  -e STUDENT="Ivan" -e COLLEGE="Algebra Bernays University" \
  docker.io/ivan123895okr/tempconverter:latest >/dev/null
until curl -fs http://localhost:8090/ >/dev/null 2>&1; do sleep 0.2; done
END=$(date +%s.%N)
awk "BEGIN{printf \"tempconverter container was READY in %.1f seconds\n\", $END-$START}"
podman rm -f tc-timing >/dev/null
