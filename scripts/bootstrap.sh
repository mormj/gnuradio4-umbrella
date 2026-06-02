#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/lib.sh"

root="$(gr4_repo_root)"
mode="clone"

usage() {
  cat <<'EOF'
Usage:
  scripts/bootstrap.sh [OPTIONS]

Options:
  --use-sibling-repos   Use sibling repositories beside the workspace repository by symlinking them into src/
  --clone               Clone component repositories into src/ (default)
  --help                Show help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --use-sibling-repos)
      mode="sibling"
      ;;
    --clone)
      mode="clone"
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      printf '[bootstrap] unknown option: %s\n\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

gr4_mkdir_layout "$root"

parent_dir="$(cd "$root/.." && pwd)"
mapfile -t repos_manifests < <(gr4_repos_manifests "$root")

printf '[bootstrap] workspace root: %s\n' "$root"
printf '[bootstrap] repos manifests:\n'
printf '  %s\n' "${repos_manifests[@]}"
printf '[bootstrap] mode: %s\n' "$mode"

checkout_ref() {
  local repo_path="$1"
  local component="$2"
  local relref="$3"
  local target commit

  git -C "$repo_path" fetch --all --tags --prune

  if git -C "$repo_path" rev-parse --verify --quiet "origin/${relref}^{commit}" >/dev/null; then
    target="origin/${relref}"
  elif git -C "$repo_path" rev-parse --verify --quiet "${relref}^{commit}" >/dev/null; then
    target="$relref"
  elif git -C "$repo_path" rev-parse --verify --quiet "refs/tags/${relref}^{commit}" >/dev/null; then
    target="refs/tags/${relref}"
  else
    printf '[bootstrap] could not resolve ref %s for %s\n' "$relref" "$component" >&2
    exit 1
  fi

  git -C "$repo_path" checkout --detach "$target"
  commit="$(git -C "$repo_path" rev-parse --short HEAD)"
  printf '[bootstrap] checked out %s at %s (%s)\n' "$component" "$target" "$commit"
}

while IFS='|' read -r component clone_url dest relref; do
  [[ -n "$component" ]] || continue

  src_link="$root/$dest"
  sibling="${parent_dir}/${component}"

  if [[ -e "$src_link" || -L "$src_link" ]]; then
    printf '[bootstrap] source already exists, skipping: %s\n' "$src_link"
    continue
  fi

  if [[ "$mode" == "clone" ]]; then
    printf '[bootstrap] cloning %s into %s\n' "$clone_url" "$src_link"
    mkdir -p "$(dirname "$src_link")"
    git clone "$clone_url" "$src_link"
    checkout_ref "$src_link" "$component" "$relref"
    continue
  fi

  if [[ -d "$sibling/.git" ]]; then
    desired_target="../../${component}"
    mkdir -p "$(dirname "$src_link")"
    (cd "$(dirname "$src_link")" && ln -s "$desired_target" "$(basename "$src_link")")
    printf '[bootstrap] linked %s -> %s\n' "$src_link" "$desired_target"
  else
    printf '[bootstrap] missing sibling Git repo for %s: %s\n' "$component" "$sibling" >&2
    printf '[bootstrap] create or clone the sibling repo, or run scripts/bootstrap.sh --clone to use default clone mode.\n' >&2
    exit 1
  fi
done < <(gr4_repos "$root")
