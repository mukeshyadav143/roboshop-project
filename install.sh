#!/usr/bin/env bash
# Install packages with dnf on RHEL-family Linux. Skips packages that are
# already installed, logs every step, and stops at the first failure.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

DEFAULT_PACKAGES=(mysql nginx python3)
DRY_RUN=0

usage() {
    cat <<EOF
Usage: sudo $0 [-n] [package ...]

Install packages with dnf. Already-installed packages are skipped.
With no packages given, installs: ${DEFAULT_PACKAGES[*]}

Options:
  -n    dry run: show what would be installed, change nothing
  -h    show this help

Logs go to $LOG_FILE (set LOG_DIR to change the folder).
EOF
}

while getopts ":nh" opt; do
    case "$opt" in
        n) DRY_RUN=1 ;;
        h) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
done
shift $((OPTIND - 1))

packages=("$@")
[ ${#packages[@]} -eq 0 ] && packages=("${DEFAULT_PACKAGES[@]}")

command -v dnf >/dev/null 2>&1 || { echo -e "${R}ERROR:${N} dnf not found. This script targets RHEL, Rocky, Alma, CentOS Stream and Fedora." >&2; exit 1; }

if [ "$DRY_RUN" -eq 1 ]; then
    for pkg in "${packages[@]}"; do
        if is_installed "$pkg"; then
            echo -e "${Y}SKIP:${N} $pkg is already installed"
        else
            echo "WOULD INSTALL: $pkg"
        fi
    done
    exit 0
fi

require_root
init_log
log "Installing: ${packages[*]}"

for pkg in "${packages[@]}"; do
    if is_installed "$pkg"; then
        log "${Y}SKIP:${N} $pkg is already installed"
        continue
    fi
    dnf install -y "$pkg" >>"$LOG_FILE" 2>&1
    validate $? "installing $pkg"
done

log "${G}Done.${N}"
