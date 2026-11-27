#!/usr/bin/env bash
# End-to-end test: deploy every RoboShop tier into its own systemd container on one
# Docker network (container names are the hostnames the apps expect), then check
# the shop through the frontend. Needs Docker. KEEP=1 leaves the containers running.

set -euo pipefail
cd "$(dirname "$0")/.."

IMAGE=roboshop-e2e
NET=roboshop-e2e
SERVICES=(mongodb redis mysql rabbitmq catalogue user cart shipping payment dispatch frontend)
SECRETS=(-e MYSQL_ROOT_PASSWORD=e2e-only-Pass1 -e RABBITMQ_USER=roboshop -e RABBITMQ_PASS=e2e-only-pass)
UNITS=(mongod redis mysqld rabbitmq-server catalogue user cart shipping payment dispatch nginx)

cleanup() {
    [ "${KEEP:-0}" = 1 ] && { echo "Containers kept. Shop: docker exec frontend curl localhost"; return; }
    docker rm -f "${SERVICES[@]}" >/dev/null 2>&1 || true
    docker network rm "$NET" >/dev/null 2>&1 || true
}
trap cleanup EXIT

dump_logs() {
    local i
    for i in "${!SERVICES[@]}"; do
        echo "::group::journal ${SERVICES[$i]} (${UNITS[$i]})"
        docker exec "${SERVICES[$i]}" journalctl -u "${UNITS[$i]}" --no-pager -n 40 || true
        echo "::endgroup::"
    done
}

fail() {
    echo "FAIL: $*"
    dump_logs
    exit 1
}

echo "Building test image"
docker build -q -t "$IMAGE" -f tests/Containerfile tests >/dev/null
docker network create "$NET" >/dev/null

for s in "${SERVICES[@]}"; do
    docker run -d --name "$s" --hostname "$s" --network "$NET" \
        --privileged --cgroupns=host -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
        -v "$PWD:/src:ro" "$IMAGE" >/dev/null
done
for s in "${SERVICES[@]}"; do
    docker exec "$s" systemctl is-system-running --wait >/dev/null 2>&1 || true
done

for s in "${SERVICES[@]}"; do
    echo "::group::deploy $s"
    if ! docker exec "${SECRETS[@]}" "$s" bash "/src/services/$s.sh"; then
        docker exec "$s" cat "/var/log/roboshop/$s.log" || true
        echo "::endgroup::"
        fail "services/$s.sh"
    fi
    echo "::endgroup::"
done

api() { docker exec frontend curl -fsS -m 10 "http://localhost/api/$1"; }

wait_for() {
    local i
    for i in $(seq 1 60); do
        api "$1" >/dev/null 2>&1 && { echo "PASS /api/$1"; return; }
        sleep 5
    done
    fail "/api/$1 did not answer within 5 minutes"
}

for path in catalogue/health user/health cart/health shipping/health payment/health; do
    wait_for "$path"
done

api catalogue/products | grep -q '"sku":"Watson"' || fail "catalogue has no product data"
echo "PASS catalogue serves products from MongoDB"

count="$(api shipping/count)"
[ "${count:-0}" -gt 0 ] 2>/dev/null || fail "shipping has no city data (got: $count)"
echo "PASS shipping serves $count cities from MySQL"

api user/uniqueid | grep -q uuid || fail "user could not get an id from Redis"
echo "PASS user gets ids from Redis"

docker exec frontend curl -fsS -m 10 http://localhost/ | grep -qi '<html' || fail "frontend page"
echo "PASS frontend serves the shop"

docker exec dispatch systemctl is-active --quiet dispatch || fail "dispatch is not running"
echo "PASS dispatch is running"

echo "All end-to-end checks passed."
