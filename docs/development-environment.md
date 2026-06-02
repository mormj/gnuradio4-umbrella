# Development Environment

GNU Radio 4 development is centered around the workspace repository. The normal
workflow is:

```bash
cp .env.example .env
./scripts/bootstrap.sh
source ./scripts/dev-env.sh
./scripts/build-all.sh
./scripts/test-all.sh
```

For release-oriented builds, use the release profile:

```bash
./scripts/build-all.sh --profile release
```

## Native Development

You need a modern C++ toolchain and CMake. The workspace scripts use:

- CMake 3.28 or newer
- a C++23-capable compiler
- Git
- pkg-config
- Ninja when available
- Python 3 for some optional flows

The source workspace is configured by `scripts/dev-env.sh`, which reads `.env`
when present and exports the workspace root, prefix, compiler, and library
paths.

## SDK Docker Image

The canonical development path is the native workspace repository above. The
SDK Docker image is most useful when you want to validate an out-of-tree module
or downstream project against an installed GNU Radio 4 SDK.

The SDK image installs GNU Radio 4 under `/opt/gnuradio4`. Downstream builds
should set `CMAKE_PREFIX_PATH=/opt/gnuradio4`.

```bash
docker run --rm -it \
  -v "$PWD:/work" \
  -w /work \
  ghcr.io/gnuradio/gnuradio4-sdk:main \
  bash
```

For reproducible CI, pin the image to a full git SHA tag rather than `:main`.
The SDK image is documented in
`src/gnuradio4-core/docs/ci/sdk-image.md`.

## Docker IDE

An IDE can use the SDK image for downstream or out-of-tree module development.
For editing the GR4 component repositories themselves, prefer the native
workspace scripts so the IDE sees the live `src/` checkouts and profile-specific
build trees.

## Windows Development

Windows support remains more manual than Linux/macOS. The previous MSYS2
instructions from the core repository still apply conceptually, but the
workspace repository now treats the split workspace and build profiles as the
canonical shape.
If you are working on Windows, use the same `repos.yaml` and build-profile
layout, then adapt the toolchain setup to the local environment.
