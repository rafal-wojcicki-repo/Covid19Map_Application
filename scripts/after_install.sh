#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="/etc/covid19map/deploy.env"
APP_DIR="/opt/covid19map"

if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

DEPLOYMENT_ID="${DEPLOYMENT_ID:-manual}"
SRC_JAR="${APP_DIR}/deployment/app.jar"
RELEASE_JAR="${APP_DIR}/releases/app-${DEPLOYMENT_ID}.jar"

if [ ! -f "$SRC_JAR" ]; then
  echo "Missing artifact at ${SRC_JAR}"
  exit 1
fi

mv "$SRC_JAR" "$RELEASE_JAR"
ln -sfn "$RELEASE_JAR" "${APP_DIR}/current.jar"
chown -h ec2-user:ec2-user "${APP_DIR}/current.jar"
