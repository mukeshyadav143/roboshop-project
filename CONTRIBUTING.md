# Contributing

Thanks for helping. Bug reports, fixes and support for more distributions are all welcome.

## Before you open a pull request

1. Lint every script:
   ```bash
   shellcheck -x -P SCRIPTDIR/.. install.sh lib/*.sh services/*.sh tests/*.sh shell-scripting/*.sh
   ```
2. If you changed anything in `services/` or `lib/`, run the end-to-end test (needs Docker):
   ```bash
   bash tests/e2e.sh
   ```
3. Keep scripts safe to run twice: check before you create or install something.

## Style

- Use the helpers in `lib/common.sh` and `lib/app.sh` (`run`, `install_pkgs`, `log`, `die`) instead of raw commands, so every step is logged and failures stop the script.
- Secrets go in `/etc/roboshop/<service>.env` through `write_env`, never in unit files or logs.
- New settings are environment variables with a sensible default, documented in the README table.

## Reporting a bug

Open an issue with your OS version, the command you ran, and the matching lines from `/var/log/roboshop/<script>.log`.
