# Installation

GNU Radio 4 is currently installed from source.

## Requirements

- CMake 3.28 or newer
- a C++23-compatible compiler
- Git
- pkg-config
- Boost.UT headers or package
- cpp-httplib headers or package
- vir-simd headers
- Python 3 is optional

## Workspace Install

The recommended way to build and install GNU Radio 4 is through the workspace
repository:

```bash
cp .env.example .env
./scripts/bootstrap.sh
source ./scripts/dev-env.sh
./scripts/build-all.sh
```

For a release-oriented install, use the release profile:

```bash
./scripts/build-all.sh --profile release
```

## Platform Notes

- Linux: expected to work with a modern toolchain
- macOS: use a modern Apple or LLVM toolchain; the workspace scripts can be
  combined with the `dev` or `release` profile in `build-profiles.yaml`
- Windows: see the development-environment notes and adapt the same workspace
  layout to the local toolchain

## Troubleshooting

- Check `cmake --version`
- Check your compiler version
- Inspect `build/<profile>/<component>/CMakeFiles/` if configuration fails

For more context on the local workspace and build policy, see:

- [docs/local-workspace.md](docs/local-workspace.md)
- [docs/development-environment.md](docs/development-environment.md)
- [docs/release-workflow.md](docs/release-workflow.md)
