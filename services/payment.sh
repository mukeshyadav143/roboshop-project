#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
# shellcheck source=lib/app.sh
source "$SCRIPT_DIR/../lib/app.sh"
require_root
init_log
# payment (Python, uWSGI) on port 8080. Uses cart, user and RabbitMQ.
# Needs RABBITMQ_USER and RABBITMQ_PASS.

require_env RABBITMQ_USER RABBITMQ_PASS
install_pkgs python3 python3-devel python3-pip gcc unzip
app_user
app_download payment
run "installing python dependencies" pip3 install -r "$APP_DIR/requirements.txt"
run "running uwsgi as $APP_USER" sed -i -e "s/^uid = .*/uid = $APP_USER/" -e "s/^gid = .*/gid = $APP_USER/" "$APP_DIR/payment.ini"
chown -R "$APP_USER:$APP_USER" "$APP_DIR"
write_env payment "CART_HOST=$CART_HOST" "CART_PORT=8080" "USER_HOST=$USER_HOST" "USER_PORT=8080" \
    "AMQP_HOST=$RABBITMQ_HOST" "AMQP_USER=$RABBITMQ_USER" "AMQP_PASS=$RABBITMQ_PASS"
# uWSGI starts as root and drops to $APP_USER itself (uid/gid in payment.ini)
write_unit payment "/usr/local/bin/uwsgi --ini $APP_DIR/payment.ini" root
start_service payment
log "${G}Done.${N} payment on port 8080"
