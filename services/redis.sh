#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
# shellcheck source=lib/app.sh
source "$SCRIPT_DIR/../lib/app.sh"
require_root
init_log
# Redis 7, reachable from user and cart.

enable_module redis:7
install_pkgs redis
run "listening on all interfaces" sed -i -e 's/^bind .*/bind 0.0.0.0/' -e 's/^protected-mode .*/protected-mode no/' /etc/redis/redis.conf
start_service redis
log "${G}Done.${N} Redis on port 6379"
