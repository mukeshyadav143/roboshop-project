# roboshop-project

Shell scripting practice for deploying RoboShop, a sample microservices e-commerce app, on RHEL-family Linux (dnf). This is a personal DevOps learning repo.

## Scripts

| File | What it does |
|---|---|
| `shell-scripting/installations.sh` | Checks for root, then installs mysql, nginx and python3 with dnf and reports success or failure for each |
| `shell-scripting/variables.sh` | Variables and string interpolation |
| `shell-scripting/data-types.sh` | Bash arrays and indexing |
| `shell-scripting/conditons.sh` | if/elif comparisons and an even/odd check on user input |
| `shell-scripting/special-variables.sh` | Special variables: `$0`, `$@`, `$$`, `$!`, `$?`, `$-` |

## Run

`sudo bash shell-scripting/installations.sh`

The install script must run as root. It stops at the first package that fails to install.

## Status

Work in progress. The next step is install scripts for each RoboShop service.
