#!/bin/bash

set -e

echo "📦 Iniciando deploy completo com Minikube..."

# Ativar Docker do Minikube
echo "🎯 Configurando Docker para usar Minikube..."
eval $(minikube docker-env)

# Lista dos serviços
SERVICES=("auth-service" "user-service" "product-service" "gateway")
JAVA_PATH="./java-microservices"
K8S_PATH="./kubernetes-cluster/microservices"

echo "📁 Aplicando namespace (microservices-app)..."
kubectl apply -f ./kubernetes-cluster/microservices/namespace.yml

# 1. Build das imagens Docker
for SERVICE in "${SERVICES[@]}"; do
  echo "🔨 Buildando imagem Docker de $SERVICE..."
  docker build -t "$SERVICE:latest" "$JAVA_PATH/$SERVICE"
done

# 2. Aplicar manifests de app e banco de cada serviço
for SERVICE in "${SERVICES[@]}"; do
  # Caso especial para gateway
  if [ "$SERVICE" == "gateway" ]; then
    SERVICE_FOLDER="gateway-service"
    APP_FOLDER="gateway"
  else
    SERVICE_FOLDER="$SERVICE"
    APP_FOLDER="${SERVICE%%-*}"  # auth, user, product
  fi

  APP_MANIFEST="$K8S_PATH/$SERVICE_FOLDER/$APP_FOLDER"
  DB_MANIFEST="$K8S_PATH/$SERVICE_FOLDER/database"

  echo "📄 Aplicando manifests do banco de dados de $SERVICE_FOLDER..."
  kubectl apply -f "$DB_MANIFEST"

  echo "🚀 Aplicando manifests da aplicação $SERVICE_FOLDER..."
  kubectl apply -f "$APP_MANIFEST"
done

# 3. Aplicar ingress (caso exista)
INGRESS_FILE="$K8S_PATH/gateway-service/ingress.yml"
if [ -f "$INGRESS_FILE" ]; then
  echo "🌐 Aplicando Ingress..."
  kubectl apply -f "$INGRESS_FILE"
fi

echo "✅ Deploy finalizado com sucesso!"
