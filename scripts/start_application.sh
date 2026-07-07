#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="/etc/covid19map/deploy.env"
SERVICE_NAME="covid19map.service"

if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

systemctl daemon-reload
systemctl restart "${SERVICE_NAME}"
