#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

echo "Apply mise bootstrap packages."
mise --yes bootstrap packages apply --update

echo "Install mise tools."
mise install

exec bash "$ROOT_DIR/scripts/setup/common.sh"
