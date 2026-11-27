#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
# shellcheck source=lib/app.sh
source "$SCRIPT_DIR/../lib/app.sh"
require_root
init_log
# MongoDB 7.0, listening on all interfaces for catalogue and user.

mongodb_repo
install_pkgs mongodb-org
run "listening on all interfaces" sed -i 's/^\(\s*bindIp:\).*/\1 0.0.0.0/' /etc/mongod.conf
start_service mongod
log "${G}Done.${N} MongoDB on port 27017"
