#!/usr/bin/env bash
set -euo pipefail

gr4_repo_root() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cd "${script_dir}/.." && pwd
}

gr4_repos_manifest() {
  local root="$1"
  printf '%s/repos.yaml' "$root"
}

gr4_local_repos_manifest() {
  local root="$1"
  printf '%s/repos.local.yaml' "$root"
}

gr4_repos_manifests() {
  local root="$1"
  local base local_manifest

  base="$(gr4_repos_manifest "$root")"
  local_manifest="$(gr4_local_repos_manifest "$root")"

  printf '%s\n' "$base"
  if [[ -f "$local_manifest" ]]; then
    printf '%s\n' "$local_manifest"
  fi
}

gr4_parse_repos_manifest() {
  local manifest="$1"
  [[ -f "$manifest" ]] || {
    printf 'missing repos manifest: %s\n' "$manifest" >&2
    return 1
  }

  awk '
    /^[[:space:]]*-[[:space:]]+name:[[:space:]]*/ {
      if (have_name || have_url || have_dest || have_ref) {
        if (!(have_name && have_url && have_dest && have_ref)) {
          print "error: incomplete repo entry in workspace manifest" > "/dev/stderr";
          exit 2;
        }
        print name "|" url "|" dest "|" ref;
      }
      name=$0; sub(/^[^:]*:[[:space:]]*/, "", name); gsub(/^["\x27]|["\x27]$/, "", name);
      url=""; dest=""; ref="";
      have_name=1; have_url=0; have_dest=0; have_ref=0;
      next;
    }
    /^[[:space:]]*url:[[:space:]]*/ {
      url=$0; sub(/^[^:]*:[[:space:]]*/, "", url); gsub(/^["\x27]|["\x27]$/, "", url);
      have_url=1;
      next;
    }
    /^[[:space:]]*dest:[[:space:]]*/ {
      dest=$0; sub(/^[^:]*:[[:space:]]*/, "", dest); gsub(/^["\x27]|["\x27]$/, "", dest);
      have_dest=1;
      next;
    }
    /^[[:space:]]*ref:[[:space:]]*/ {
      ref=$0; sub(/^[^:]*:[[:space:]]*/, "", ref); gsub(/^["\x27]|["\x27]$/, "", ref);
      have_ref=1;
      next;
    }
    END {
      if (have_name || have_url || have_dest || have_ref) {
        if (!(have_name && have_url && have_dest && have_ref)) {
          print "error: incomplete repo entry in workspace manifest" > "/dev/stderr";
          exit 2;
        }
        print name "|" url "|" dest "|" ref;
      }
    }
  ' "$manifest"
}

gr4_repos() {
  local root="$1"
  local manifest name url dest ref

  while IFS= read -r manifest; do
    [[ -n "$manifest" ]] || continue
    while IFS='|' read -r name url dest ref; do
      [[ -n "$name" ]] || continue
      printf '%s|%s|%s|%s\n' "$name" "$url" "$dest" "$ref"
    done < <(gr4_parse_repos_manifest "$manifest")
  done < <(gr4_repos_manifests "$root") | awk -F'|' '
    {
      if (seen_name[$1]++) {
        print "error: duplicate repo name in workspace manifests: " $1 > "/dev/stderr";
        failed = 1;
        exit 2;
      }
      if (seen_dest[$3]++) {
        print "error: duplicate repo destination in workspace manifests: " $3 > "/dev/stderr";
        failed = 1;
        exit 2;
      }
      repos[++repo_count] = $0;
    }
    END {
      if (failed) {
        exit 2;
      }
      for (i = 1; i <= repo_count; i++) {
        print repos[i];
      }
    }
  '
}

gr4_repo_names() {
  local root="$1"
  local name url dest ref
  while IFS='|' read -r name url dest ref; do
    [[ -n "$name" ]] || continue
    printf '%s\n' "$name"
  done < <(gr4_repos "$root")
}

gr4_known_repo() {
  local root="$1"
  local requested="$2"
  local component
  while IFS= read -r component; do
    [[ "$component" == "$requested" ]] && return 0
  done < <(gr4_repo_names "$root")
  return 1
}

gr4_build_profiles_file() {
  local root="$1"
  printf '%s/build-profiles.yaml' "$root"
}

gr4_local_build_profiles_file() {
  local root="$1"
  printf '%s/build-profiles.local.yaml' "$root"
}

gr4_build_profile_files() {
  local root="$1"
  local base local_profiles

  base="$(gr4_build_profiles_file "$root")"
  local_profiles="$(gr4_local_build_profiles_file "$root")"

  printf '%s\n' "$base"
  if [[ -f "$local_profiles" ]]; then
    printf '%s\n' "$local_profiles"
  fi
}

gr4_build_profile_names() {
  local root="$1"
  local file

  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    [[ -f "$file" ]] || {
      printf 'missing build profiles file: %s\n' "$file" >&2
      return 1
    }
    awk '
      function trim(value) {
        sub(/^[[:space:]]+/, "", value);
        sub(/[[:space:]]+$/, "", value);
        return value;
      }
      function indent_of(line) {
        match(line, /^[ ]*/);
        return RLENGTH;
      }
      /^[[:space:]]*#/ || /^[[:space:]]*$/ {
        next;
      }
      {
        indent = indent_of($0);
        name = trim($0);
      }
      indent == 2 && name ~ /^[^:]+:[[:space:]]*$/ {
        sub(/:.*/, "", name);
        print name;
      }
    ' "$file"
  done < <(gr4_build_profile_files "$root") | awk '!seen[$0]++'
}

