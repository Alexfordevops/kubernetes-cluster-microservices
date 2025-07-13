#!/bin/bash

set -e  # Encerra se algum comando falhar

echo "🎯 Usando Docker do Minikube..."
eval $(minikube docker-env)

echo "📦 Buildando imagens..."

SERVICES=("gateway" "auth-service" "user-service" "product-service")

for SERVICE in "${SERVICES[@]}"; do
  echo "🔨 Buildando $SERVICE..."
  docker build -t "$SERVICE:latest" "./$SERVICE"
done

echo "🚀 Aplicando namespace..."
kubectl apply -f k8s/namespace.yml

echo "🧩 Aplicando recursos dos serviços..."

for SERVICE in "${SERVICES[@]}"; do
  echo "📄 Aplicando manifests de $SERVICE..."
  kubectl apply -f "k8s/$SERVICE/"
done

echo "🌐 Aplicando ingress..."
kubectl apply -f k8s/ingress.yml

echo "✅ Tudo pronto!"
