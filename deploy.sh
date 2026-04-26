#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="rosetown11/docuseal:latest"

git add .

read -r -p "Commit message: " COMMIT_MESSAGE

if [ -z "${COMMIT_MESSAGE}" ]; then
  echo "Commit message cannot be empty."
  exit 1
fi

git commit -m "${COMMIT_MESSAGE}"
git push

docker build -t "${IMAGE_NAME}" .
docker push "${IMAGE_NAME}"
