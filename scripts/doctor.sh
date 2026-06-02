#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/lib.sh"

root="$(gr4_repo_root)"

printf '[doctor] workspace root: %s\n' "$root"
for tool in cmake git c++; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf '[doctor] found %s: %s\n' "$tool" "$(command -v "$tool")"
  else
    printf '[doctor] missing required tool: %s\n' "$tool" >&2
    exit 1
  fi
done

for optional in ninja python3; do
  if command -v "$optional" >/dev/null 2>&1; then
    printf '[doctor] found optional %s: %s\n' "$optional" "$(command -v "$optional")"
  else
    printf '[doctor] optional tool not found: %s\n' "$optional"
  fi
done

for dep in UT VIR_SIMD; do
  if source_dir="$(gr4_locate_cached_fetchcontent_source "$dep" || true)"; [[ -n "${source_dir:-}" ]]; then
    printf '[doctor] cached FetchContent source for %s: %s\n' "$dep" "$source_dir"
  else
    printf '[doctor] no cached FetchContent source found for %s\n' "$dep"
  fi
done

for component in gnuradio4-core gnuradio4-algorithm gnuradio4-blocks; do
  src_dir="$(gr4_component_src "$root" "$component")"
  if [[ -e "$src_dir" ]]; then
    printf '[doctor] source ready: %s\n' "$src_dir"
  else
    printf '[doctor] source missing: %s\n' "$src_dir"
  fi
done

if [[ -d "$root/install" ]]; then
  printf '[doctor] install prefix exists: %s\n' "$root/install"
else
  printf '[doctor] install prefix will be created at: %s\n' "$root/install"
fi

printf '[doctor] next steps:\n'
printf '  ./scripts/bootstrap.sh\n'
printf '  source ./scripts/dev-env.sh\n'
printf '  ./scripts/build-all.sh\n'
printf '  ./scripts/test-all.sh\n'
printf '  ./scripts/integration-smoke.sh\n'
