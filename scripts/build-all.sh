#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/lib.sh"

profile="${GR4_BUILD_PROFILE:-dev}"

usage() {
  cat <<'EOF'
Usage:
  scripts/build-all.sh [OPTIONS]

Options:
  --profile PROFILE   Use the named build profile (dev or release)
  --help              Show help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      shift
      profile="${1:-}"
      [[ -n "$profile" ]] || {
        printf 'error: --profile requires a value\n' >&2
        usage >&2
        exit 2
      }
      ;;
    --help)
      usage
      exit 0
      ;;
    --*)
      printf 'error: unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
    *)
      printf 'error: unexpected argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

root="$(gr4_repo_root)"
gr4_build_profile_validate "$root" "$profile"
printf '[build-all] profile: %s\n' "$profile"
"${root}/scripts/bootstrap.sh"

while IFS= read -r component; do
  [[ -n "$component" ]] || continue
  "${root}/scripts/build.sh" --profile "$profile" "$component"
done < <(gr4_repo_names "$root")
