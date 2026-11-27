#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
# shellcheck source=lib/app.sh
source "$SCRIPT_DIR/../lib/app.sh"
require_root
init_log
# shipping (Java, Spring Boot) on port 8080. Builds with Maven, loads city data
# into MySQL once. Needs MYSQL_ROOT_PASSWORD unless SKIP_SERVICE_START=1.

starting_services && require_env MYSQL_ROOT_PASSWORD
install_pkgs maven unzip mysql
app_user
app_download shipping
run "building with maven (takes a few minutes)" mvn -q -f "$APP_DIR/pom.xml" clean package -DskipTests
run "placing shipping.jar" mv "$APP_DIR/target/shipping-1.0.jar" "$APP_DIR/shipping.jar"
chown -R "$APP_USER:$APP_USER" "$APP_DIR"
write_env shipping "CART_ENDPOINT=$CART_HOST:8080" "DB_HOST=$MYSQL_HOST"
write_unit shipping "/usr/bin/java -jar $APP_DIR/shipping.jar"
export MYSQL_PWD="${MYSQL_ROOT_PASSWORD:-}"
if starting_services; then
    if mysql -h "$MYSQL_HOST" -uroot -e 'USE cities' >/dev/null 2>&1; then
        log "${Y}SKIP:${N} cities data already loaded"
    else
        for f in schema app-user master-data; do
            run "loading $f.sql" sh -c "mysql -h '$MYSQL_HOST' -uroot < '$APP_DIR/db/$f.sql'"
        done
    fi
fi
start_service shipping
log "${G}Done.${N} shipping on port 8080"
