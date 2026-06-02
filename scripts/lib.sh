#!/usr/bin/env bash
set -euo pipefail

gr4_repo_root() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cd "${script_dir}/.." && pwd
}

gr4_read_args_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    printf '%s\n' "$line"
  done <"$file"
}

gr4_choose_generator() {
  if command -v ninja >/dev/null 2>&1; then
    printf '%s\n' "Ninja"
  fi
}

gr4_component_src() {
  local root="$1"
  local component="$2"
  printf '%s/src/%s' "$root" "$component"
}

gr4_component_build() {
  local root="$1"
  local component="$2"
  printf '%s/build/%s' "$root" "$component"
}

gr4_component_install() {
  local root="$1"
  printf '%s\n' "${GR4_PREFIX:-$root/install}"
}

gr4_mkdir_layout() {
  local root="$1"
  mkdir -p "$root/src" "$root/build" "$root/install"
}

gr4_env_exports() {
  local root="$1"
  local prefix
  prefix="$(gr4_component_install "$root")"
  export GR4_WORKSPACE_ROOT="$root"
  export GR4_PREFIX="$prefix"
  export CMAKE_PREFIX_PATH="${prefix}${CMAKE_PREFIX_PATH:+:${CMAKE_PREFIX_PATH}}"
  export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig:${prefix}/share/pkgconfig${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}}"
  export PATH="${prefix}/bin:${PATH:-}"
  if ut_source="$(gr4_locate_cached_fetchcontent_source UT)"; [[ -n "${ut_source:-}" ]]; then
    export GR4_FETCHCONTENT_SOURCE_DIR_UT="$ut_source"
  fi
  if vir_source="$(gr4_locate_cached_fetchcontent_source VIR_SIMD)"; [[ -n "${vir_source:-}" ]]; then
    export GR4_FETCHCONTENT_SOURCE_DIR_VIR_SIMD="$vir_source"
  fi
  if [[ "$(uname -s)" == "Darwin" ]]; then
    export DYLD_LIBRARY_PATH="${prefix}/lib${DYLD_LIBRARY_PATH:+:${DYLD_LIBRARY_PATH}}"
  else
    export LD_LIBRARY_PATH="${prefix}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
  fi
}

gr4_locate_cached_fetchcontent_source() {
  local dep="${1:-}"
  local search_root="${GR4_FETCHCONTENT_SEARCH_ROOT:-$HOME/gnuradio}"
  local candidate pattern candidate_var

  case "$dep" in
    UT)
      pattern='ut-src'
      ;;
    VIR_SIMD)
      pattern='vir-simd-src'
      ;;
    *)
      return 0
      ;;
  esac

  candidate_var="GR4_FETCHCONTENT_SOURCE_DIR_${dep}"
  if [[ -n "${!candidate_var:-}" && -d "${!candidate_var}" ]]; then
    printf '%s\n' "${!candidate_var}"
    return 0
  fi

  if [[ -d "$search_root" ]]; then
    candidate="$(find "$search_root" -type d -path "*/build/_deps/${pattern}" -print -quit 2>/dev/null || true)"
    if [[ -d "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  fi
}

gr4_fetchcontent_args_for_component() {
  local component="${1:-}"
  local ut_source vir_source

  if [[ "$component" == "gnuradio4-core" ]]; then
    ut_source="$(gr4_locate_cached_fetchcontent_source UT || true)"
    vir_source="$(gr4_locate_cached_fetchcontent_source VIR_SIMD || true)"
    if [[ -n "$ut_source" ]]; then
      printf '%s\n' "-DFETCHCONTENT_SOURCE_DIR_UT=$ut_source"
    fi
    if [[ -n "$vir_source" ]]; then
      printf '%s\n' "-DFETCHCONTENT_SOURCE_DIR_VIR-SIMD=$vir_source"
    fi
    return 0
  fi

  ut_source="$(gr4_locate_cached_fetchcontent_source UT || true)"
  if [[ -n "$ut_source" ]]; then
    printf '%s\n' "-DFETCHCONTENT_SOURCE_DIR_UT=$ut_source"
  fi
}
