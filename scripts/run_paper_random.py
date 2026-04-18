#!/usr/bin/env python3
"""Generate and run random-H paper-parameter MDPC decoder simulations."""

from __future__ import annotations

import argparse
import os
import random
import secrets
import subprocess
from pathlib import Path


N0 = 2
R = 4801
W = 45
N = N0 * R
L = 2
D = 4
I_MAX = 30
C_VAL = 9
ALPHA_FRAC_W = 6
ALPHA_SHIFT_0 = 4
ALPHA_SHIFT_1 = 5
APP_W = 8

RTL_CORE = [
    "rtl/ram_i.sv",
    "rtl/ram_c.sv",
    "rtl/ram_m.sv",
    "rtl/ram_s.sv",
    "rtl/ram_t.sv",
    "rtl/ram_u.sv",
    "rtl/h_shift.sv",
    "rtl/cnu_a.sv",
    "rtl/cnu_b.sv",
    "rtl/vnu.sv",
    "rtl/decoder_top.sv",
]


def parse_int(value: str) -> int:
    return int(value, 0)


def format_values(values: list[int], per_line: int, indent: str) -> str:
    lines = []
    for idx in range(0, len(values), per_line):
        lines.append(indent + ", ".join(str(v) for v in values[idx : idx + per_line]))
    return ",\n".join(lines)


def build_cases(case_count: int, base_seed: int, error_count: int) -> list[dict[str, object]]:
    seed_rng = random.Random(base_seed)
    cases = []

    for case_idx in range(case_count):
        case_seed = seed_rng.getrandbits(64)
        case_rng = random.Random(case_seed)
        h_base = [sorted(case_rng.sample(range(R), W)) for _ in range(N0)]
        errors = sorted(case_rng.sample(range(N), error_count))
        cases.append({"idx": case_idx, "seed": case_seed, "h_base": h_base, "errors": errors})

    return cases


def emit_pkg(path: Path, cases: list[dict[str, object]]) -> None:
    lines = [
        "package mdpc_paper_pkg;",
        f"  parameter int N0 = {N0};",
        f"  parameter int R = {R};",
        f"  parameter int W = {W};",
        "  parameter int N = N0 * R;",
        f"  parameter int L = {L};",
        f"  parameter int D = {D};",
        f"  parameter int I_MAX = {I_MAX};",
        f"  parameter int C_VAL = {C_VAL};",
        f"  parameter int ALPHA_FRAC_W = {ALPHA_FRAC_W};",
        f"  parameter int ALPHA_SHIFT_0 = {ALPHA_SHIFT_0};",
        f"  parameter int ALPHA_SHIFT_1 = {ALPHA_SHIFT_1};",
        "  parameter int MAG_MAX = (1 << D) - 1;",
        "  parameter int ROW_SEG_SIZE = (R + L - 1) / L;",
        "  parameter int ROW_SPLIT = ROW_SEG_SIZE;",
        f"  parameter int APP_W = {APP_W};",
        "  parameter int VAR_W = (N > 1) ? $clog2(N) : 1;",
        "  parameter int ROW_W = (R > 1) ? $clog2(R) : 1;",
        "  parameter int EDGE_W = (W > 1) ? $clog2(W) : 1;",
        "  parameter int BANK_W = (N0 > 1) ? $clog2(N0) : 1;",
        "  parameter int LANE_COUNT_W = (W > 1) ? $clog2(W + 1) : 1;",
        f"  parameter int H_NUM = {len(cases)};",
        "  parameter int H_SEL_W = (H_NUM > 1) ? $clog2(H_NUM) : 1;",
        "  localparam int DEC_STATE_W = 4;",
        "  localparam logic [DEC_STATE_W-1:0] DEC_IDLE  = 4'd0;",
        "  localparam logic [DEC_STATE_W-1:0] DEC_LOAD  = 4'd1;",
        "  localparam logic [DEC_STATE_W-1:0] DEC_CNU_A = 4'd2;",
        "  localparam logic [DEC_STATE_W-1:0] DEC_CNU_B = 4'd3;",
        "  localparam logic [DEC_STATE_W-1:0] DEC_VNU_ACCUM = 4'd4;",
        "  localparam logic [DEC_STATE_W-1:0] DEC_VNU_EMIT  = 4'd5;",
        "  localparam logic [DEC_STATE_W-1:0] DEC_VNU       = DEC_VNU_ACCUM;",
        "  localparam logic [DEC_STATE_W-1:0] DEC_CHECK     = 4'd6;",
        "  localparam logic [DEC_STATE_W-1:0] DEC_DONE      = 4'd7;",
        "",
        "  localparam int MSG_W = D + 1;",
        "  localparam int MSG_MAG_LSB = 0;",
        "  localparam int MSG_SIGN_BIT = D;",
        "",
        "  localparam int ROW_STATE_MIN1_LSB = 0;",
        "  localparam int ROW_STATE_MIN2_LSB = ROW_STATE_MIN1_LSB + D;",
        "  localparam int ROW_STATE_MIN_ID_LSB = ROW_STATE_MIN2_LSB + D;",
        "  localparam int ROW_STATE_SIGN_XOR_BIT = ROW_STATE_MIN_ID_LSB + VAR_W;",
        "  localparam int ROW_STATE_W = ROW_STATE_SIGN_XOR_BIT + 1;",
        "  localparam logic [ROW_STATE_W-1:0] ROW_STATE_INIT = {",
        "    1'b0,",
        "    VAR_W'(0),",
        "    D'(MAG_MAX),",
        "    D'(MAG_MAX)",
        "  };",
        "",
        "  localparam int LANE_EDGE_VALID_BIT = 0;",
        "  localparam int LANE_EDGE_ROW_LOCAL_LSB = LANE_EDGE_VALID_BIT + 1;",
        "  localparam int LANE_EDGE_ROW_GLOBAL_LSB = LANE_EDGE_ROW_LOCAL_LSB + ROW_W;",
        "  localparam int LANE_EDGE_VAR_IDX_LSB = LANE_EDGE_ROW_GLOBAL_LSB + ROW_W;",
        "  localparam int LANE_EDGE_EDGE_SLOT_LSB = LANE_EDGE_VAR_IDX_LSB + VAR_W;",
        "  localparam int LANE_EDGE_W = LANE_EDGE_EDGE_SLOT_LSB + EDGE_W;",
        "  localparam int I_ENTRY_ROW_LOCAL_LSB = 0;",
        "  localparam int I_ENTRY_EDGE_SLOT_LSB = I_ENTRY_ROW_LOCAL_LSB + ROW_W;",
        "  localparam int I_ENTRY_W = I_ENTRY_EDGE_SLOT_LSB + EDGE_W;",
        "",
        "  localparam int unsigned H_BASE [0:H_NUM-1][0:N0-1][0:W-1] = '{",
    ]

    for case_idx, case in enumerate(cases):
        h_base = case["h_base"]
        assert isinstance(h_base, list)
        lines.append("    '{")
        for bank_idx, bank_rows in enumerate(h_base):
            lines.append("      '{")
            lines.append(format_values(bank_rows, per_line=9, indent="        "))
            lines.append("      }" + ("," if bank_idx != len(h_base) - 1 else ""))
        lines.append("    }" + ("," if case_idx != len(cases) - 1 else ""))

    lines += ["  };", "endpackage", ""]
    path.write_text("\n".join(lines))


