#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
# shellcheck source=lib/app.sh
source "$SCRIPT_DIR/../lib/app.sh"
require_root
init_log
# user (Node.js) on port 8080. Uses MongoDB and Redis.

nodejs_app user "MONGO_URL=mongodb://$MONGODB_HOST:27017/users" "REDIS_URL=redis://$REDIS_HOST:6379"
log "${G}Done.${N} user on port 8080"
