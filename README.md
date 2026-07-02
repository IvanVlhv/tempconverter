# tempconverter — Intro to DevOps project

Containerised deployment of the [tempconverter](https://github.com/jstanesic/tempconverter)
Flask application (°C → °F converter backed by MySQL 8) for the *Intro to DevOps*
course at Algebra Bernays University. Student: **Ivan**.

The application is configured entirely through environment variables
(`DB_USER`, `DB_PASS`, `DB_HOST`, `DB_NAME`, `STUDENT`, `COLLEGE`), so the **same
image** (`docker.io/ivan123895okr/tempconverter`) runs unchanged everywhere below.

## Repository layout

```
Dockerfile                  image build (updates OS pkgs, installs reqs, EXPOSE 5000, CMD)
converter.py                pure conversion logic (unit-testable without a DB)
app.py                      Flask app (upstream + 2 minimal changes, see project doc)
tests/                      unit tests + HTTP integration tests
.github/workflows/ci.yml    pipeline: tests (with real MySQL) -> build -> push
podman/                     local deployment scripts + resource measurement helper
swarm/                      3-node Swarm setup (dind) + stack.yml deployment template
k8s/                        Kubernetes manifests (namespace, config, MySQL, app, ingress)
```

## Quick start

```bash
# Local (podman): MySQL + app on http://localhost:8080
./podman/deploy-local.sh

# Docker Swarm (3 nodes inside one VM), app on http://localhost:80
./swarm/setup-swarm.sh
docker stack deploy -c swarm/stack.yml tempconverter

# Kubernetes (3-node minikube), app on http://tempconverter.local:80
minikube start --driver=docker --nodes 3 --cpus 2 --memory 2200
minikube addons enable ingress
kubectl apply -f k8s/
echo "$(minikube ip) tempconverter.local" | sudo tee -a /etc/hosts
```

## Tests

```bash
pip install -r requirements-dev.txt
pytest tests/test_unit.py -v                                  # no DB needed
APP_URL=http://localhost:8080 pytest tests/test_integration.py -v   # against a running deployment
```

CI (GitHub Actions) runs both test suites against a real MySQL 8 service container
and pushes the image to Docker Hub on every push to `main`
(secrets: `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`).
