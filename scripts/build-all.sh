#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/lib.sh"

root="$(gr4_repo_root)"
"${root}/scripts/bootstrap.sh"

for component in gnuradio4-core gnuradio4-algorithm gnuradio4-blocks; do
  "${root}/scripts/build.sh" "$component"
done

