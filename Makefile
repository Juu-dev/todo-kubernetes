SHELL := /bin/bash

NAMESPACE := todo-app
FRONTEND_IMAGE := todo-frontend
BACKEND_IMAGE := todo-backend
FRONTEND_TAG := latest
BACKEND_TAG := latest
FRONTEND_SERVICE := todo-frontend-service

.PHONY: help minikube-env build-frontend build-backend build-images \
	deploy-namespace deploy-database deploy-backend deploy-frontend deploy \
	status pods services logs-backend logs-frontend port-forward delete

help:
	@echo "Available targets:"
	@echo "  make minikube-env      Print the Docker env command for Minikube"
	@echo "  make build-images      Build frontend and backend images with Minikube"
	@echo "  make deploy            Deploy namespace, database, backend, and frontend"
	@echo "  make status            Show resources in namespace $(NAMESPACE)"
	@echo "  make pods              Show pods in namespace $(NAMESPACE)"
	@echo "  make services          Show services in namespace $(NAMESPACE)"
	@echo "  make logs-backend      Tail backend logs"
	@echo "  make logs-frontend     Tail frontend logs"
	@echo "  make port-forward      Forward frontend service to http://localhost:8080"
	@echo "  make delete            Remove deployed resources"

minikube-env:
	@echo 'Run this command before building images:'
	@echo 'eval $$(minikube docker-env)'

build-frontend:
	minikube image build -t $(FRONTEND_IMAGE):$(FRONTEND_TAG) ./frontend

build-backend:
	minikube image build -t $(BACKEND_IMAGE):$(BACKEND_TAG) ./backend

build-images: build-frontend build-backend

deploy-namespace:
	kubectl apply -f kubernetes/namespace.yaml

deploy-database: deploy-namespace
	kubectl apply -f kubernetes/database

deploy-backend: deploy-database
	kubectl apply -f kubernetes/backend

deploy-frontend: deploy-backend
	kubectl apply -f kubernetes/frontend

deploy: build-images deploy-frontend

status:
	kubectl get all -n $(NAMESPACE)

pods:
	kubectl get pods -n $(NAMESPACE) -o wide

services:
	kubectl get svc -n $(NAMESPACE)

logs-backend:
	kubectl logs -n $(NAMESPACE) deployment/todo-backend -f

logs-frontend:
	kubectl logs -n $(NAMESPACE) deployment/todo-frontend -f

port-forward:
	kubectl port-forward -n $(NAMESPACE) svc/$(FRONTEND_SERVICE) 8080:80

delete:
	kubectl delete -f kubernetes/frontend --ignore-not-found
	kubectl delete -f kubernetes/backend --ignore-not-found
	kubectl delete -f kubernetes/database --ignore-not-found
	kubectl delete -f kubernetes/namespace.yaml --ignore-not-found
