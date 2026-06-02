#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/lib.sh"

profile="${GR4_BUILD_PROFILE:-dev}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      shift
      profile="${1:-}"
      [[ -n "$profile" ]] || {
        printf 'error: --profile requires a value\n' >&2
        exit 2
      }
      ;;
    --help)
      printf 'Usage: %s [--profile PROFILE]\n' "$0" >&2
      exit 0
      ;;
    *)
      printf 'error: unknown option: %s\n' "$1" >&2
      exit 2
      ;;
  esac
  shift
done

root="$(gr4_repo_root)"
gr4_build_profile_validate "$root" "$profile"
printf '[test-all] profile: %s\n' "$profile"
while IFS= read -r component; do
  [[ -n "$component" ]] || continue
  build_dir="$(gr4_component_build "$root" "$profile" "$component")"
  if [[ -d "$build_dir" ]]; then
    printf '[test] ctest %s\n' "$component"
    ctest --test-dir "$build_dir" --output-on-failure
  else
    printf '[test] skipping %s, build directory does not exist: %s\n' "$component" "$build_dir"
  fi
done < <(gr4_repo_names "$root")
