# Todo Kubernetes Project

## Structure

```text
frontend/
backend/
kubernetes/
```

## Frontend

- React app built with Vite
- Nginx serves static files and proxies `/api/*` to backend

## Backend

- Spring Boot REST API
- PostgreSQL persistence via Spring Data JPA

## API

- `GET /api/todos`
- `POST /api/todos`
- `DELETE /api/todos/{id}`

## Run locally with Docker

Build images:

```bash
docker build -t todo-frontend:v1 ./frontend
docker build -t todo-backend:v2 ./backend
```

## Deploy to Kubernetes

```bash
kubectl apply -f namespace.yaml
kubectl apply -f kubernetes/postgres-pv.yaml
kubectl apply -f kubernetes/postgres-pvc.yaml
kubectl apply -f kubernetes/secret.yaml
kubectl apply -f kubernetes/configmap.yaml
kubectl apply -f kubernetes/postgres-deployment.yaml
kubectl apply -f kubernetes/backend-deployment.yaml
kubectl apply -f kubernetes/frontend-deployment.yaml
kubectl apply -f kubernetes/ingress.yaml
```

If you are using a local cluster such as Minikube or kind, make sure the images exist inside that cluster runtime before applying the deployments. The manifests currently use `imagePullPolicy: Never`, so Kubernetes will fail immediately if `todo-frontend:v1` or `todo-backend:v2` is not already present on the node.

## Enable Horizontal Pod Autoscaler for backend

The backend deployment already defines CPU requests, so it can scale based on CPU usage.

Make sure `metrics-server` is installed in the cluster, then apply:

```bash
kubectl apply -f kubernetes/backend-deployment.yaml
kubectl apply -f kubernetes/backend-hpa.yaml
kubectl get hpa -n todo-app
```
