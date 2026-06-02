#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/lib.sh"

root="$(gr4_repo_root)"
gr4_mkdir_layout "$root"

parent_dir="$(cd "$root/.." && pwd)"
mkdir -p "$root/src"

components=(gnuradio4-core gnuradio4-algorithm gnuradio4-blocks)

for component in "${components[@]}"; do
  src_link="$(gr4_component_src "$root" "$component")"
  sibling="${parent_dir}/${component}"
  if [[ -d "$sibling" ]]; then
    if [[ -L "$src_link" ]]; then
      current_target="$(readlink "$src_link")"
      desired_target="../../${component}"
      if [[ "$current_target" != "$desired_target" ]]; then
        ln -sfn "$desired_target" "$src_link"
      fi
      printf '[bootstrap] linked %s -> %s\n' "$src_link" "$desired_target"
    elif [[ ! -e "$src_link" ]]; then
      (cd "$root/src" && ln -s "../../${component}" "${component}")
      printf '[bootstrap] linked %s -> ../../%s\n' "$src_link" "$component"
    else
      printf '[bootstrap] leaving existing real directory in place: %s\n' "$src_link"
    fi
  else
    if [[ ! -e "$src_link" ]]; then
      printf '[bootstrap] missing sibling repo for %s\n' "$component"
      printf '  clone command: git clone https://github.com/gnuradio/%s.git %s\n' "$component" "$sibling"
    else
      printf '[bootstrap] source already exists without sibling repo: %s\n' "$src_link"
    fi
  fi
done

