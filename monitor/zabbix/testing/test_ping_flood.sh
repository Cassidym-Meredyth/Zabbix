#!/usr/bin/env bash
set -euo pipefail

cd /vagrant/monitor/zabbix/testing

source ./zbx_env.sh

TRIGGER_FLOOD_NGINX="Flood Nginx"   # имя триггера в Zabbix
FLOOD_DURATION=${1:-30}             # сколько секунд лить трафик

zbx_login

log "TEST_FLOOD_NGINX: start HTTP flood to fail500 for ${FLOOD_DURATION}s"

# запуск флуда (генерация кода 500 и записей 'flood' в логи)
timeout "${FLOOD_DURATION}" /vagrant/monitor/zabbix/testing/curl_flood.sh "${FLOOD_DURATION}" || true

STATUS="FAIL"
DETAILS="trigger not fired"

if wait_trigger_problem "${TRIGGER_FLOOD_NGINX}"; then
  STATUS="OK"
  DETAILS="trigger fired after HTTP flood"
fi

echo "TEST_FLOOD_NGINX | HTTP flood на /fail500 (500 errors) | ${STATUS} | ${DETAILS}"

if [[ "${STATUS}" != "OK" ]]; then
  exit 1
fi
