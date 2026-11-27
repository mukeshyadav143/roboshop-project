#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
# shellcheck source=lib/app.sh
source "$SCRIPT_DIR/../lib/app.sh"
require_root
init_log
# cart (Node.js) on port 8080. Uses Redis and catalogue.

nodejs_app cart "REDIS_HOST=$REDIS_HOST" "CATALOGUE_HOST=$CATALOGUE_HOST" "CATALOGUE_PORT=8080"
log "${G}Done.${N} cart on port 8080"
