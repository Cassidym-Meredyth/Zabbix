#!/usr/bin/env bash

URL="http://192.168.10.30/fail500"
DURATION=${1:-30}

end_time=$(( $(date +%s) + DURATION ))

while [ "$(date +%s)" -lt "${end_time}" ]; do
  code=$(curl -s -o /dev/null -w "%{http_code}\n" "$URL")
  logger -t "flood" "$code"
done
