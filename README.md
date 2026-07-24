# Todo Kubernetes Project

## Structure

```text
frontend/
backend/
kubernetes/
  base/
  overlays/
    dev/
    staging/
    prod/
```

## App Stack

- Frontend: React + Nginx
- Backend: Spring Boot REST API + Actuator health endpoints
- Database: PostgreSQL

## API

- `GET /api/todos`
- `POST /api/todos`
- `DELETE /api/todos/{id}`

## Kubernetes Features

- Liveness, readiness, and startup probes
- CPU and memory requests/limits
- Rolling update with `maxUnavailable: 0`
- Pod Disruption Budget for frontend and backend
- Horizontal Pod Autoscaler for frontend and backend
- Graceful shutdown for Spring Boot and deployment lifecycle hooks
- Postgres backup CronJob plus manual backup target
- Environment overlays for `dev`, `staging`, and `prod`

## Minikube Workflow

```bash
make build-images ENV=dev
make deploy ENV=dev
make rollout-status ENV=dev
make port-forward ENV=dev
```

## Useful Commands

```bash
make status ENV=dev
make top ENV=dev
make backup-db ENV=dev
make delete ENV=dev
```

## Notes

- `make top` and HPA need `metrics-server` enabled in Minikube.
- `staging` builds use image tag `staging`; `prod` builds use image tag `prod`.
