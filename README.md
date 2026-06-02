# GNU Radio 4

This repository is the umbrella and release workspace for GNU Radio 4.
It does not contain implementation sources for core, algorithm, or standard block libraries.
Those live in sibling component repositories and are composed here through a release manifest and local workspace scripts.

## What lives here

- `manifest.yaml`: development composition of the current GNU Radio 4 stack
- `releases/`: immutable release manifests, one per published distribution
- `docs/`: architecture, local workspace, and release workflow notes
- `scripts/`: bootstrap, environment, build, test, smoke, and cleanup helpers
- `integration_smoke/`: a minimal out-of-tree consumer of the installed SDK

## Local workspace layout

The workspace uses a shared source/build/install model:

```text
gnuradio4/
  src/
    gnuradio4-core/
    gnuradio4-algorithm/
    gnuradio4-blocks/
  build/
    gnuradio4-core/
    gnuradio4-algorithm/
    gnuradio4-blocks/
    integration_smoke/
  install/
```

If sibling repositories already exist next to this repo, `scripts/bootstrap.sh` will register them under `src/` as relative symlinks.

## Quick start

```bash
./scripts/bootstrap.sh
source ./scripts/dev-env.sh
./scripts/build-all.sh
./scripts/test-all.sh
./scripts/integration-smoke.sh
```

## Component roles

- `gnuradio4-core`: runtime, scheduler, graph API, block API, SDK, plugin/blocklib support, and package exports
- `gnuradio4-algorithm`: reusable non-block DSP and algorithm libraries
- `gnuradio4-blocks`: standard MIT block libraries built on core and algorithm

## CMake package names

The repository and package naming differ slightly:

- repositories stay hyphenated
- CMake packages remain camelCase for compatibility:
  - `gnuradio4Algorithm`
  - `gnuradio4Blocks`

## Release-centric model

The manifest here defines the current development composition.
Later, immutable release BOMs will be recorded under `releases/` and tagged with the umbrella repository.
