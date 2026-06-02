# Local Workspace

The local workspace uses a shared source/build/install layout:

```text
gnuradio4/
  src/
  build/
  install/
```

## Environment

`scripts/dev-env.sh` exports these variables:

- `GR4_WORKSPACE_ROOT`
- `GR4_PREFIX`
- `CMAKE_PREFIX_PATH`
- `PKG_CONFIG_PATH`
- `PATH`
- `LD_LIBRARY_PATH` on Linux
- `DYLD_LIBRARY_PATH` on macOS

## Sibling repositories

If the component repositories already exist next to the umbrella repo, `scripts/bootstrap.sh` will register them as relative symlinks under `src/`.

If they do not exist locally, the script prints the clone commands that would be used from `manifest.yaml`.

## Package names

The repository names are hyphenated, but the current CMake package names are camelCase for compatibility:

- `gnuradio4Algorithm`
- `gnuradio4Blocks`

## Build outputs

Each component builds out of source under:

```text
build/<component>
```

All components install into the shared prefix:

```text
install/
```

## Build parallelism

The workspace build scripts default to 4 parallel jobs.
That stays within the safe memory envelope for the generated block targets on this machine.
You can raise `GR4_BUILD_JOBS` up to 8 if your system can handle it, but the safe default is lower.
