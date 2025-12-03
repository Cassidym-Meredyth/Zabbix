#!/usr/bin/env bash
set -euo pipefail

cd /vagrant/monitor/zabbix/testing

REPORT_FILE="test_report.md"

# Заголовок таблицы
cat >> "$REPORT_FILE" <<EOF
# Тестирование триггеров
| Test Number | Description                                      | Status | Details |
|-------------|--------------------------------------------------|--------|---------|
EOF

run_test() {
  local num="$1"
  local desc="$2"
  local cmd="$3"

  local output
  if output=$($cmd 2>&1); then
    :
  else
    :
  fi

  local last_line
  last_line=$(echo "$output" | tail -n 1)

  local name desc_out status details
  name=$(echo "$last_line"    | cut -d'|' -f1 | xargs)
  desc_out=$(echo "$last_line"| cut -d'|' -f2 | xargs)
  status=$(echo "$last_line"  | cut -d'|' -f3 | xargs)
  details=$(echo "$last_line" | cut -d'|' -f4 | xargs)

  printf '| %s | %s | %s | %s |\n' "$num" "$desc_out" "$status" "$details" >> "$REPORT_FILE"

  echo "$last_line"
}

echo "NAME | DESCRIPTION | STATUS | DETAILS"

run_test 1 "Высокая нагрузка CPU" "./test_cpu_high.sh"
run_test 2 "HTTP flood на /fail500" "./test_ping_flood.sh"
run_test 3 "Случайное отключение контейнера" "./test_random_container.sh"

echo
echo "Отчёт записан в $REPORT_FILE"
