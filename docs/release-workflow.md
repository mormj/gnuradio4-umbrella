# Release Workflow

`manifest.yaml` is the live development composition.

Future release manifests under `releases/` are immutable bills of materials that record the exact component versions used for a published GNU Radio 4 distribution.

## Intended release flow

1. Tag the component repositories.
2. Update or create the release manifest in `releases/`.
3. Validate the composed workspace in the umbrella repository.
4. Tag the umbrella repository to represent the full GNU Radio 4 distribution.

## Why this repo exists

The umbrella repository gives GNU Radio 4 a canonical top-level entry point without merging implementation code back together.
It keeps the split-repo architecture intact while still supporting a release and validation workflow that looks like a single product.

