#!/bin/bash

set -e

echo "📦 Iniciando deploy dos microserviços com Minikube..."

# 1. Usar Docker do Minikube
echo "🎯 Configurando Docker do Minikube..."
eval $(minikube docker-env)

# 2. Build de todas as imagens (Java microservices)
SERVICES=("auth-service" "user-service" "product-service" "gateway")
for SERVICE in "${SERVICES[@]}"; do
  echo "🔨 Buildando imagem: $SERVICE..."
  docker build -t "$SERVICE:latest" "./java-microservices/$SERVICE"
done

# 3. Aplicar namespace (se existir um)
NAMESPACE_FILE="./kubernetes-cluster/microservices/namespace.yml"
if [ -f "$NAMESPACE_FILE" ]; then
  echo "📁 Aplicando namespace..."
  kubectl apply -f "$NAMESPACE_FILE"
fi

# 4. Aplicar os manifests Kubernetes
for SERVICE in "${SERVICES[@]}"; do
  echo "🚀 Aplicando manifestos do serviço: $SERVICE..."
  kubectl apply -f "./kubernetes-cluster/microservices/$SERVICE"
done

# 5. Aplicar o ingress do gateway
echo "🌐 Aplicando Ingress (gateway)..."
kubectl apply -f "./kubernetes-cluster/microservices/gateway-service/ingress.yml"

echo "✅ Deploy finalizado com sucesso!"
