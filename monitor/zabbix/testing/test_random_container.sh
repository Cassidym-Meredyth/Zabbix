#!/usr/bin/env bash
set -euo pipefail

cd /vagrant/monitor/zabbix

source ./zbx_env.sh

TRIGGER_NGINX_DOWN="Nginx container is down"
TRIGGER_APP_AGENT_DOWN="Zabbix agent on app1 is down"
TRIGGER_HOST3_AGENT_DOWN="Zabbix agent on host3 is down"

DURATION=$(( (RANDOM % 30) + 30 ))   # 30-59 секунд
MODE=$(( RANDOM % 3 ))               # 0 = nginx, 1 = app1 agent, 2 = host3 agent

SERVICE=""
TRIGGER_DESC=""
DESC=""

case "${MODE}" in
  0)
    SERVICE="nginx"
    TRIGGER_DESC="${TRIGGER_NGINX_DOWN}"
    DESC="Отключение nginx-контейнера на host3"
    ;;
  1)
    SERVICE="app1"
    TRIGGER_DESC="${TRIGGER_APP_AGENT_DOWN}"
    DESC="Отключение zabbix-agent в контейнере app1"
    ;;
  2)
    SERVICE="zabbix-agent"
    TRIGGER_DESC="${TRIGGER_HOST3_AGENT_DOWN}"
    DESC="Отключение zabbix-agent, собирающего метрики host3"
    ;;
esac

zbx_login

log "TEST_RANDOM_CONTAINER: mode=${MODE}, service=${SERVICE}, duration=${DURATION}s"
log "Stopping container ${SERVICE} on host3..."

docker compose -f /vagrant/host3/docker-compose.yml stop "${SERVICE}" || true
sleep "${DURATION}"
log "Starting container ${SERVICE} on host3..."
docker compose -f /vagrant/host3/docker-compose.yml start "${SERVICE}" || true

STATUS="FAIL"
DETAILS="trigger not fired; service=${SERVICE}, duration=${DURATION}s"

if wait_trigger_problem "${TRIGGER_DESC}"; then
  STATUS="OK"
  DETAILS="trigger fired; service=${SERVICE}, duration=${DURATION}s"
fi

echo "TEST_RANDOM_CONTAINER | ${DESC} | ${STATUS} | ${DETAILS}"

if [[ "${STATUS}" != "OK" ]]; then
  exit 1
fi
