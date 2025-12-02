FROM zabbix/zabbix-agent2:7.4-ubuntu-latest

USER root

RUN apt-get update && apt-get -y \
    install \
    curl \
    wget \
    fping
    net-tools \
    && rm -rf /var/lib/apt/lists/*

COPY zbx_nginx.sh /usr/local/bin/zbx_nginx.sh
COPY zabbix_agent2.conf /etc/zabbix/zabbix_agent2.conf
COPY custom_logs.conf /etc/zabbix/zabbix_agent2.d/custom_logs.conf

RUN ln -sf /usr/bin/fping  /usr/sbin/fping
RUN chmod u+s /usr/bin/fping    