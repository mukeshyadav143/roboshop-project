#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
# shellcheck source=lib/app.sh
source "$SCRIPT_DIR/../lib/app.sh"
require_root
init_log
# frontend: Nginx serving the web UI on port 80 and proxying /api/* to the services.

enable_module nginx:1.24
install_pkgs nginx unzip
run "downloading frontend" curl -fsSL -o /tmp/frontend.zip "$ARTIFACT_BASE/frontend-$ARTIFACT_VERSION.zip"
rm -rf /usr/share/nginx/html
mkdir -p /usr/share/nginx/html
run "unpacking frontend" unzip -o -q /tmp/frontend.zip -d /usr/share/nginx/html
cat >/etc/nginx/default.d/roboshop.conf <<CONF
proxy_http_version 1.1;
location /images/ {
    expires 5s;
    root /usr/share/nginx/html;
    try_files \$uri /images/placeholder.jpg;
}
location /api/catalogue/ { proxy_pass http://$CATALOGUE_HOST:8080/; }
location /api/user/      { proxy_pass http://$USER_HOST:8080/; }
location /api/cart/      { proxy_pass http://$CART_HOST:8080/; }
location /api/shipping/  { proxy_pass http://$SHIPPING_HOST:8080/; }
location /api/payment/   { proxy_pass http://$PAYMENT_HOST:8080/; }
location /health {
    stub_status on;
    access_log off;
}
CONF
log "${G}OK:${N} wrote /etc/nginx/default.d/roboshop.conf"
run "checking nginx config" nginx -t
start_service nginx
log "${G}Done.${N} frontend on port 80"
