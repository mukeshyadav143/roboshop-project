#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
# shellcheck source=lib/app.sh
source "$SCRIPT_DIR/../lib/app.sh"
require_root
init_log
# dispatch (Go). Consumes orders from RabbitMQ. Needs RABBITMQ_USER and RABBITMQ_PASS.

require_env RABBITMQ_USER RABBITMQ_PASS
install_pkgs golang unzip
app_user
app_download dispatch
run "creating go module" sh -c "cd '$APP_DIR' && go mod init dispatch"
run "downloading go dependencies" sh -c "cd '$APP_DIR' && go get"
run "building dispatch" sh -c "cd '$APP_DIR' && go build -o dispatch"
chown -R "$APP_USER:$APP_USER" "$APP_DIR"
write_env dispatch "AMQP_HOST=$RABBITMQ_HOST" "AMQP_USER=$RABBITMQ_USER" "AMQP_PASS=$RABBITMQ_PASS"
write_unit dispatch "$APP_DIR/dispatch"
start_service dispatch
log "${G}Done.${N} dispatch"
