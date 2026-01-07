#!/usr/bin/env bash
set -euo pipefail

echo "Пересоздаём кластер"
minikube delete
minikube start --cni=calico # чтобы Network Policy действительно работали

echo "Применяем деплойменты..."
minikube kubectl -- apply -f deploy/

echo "Ждём готовности подов..."
minikube kubectl rollout status deployment/some-front-end-app
minikube kubectl rollout status deployment/some-back-end-api
minikube kubectl rollout status deployment/admin-front-end-app
minikube kubectl rollout status deployment/admin-back-end-api

echo "Применяем сервисы..."
minikube kubectl -- apply -f services/

echo "Готово."