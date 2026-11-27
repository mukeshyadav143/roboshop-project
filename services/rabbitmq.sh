#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
# shellcheck source=lib/app.sh
source "$SCRIPT_DIR/../lib/app.sh"
require_root
init_log
# RabbitMQ for payment and dispatch. Needs RABBITMQ_USER and RABBITMQ_PASS.

require_env RABBITMQ_USER RABBITMQ_PASS
cat >/etc/yum.repos.d/rabbitmq.repo <<'REPO'
[rabbitmq-erlang]
name=RabbitMQ Erlang
baseurl=https://yum1.rabbitmq.com/erlang/el/9/$basearch
gpgcheck=1
gpgkey=https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key
repo_gpgcheck=1
enabled=1

[rabbitmq-server]
name=RabbitMQ Server
baseurl=https://yum1.rabbitmq.com/rabbitmq/el/9/noarch
gpgcheck=1
gpgkey=https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key
       https://github.com/rabbitmq/signing-keys/releases/download/3.0/rabbitmq-release-signing-key.asc
repo_gpgcheck=1
enabled=1
REPO
log "${G}OK:${N} added RabbitMQ repos"
install_pkgs erlang rabbitmq-server
start_service rabbitmq-server
if starting_services; then
    if rabbitmqctl list_users -q | awk '{print $1}' | grep -qx "$RABBITMQ_USER"; then
        run "updating password for $RABBITMQ_USER" rabbitmqctl change_password "$RABBITMQ_USER" "$RABBITMQ_PASS"
    else
        run "adding user $RABBITMQ_USER" rabbitmqctl add_user "$RABBITMQ_USER" "$RABBITMQ_PASS"
    fi
    run "granting permissions" rabbitmqctl set_permissions -p / "$RABBITMQ_USER" ".*" ".*" ".*"
fi
log "${G}Done.${N} RabbitMQ on port 5672"
