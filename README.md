# GNU Radio 4.0

<p align="center">
<img src="docs/logo.png" width="30%" />
</p>

> [!IMPORTANT]
> GNU Radio 4.0 (GR4) is still maturing toward its first stable release. It is
> intended for evaluation, experimentation, and early development. GNU Radio 3.x
> remains the current stable series for users who need a production-supported
> release line.

GNU Radio is a free and open source signal-processing runtime and toolkit.
GNU Radio 4 keeps the familiar flowgraph model while updating the core runtime,
block model, and development workflow around modern C++ and a split-repository
workspace.

## What is New in GNU Radio 4.0?

GNU Radio 4 modernizes the runtime, block model, and application architecture
while preserving the core GNU Radio workflow of composing signal-processing
systems from reusable blocks and flowgraphs.

- Modern C++ block development with stronger typing and clearer APIs
- Better support for fundamental, structured, and application-specific data
  types
- A runtime designed for efficient signal processing with lock-free buffers and
  compile-time optimization
- A more flexible scheduling model with room for throughput, latency, and
  application-specific execution needs
- Recursive flowgraphs and feedback support
- Broad execution-target support, starting with CPUs and leaving room for
  accelerators
- A project shape that covers experimentation, education, prototyping, test
  systems, and operational or industrial deployments

## Quick Start

```bash
cp .env.example .env
./scripts/bootstrap.sh
source ./scripts/dev-env.sh
./scripts/build-all.sh
./scripts/test-all.sh
```

## What Lives Here

- `repos.yaml`: committed workspace composition
- `repos.local.yaml`: gitignored local workspace overlay
- `build-profiles.yaml`: committed dev and release build policy
- `build-profiles.local.yaml`: gitignored local build-policy overlay
- `releases/`: future immutable release manifests and BOMs
- `docs/`: workspace, development, installation, and release notes
- `scripts/`: bootstrap, environment, build, test, and cleanup helpers


## Local Workspace

This repository is the canonical workspace landing point for GNU Radio 4.
`repos.yaml` describes the committed workspace layout and `repos.local.yaml`
adds personal out-of-tree repositories without touching the committed list.

The workspace uses a shared source tree with profile-specific build and install
trees:

```text
gnuradio4/
  src/
    gnuradio4-core/
    gnuradio4-algorithm/
    gnuradio4-blocks/
  build/
    dev/
      gnuradio4-core/
      gnuradio4-algorithm/
      gnuradio4-blocks/
    release/
      gnuradio4-core/
      gnuradio4-algorithm/
      gnuradio4-blocks/
  install/
    dev/
    release/
```

See [docs/local-workspace.md](docs/local-workspace.md) for the workspace model
and [docs/release-workflow.md](docs/release-workflow.md) for the release split.

## Build Policy

Development builds use the `dev` profile from `build-profiles.yaml` by default.
Release-oriented builds use the `release` profile. Local overrides live in
`build-profiles.local.yaml`, which is loaded after the committed profile file.

The default development profile uses FetchContent helpers where needed. The
release profile keeps that policy explicit and separate so release builds do not
inherit development-only dependencies or assumptions.


## Development and Installation

The previous single-repository landing-page docs have been moved into the
workspace repository and updated for the split workspace.

- [docs/development-environment.md](docs/development-environment.md)
- [docs/installation.md](docs/installation.md)
- [docs/local-workspace.md](docs/local-workspace.md)

## Helpful Links

