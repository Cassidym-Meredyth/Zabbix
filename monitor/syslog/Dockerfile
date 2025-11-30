FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    rsyslog \
    rsyslog-gnutls \
    && rm -rf /var/lib/apt/lists/*

COPY config/server.conf /etc/rsyslog.conf
COPY certs/ca.crt /etc/pki/tls/ca.crt
COPY certs/monitor.crt /etc/pki/tls/monitor.crt
COPY certs/monitor.key /etc/pki/tls/monitor.key

RUN chmod 600 /etc/pki/tls/monitor.key && \
    chmod 644 /etc/pki/tls/ca.crt && \
    chmod 644 /etc/pki/tls/monitor.crt && \
    mkdir -p /var/log/rsyslog

EXPOSE 10514/tcp

CMD ["/usr/sbin/rsyslogd", "-n"]
