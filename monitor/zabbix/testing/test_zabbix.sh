#!/usr/bin/env bash
set -euo pipefail

cd /vagrant/monitor/zabbix

echo "NAME | DESCRIPTION | STATUS | DETAILS"

./test_cpu_high.sh
./test_ping_flood.sh
./test_random_container.sh
