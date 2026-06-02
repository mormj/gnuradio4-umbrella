#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/lib.sh"

root="$(gr4_repo_root)"
printf '[clean] removing %s/build and %s/install\n' "$root" "$root"
rm -rf "$root/build" "$root/install"
printf '[clean] leaving src/ in place. Remove it manually if needed.\n'
