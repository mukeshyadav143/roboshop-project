#!/usr/bin/env bash
# Helpers for RoboShop application services. Source after lib/common.sh.

APP_DIR=/app
APP_USER=roboshop
ENV_DIR=/etc/roboshop
ARTIFACT_BASE="${ARTIFACT_BASE:-https://roboshop-artifacts.s3.amazonaws.com}"
ARTIFACT_VERSION="${ARTIFACT_VERSION:-v3}"

# Where each tier lives. Defaults are the names the RoboShop apps use themselves;
# point them at real hostnames or IPs with environment variables.
MONGODB_HOST="${MONGODB_HOST:-mongodb}"
REDIS_HOST="${REDIS_HOST:-redis}"
MYSQL_HOST="${MYSQL_HOST:-mysql}"
RABBITMQ_HOST="${RABBITMQ_HOST:-rabbitmq}"
CATALOGUE_HOST="${CATALOGUE_HOST:-catalogue}"
USER_HOST="${USER_HOST:-user}"
CART_HOST="${CART_HOST:-cart}"
SHIPPING_HOST="${SHIPPING_HOST:-shipping}"
PAYMENT_HOST="${PAYMENT_HOST:-payment}"

# SKIP_SERVICE_START=1 installs and builds everything but starts nothing and
# loads no data. Useful for baking machine images (and for CI containers).
SKIP_SERVICE_START="${SKIP_SERVICE_START:-0}"

starting_services() { [ "$SKIP_SERVICE_START" != "1" ]; }

# require_env VAR...: stop unless each variable is set
require_env() {
    local v
    for v in "$@"; do
        [ -n "${!v:-}" ] || die "set $v first, for example: sudo $v=... bash $0"
    done
}

app_user() {
    if id "$APP_USER" >/dev/null 2>&1; then
        log "${Y}SKIP:${N} user $APP_USER exists"
    else
        run "creating user $APP_USER" useradd --system --home-dir "$APP_DIR" --shell /sbin/nologin "$APP_USER"
    fi
}

# app_download <component>: fresh copy of the component's code in /app
app_download() {
    local zip="/tmp/$1.zip"
    run "downloading $1" curl -fsSL -o "$zip" "$ARTIFACT_BASE/$1-$ARTIFACT_VERSION.zip"
    rm -rf "$APP_DIR"
    mkdir -p "$APP_DIR"
    run "unpacking $1" unzip -o -q "$zip" -d "$APP_DIR"
}

# write_env <component> <KEY=value...>: root-only environment file for the service
write_env() {
    local name="$1"
    shift
    mkdir -p "$ENV_DIR"
    (umask 077 && printf '%s\n' "$@" >"$ENV_DIR/$name.env")
    log "${G}OK:${N} wrote $ENV_DIR/$name.env"
}

# write_unit <component> <ExecStart> [User]: systemd service reading $ENV_DIR/<component>.env
write_unit() {
    cat >"/etc/systemd/system/$1.service" <<UNIT
[Unit]
Description=RoboShop $1 service
After=network-online.target
Wants=network-online.target

[Service]
User=${3:-$APP_USER}
WorkingDirectory=$APP_DIR
EnvironmentFile=$ENV_DIR/$1.env
ExecStart=$2
Restart=on-failure
SyslogIdentifier=$1

[Install]
WantedBy=multi-user.target
UNIT
    log "${G}OK:${N} wrote /etc/systemd/system/$1.service"
}

# start_service <unit>: enable and (re)start, unless SKIP_SERVICE_START=1
start_service() {
    if ! starting_services; then
        log "${Y}SKIP:${N} not starting $1 (SKIP_SERVICE_START=1)"
        return
    fi
    run "reloading systemd" systemctl daemon-reload
    run "enabling $1" systemctl enable "$1"
    run "starting $1" systemctl restart "$1"
}

# enable_module <name:stream>: switch a dnf module stream (nodejs:20, redis:7, nginx:1.24)
enable_module() {
    run "disabling default ${1%%:*} module" dnf module disable -y "${1%%:*}"
    run "enabling module $1" dnf module enable -y "$1"
}

mongodb_repo() {
    cat >/etc/yum.repos.d/mongodb-org-7.0.repo <<'REPO'
[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/9/mongodb-org/7.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-7.0.asc
REPO
    log "${G}OK:${N} added MongoDB 7.0 repo"
}

# Common setup for the three Node.js services
nodejs_app() {
    local name="$1"
    shift
    enable_module nodejs:20
    install_pkgs nodejs unzip
    app_user
    app_download "$name"
    run "installing npm dependencies" npm install --prefix "$APP_DIR" --omit=dev
    chown -R "$APP_USER:$APP_USER" "$APP_DIR"
    write_env "$name" "$@"
    write_unit "$name" "/usr/bin/node $APP_DIR/server.js"
    start_service "$name"
}
