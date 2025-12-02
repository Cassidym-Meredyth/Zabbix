#!/usr/bin/env bash
set -euo pipefail

cd /vagrant/monitor/zabbix/testing
source ./zbx_env.sh

TRIGGER_CPU_HIGH="High CPU utilization on host3"
FLOOD_DURATION=${1:-60}   # сколько секунд долбить ping'ом

zbx_login

log "TEST_CPU_HIGH: start ICMP load to 192.168.10.30 for ${FLOOD_DURATION}s"

# ограниченный по времени ping
timeout "${FLOOD_DURATION}" ping -i 0.002 192.168.10.30 > /dev/null || true

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
