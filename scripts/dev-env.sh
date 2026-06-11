#!/usr/bin/env bash
# shellcheck shell=bash

# This script is intended to be sourced:
#   source scripts/dev-env.sh

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "error: source this script instead of executing it" >&2
  echo "usage: source scripts/dev-env.sh" >&2
  exit 1
fi

if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
  script_path="${BASH_SOURCE[0]}"
else
  script_path="$0"
fi

script_dir="$(cd "$(dirname "${script_path}")" && pwd)"
source "${script_dir}/lib.sh"

root="$(gr4_repo_root)"
env_file="${root}/.env"

set -a

# Defaults. Copy .env.example to .env to override these locally.
GR4_ENV_NAME="${GR4_ENV_NAME:-local}"
GR4_SRC_DIR="${GR4_SRC_DIR:-src}"
GR4_LLVM_ROOT="${GR4_LLVM_ROOT:-}"
GR4_CC="${GR4_CC:-}"
GR4_CXX="${GR4_CXX:-}"
GR4_PKGCONF="${GR4_PKGCONF:-pkgconf}"
GR4_LOG_LEVEL="${GR4_LOG_LEVEL:-info}"
GR4_DEBUG="${GR4_DEBUG:-0}"

if [[ -f "$env_file" ]]; then
  # shellcheck disable=SC1090
  source "$env_file"
fi

GR4_BUILD_PROFILE="${GR4_BUILD_PROFILE:-dev}"
GR4_BUILD_DIR="${GR4_BUILD_DIR:-build/${GR4_BUILD_PROFILE}}"
GR4_PREFIX_DIR="${GR4_PREFIX_DIR:-install/${GR4_BUILD_PROFILE}}"

export GR4_ROOT_DIR="$root"
export GR4_WORKSPACE_ROOT="$root"
export GR4_SRC_PATH="${root}/${GR4_SRC_DIR}"
export GR4_BUILD_PATH="${root}/${GR4_BUILD_DIR}"
export GR4_PREFIX_PATH="${root}/${GR4_PREFIX_DIR}"
export GR4_PREFIX="$GR4_PREFIX_PATH"

mkdir -p "$GR4_SRC_PATH" "$GR4_BUILD_PATH" "$GR4_PREFIX_PATH" "$root/var/logs" "$root/var/run"

prepend_path() {
  local dir="$1"
  case ":${PATH}:" in
    *":${dir}:"*) ;;
    *) PATH="${dir}${PATH:+:${PATH}}" ;;
  esac
}

prepend_colon_path() {
  local var_name="$1"
  local dir="$2"
  local current

  eval "current=\${${var_name}:-}"
  case ":${current}:" in
    *":${dir}:"*) ;;
    *) eval "export ${var_name}=\"${dir}\${current:+:\${current}}\"" ;;
  esac
}

prepend_flags() {
  local var_name="$1"
  local flag="$2"
  local current

  eval "current=\${${var_name}:-}"
  case " ${current} " in
    *" ${flag} "*) ;;
    *) eval "export ${var_name}=\"${flag}\${current:+ \${current}}\"" ;;
  esac
}

if [[ -n "$GR4_LLVM_ROOT" && -d "${GR4_LLVM_ROOT}/bin" ]]; then
  prepend_path "${GR4_LLVM_ROOT}/bin"
fi

if [[ -n "$GR4_CC" ]]; then
  if [[ -n "$GR4_LLVM_ROOT" && "$GR4_CC" == "clang" && -x "${GR4_LLVM_ROOT}/bin/clang" ]]; then
    GR4_CC="${GR4_LLVM_ROOT}/bin/clang"
  fi
  export CC="$GR4_CC"
  export CMAKE_C_COMPILER="$CC"
else
  unset CC CMAKE_C_COMPILER
fi

if [[ -n "$GR4_CXX" ]]; then
  if [[ -n "$GR4_LLVM_ROOT" && "$GR4_CXX" == "clang++" && -x "${GR4_LLVM_ROOT}/bin/clang++" ]]; then
    GR4_CXX="${GR4_LLVM_ROOT}/bin/clang++"
  fi
  export CXX="$GR4_CXX"
  export CMAKE_CXX_COMPILER="$CXX"
else
  unset CXX CMAKE_CXX_COMPILER
fi

export PKGCONF="$GR4_PKGCONF"
export PKG_CONFIG="$PKGCONF"

prepend_path "${GR4_PREFIX_PATH}/bin"
export PATH

if [[ "$(uname -s)" == "Darwin" && -n "$GR4_LLVM_ROOT" ]]; then
  prepend_flags CPPFLAGS "-D_LIBCPP_DISABLE_AVAILABILITY"
  prepend_flags LDFLAGS "-L${GR4_LLVM_ROOT}/lib/c++"
  prepend_flags LDFLAGS "-L${GR4_LLVM_ROOT}/lib/unwind"
  prepend_flags LDFLAGS "-Wl,-rpath,${GR4_LLVM_ROOT}/lib/c++"
  prepend_flags LDFLAGS "-Wl,-rpath,${GR4_LLVM_ROOT}/lib/unwind"
fi

prepend_colon_path CMAKE_PREFIX_PATH "$GR4_PREFIX_PATH"
prepend_colon_path PKG_CONFIG_PATH "${GR4_PREFIX_PATH}/share/pkgconfig"
prepend_colon_path PKG_CONFIG_PATH "${GR4_PREFIX_PATH}/lib64/pkgconfig"
prepend_colon_path PKG_CONFIG_PATH "${GR4_PREFIX_PATH}/lib/pkgconfig"
prepend_colon_path LD_LIBRARY_PATH "${GR4_PREFIX_PATH}/lib64"
prepend_colon_path LD_LIBRARY_PATH "${GR4_PREFIX_PATH}/lib"
prepend_colon_path DYLD_LIBRARY_PATH "${GR4_PREFIX_PATH}/lib64"
prepend_colon_path DYLD_LIBRARY_PATH "${GR4_PREFIX_PATH}/lib"
prepend_colon_path PYTHONPATH "${GR4_PREFIX_PATH}/lib/python3/site-packages"
mapfile -t gr4_plugin_dirs < <(gr4_build_profile_plugin_directories "$root" "$GR4_BUILD_PROFILE")
if [[ "${#gr4_plugin_dirs[@]}" -eq 0 ]]; then
  gr4_plugin_dirs=(lib lib/gnuradio-4/plugins)
fi
for gr4_plugin_dir in "${gr4_plugin_dirs[@]}"; do
  [[ -n "$gr4_plugin_dir" ]] || continue
  prepend_colon_path GNURADIO4_PLUGIN_DIRECTORIES "${GR4_PREFIX_PATH}/${gr4_plugin_dir}"
done
unset gr4_plugin_dir gr4_plugin_dirs

set +a

echo "Loaded GNU Radio 4 environment (${GR4_ENV_NAME})"
echo "ROOT=${GR4_ROOT_DIR}"
echo "PREFIX=${GR4_PREFIX_PATH}"
