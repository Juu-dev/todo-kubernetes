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
docker build -t todo-frontend:latest ./frontend
docker build -t todo-backend:latest ./backend
```

## Deploy to Kubernetes

```bash
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/database
kubectl apply -f kubernetes/backend
kubectl apply -f kubernetes/frontend
```
