#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="/etc/covid19map/deploy.env"
SERVICE_NAME="covid19map.service"
HEALTHCHECK_URL="http://localhost:8080/health"

if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

for _ in $(seq 1 30); do
  if systemctl is-active --quiet "${SERVICE_NAME}" && curl -fsS "${HEALTHCHECK_URL}" >/dev/null; then
    exit 0
  fi
  sleep 5
done

systemctl --no-pager --full status "${SERVICE_NAME}" || true
journalctl -u "${SERVICE_NAME}" -n 120 --no-pager || true
echo "Health check failed: ${HEALTHCHECK_URL}"
exit 1