def emit_tb(path: Path, case: dict[str, object], error_count: int, timeout_cycles: int) -> None:
    case_idx = case["idx"]
    seed = case["seed"]
    errors = case["errors"]
    assert isinstance(case_idx, int)
    assert isinstance(seed, int)
    assert isinstance(errors, list)

    lines = [
        "`timescale 1ns/1ps",
        "",
        "module tb_mdpc_decoder_random;",
        "  import mdpc_paper_pkg::*;",
        "",
        f"  localparam int ERR_COUNT = {error_count};",
        f"  localparam int TIMEOUT_CYCLES = {timeout_cycles};",
        f"  localparam int CASE_INDEX = {case_idx};",
        f"  localparam longint unsigned CASE_SEED = 64'h{seed:016X};",
        "  localparam int ERR_POS [0:ERR_COUNT-1] = '{",
    ]

    lines += [
        format_values(errors, per_line=12, indent="    "),
        "  };",
        "",
        "  logic clk;",
        "  logic rst_n;",
        "  logic start;",
        "  logic [H_SEL_W-1:0] h_sel;",
        "  logic [N-1:0] x_in;",
        "  logic done;",
        "  logic success;",
        "  logic [N-1:0] x_out;",
        "  logic [$clog2(I_MAX + 1)-1:0] iter_count;",
        "",
        "  decoder_top dut (",
        "    .i_clk(clk),",
        "    .i_rst_n(rst_n),",
        "    .i_start(start),",
        "    .i_h_sel(h_sel),",
        "    .i_x(x_in),",
        "    .o_done(done),",
        "    .o_success(success),",
        "    .o_x(x_out),",
        "    .o_iter_count(iter_count)",
        "  );",
        "",
        "  initial clk = 1'b0;",
        "  always #5 clk = ~clk;",
        "",
        "  task automatic apply_reset;",
        "    begin",
        "      rst_n = 1'b0;",
        "      start = 1'b0;",
        "      x_in = '0;",
        "      repeat (2) @(posedge clk);",
        "      rst_n = 1'b1;",
        "      @(posedge clk);",
        "    end",
        "  endtask",
        "",
        "  initial begin",
        "    int case_passed;",
        "    int cycles;",
        "    int out_weight;",
        "",
        "    h_sel = '0;",
        "    rst_n = 1'b0;",
        "    start = 1'b0;",
        "    x_in = '0;",
        "    apply_reset();",
        "",
        "    for (int idx = 0; idx < ERR_COUNT; idx++) begin",
        "      x_in[ERR_POS[idx]] = 1'b1;",
        "    end",
        "",
        "    start = 1'b1;",
        "    @(posedge clk);",
        "    start = 1'b0;",
        "",
        "    cycles = 0;",
        "    while ((done !== 1'b1) && (cycles < TIMEOUT_CYCLES)) begin",
        "      @(posedge clk);",
        "      cycles++;",
        "    end",
        "",
        "    if (done !== 1'b1) begin",
        "      $fatal(1, \"random case %0d seed=0x%016h timed out after %0d cycles\",",
        "             CASE_INDEX, CASE_SEED, cycles);",
        "    end",
        "",
        "    @(posedge clk);",
        "    out_weight = 0;",
        "    for (int idx = 0; idx < N; idx++) begin",
        "      out_weight += int'(x_out[idx]);",
        "    end",
        "    case_passed = ((success === 1'b1) && (out_weight == 0)) ? 1 : 0;",
        "    $display(\"random case %0d seed=0x%016h: pass=%0d success=%0d iterations=%0d out_weight=%0d cycles=%0d\",",
        "             CASE_INDEX, CASE_SEED, case_passed, success, iter_count, out_weight, cycles);",
        "",
        "    if (case_passed != 1) begin",
        "      $fatal(1, \"random case %0d failed\", CASE_INDEX);",
        "    end",
        "    $finish;",
        "  end",
        "endmodule",
        "",
    ]

    path.write_text("\n".join(lines))


