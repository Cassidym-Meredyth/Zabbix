#!/bin/bash

URL="http://192.168.20.30/fail500"


code=$(curl -s -o /dev/null -w "%{http_code}\n" "$URL")

logger -t "fail500" "$code"


