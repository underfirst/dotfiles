#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v mise >/dev/null 2>&1; then
  echo "mise is required. Install mise first, then rerun setup.sh." >&2
  exit 1
fi

exec mise -C "$ROOT_DIR" run setup
