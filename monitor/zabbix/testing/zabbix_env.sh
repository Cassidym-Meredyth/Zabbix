# monitor/zabbix/zbx_env.sh
ZBX_URL="http://192.168.10.10/api_jsonrpc.php"
ZBX_USER="Zabbix API"
ZBX_PASS="grafana_api"

TIMEOUT=180
SLEEP_INT=10

log() { echo "[$(date +'%F %T')] $*"; }

zbx_login() {
  log "Login to Zabbix API..."
  local resp
  resp=$(curl -s -X POST -H 'Content-Type: application/json-rpc' \
    -d "{
      \"jsonrpc\": \"2.0\",
      \"method\": \"user.login\",
      \"params\": {\"user\": \"${ZBX_USER}\", \"password\": \"${ZBX_PASS}\"},
      \"id\": 1
    }" "${ZBX_URL}")
  ZBX_AUTH=$(echo "$resp" | jq -r '.result')
  if [[ -z "${ZBX_AUTH}" || "${ZBX_AUTH}" == "null" ]]; then
    echo "Failed to login to Zabbix API: $resp" >&2
    exit 1
  fi
  log "Got auth token"
}

zbx_api() {
  local method=$1
  local params=$2
  curl -s -X POST -H 'Content-Type: application/json-rpc' \
    -d "{
      \"jsonrpc\": \"2.0\",
      \"method\": \"${method}\",
      \"params\": ${params},
      \"auth\": \"${ZBX_AUTH}\",
      \"id\": 1
    }" "${ZBX_URL}"
}

get_trigger_id_by_desc() {
  local desc="$1"
  local resp
  resp=$(zbx_api "trigger.get" "{
    \"output\": [\"triggerid\",\"description\",\"value\"],
    \"filter\": {\"description\": [\"${desc}\"]}
  }")
  echo "$resp" | jq -r '.result[0].triggerid'
}

wait_trigger_problem() {
  local trig_desc="$1"
  local trig_id
  trig_id=$(get_trigger_id_by_desc "$trig_desc")
  if [[ -z "$trig_id" || "$trig_id" == "null" ]]; then
    log "Trigger '${trig_desc}' not found"
    return 1
  fi

  log "Waiting for trigger '${trig_desc}' (id=${trig_id}) to go PROBLEM..."
  local elapsed=0
  while (( elapsed < TIMEOUT )); do
    local resp value
    resp=$(zbx_api "trigger.get" "{
      \"output\": [\"triggerid\",\"value\"],
      \"triggerids\": [\"${trig_id}\"]
    }")
    value=$(echo "$resp" | jq -r '.result[0].value')
    if [[ "$value" == "1" ]]; then
      log "Trigger '${trig_desc}' is in PROBLEM state"
      return 0
    fi
    sleep "$SLEEP_INT"
    ((elapsed += SLEEP_INT))
  done

  log "Timeout waiting for trigger '${trig_desc}' PROBLEM state"
  return 1
}
