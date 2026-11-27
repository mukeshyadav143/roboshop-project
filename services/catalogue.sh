#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
# shellcheck source=lib/app.sh
source "$SCRIPT_DIR/../lib/app.sh"
require_root
init_log
# catalogue (Node.js) on port 8080. Loads product data into MongoDB once.

nodejs_app catalogue "MONGO_URL=mongodb://$MONGODB_HOST:27017/catalogue"
mongodb_repo
install_pkgs mongodb-mongosh
if starting_services; then
    if [ "$(mongosh --host "$MONGODB_HOST" --quiet --eval 'db.getMongo().getDBNames().indexOf("catalogue")')" -ge 0 ]; then
        log "${Y}SKIP:${N} catalogue data already loaded"
    else
        run "loading product data" mongosh --host "$MONGODB_HOST" --file "$APP_DIR/db/master-data.js"
    fi
fi
log "${G}Done.${N} catalogue on port 8080"
