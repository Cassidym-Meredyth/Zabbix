| Test Number | Description                                      | Status | Details |
|-------------|--------------------------------------------------|--------|---------|
| 1 | Высокая нагрузка CPU | OK | trigger fired |
| 2 | HTTP flood на /fail500 (500 errors) | OK | trigger fired after HTTP flood |
| 3 | Отключение zabbix-agent в контейнере app1 | OK | trigger fired; service=app1, duration=164s |