- [GNU Radio Website](https://gnuradio.org)
- [GNU Radio Wiki](https://wiki.gnuradio.org/)
- [Issue Tracker](https://github.com/gnuradio/gnuradio4/issues)
- [Mailing List Archive](https://lists.gnu.org/archive/html/discuss-gnuradio/)
- [Mailing List Subscription](https://lists.gnu.org/mailman/listinfo/discuss-gnuradio)
- [Matrix Chat](https://chat.gnuradio.org/)

## License and Copyright

This workspace repository is licensed under the MIT License.
The current core repositories - `gnuradio4-core`, `gnuradio4-algorithm`, and
`gnuradio4-blocks` - are also MIT licensed. Future sibling repositories may
use different licenses where the component's purpose or code origin requires
it.

## Acknowledgements

GNU Radio 4 builds on contributions from the GNU Radio community and the
broader ecosystem around SDR, signal processing, and systems engineering.

The GNU Radio project specifically appreciates the contributions from
GSI/FAIR in the co-development of GNU Radio 4 Core. Their work helped shape
the runtime, block model, and surrounding tooling that the workspace repository
now organizes.

The contributors below are recognized for their roles in redesigning the core
that evolved into GR4.

## Contributors

Thanks goes to these wonderful people:

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/wirew0rm"><img src="https://avatars.githubusercontent.com/u/1202371?v=4" width="100px;" alt=""/><br /><sub><b>Alexander Krimm</b></sub></a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/noc0lour"><img src="https://avatars.githubusercontent.com/u/4438327?v=4" width="100px;" alt=""/><br /><sub><b>Andrej Rode</b></sub></a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/gitXsingh"><img src="https://avatars.githubusercontent.com/u/149612072?v=4" width="100px;" alt=""/><br /><sub><b>Anmolmeet Singh</b></sub></a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/cafeclimber"><img src="https://avatars.githubusercontent.com/u/10188900?v=4" width="100px;" alt=""/><br /><sub><b>Bailey Campbell</b></sub></a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/chrisjohgorman"><img src="https://avatars.githubusercontent.com/u/29354995?v=4" width="100px;" alt=""/><br /><sub><b>Chris Gorman</b></sub></a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://destevez.net"><img src="https://avatars.githubusercontent.com/u/15093841?v=4" width="100px;" alt=""/><br /><sub><b>Daniel Estévez</b></sub></a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/dennisklein"><img src="https://avatars.githubusercontent.com/u/297548?v=4" width="100px;" alt=""/><br /><sub><b>Dennis Klein</b></sub></a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/frankosterfeld"><img src="https://avatars.githubusercontent.com/u/483854?v=4" width="100px;" alt=""/><br /><sub><b>Frank Osterfeld</b></sub></a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://cukic.co"><img src="https://avatars.githubusercontent.com/u/90119?v=4" width="100px;" alt=""/><br /><sub><b>Ivan Čukić</b></sub></a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/marcusmueller"><img src="https://avatars.githubusercontent.com/u/958972?v=4" width="100px;" alt=""/><br /><sub><b>Marcus Müller</b></sub></a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://mattkretz.github.io/"><img src="https://avatars.githubusercontent.com/u/3306474?v=4" width="100px;" alt=""/><br /><sub><b>Matthias Kretz</b></sub></a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/eltos"><img src="https://avatars.githubusercontent.com/u/19860638?v=4" width="100px;" alt=""/><br /><sub><b>Philipp Niedermayer</b></sub></a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/RalphSteinhagen"><img src="https://avatars.githubusercontent.com/u/46007894?v=4" width="100px;" alt=""/><br /><sub><b>Ralph J. Steinhagen</b></sub></a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/iamsergio"><img src="https://avatars.githubusercontent.com/u/20387?v=4" width="100px;" alt=""/><br /><sub><b>Sergio Martins</b></sub></a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/flynn378"><img src="https://avatars.githubusercontent.com/u/6114517?v=4" width="100px;" alt=""/><br /><sub><b>Toby Flynn</b></sub></a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/gretel"><img src="https://avatars.githubusercontent.com/u/80815?v=4" width="100px;" alt=""/><br /><sub><b>Tom Hensel</b></sub></a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/drslebedev"><img src="https://avatars.githubusercontent.com/u/25366186?v=4" width="100px;" alt=""/><br /><sub><b>drslebedev</b></sub></a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/mormj"><img src="https://avatars.githubusercontent.com/u/34754695?v=4" width="100px;" alt=""/><br /><sub><b>mormj</b></sub></a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->
