#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/lib.sh"

root="$(gr4_repo_root)"
smoke_src="$root/integration_smoke"
smoke_build="$root/build/integration_smoke"
install_prefix="$(gr4_component_install "$root")"
mkdir -p "$root/build"

generator_args=()
if [[ ! -f "$smoke_build/CMakeCache.txt" ]]; then
  if generator="$(gr4_choose_generator)"; [[ -n "${generator:-}" ]]; then
    generator_args+=(-G "$generator")
  fi
fi

printf '[smoke] configuring integration_smoke\n'
CMAKE_PREFIX_PATH="$install_prefix" cmake -S "$smoke_src" -B "$smoke_build" \
  "${generator_args[@]}"

printf '[smoke] building integration_smoke\n'
cmake --build "$smoke_build" --parallel "${GR4_BUILD_JOBS:-8}"

printf '[smoke] running integration_smoke\n'
"$smoke_build/integration_smoke"
