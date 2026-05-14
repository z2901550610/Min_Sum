#!/usr/bin/env python3
"""Generate and run small BIKE-shaped decoder simulations one seed at a time."""

from __future__ import annotations

import argparse
import random
import shlex
import subprocess
from pathlib import Path

from ram_i_hex import first_column_tables as build_first_column_tables
from ram_i_hex import generate_hex_files
from ram_i_hex import lane_depth_from_counts


RTL_CORE = [
    "rtl/ram_i.sv",
    "rtl/h_shift.sv",
    "rtl/msg_signmag_to_tc.sv",
    "rtl/msg_tc_to_signmag_sat.sv",
    "rtl/decoder_ctrl.sv",
    "rtl/ram_c.sv",
    "rtl/ram_m.sv",
    "rtl/ram_s.sv",
    "rtl/ram_syndrome.sv",
    "rtl/ram_t.sv",
    "rtl/cnu_a.sv",
    "rtl/cnu_b.sv",
    "rtl/vnu.sv",
    "rtl/decoder_top.sv",
]


def bit_vector_hex(bits: list[int], width: int) -> str:
    value = 0
    for idx, bit in enumerate(bits):
        if bit:
            value |= 1 << idx
    hex_digits = max(1, (width + 3) // 4)
    return f"{width}'h{value:0{hex_digits}x}"


def sample_support(rng: random.Random, r: int, w: int) -> list[int]:
    return sorted(rng.sample(range(r), w))


def calc_syndrome(h_base: list[list[int]], error_bits: list[int], r: int, w: int) -> list[int]:
    syndrome = [0 for _ in range(r)]
    for var_idx, bit in enumerate(error_bits):
        if not bit:
            continue
        h_block_idx = var_idx // r
        col = var_idx % r
        for edge_idx in range(w):
            row_idx = (h_base[h_block_idx][edge_idx] + col) % r
            syndrome[row_idx] ^= 1
    return syndrome


def sv_array(values: list[int]) -> str:
    return "'{" + ", ".join(str(value) for value in values) + "}"


def render_group_count_param(group_counts: list[list[int]]) -> str:
    lines = ["  localparam logic [GROUP_COUNT_W-1:0] QC_FIRST_COL_GROUP_COUNT [0:N0-1][0:L-1] = '{"]
    for h_block_idx, h_block_group_counts in enumerate(group_counts):
        suffix = "," if h_block_idx != len(group_counts) - 1 else ""
        lines.append(
            "    '{"
            + ", ".join(f"GROUP_COUNT_W'({count})" for count in h_block_group_counts)
            + "}"
            + suffix
        )
    lines.append("  };")
    return "\n".join(lines)


def render_group_entry_param(
    group_entries: list[list[list[tuple[int, int] | None]]],
    lane_depth: int,
) -> str:
    lines = ["  localparam logic [I_ENTRY_W-1:0] QC_FIRST_COL_GROUP_ENTRY [0:N0-1][0:L-1][0:RAM_LANE_DEPTH-1] = '{"]
    for h_block_idx, h_block_group_entries in enumerate(group_entries):
        h_block_suffix = "," if h_block_idx != len(group_entries) - 1 else ""
        lines.append("    '{")
        for group_idx, group_entry_list in enumerate(h_block_group_entries):
            group_suffix = "," if group_idx != len(h_block_group_entries) - 1 else ""
            entry_text = []
            for item in group_entry_list[:lane_depth]:
                if item is None:
                    entry_text.append("'0")
                else:
                    one_idx, row_idx_group = item
                    entry_text.append(f"{{ONE_IDX_W'({one_idx}), ROW_GROUP_W'({row_idx_group})}}")
            lines.append("      '{" + ", ".join(entry_text) + "}" + group_suffix)
        lines.append("    }" + h_block_suffix)
    lines.append("  };")
    return "\n".join(lines)


def emit_pkg(
    path: Path,
    *,
    r: int,
    w: int,
    i_max: int,
    c_val: int,
    alpha_shift_0: int,
    alpha_shift_1: int,
    h_base: list[list[int]],
) -> None:
    group_counts, group_entries = build_first_column_tables(h_base)
    lane_depth = lane_depth_from_counts(group_counts)
    path.write_text(
        f"""`timescale 1ns/1ps
package bike_pkg;

  /* verilator lint_off UNUSEDPARAM */

  parameter int N0 = 2;
  parameter int R = {r};
  parameter int W = {w};
  parameter int I_MAX = {i_max};
  parameter int C_VAL = {c_val};
  parameter int ALPHA_SHIFT_0 = {alpha_shift_0};
  parameter int ALPHA_SHIFT_1 = {alpha_shift_1};
  parameter int RAM_LANE_DEPTH = {lane_depth};

  parameter int N = N0 * R;
  parameter int L = 2;
  parameter int D = 4;
  parameter int ALPHA_FRAC_W = 6;
  parameter int MAG_MAX = (1 << D) - 1;
  parameter int MSG_W = D + 1;
  parameter int ROW_SEG_SIZE = (R + L - 1) / L;
  parameter int ROW_GROUP_DEPTH = ROW_SEG_SIZE;
  parameter int VNU_TC_W = MSG_W + ((W > 1) ? $clog2(W + 1) : 1);
  parameter int COL_W = (N > 1) ? $clog2(N) : 1;
  parameter int H_BLOCK_W = (N0 > 1) ? $clog2(N0) : 1;
  parameter int H_NUM = 1;

  parameter int ONE_IDX_W = (W > 1) ? $clog2(W) : 1;
  parameter int ROW_IDX_W = (R > 1) ? $clog2(R) : 1;
  parameter int GROUP_IDX_W = (L > 1) ? $clog2(L) : 1;
  parameter int ROW_GROUP_W = ROW_IDX_W - GROUP_IDX_W;
  parameter int ENTRY_POS_W = (RAM_LANE_DEPTH > 1) ? $clog2(RAM_LANE_DEPTH) : 1;
  parameter int GROUP_COUNT_W = (RAM_LANE_DEPTH > 1) ? $clog2(RAM_LANE_DEPTH + 1) : 1;

  localparam int DEC_STATE_W = 4;
  localparam logic [DEC_STATE_W-1:0] DEC_WAIT_START       = 4'd0;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_C2V_PRIME   = 4'd4;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_OVERLAP     = 4'd5;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_V2C_DRAIN   = 4'd6;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_CHECK       = 4'd8;
  localparam logic [DEC_STATE_W-1:0] DEC_DONE             = 4'd9;

  localparam int DEC_PHASE_W = 5;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_WAIT                = 5'd0;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_PRIME_READ          = 5'd7;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_PRIME_WRITE         = 5'd8;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_OVERLAP_ACCUM_READ  = 5'd9;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_OVERLAP_ACCUM_USE   = 5'd10;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_OVERLAP_PREP        = 5'd11;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_OVERLAP_EMIT_READ   = 5'd12;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_OVERLAP_EMIT_CNU_A  = 5'd13;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_OVERLAP_EMIT_WRITE  = 5'd14;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_PROD_FINISH_READ    = 5'd15;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_PROD_FINISH_WRITE   = 5'd16;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_DRAIN_ACCUM_READ    = 5'd17;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_DRAIN_ACCUM_USE     = 5'd18;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_DRAIN_PREP          = 5'd19;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_DRAIN_EMIT_READ     = 5'd20;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_DRAIN_EMIT_CNU_A    = 5'd21;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_DRAIN_EMIT_WRITE    = 5'd22;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_ITER_CHECK          = 5'd23;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_DONE                = 5'd24;

  localparam int MSG_MAG_LSB = 0;
  localparam int MSG_SIGN_BIT = D;

  localparam int COMP_C2V_MIN1_LSB = 0;
  localparam int COMP_C2V_MIN2_LSB = COMP_C2V_MIN1_LSB + D;
  localparam int COMP_C2V_MIN_ID_LSB = COMP_C2V_MIN2_LSB + D;
  localparam int COMP_C2V_SIGN_XOR_BIT = COMP_C2V_MIN_ID_LSB + COL_W;
  localparam int COMP_C2V_W = COMP_C2V_SIGN_XOR_BIT + 1;
  localparam logic [COMP_C2V_W-1:0] COMP_C2V_INIT = {{
    1'b0,
    COL_W'(0),
    D'(MAG_MAX),
    D'(MAG_MAX)
  }};

  localparam int I_ENTRY_ROW_IDX_GROUP_LSB = 0;
  localparam int I_ENTRY_ONE_IDX_LSB = I_ENTRY_ROW_IDX_GROUP_LSB + ROW_GROUP_W;
  localparam int I_ENTRY_W = I_ENTRY_ONE_IDX_LSB + ONE_IDX_W;

  localparam int unsigned H_BASE [0:H_NUM-1][0:N0-1][0:W-1] = '{{
    '{{
      {sv_array(h_base[0])},
      {sv_array(h_base[1])}
    }}
  }};
{render_group_count_param(group_counts)}
{render_group_entry_param(group_entries, lane_depth)}
  localparam logic [GROUP_COUNT_W-1:0] QC_FIRST_COL_LANE_COUNT [0:N0-1][0:L-1] =
    QC_FIRST_COL_GROUP_COUNT;
  localparam logic [I_ENTRY_W-1:0] QC_FIRST_COL_LANE_ENTRY [0:N0-1][0:L-1][0:RAM_LANE_DEPTH-1] =
    QC_FIRST_COL_GROUP_ENTRY;
  localparam logic [GROUP_COUNT_W-1:0] QC_FIRST_COL_ROW_GROUP_COUNT [0:N0-1][0:L-1] =
    QC_FIRST_COL_GROUP_COUNT;
  localparam logic [I_ENTRY_W-1:0] QC_FIRST_COL_ROW_GROUP_ENTRY [0:N0-1][0:L-1][0:RAM_LANE_DEPTH-1] =
    QC_FIRST_COL_GROUP_ENTRY;
  /* verilator lint_on UNUSEDPARAM */
endpackage
""",
        encoding="utf-8",
    )


def emit_tb(
    path: Path,
    *,
    seed: int,
    timeout_cycles: int,
    syndrome_hex: str,
    target_hex: str,
    require_success: bool,
    ram_i0_hex_stem: str,
    ram_i1_hex_stem: str,
) -> None:
    require_success_sv = "1'b1" if require_success else "1'b0"
    path.write_text(
        f"""`timescale 1ns/1ps

module tb_bike_decoder_random;
  import bike_pkg::*;

  localparam int TEST_SEED = {seed};
  localparam int TIMEOUT_CYCLES = {timeout_cycles};
  localparam bit REQUIRE_SUCCESS = {require_success_sv};
  localparam logic [R-1:0] INPUT_SYNDROME = {syndrome_hex};
  localparam logic [N-1:0] TARGET_ERROR = {target_hex};

  logic clk;
  logic rst_n;
  logic start;
  logic done;
  logic success;
  logic syndrome_we;
  logic [ROW_IDX_W-1:0] syndrome_addr;
  logic syndrome_wdata;
  logic [COL_W-1:0] e_read_col_idx;
  logic e_rdata;
  logic [N-1:0] e_out;
  logic [$clog2(I_MAX + 1)-1:0] iter_count;

  decoder_top #(
    .RAM_I0_HEX_STEM("{ram_i0_hex_stem}"),
    .RAM_I1_HEX_STEM("{ram_i1_hex_stem}"),
    .RAM_I_HEX_TAG("")
  ) dut (
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_start(start),
    .i_syndrome_we(syndrome_we),
    .i_syndrome_addr(syndrome_addr),
    .i_syndrome_wdata(syndrome_wdata),
    .i_e_read_col_idx(e_read_col_idx),
    .o_done(done),
    .o_success(success),
    .o_e_rdata(e_rdata),
    .o_iter_count(iter_count)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  task automatic load_syndrome(input logic [R-1:0] syndrome);
    begin
      for (int row_idx = 0; row_idx < R; row_idx++) begin
        syndrome_we = 1'b1;
        syndrome_addr = ROW_IDX_W'(row_idx);
        syndrome_wdata = syndrome[row_idx];
        @(posedge clk);
      end
      syndrome_we = 1'b0;
      syndrome_addr = '0;
      syndrome_wdata = 1'b0;
      @(posedge clk);
    end
  endtask

  function automatic logic [R-1:0] residual_of(input logic [N-1:0] candidate);
    logic [R-1:0] residual;
    int var_idx;
    logic [H_BLOCK_W-1:0] h_block_idx;
    int col_idx;
    int edge_idx;
    logic [ROW_IDX_W-1:0] row_idx;
    begin
      residual = INPUT_SYNDROME;
      for (var_idx = 0; var_idx < N; var_idx++) begin
        if (candidate[var_idx]) begin
          h_block_idx = H_BLOCK_W'(var_idx / R);
          col_idx = var_idx % R;
          for (edge_idx = 0; edge_idx < W; edge_idx++) begin
            row_idx = ROW_IDX_W'((H_BASE[0][h_block_idx][edge_idx] + col_idx) % R);
            residual[row_idx] = residual[row_idx] ^ 1'b1;
          end
        end
      end
      return residual;
    end
  endfunction

  function automatic int weight_r(input logic [R-1:0] bits);
    int idx;
    begin
      weight_r = 0;
      for (idx = 0; idx < R; idx++) begin
        weight_r += bits[idx] ? 1 : 0;
      end
    end
  endfunction

  function automatic int weight_n(input logic [N-1:0] bits);
    int idx;
    begin
      weight_n = 0;
      for (idx = 0; idx < N; idx++) begin
        weight_n += bits[idx] ? 1 : 0;
      end
    end
  endfunction

  initial begin
    int cycles;
    logic [R-1:0] residual;

    rst_n = 1'b0;
    start = 1'b0;
    syndrome_we = 1'b0;
    syndrome_addr = '0;
    syndrome_wdata = 1'b0;
    e_read_col_idx = '0;
    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);

    load_syndrome(INPUT_SYNDROME);

    start = 1'b1;
    @(posedge clk);
    start = 1'b0;

    cycles = 0;
    while ((done !== 1'b1) && (cycles < TIMEOUT_CYCLES)) begin
      cycles += 1;
      @(posedge clk);
    end
    if (done !== 1'b1) begin
      $fatal(1, "seed=%0d timeout after %0d cycles", TEST_SEED, cycles);
    end

    e_out = '0;
    for (int col_idx = 0; col_idx < N; col_idx++) begin
      e_read_col_idx = COL_W'(col_idx);
      @(posedge clk);
      #1;
      e_out[col_idx] = e_rdata;
    end

    residual = residual_of(e_out);
    if (success !== 1'b0) begin
      $fatal(1, "seed=%0d fixed-iteration core should leave success low", TEST_SEED);
    end
    if (REQUIRE_SUCCESS && (residual != '0)) begin
      $fatal(1, "seed=%0d did not converge; residual_weight=%0d", TEST_SEED, weight_r(residual));
    end

    $display(
      "seed=%0d success=%0d iter=%0d cycles=%0d target_weight=%0d output_weight=%0d residual_weight=%0d exact=%0d",
      TEST_SEED,
      success,
      iter_count,
      cycles,
      weight_n(TARGET_ERROR),
      weight_n(e_out),
      weight_r(residual),
      (e_out === TARGET_ERROR)
    );
    $finish;
  end
endmodule
""",
        encoding="utf-8",
    )


def run_command(command: list[str], cwd: Path) -> None:
    exe = Path(command[0]).name
    if "verilator" in exe:
        top = "unknown"
        if "--top-module" in command:
            top_idx = command.index("--top-module")
            if top_idx + 1 < len(command):
                top = command[top_idx + 1]
        print(f"+ verilator {top}", flush=True)
    elif exe == "run_quiet.py" and len(command) > 1:
        print(f"+ sim {Path(command[1]).name}", flush=True)
    else:
        print("+ " + shlex.join(command), flush=True)
    subprocess.run(command, cwd=cwd, check=True)


def run_case(args: argparse.Namespace, repo_root: Path, case_idx: int, seed: int) -> bool:
    rng = random.Random(seed)
    out_dir_arg = Path(args.out_dir)
    case_dir = out_dir_arg / f"case_{case_idx:03d}_seed_{seed}"
    out_dir = case_dir if case_dir.is_absolute() else repo_root / case_dir
    sv_case_dir = out_dir if case_dir.is_absolute() else case_dir
    obj_dir = out_dir / "obj_dir"
    out_dir.mkdir(parents=True, exist_ok=True)

    n = args.r * 2
    if args.error_count < 0 or args.error_count > n:
        raise ValueError(f"--error-count must be between 0 and {n}")
    if args.w < 1 or args.w > args.r:
        raise ValueError("--w must be between 1 and --r")

    h_base = [sample_support(rng, args.r, args.w), sample_support(rng, args.r, args.w)]
    error_positions = sorted(rng.sample(range(n), args.error_count))
    error_bits = [0 for _ in range(n)]
    for pos in error_positions:
        error_bits[pos] = 1
    syndrome = calc_syndrome(h_base, error_bits, args.r, args.w)

    pkg_path = out_dir / "bike_pkg.sv"
    tb_path = out_dir / "tb_bike_decoder_random.sv"
    emit_pkg(
        pkg_path,
        r=args.r,
        w=args.w,
        i_max=args.i_max,
        c_val=args.c_val,
        alpha_shift_0=args.alpha_shift_0,
        alpha_shift_1=args.alpha_shift_1,
        h_base=h_base,
    )
    generate_hex_files(h_base, args.r, args.w, "", out_dir)
    emit_tb(
        tb_path,
        seed=seed,
        timeout_cycles=args.timeout_cycles,
        syndrome_hex=bit_vector_hex(syndrome, args.r),
        target_hex=bit_vector_hex(error_bits, n),
        require_success=args.require_success,
        ram_i0_hex_stem=str((sv_case_dir / "ram_i0").as_posix()),
        ram_i1_hex_stem=str((sv_case_dir / "ram_i1").as_posix()),
    )

    command = [
        args.verilator,
        "--binary",
        "--sv",
        "-DBIKE_PKG_EXTERNAL",
        "-DBIKE_SIM_DEBUG",
        "-Wall",
        "-Wno-fatal",
        "-I./tb",
        "--Mdir",
        str(obj_dir),
        "--top-module",
        "tb_bike_decoder_random",
        str(pkg_path),
        *RTL_CORE,
        str(tb_path),
    ]
    run_command(command, repo_root)
    run_command(["scripts/run_quiet.py", str(obj_dir / "Vtb_bike_decoder_random"), "+verilator+quiet"], repo_root)
    return True


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate BIKE-shaped random decoder testbenches and run them one at a time."
    )
    parser.add_argument("--base-seed", type=int, default=1)
    parser.add_argument("--trials", type=int, default=8)
    parser.add_argument("--error-count", type=int, default=1)
    parser.add_argument("--timeout-cycles", type=int, default=200000)
    parser.add_argument("--out-dir", default="tb/generated/bike_random")
    parser.add_argument("--verilator", default="verilator")
    parser.add_argument("--r", type=int, default=8)
    parser.add_argument("--w", type=int, default=3)
    parser.add_argument("--i-max", type=int, default=4)
    parser.add_argument("--c-val", type=int, default=9)
    parser.add_argument("--alpha-shift-0", type=int, default=4)
    parser.add_argument("--alpha-shift-1", type=int, default=5)
    parser.add_argument(
        "--require-success",
        action="store_true",
        help="Treat non-convergence as a test failure instead of only checking flag/residual consistency.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    repo_root = Path(__file__).resolve().parents[1]
    if args.trials < 1:
        raise ValueError("--trials must be positive")

    for case_idx in range(args.trials):
        seed = args.base_seed + case_idx
        print(f"== BIKE random case {case_idx + 1}/{args.trials}: seed={seed} ==", flush=True)
        run_case(args, repo_root, case_idx, seed)

    print(f"PASS: ran {args.trials} BIKE random decoder testbench(es) one at a time")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
