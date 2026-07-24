SHELL := /bin/bash

ENV ?= dev
KUSTOMIZE_DIR := kubernetes/overlays/$(ENV)
NAMESPACE := todo-app-$(ENV)
FRONTEND_IMAGE := todo-frontend
BACKEND_IMAGE := todo-backend
FRONTEND_SERVICE := todo-frontend-service
BACKUP_JOB := todo-postgres-backup-manual

ifeq ($(ENV),dev)
FRONTEND_TAG := latest
BACKEND_TAG := latest
else
FRONTEND_TAG := $(ENV)
BACKEND_TAG := $(ENV)
endif

.PHONY: help minikube-env build-frontend build-backend build-images \
	deploy rollout-status status pods services hpa pdb cronjobs top \
	logs-backend logs-frontend port-forward delete backup-db backup-history

help:
	@echo "Available targets:"
	@echo "  make build-images ENV=dev      Build frontend and backend images with Minikube"
	@echo "  make deploy ENV=dev            Deploy the selected overlay"
	@echo "  make rollout-status ENV=dev    Wait for frontend and backend rollout"
	@echo "  make status ENV=dev            Show resources, HPA, PDB, and CronJobs"
	@echo "  make pods ENV=dev              Show pods in namespace $(NAMESPACE)"
	@echo "  make services ENV=dev          Show services in namespace $(NAMESPACE)"
	@echo "  make top ENV=dev               Show pod resource usage (metrics-server required)"
	@echo "  make backup-db ENV=dev         Trigger a manual Postgres backup job"
	@echo "  make backup-history ENV=dev    Show backup jobs"
	@echo "  make logs-backend ENV=dev      Tail backend logs"
	@echo "  make logs-frontend ENV=dev     Tail frontend logs"
	@echo "  make port-forward ENV=dev      Forward frontend service to http://localhost:8080"
	@echo "  make delete ENV=dev            Remove deployed resources for one environment"

minikube-env:
	@echo 'Run this command before building images:'
	@echo 'eval $$(minikube docker-env)'

build-frontend:
	minikube image build -t $(FRONTEND_IMAGE):$(FRONTEND_TAG) ./frontend

build-backend:
	minikube image build -t $(BACKEND_IMAGE):$(BACKEND_TAG) ./backend

build-images: build-frontend build-backend

deploy: build-images
	kubectl apply -k $(KUSTOMIZE_DIR)
	$(MAKE) rollout-status ENV=$(ENV)

rollout-status:
	kubectl rollout status deployment/todo-backend -n $(NAMESPACE) --timeout=180s
	kubectl rollout status deployment/todo-frontend -n $(NAMESPACE) --timeout=180s

status:
	kubectl get all -n $(NAMESPACE)
	kubectl get hpa -n $(NAMESPACE)
	kubectl get pdb -n $(NAMESPACE)
	kubectl get cronjobs -n $(NAMESPACE)

pods:
	kubectl get pods -n $(NAMESPACE) -o wide

services:
	kubectl get svc -n $(NAMESPACE)

hpa:
	kubectl get hpa -n $(NAMESPACE)

pdb:
	kubectl get pdb -n $(NAMESPACE)

cronjobs:
	kubectl get cronjobs -n $(NAMESPACE)

top:
	kubectl top pods -n $(NAMESPACE)

logs-backend:
	kubectl logs -n $(NAMESPACE) deployment/todo-backend -f

logs-frontend:
	kubectl logs -n $(NAMESPACE) deployment/todo-frontend -f

port-forward:
	kubectl port-forward -n $(NAMESPACE) svc/$(FRONTEND_SERVICE) 8080:80

backup-db:
	kubectl delete job -n $(NAMESPACE) $(BACKUP_JOB) --ignore-not-found
	kubectl create job -n $(NAMESPACE) --from=cronjob/todo-postgres-backup $(BACKUP_JOB)

backup-history:
	kubectl get jobs -n $(NAMESPACE)

delete:
	kubectl delete -k $(KUSTOMIZE_DIR) --ignore-not-found