gr4_build_profile_validate() {
  local root="$1"
  local profile="${2:-dev}"
  local known

  while IFS= read -r known; do
    [[ "$known" == "$profile" ]] && return 0
  done < <(gr4_build_profile_names "$root")

  printf 'unknown build profile: %s\n' "$profile" >&2
  printf 'known build profiles:\n' >&2
  gr4_build_profile_names "$root" >&2
  return 1
}

gr4_parse_build_profile() {
  local file="$1"
  local requested_profile="$2"
  [[ -f "$file" ]] || {
    printf 'missing build profiles file: %s\n' "$file" >&2
    return 1
  }

  awk -v requested_profile="$requested_profile" '
    function trim(value) {
      sub(/^[[:space:]]+/, "", value);
      sub(/[[:space:]]+$/, "", value);
      gsub(/^["\x27]|["\x27]$/, "", value);
      return value;
    }
    function indent_of(line) {
      match(line, /^[ ]*/);
      return RLENGTH;
    }
    /^[[:space:]]*#/ || /^[[:space:]]*$/ {
      next;
    }
    {
      indent = indent_of($0);
      line = trim($0);
    }
    indent == 2 && line ~ /^[^:]+:[[:space:]]*$/ {
      profile = line;
      sub(/:.*/, "", profile);
      in_profile = (profile == requested_profile);
      section = "";
      component = "";
      in_cache = 0;
      next;
    }
    !in_profile {
      next;
    }
    indent == 4 && line == "cmake:" {
      section = "cmake";
      component = "";
      in_cache = 0;
      next;
    }
    indent == 4 && line == "components:" {
      section = "components";
      component = "";
      in_cache = 0;
      next;
    }
    section == "cmake" && indent == 6 && line == "cache:" {
      in_cache = 1;
      next;
    }
    section == "cmake" && indent == 6 && line ~ /^generator:[[:space:]]*/ {
      value = line;
      sub(/^[^:]+:[[:space:]]*/, "", value);
      print "generator|" trim(value);
      next;
    }
    section == "cmake" && indent == 8 && in_cache && line ~ /^[^:]+:[[:space:]]*/ {
      key = line;
      sub(/:.*/, "", key);
      value = line;
      sub(/^[^:]+:[[:space:]]*/, "", value);
      print "common|" trim(key) "|" trim(value);
      next;
    }
    section == "components" && indent == 6 && line ~ /^[^:]+:[[:space:]]*$/ {
      component = line;
      sub(/:.*/, "", component);
      in_cache = 0;
      next;
    }
    section == "components" && indent == 8 && line == "cache:" {
      in_cache = 1;
      next;
    }
    section == "components" && indent == 10 && in_cache && line ~ /^[^:]+:[[:space:]]*/ {
      key = line;
      sub(/:.*/, "", key);
      value = line;
      sub(/^[^:]+:[[:space:]]*/, "", value);
      print "component|" component "|" trim(key) "|" trim(value);
      next;
    }
  ' "$file"
}

gr4_build_profile_entries() {
  local root="$1"
  local profile="$2"
  local file

  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    gr4_parse_build_profile "$file" "$profile"
  done < <(gr4_build_profile_files "$root")
}

gr4_build_profile_cmake_args() {
  local root="$1"
  local profile="$2"
  local component="$3"
  local kind name key value

  while IFS='|' read -r kind name key value; do
    case "$kind" in
      common)
        printf -- '-D%s=%s\n' "$name" "$key"
        ;;
      component)
        [[ "$name" == "$component" ]] || continue
        printf -- '-D%s=%s\n' "$key" "$value"
        ;;
    esac
  done < <(gr4_build_profile_entries "$root" "$profile")
}

gr4_build_profile_generator() {
  local root="$1"
  local profile="$2"
  local kind value last=""

  while IFS='|' read -r kind value _; do
    if [[ "$kind" == "generator" ]]; then
      last="$value"
    fi
  done < <(gr4_build_profile_entries "$root" "$profile")

  printf '%s\n' "$last"
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

gr4_profile_build_root() {
  local root="$1"
  local profile="${2:-dev}"
  printf '%s/build/%s' "$root" "$profile"
}

gr4_profile_install_root() {
  local root="$1"
  local profile="${2:-dev}"
  printf '%s/install/%s' "$root" "$profile"
}

gr4_component_build() {
  local root="$1"
  local profile="${2:-dev}"
  local component="${3:-}"
  printf '%s/%s' "$(gr4_profile_build_root "$root" "$profile")" "$component"
}

gr4_component_install() {
  local root="$1"
  local profile="${2:-dev}"
  printf '%s\n' "$(gr4_profile_install_root "$root" "$profile")"
}

gr4_mkdir_layout() {
  local root="$1"
  mkdir -p "$root/src" "$root/build" "$root/install"
}
