#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/lib.sh"

root="$(gr4_repo_root)"
install_prefix="$(gr4_component_install "$root")"
printf '[clean] removing %s/build and %s\n' "$root" "$install_prefix"
rm -rf "$root/build" "$install_prefix"
printf '[clean] leaving src/ in place. Remove it manually if needed.\n'
