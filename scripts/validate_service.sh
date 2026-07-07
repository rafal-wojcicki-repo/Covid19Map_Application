#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="/etc/covid19map/deploy.env"
SERVICE_NAME="covid19map.service"
HEALTHCHECK_URL="http://localhost:8080/health"

if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

systemctl is-active --quiet "${SERVICE_NAME}"
curl -fsS "${HEALTHCHECK_URL}" >/dev/null
