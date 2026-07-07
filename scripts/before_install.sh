#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="/etc/covid19map/deploy.env"
APP_DIR="/opt/covid19map"
SERVICE_NAME="covid19map.service"

if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

mkdir -p "${APP_DIR}/releases" "${APP_DIR}/deployment"
chown -R ec2-user:ec2-user "${APP_DIR}"
