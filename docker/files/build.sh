#!/bin/bash

# Comprobamos que el archivo JSON existe
if [ ! -f "images.json" ]; then
  echo "El archivo images.json no existe"
  exit 1
fi

# Obtenemos la fecha actual en el formato "YYYYmmddhhMMSS"
CURRENT_DATE=$(date +"%Y%m%d%H%M%S")

# Leemos el archivo JSON y procesamos cada entrada
jq -c '.[]' images.json | while read -r image_data; do
  # Extraemos los datos básicos del JSON
  NAME=$(echo "$image_data" | jq -r '.name')
  FILE=$(echo "$image_data" | jq -r '.file')
  TAG=$(echo "$image_data" | jq -r '.tag')

  # Inicializamos la cadena de argumentos para el comando docker build
  DOCKER_ARGS=""

  # Procesamos los argumentos del array "args"
  ARG_PLACEHOLDERS=$(echo "$image_data" | jq -c '.args[]')
  for arg in $ARG_PLACEHOLDERS; do
    ARG_NAME=$(echo "$arg" | jq -r '.name')
    ARG_VALUE=$(echo "$arg" | jq -r '.value')

    # Reemplazamos el placeholder en el tag
    TAG=$(echo "$TAG" | sed "s/{{${ARG_NAME}}}/$ARG_VALUE/g")

    # Añadimos el argumento al comando de docker build
    DOCKER_ARGS="$DOCKER_ARGS --build-arg $ARG_NAME=$ARG_VALUE"
  done

  # Reemplazamos el placeholder especial de la fecha
  TAG=$(echo "$TAG" | sed "s/{{DATE}}/$CURRENT_DATE/g")

  # Construimos la imagen de Docker
  echo -e "\n\nConstruyendo la imagen '$NAME' con el tag '$TAG' usando el Dockerfile '$FILE'..."
  docker build \
    -f "$FILE" \
    -t "$NAME:$TAG" \
    -t "$NAME:latest" \
    --build-arg USER_ID="$(id -u)" \
    --build-arg GROUP_ID="$(id -g)" \
    $DOCKER_ARGS .

  if [[ "$1" == "--publish" ]]; then
    echo "==> Publicando la imagen ${CLANG_TAG} en Docker Hub..."
    docker push "$NAME:$TAG"
    docker push "$NAME:latest"
  fi
done
