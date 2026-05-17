# AGENTS.md

## Project Snapshot

- SystemVerilog RTL for a BIKE/MDPC-style min-sum decoder.
- RTL lives in `rtl/`; testbenches live in `tb/`; helper scripts live in `scripts/`.
- Generated files are under `rtl/generated/` and `tb/generated/`.

## Common Commands

- `make test-unit` - run unit testbenches.
- `make test-integration` - run the full decoder testbench.
- `make test-bike-random BIKE_RANDOM_TRIALS=1` - run one generated random BIKE decoder case.
- `make test` - run unit plus integration tests.

## Verilator Output

- The default `VERILATOR` is `./scripts/verilator_quiet.py`.
- Full compile logs are saved in `build/logs/verilator/`.
- Runtime logs are saved in `build/logs/run/`.
- Use `VERILATOR_QUIET=0 make ...` only when raw Verilator output is needed.

## Key Files

- `Makefile` - canonical build/test entry points.
- `docs/references/cai-zhang-2023-low-complexity-parallel-min-sum-mdpc-decoder.pdf` - reference paper for the decoder architecture.
- `rtl/bike_pkg.sv` - shared parameters/types.
- `rtl/decoder_top.sv` - top-level decoder RTL.
- `scripts/run_bike_random.py` - generated random decoder simulations.

## Working Notes

- Prefer Makefile targets over hand-written Verilator commands.
- Keep terminal output compact; inspect saved logs only when a failure needs detail.
- Do not delete generated files casually; many tests depend on generated SV headers.
- 文档和代码注释中只描述当前状态，不写与旧版本的对比（避免"不再"、"目前已改为"、"no longer"、"now"、"instead of"、"rather than"等表述）。设计文档应描述成品架构，而非修改记录。
