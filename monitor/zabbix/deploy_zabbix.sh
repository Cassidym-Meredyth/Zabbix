#!/usr/bin/env bash
set -e

echo "=== Prepare Zabbix volumes ==="
docker volume create zabbix_grafana_data
docker volume create zabbix_patroni1_data
docker volume create zabbix_patroni2_data

cd /vagrant/monitor/zabbix/zabbix-zabbix || {
  echo "WARN: /vagrant/monitor/zabbix/zabbix-zabbix not found"
  exit 0
}

echo "=== Grafana Data ==="
docker run --rm -v zabbix_grafana_data:/data -v "$(pwd)":/backup \
  busybox sh -c "cd /data && tar xzf /backup/zabbix_grafana_data.tar.gz" || true

echo "=== Patroni1 Data ==="
docker run --rm -v zabbix_patroni1_data:/data -v "$(pwd)":/backup \
  busybox sh -c "cd /data && tar xzf /backup/zabbix_patroni1_data.tar.gz" || true

echo "=== Patroni2 Data ==="
docker run --rm -v zabbix_patroni2_data:/data -v "$(pwd)":/backup \
  busybox sh -c "cd /data && tar xzf /backup/zabbix_patroni2_data.tar.gz" || true

echo "=== Start Docker compose ==="
cd /vagrant/monitor/zabbix
docker compose up -d --build
