| Test Number | Description                                      | Status | Details |
|-------------|--------------------------------------------------|--------|---------|
| 1 | Высокая нагрузка CPU | OK | trigger fired |
| 2 | HTTP flood на /fail500 (500 errors) | OK | trigger fired after HTTP flood |
| 3 | Отключение zbx-agent, собирающего метрики host3 | OK | trigger fired; service=zabbix-agent, duration=169s |
