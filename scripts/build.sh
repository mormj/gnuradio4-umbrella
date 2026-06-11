#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/lib.sh"

profile="${GR4_BUILD_PROFILE:-dev}"
component=""

usage() {
  cat <<'EOF'
Usage:
  scripts/build.sh [OPTIONS] <component-name>

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
      if [[ -z "$component" ]]; then
        component="$1"
      else
        printf 'error: unexpected extra argument: %s\n' "$1" >&2
        usage >&2
        exit 2
      fi
      ;;
  esac
  shift
done

if [[ -z "$component" ]]; then
  usage >&2
  printf 'known components:\n' >&2
  gr4_repo_names "$(gr4_repo_root)" >&2
  exit 2
fi

root="$(gr4_repo_root)"
gr4_build_profile_validate "$root" "$profile"
if ! gr4_known_repo "$root" "$component"; then
  printf 'unknown component: %s\n' "$component" >&2
  printf 'known components:\n' >&2
  gr4_repo_names "$root" >&2
  exit 2
fi

src_dir="$(gr4_component_src "$root" "$component")"
build_dir="$(gr4_component_build "$root" "$profile" "$component")"
install_prefix="$(gr4_component_install "$root" "$profile")"
cmake_source="$(gr4_build_profile_component_cmake_source "$root" "$profile" "$component")"

if [[ ! -d "$src_dir" ]]; then
  printf 'source directory is missing: %s\nRun ./scripts/bootstrap.sh first.\n' "$src_dir" >&2
  exit 1
fi

if [[ ! -f "$src_dir/CMakeLists.txt" && -f "$src_dir/package.json" ]]; then
  printf '[build] profile: %s\n' "$profile"
  printf '[build] npm project: %s\n' "$component"
  if [[ ! -d "$src_dir/node_modules" ]]; then
    printf '[build] installing npm dependencies for %s\n' "$component"
    (cd "$src_dir" && npm ci)
  fi
  printf '[build] building %s\n' "$component"
  (cd "$src_dir" && GR4_PREFIX_PATH="$install_prefix" GR4_PREFIX="$install_prefix" npm run build)
  if [[ -n "$cmake_source" ]]; then
    cmake_src_dir="$src_dir/$cmake_source"
    cmake_build_dir="$build_dir/$cmake_source"
    if [[ ! -f "$cmake_src_dir/CMakeLists.txt" ]]; then
      printf 'configured CMake source for %s is missing CMakeLists.txt: %s\n' "$component" "$cmake_src_dir" >&2
      exit 1
    fi
    mkdir -p "$cmake_build_dir"
    mapfile -t cmake_args < <(gr4_build_profile_cmake_args "$root" "$profile" "$component")
    generator_args=()
    if [[ ! -f "$cmake_build_dir/CMakeCache.txt" ]]; then
      generator="$(gr4_build_profile_generator "$root" "$profile")"
      if [[ -z "${generator:-}" ]]; then
        generator="$(gr4_choose_generator)"
      fi
      if [[ -n "${generator:-}" ]]; then
        generator_args+=(-G "$generator")
      fi
    fi
    printf '[build] configuring %s (%s)\n' "$component" "$cmake_source"
    PATH="$install_prefix/bin:${PATH:-}" \
      CMAKE_PREFIX_PATH="$install_prefix" \
      PKG_CONFIG_PATH="$install_prefix/lib/pkgconfig:$install_prefix/lib64/pkgconfig:$install_prefix/share/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}" \
      cmake -S "$cmake_src_dir" -B "$cmake_build_dir" \
        "${generator_args[@]}" \
        "${cmake_args[@]}" \
        -DCMAKE_INSTALL_PREFIX="$install_prefix"
    printf '[build] building %s (%s)\n' "$component" "$cmake_source"
    cmake --build "$cmake_build_dir" --parallel "${GR4_BUILD_JOBS:-6}"
    printf '[build] installing %s (%s)\n' "$component" "$cmake_source"
    cmake --install "$cmake_build_dir"
  fi
  exit 0
fi

if [[ -n "$cmake_source" ]]; then
  src_dir="$src_dir/$cmake_source"
  build_dir="$build_dir/$cmake_source"
fi

if [[ ! -f "$src_dir/CMakeLists.txt" ]]; then
  printf 'unsupported build layout for %s: expected CMakeLists.txt or package.json in %s\n' "$component" "$src_dir" >&2
  exit 1
fi

mkdir -p "$build_dir"

mapfile -t cmake_args < <(gr4_build_profile_cmake_args "$root" "$profile" "$component")

generator_args=()
if [[ ! -f "$build_dir/CMakeCache.txt" ]]; then
  generator="$(gr4_build_profile_generator "$root" "$profile")"
  if [[ -z "${generator:-}" ]]; then
    generator="$(gr4_choose_generator)"
  fi
  if [[ -n "${generator:-}" ]]; then
    generator_args+=(-G "$generator")
  fi
fi

printf '[build] profile: %s\n' "$profile"
printf '[build] configuring %s\n' "$component"
CMAKE_PREFIX_PATH="$install_prefix" cmake -S "$src_dir" -B "$build_dir" \
  "${generator_args[@]}" \
  "${cmake_args[@]}" \
  -DCMAKE_INSTALL_PREFIX="$install_prefix"

printf '[build] building %s\n' "$component"
cmake --build "$build_dir" --parallel "${GR4_BUILD_JOBS:-6}"

printf '[build] installing %s\n' "$component"
cmake --install "$build_dir"
