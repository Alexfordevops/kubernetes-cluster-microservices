#!/bin/bash
set -e

echo "📦 Iniciando deploy completo com Minikube..."

# Ativa o Docker do Minikube
echo "🎯 Configurando Docker para usar o ambiente do Minikube..."
eval $(minikube docker-env)

# 0. Aplica o namespace antes de tudo
echo "📁 Aplicando namespace (microservices-app)..."
kubectl apply -f ./kubernetes-cluster/namespace.yml

# Lista dos microserviços
SERVICES=("auth-service" "user-service" "product-service" "gateway")
JAVA_PATH="./java-microservices"
K8S_PATH="./kubernetes-cluster/microservices"

# 1. Build das imagens Docker
for SERVICE in "${SERVICES[@]}"; do
  echo "🔨 Buildando imagem Docker de $SERVICE..."
  docker build -t "$SERVICE:latest" "$JAVA_PATH/$SERVICE"
done

# 2. Aplicar os YAMLs de database e aplicação
for SERVICE in "${SERVICES[@]}"; do
  if [ "$SERVICE" == "gateway" ]; then
    SERVICE_FOLDER="gateway-service"
    APP_FOLDER="gateway"
    SKIP_DB=true
  else
    SERVICE_FOLDER="$SERVICE"
    APP_FOLDER="${SERVICE%%-*}"
    SKIP_DB=false
  fi

  DB_PATH="$K8S_PATH/$SERVICE_FOLDER/database"
  APP_PATH="$K8S_PATH/$SERVICE_FOLDER/$APP_FOLDER"

  # Aplica banco de dados (exceto gateway)
  if [ "$SKIP_DB" = false ]; then
    echo "📄 Aplicando banco de dados de $SERVICE_FOLDER..."
    kubectl apply -f "$DB_PATH"
  fi

  echo "🚀 Aplicando aplicação de $SERVICE_FOLDER..."
  kubectl apply -f "$APP_PATH"
done

# 3. Aplica Ingress (novo caminho correto)
INGRESS_FILE="./kubernetes-cluster/ingress.yml"
if [ -f "$INGRESS_FILE" ]; then
  echo "🌐 Aplicando Ingress..."
  kubectl apply -f "$INGRESS_FILE"
fi

echo "✅ Deploy finalizado com sucesso!"