def run_command(command: list[str], cwd: Path) -> None:
    printable = " ".join(command)
    print(f"+ {printable}", flush=True)
    subprocess.run(command, cwd=cwd, check=True)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cases", type=int, default=10, help="number of random H matrices to test")
    parser.add_argument(
        "--seed",
        type=parse_int,
        default=None,
        help="base seed; accepts decimal or 0x...; omit to auto-generate one",
    )
    parser.add_argument("--errors", type=int, default=84, help="number of error bits per test vector")
    parser.add_argument("--timeout-cycles", type=int, default=50_000_000)
    parser.add_argument("--out-dir", default="tb/generated/random", help="directory for generated SV files")
    parser.add_argument("--generate-only", action="store_true", help="only generate SV files")
    parser.add_argument("--compile-only", action="store_true", help="generate and compile, but do not run")
    parser.add_argument("--verilator", default=os.environ.get("VERILATOR", "verilator"))
    args = parser.parse_args()

    if args.cases < 1:
        raise SystemExit("--cases must be at least 1")
    if args.errors < 0 or args.errors > N:
        raise SystemExit(f"--errors must be in [0, {N}]")

    repo_root = Path(__file__).resolve().parents[1]
    out_dir = (repo_root / args.out_dir).resolve()
    out_dir.mkdir(parents=True, exist_ok=True)
    pkg_path = out_dir / "mdpc_paper_pkg.sv"
    tb_path = out_dir / "tb_mdpc_decoder_random.sv"

    base_seed = args.seed if args.seed is not None else secrets.randbits(64)
    cases = build_cases(args.cases, base_seed, args.errors)
    print(f"Generated {args.cases} case(s) with base seed {base_seed} ({base_seed:#x})")
    for case in cases:
        print(f"case {case['idx']:>3}: seed=0x{case['seed']:016X}")

    if args.generate_only:
        for case in cases:
            case_out_dir = out_dir if args.cases == 1 else out_dir / f"case_{int(case['idx']):03d}"
            case_out_dir.mkdir(parents=True, exist_ok=True)
            emit_pkg(case_out_dir / pkg_path.name, [case])
            emit_tb(case_out_dir / tb_path.name, case, args.errors, args.timeout_cycles)
            print(f"generated case {case['idx']}: {case_out_dir.relative_to(repo_root)}")
        return 0

    for case in cases:
        print(f"\n=== random case {case['idx']} seed=0x{case['seed']:016X} ===", flush=True)
        emit_pkg(pkg_path, [case])
        emit_tb(tb_path, case, args.errors, args.timeout_cycles)
        print(f"Package: {pkg_path.relative_to(repo_root)}")
        print(f"Testbench: {tb_path.relative_to(repo_root)}")

        verilator_cmd = [
            args.verilator,
            "--binary",
            "--sv",
            "-Wall",
            "-Wno-fatal",
            "-I./tb",
            "-DMDPC_PAPER_CFG",
            "--top-module",
            "tb_mdpc_decoder_random",
            str(pkg_path.relative_to(repo_root)),
            *RTL_CORE,
            str(tb_path.relative_to(repo_root)),
        ]
        run_command(verilator_cmd, repo_root)

        if not args.compile_only:
            run_command(["./obj_dir/Vtb_mdpc_decoder_random"], repo_root)

    mode = "compiled" if args.compile_only else "passed"
    print(f"\nrandom paper summary: {args.cases}/{args.cases} case(s) {mode}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
