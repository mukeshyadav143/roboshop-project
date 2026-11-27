#!/usr/bin/env bash
# Shared helpers for RoboShop setup scripts. Source this file; do not run it.

# shellcheck disable=SC2034  # colours are used by scripts that source this file
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_DIR="${LOG_DIR:-/var/log/roboshop}"
LOG_FILE="${LOG_FILE:-$LOG_DIR/$(basename "$0" .sh).log}"

log() {
    local msg
    msg="$(date '+%F %T') $*"
    echo -e "$msg"
    echo -e "$msg" >>"$LOG_FILE"
}

die() {
    log "${R}ERROR:${N} $*"
    exit 1
}

require_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${R}ERROR:${N} run this script as root, for example: sudo $0" >&2
        exit 1
    fi
}

init_log() {
    mkdir -p "$LOG_DIR" || die "cannot create $LOG_DIR"
    touch "$LOG_FILE" || die "cannot write $LOG_FILE"
}

# validate <exit-code> <description>
validate() {
    if [ "$1" -ne 0 ]; then
        die "$2 failed (see $LOG_FILE)"
    fi
    log "${G}OK:${N} $2"
}

# run <description> <command...>: run quietly, output to the log, stop on failure
run() {
    local desc="$1"
    shift
    "$@" >>"$LOG_FILE" 2>&1
    validate $? "$desc"
}

# install_pkgs <package...>: dnf install, skipping packages already present
install_pkgs() {
    local pkg
    for pkg in "$@"; do
        if is_installed "$pkg"; then
            log "${Y}SKIP:${N} $pkg is already installed"
        else
            run "installing $pkg" dnf install -y "$pkg"
        fi
    done
}

is_installed() {
    rpm -q "$1" >/dev/null 2>&1
}
