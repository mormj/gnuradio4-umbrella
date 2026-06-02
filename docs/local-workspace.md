# Local Workspace

The local workspace uses a shared source tree with profile-specific build/install layouts:

```text
gnuradio4/
  src/
  build/
    dev/
    release/
  install/
    dev/
    release/
  var/
```

## Environment

Copy `.env.example` to `.env` for local overrides:

```bash
cp .env.example .env
```

`scripts/dev-env.sh` is intended to be sourced:

```bash
source scripts/dev-env.sh
```

It creates the workspace directories if needed and exports these variables:

- `GR4_ROOT_DIR`
- `GR4_WORKSPACE_ROOT`
- `GR4_SRC_PATH`
- `GR4_BUILD_PATH`
- `GR4_PREFIX`
- `GR4_PREFIX_PATH`
- `CC`, `CXX`, `CMAKE_C_COMPILER`, and `CMAKE_CXX_COMPILER` when `GR4_CC` or `GR4_CXX` are set
- `PKGCONF`
- `PKG_CONFIG`
- `CMAKE_PREFIX_PATH`
- `PKG_CONFIG_PATH`
- `PATH`
- `LD_LIBRARY_PATH` on Linux
- `DYLD_LIBRARY_PATH` on macOS
- `PYTHONPATH`
- `GNURADIO4_PLUGIN_DIRECTORIES`

The default `.env.example` sets `GR4_BUILD_JOBS=6`. You can edit `.env` or export the variable in your shell to change build parallelism.
It also sets `GR4_BUILD_PROFILE=dev` so the default build policy is explicit.

## Local workspace manifest

`repos.yaml` drives the committed local workspace bootstrap. Each entry has:

- `name`
- `url`
- `dest`
- `ref`

Refs may be branches, tags, or commit SHAs. Bootstrap uses this file for clone URLs, destination paths, and checkout refs.

For personal out-of-tree repos, copy the example overlay:

```bash
cp repos.local.yaml.example repos.local.yaml
```

`repos.local.yaml` is gitignored, uses the same schema, and is loaded after `repos.yaml`. This lets local modules participate in bootstrap, build, and test without editing the committed workspace list.

Duplicate repo names or destinations across `repos.yaml` and `repos.local.yaml` fail with a clear error.

The current repo entries are:

- `gnuradio4-core`
- `gnuradio4-algorithm`
- `gnuradio4-blocks`

## Default bootstrap mode

By default, `scripts/bootstrap.sh` creates `src/`, `build/`, and `install/`, then clones missing component repositories from the combined workspace manifests into `src/`:

```bash
./scripts/bootstrap.sh
```

Existing `src/<component>` directories or symlinks are left in place. Bootstrap does not fetch, reset, or check out refs for existing source paths.

You can also request clone mode explicitly:

```bash
./scripts/bootstrap.sh --clone
```

## Sibling repositories

For split-development or repository reorganization workflows, use sibling mode:

```bash
./scripts/bootstrap.sh --use-sibling-repos
```

In this mode, if the component repositories already exist next to the workspace repository, bootstrap registers them as relative symlinks under `src/`. If a sibling Git repository is missing, the script fails with a clear error and does not fall back to cloning.

The symlink targets are relative to `src/`:

- `src/gnuradio4-core -> ../../gnuradio4-core`
- `src/gnuradio4-algorithm -> ../../gnuradio4-algorithm`
- `src/gnuradio4-blocks -> ../../gnuradio4-blocks`

## Build and Test Helpers

`scripts/build-all.sh` runs bootstrap in default clone mode, then builds each repo from `repos.yaml` followed by `repos.local.yaml` order. If sibling symlinks already exist under `src/`, bootstrap skips them and the build uses those sources.

Build policy is profile-based and lives in `build-profiles.yaml`:

- `dev` is the default development profile
- `release` is the release-oriented profile
- `build-profiles.local.yaml` is a gitignored local override loaded after the committed profile file
- `scripts/build.sh --profile release <component>` and `scripts/build-all.sh --profile release` select the release profile
- omit `--profile` to use the default dev profile

The profile file declares shared CMake cache variables and component-specific
cache variables in structured YAML instead of loose command-line fragments:

```yaml
profiles:
  dev:
    cmake:
      generator: Ninja
      cache:
        CMAKE_BUILD_TYPE: RelWithDebInfo
    components:
      gnuradio4-core:
        cache:
          GR_USE_FETCHCONTENT_DEPS: ON
```

For machine-local changes, copy the example overlay:

```bash
cp build-profiles.local.yaml.example build-profiles.local.yaml
```

`scripts/build.sh <component>` builds and installs one known component into the profile-specific prefix.

`scripts/test-all.sh` runs `ctest` for component build directories that exist and skips missing build directories.
Use `scripts/test-all.sh --profile release` to run tests against the release build trees.

The default profile uses:

```text
build/dev/<component>
install/dev/
```

The release profile uses:

```text
build/release/<component>
install/release/
```

## Package names

The repository names are hyphenated, but the current CMake package names are camelCase for compatibility:

- `gnuradio4Algorithm`
- `gnuradio4Blocks`

## Build outputs

Each component builds out of source under:

```text
build/<profile>/<component>
```

All components install into a profile-specific prefix:

```text
install/<profile>/
```

## Build parallelism

The workspace build scripts default to 6 parallel jobs.
Override this with `GR4_BUILD_JOBS` if your system needs a different value.
