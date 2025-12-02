#!/usr/bin/env bash
set -euo pipefail

cd /vagrant/monitor/zabbix

source ./zbx_env.sh

TRIGGER_CPU_HIGH="Hight CPU host3"

zbx_login

log "TEST_CPU_HIGH: start CPU load on vm3 (nginx host)"

ssh host3 "stress --cpu 1 --timeout 120"

STATUS="FAIL"
DETAILS="trigger not fired"

if wait_trigger_problem "${TRIGGER_CPU_HIGH}"; then
  STATUS="OK"
  DETAILS="trigger fired"
fi

echo "TEST_CPU_HIGH | Высокая нагрузка CPU | ${STATUS} | ${DETAILS}"

if [[ "${STATUS}" != "OK" ]]; then
  exit 1
fi
