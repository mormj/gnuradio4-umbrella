# Release Workflow

`repos.yaml` is the live local development composition.

Future release manifests under `releases/` are immutable bills of materials that record the exact component versions used for a published GNU Radio 4 distribution.
No release manifest format is active yet; for now, local development and validation use `repos.yaml`.

Release builds should use the `release` profile in `scripts/build.sh` and `scripts/build-all.sh`. That profile is defined in `build-profiles.yaml` and is kept separate from the dev profile so release-oriented CMake policy, including FetchContent behavior, does not leak into the normal workspace defaults.

## Intended release flow

1. Tag the component repositories.
2. Update or create the release manifest in `releases/`.
3. Validate the composed workspace in the workspace repository.
4. Tag the workspace repository to represent the full GNU Radio 4 distribution.

## Why this repo exists

The workspace repository gives GNU Radio 4 a canonical top-level entry point without merging implementation code back together.
It keeps the split-repo architecture intact while still supporting a release and validation workflow that looks like a single product.
