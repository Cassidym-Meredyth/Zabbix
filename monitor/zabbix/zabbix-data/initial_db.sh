#!/usr/bin/env bash

mkdir -p /tmp/pgdata
rm -rf /tmp/pgdata/*
tar -xzf zabbix_patroni1_data.tar.gz -C /tmp/pgdata

mkdir -p /var/lib/docker/volumes/zabbix_patroni1_data/_data
rm -rf /var/lib/docker/volumes/zabbix_patroni1_data/_data/*
cp -r /tmp/pgdata/patroni1/* /var/lib/docker/volumes/zabbix_patroni1_data/_data/

echo "=== Выдача прав для volume БД ==="
chmod 700 /var/lib/docker/volumes/zabbix_patroni1_data/_data
chown -R 999:999 /var/lib/docker/volumes/zabbix_patroni1_data/_data

mkdir -p /var/lib/docker/volumes/zabbix_patroni2_data/_data
chmod 700 /var/lib/docker/volumes/zabbix_patroni2_data/_data
chown -R 999:999 /var/lib/docker/volumes/zabbix_patroni2_data/_data