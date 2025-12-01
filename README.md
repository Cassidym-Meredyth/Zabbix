# Zabbix Lab Work

## Структура проекта
```
Zabbix
├───host2
│   ├───zabbix-agent
│   │   ├───custom_logs.conf
│   │   ├───Dockerfile
│   │   └───zabbix_agent2.conf
│   ├───zabbix-backup
│   │   └───zabbix_server.conf
│   ├───zabbix-proxy
│   │   ├───zabbix_proxy_server_communication.conf
│   │   └───zabbix_proxy.conf
│   ├───99-forward-tls.conf
│   └───docker-compose.yml    
│
├───host3
│   ├───app1
│   │   └───zabbix_agent2.conf
│   ├───nginx
│   │   ├───Dockerfile
│   │   ├───go.mod
│   │   ├───index.html
│   │   ├───main.go
│   │   ├───nginx-check
│   │   ├───nginx-conf
│   │   ├───restart-nginx.sh
│   │   └───start.sh
│   ├───zabbix-agent
│   │   ├───custom_logs.conf
│   │   ├───Dockerfile
│   │   ├───zabbix_agent2.conf
│   │   └───zbx_nginx.sh
│   ├───99-forward-tls.conf
│   └───docker-compose.yml
│
├───monitor
│   ├───syslog
│   │   ├───certs
│   │   ├───config
│   │   │   └───server.conf
│   │   └───Dockerfile
│   ├───zabbix
│   │   ├───haproxy
│   │   │   └───haproxy.conf
│   │   ├───patroni
│   │   │   ├───entrypoint.sh
│   │   │   └───patroni.yml
│   │   ├───server
│   │   │   └───zabbix_server.conf
│   │   ├───zabbix-agent
│   │   │   ├───custom_logs.conf
│   │   │   ├───Dockerfile
│   │   │   └───zabbix_agent2.conf
│   │   ├───zabbix-data
│   │   ├───zabbix-proxy
│   │   │   ├───zabbix_proxy_server_communication.conf
│   │   │   └───zabbix_proxy.conf
│   │   ├───curl_fail500.sh
│   │   ├───deploy_zabbix.sh
│   │   └───docker-compose.yml
│   └───99-forward-tls.conf
├───README.md
└───Vagrantfile
```