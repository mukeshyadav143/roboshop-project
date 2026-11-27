# roboshop-project

[![CI](https://github.com/mukeshyadav143/roboshop-project/actions/workflows/ci.yml/badge.svg)](https://github.com/mukeshyadav143/roboshop-project/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Bash scripts for setting up servers for RoboShop, a sample microservices e-commerce app, on RHEL-family Linux (RHEL, Rocky, Alma, CentOS Stream, Fedora).

## install.sh

Installs packages with `dnf`, safely enough to run again and again:

- skips packages that are already installed
- logs every step to `/var/log/roboshop/install.log`
- stops at the first failure and points you to the log
- `-n` dry run shows what would change without touching the system

```bash
git clone https://github.com/mukeshyadav143/roboshop-project.git
cd roboshop-project

bash install.sh -n nginx          # dry run
sudo bash install.sh nginx redis  # install specific packages
sudo bash install.sh              # default set: mysql nginx python3
```

Example output:

```text
2026-11-27 10:00:01 Installing: nginx redis
2026-11-27 10:00:01 SKIP: nginx is already installed
2026-11-27 10:00:19 OK: installing redis
2026-11-27 10:00:19 Done.
```

Set `LOG_DIR` to log somewhere else: `sudo LOG_DIR=/tmp/roboshop bash install.sh`.

## Reuse the helpers

`lib/common.sh` holds the shared functions. Source it in your own scripts:

| Function | What it does |
|---|---|
| `require_root` | Exits unless running as root |
| `init_log` | Creates the log folder and file |
| `log "msg"` | Prints a timestamped line and appends it to the log |
| `validate $? "step"` | Logs OK, or logs the error and exits |
| `is_installed pkg` | True if the RPM package is installed |
| `die "msg"` | Logs an error and exits |

## Shell scripting examples

`shell-scripting/` holds short examples I wrote while learning Bash: variables, arrays, conditions, special variables (`$0`, `$@`, `$$`, `$?`) and the first version of the installer.

## Tests

CI runs on every push:

- [ShellCheck](https://www.shellcheck.net/) on every script
- `install.sh` in a Rocky Linux 9 container: dry run changes nothing, a real install works, a second run skips the package, and an unknown package fails

## Roadmap

- Per-service setup scripts for the RoboShop components (MongoDB, Redis, MySQL, RabbitMQ, catalogue, user, cart, shipping, payment, frontend)

## License

[MIT](LICENSE)
