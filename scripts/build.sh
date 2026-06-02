#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/lib.sh"

component="${1:-}"
if [[ -z "$component" ]]; then
  printf 'usage: %s <gnuradio4-core|gnuradio4-algorithm|gnuradio4-blocks>\n' "$0" >&2
  exit 2
fi

case "$component" in
  gnuradio4-core|gnuradio4-algorithm|gnuradio4-blocks) ;;
  *)
    printf 'unknown component: %s\n' "$component" >&2
    exit 2
    ;;
esac

root="$(gr4_repo_root)"
src_dir="$(gr4_component_src "$root" "$component")"
build_dir="$(gr4_component_build "$root" "$component")"
install_prefix="$(gr4_component_install "$root")"

if [[ ! -d "$src_dir" ]]; then
  printf 'source directory is missing: %s\nRun ./scripts/bootstrap.sh first.\n' "$src_dir" >&2
  exit 1
fi

mkdir -p "$build_dir"

mapfile -t common_args < <(gr4_read_args_file "$root/config/common.cmake.args")
mapfile -t component_args < <(gr4_read_args_file "$root/config/${component}.cmake.args")
mapfile -t fetchcontent_args < <(gr4_fetchcontent_args_for_component "$component")

generator_args=()
if [[ ! -f "$build_dir/CMakeCache.txt" ]]; then
  if generator="$(gr4_choose_generator)"; [[ -n "${generator:-}" ]]; then
    generator_args+=(-G "$generator")
  fi
fi

printf '[build] configuring %s\n' "$component"
CMAKE_PREFIX_PATH="$install_prefix" cmake -S "$src_dir" -B "$build_dir" \
  "${generator_args[@]}" \
  "${common_args[@]}" \
  "${component_args[@]}" \
  "${fetchcontent_args[@]}" \
  -DCMAKE_INSTALL_PREFIX="$install_prefix"

printf '[build] building %s\n' "$component"
cmake --build "$build_dir" --parallel "${GR4_BUILD_JOBS:-4}"

printf '[build] installing %s\n' "$component"
cmake --install "$build_dir"
