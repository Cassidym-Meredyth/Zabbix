FROM zabbix/zabbix-agent2:7.4-ubuntu-latest

USER root

RUN apt-get update && apt-get -y \
    install \
    curl \
    wget \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

COPY zabbix_agent2.conf /etc/zabbix/zabbix_agent2.conf
COPY custom_logs.conf /etc/zabbix/zabbix_agent2.d/custom_logs.conf
