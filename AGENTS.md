# AGENTS.md

## Project Snapshot

- SystemVerilog RTL for a BIKE/MDPC-style min-sum decoder.
- RTL lives in `rtl/`; testbenches live in `tb/`; helper scripts live in `scripts/`.
- Generated simulation fixtures are under `tb/generated/`.

## Design Goals

- Constant-time decoding is a hard requirement.
- For a given public parameter level, decode latency must be fixed and independent of the private key, first-column support set, syndrome, error pattern, and decoder convergence behavior.
- Each parameter level may use its own fixed cycle budget, memory geometry, and parallelism settings.
- Architecture changes should minimize fixed decode cycles first, then memory footprint, while keeping the implementation hardware-friendly for synthesis and timing closure.
- Avoid early termination, key-dependent scheduling depth, key-dependent bank counts, and data-dependent memory access counts in the main decode path.

## Common Commands

- `make test-unit` - run unit testbenches.
- `make test-integration` - run the full decoder testbench.
- `make test-bike-random BIKE_RANDOM_TRIALS=1` - run one generated random BIKE decoder case.
- `make test` - run unit plus integration tests.
- `make format-rtl` - format maintained RTL/testbench SV files.
- `make check-format-rtl && make lint-rtl` - check RTL formatting and Verible lint.

## Verilator Output

- The default `VERILATOR` is `./scripts/verilator_quiet.py`.
- Full compile logs are saved in `build/logs/verilator/`.
- Runtime logs are saved in `build/logs/run/`.
- Use `VERILATOR_QUIET=0 make ...` only when raw Verilator output is needed.

## Key Files

- `Makefile` - canonical build/test entry points.
- `docs/vivado_systemverilog_guidelines.md` - Vivado/SystemVerilog RTL, XDC, CDC, reset, resource inference, and verification rules for this repository.
- `docs/references/cai-zhang-2023-low-complexity-parallel-min-sum-mdpc-decoder.pdf` - reference paper for the decoder architecture.
- `rtl/bike_pkg.sv` - shared parameters/types.
- `rtl/decoder_top.sv` - top-level decoder RTL.
- `scripts/run_bike_random.py` - generated random decoder simulations.

## Working Notes

- Prefer Makefile targets over hand-written Verilator commands.
- Use `make format-rtl` for RTL/TB formatting. Declarations align direction/`logic`/packed width/name; unpacked dimensions stay tight to the name, e.g. `foo[0:L-1]`.
- Keep terminal output compact; inspect saved logs only when a failure needs detail.
- Do not delete generated files casually; generated SV headers are used by tests.
- Follow `docs/vivado_systemverilog_guidelines.md` when generating, modifying, reviewing, or documenting RTL, testbenches, Vivado XDC, and synthesis scripts.
- 文档和代码注释中只描述当前状态，不写与旧版本的对比（避免"不再"、"目前已改为"、"no longer"、"now"、"instead of"、"rather than"等表述）。设计文档应描述成品架构，而非修改记录。
