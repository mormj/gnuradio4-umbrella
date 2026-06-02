#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/lib.sh"

root="$(gr4_repo_root)"
for component in gnuradio4-core gnuradio4-algorithm gnuradio4-blocks; do
  build_dir="$(gr4_component_build "$root" "$component")"
  if [[ -d "$build_dir" ]]; then
    printf '[test] ctest %s\n' "$component"
    ctest --test-dir "$build_dir" --output-on-failure
  else
    printf '[test] skipping %s, build directory does not exist: %s\n' "$component" "$build_dir"
  fi
done

