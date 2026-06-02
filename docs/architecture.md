# Architecture

The GNU Radio 4 workspace repository coordinates three main component repositories:

- `gnuradio4-core`
- `gnuradio4-algorithm`
- `gnuradio4-blocks`

It also leaves room for future sibling repositories such as:

- `gnuradio4-blocks-gpl`
- `gnuradio4-control-plane`
- `gnuradio4-studio`

## Dependency direction

- `gnuradio4-core` has no dependency on algorithm or standard blocks
- `gnuradio4-algorithm` depends on `gnuradio4-core`
- `gnuradio4-blocks` depends on `gnuradio4-core` and `gnuradio4-algorithm`
- the workspace repository integrates, validates, packages, and releases the stack

## Role of the workspace repository

The workspace repository is the canonical landing point for GNU Radio 4:

- it defines the current local development composition in `repos.yaml`
- it holds release BOMs under `releases/`
- it provides a local multi-repo workspace

Implementation source stays in the component repositories under `src/`. The workspace repository owns orchestration scripts, workspace configuration, documentation, and release metadata.
