# VLSI-Projekat

This repository contains the HDL sources, synthesis artifacts and supporting tooling for a university VLSI / FPGA project implemented for the DE0-CV (Cyclone V) board.

The project implements a top-level design (DE0_TOP / DE0_CV_TOP) and various modules used for simulation and synthesis. The repository includes Quartus project files and synthesis output so you can reproduce or inspect the generated bitstream and reports.

## Quick status

- HDL sources: in `src/synthesis/` and `src/synthesis/modules/`
- Quartus project and generated artifacts: in `tooling/`
- Simulation & build helper lists and scripts: in `tooling/config/`

## Repository layout

- `src/synthesis/` — top-level Verilog files and board-specific top (DE0_CV_TOP.v, DE0_TOP.v).
- `src/synthesis/modules/` — reusable modules used by the top-level design.
- `tooling/` — Quartus output files (.qpf, .qsf, .sof, fit/stats reports), makefile and other generated artifacts.
- `tooling/config/` — helper lists for simulators/synth tools and small scripts (e.g. `list-icarus-verilog.lst`, `run.tcl`, waveform definitions).
- `tooling/mem_init.mif` — memory initialization file used by RAM/ROM IP in the design.
- `db/`, `incremental_db/`, `xpack/` — Quartus internal and database files; present for historical/snapshot purposes.

## Purpose and scope

This project was created as an academic exercise to design, simulate and synthesize digital logic on an FPGA development board (Altera/Intel DE0-CV). It contains the full Quartus project and intermediate reports, so you can inspect synthesis/placement/routing results or re-run flows locally.

## Getting started

Prerequisites (typical):

- Intel Quartus Prime (or the appropriate version used for the project)
- Icarus Verilog (for fast, local RTL simulation) or ModelSim/Questa (for waveform-driven simulation)
- GTKWave or ModelSim for waveform viewing

Simulation (quick, using Icarus Verilog):

1. Review the file list used for simulation at `tooling/config/list-src-files-simul.lst`. This file lists sources and compilation order.
2. From a shell with Icarus installed, you can run (example PowerShell commands):

```powershell
# compile
iverilog -f tooling/config/list-src-files-simul.lst -o simv
# run
vvp simv
```

If you use ModelSim, open the `tooling/config/waveform-define.do` or use `run.tcl` where provided.

Synthesis (Quartus):

1. Open the Quartus project file `tooling/DE0_TOP.qpf` in the version of Quartus used for the project.
2. Analyze & Elaboration -> Compilation (or use the provided `makefile`/flow if setup).
3. Generated artifacts (fitter reports, .sof bitstream, .pin assignments) are under `tooling/` and `db/`.

Programming the board:

- Use Quartus Programmer to load `tooling/DE0_TOP.sof` to the DE0-CV board.
- Ensure any external memory initialization files (e.g. `tooling/mem_init.mif`) are in place and paths in the project are correct.

## Important files

- `src/synthesis/DE0_CV_TOP.v` — Cyclone V board-specific top.
- `src/synthesis/DE0_TOP.v` — generic/top-level design.
- `tooling/DE0_TOP.qpf`, `tooling/DE0_TOP.qsf` — Quartus project and assignments.
- `tooling/DE0_TOP.sof` — compiled FPGA bitstream (binary) — use with care.
- `tooling/config/list-src-files-simul.lst` — source file list for simulation tools.
- `tooling/config/list-src-files-synth.lst` — synthesis source ordering for tool flows.

## Notes & tips

- The repository contains many Quartus-generated database files under `db/` and `incremental_db/` — these are useful for inspecting past synthesis runs but are not required to build from source if you re-run Quartus locally.
- If you plan to re-synthesize, install the same Quartus version that was used originally to avoid toolchain/fit differences.
- For simulation, ensure any testbench stimulus files or MIFs are reachable by the simulator working directory.

## Tests

This repo does not currently include automated unit tests for HDL. A straightforward improvement is to add a small Icarus-based testbench harness and a CI job that runs iverilog + vvp to validate smoke tests on each push.

## Contributions and license

If you want to contribute, open an issue or a pull request with proposed changes. Consider adding a LICENSE file to indicate permitted reuse. If you want, I can add an MIT or BSD license for the repo.

## Contact / Author

Repository owner: verbabic-filip

---

If you want, I can:

- add step-by-step, exact commands for Quartus automation (CLI) or a PowerShell script to program the board;
- add a small Icarus testbench and a GitHub Actions workflow to run the simulation on each push.

If you'd like any of those, tell me which and I will implement them next.