#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
# shellcheck source=lib/app.sh
source "$SCRIPT_DIR/../lib/app.sh"
require_root
init_log
# MySQL 8 for shipping. Needs MYSQL_ROOT_PASSWORD.

require_env MYSQL_ROOT_PASSWORD
install_pkgs mysql-server
start_service mysqld
case "$MYSQL_ROOT_PASSWORD" in *"'"*|*\\*) die "MYSQL_ROOT_PASSWORD must not contain ' or \\" ;; esac
if starting_services; then
    if MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot -e 'SELECT 1' >/dev/null 2>&1; then
        log "${Y}SKIP:${N} root password already set"
    else
        # Fresh RHEL-family installs let root in without a password. Set it, and
        # allow root over the network so shipping can load its data.
        run "setting root password" mysql -uroot -e "
            ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
            CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
            GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
            FLUSH PRIVILEGES;"
    fi
fi
log "${G}Done.${N} MySQL on port 3306"
