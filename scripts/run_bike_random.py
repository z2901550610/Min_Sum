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
from ram_i_hex import row_bank_schedule_depth
from ram_i_hex import select_row_bank_count


RTL_CORE = [
    "rtl/ram_1r1w_sync_read.sv",
    "rtl/ram_1r1w_async_read.sv",
    "rtl/edge_message_pipe.sv",
    "rtl/ram_i.sv",
    "rtl/msg_signmag_to_tc.sv",
    "rtl/msg_tc_to_signmag_sat.sv",
    "rtl/decoder_ctrl.sv",
    "rtl/ram_i_idx_loader.sv",
    "rtl/ram_c.sv",
    "rtl/ram_m.sv",
    "rtl/ram_m_bank_array.sv",
    "rtl/ram_s.sv",
    "rtl/ram_syndrome.sv",
    "rtl/ram_t.sv",
    "rtl/cnu_a.sv",
    "rtl/cnu_b.sv",
    "rtl/vnu.sv",
    "rtl/decoder_top.sv",
]

PARAM_SETS = {
    "toy": {
        "n0": 2,
        "r": 8,
        "w": 3,
        "error_count": 1,
        "i_max": 4,
        "c_val": 2,
        "alpha_shift_0": 1,
        "alpha_shift_1": 3,
    },
    "bike128": {
        "n0": 3,
        "r": 8117,
        "w": 27,
        "error_count": 201,
        "i_max": 7,
        "c_val": 5,
        "alpha_shift_0": 3,
        "alpha_shift_1": 4,
    },
    "bike160": {
        "n0": 3,
        "r": 12739,
        "w": 35,
        "error_count": 263,
        "i_max": 7,
        "c_val": 5,
        "alpha_shift_0": 3,
        "alpha_shift_1": 4,
    },
    "bike256": {
        "n0": 3,
        "r": 29501,
        "w": 55,
        "error_count": 429,
        "i_max": 7,
        "c_val": 5,
        "alpha_shift_0": 3,
        "alpha_shift_1": 4,
    },
    "bike384": {
        "n0": 3,
        "r": 73421,
        "w": 83,
        "error_count": 659,
        "i_max": 7,
        "c_val": 5,
        "alpha_shift_0": 3,
        "alpha_shift_1": 6,
    },
    "bike512": {
        "n0": 3,
        "r": 156011,
        "w": 111,
        "error_count": 877,
        "i_max": 7,
        "c_val": 5,
        "alpha_shift_0": 3,
        "alpha_shift_1": 6,
    },
}


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
            for entry_idx in range(lane_depth):
                item = group_entry_list[entry_idx] if entry_idx < len(group_entry_list) else None
                if item is None:
                    entry_text.append("'0")
                else:
                    _one_idx, row_idx_global = item
                    entry_text.append(f"ROW_IDX_W'({row_idx_global})")
            lines.append("      '{" + ", ".join(entry_text) + "}" + group_suffix)
        lines.append("    }" + h_block_suffix)
    lines.append("  };")
    return "\n".join(lines)


def emit_pkg(
    path: Path,
    *,
    n0: int,
    r: int,
    w: int,
    i_max: int,
    c_val: int,
    alpha_shift_0: int,
    alpha_shift_1: int,
    l: int,
    t: int,
    h_base: list[list[int]],
    lane_depth: int,
    row_bank_count: int,
) -> None:
    group_counts, group_entries = build_first_column_tables(h_base, group_count=l)
    path.write_text(
        f"""`timescale 1ns/1ps
package bike_pkg;

  /* verilator lint_off UNUSEDPARAM */

  parameter int N0 = {n0};
  parameter int R = {r};
  parameter int W = {w};
  parameter int T = {t};
  parameter int I_MAX = {i_max};
  parameter int C_VAL = {c_val};
  parameter int ALPHA_SHIFT_0 = {alpha_shift_0};
  parameter int ALPHA_SHIFT_1 = {alpha_shift_1};
  parameter int EDGE_SLOT_DEPTH = (W + L - 1) / L;
  parameter int RAM_LANE_DEPTH = {lane_depth};

  parameter int N = N0 * R;
  parameter int L = {l};
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
  parameter int ROW_EDGE_COUNT = N0 * W;

  parameter int ONE_IDX_W = (W > 1) ? $clog2(W) : 1;
  parameter int EDGE_ID_W = (ROW_EDGE_COUNT > 1) ? $clog2(ROW_EDGE_COUNT) : 1;
  parameter int ROW_IDX_W = (R > 1) ? $clog2(R) : 1;
  parameter int LANE_IDX_W = (L > 1) ? $clog2(L) : 1;
  parameter int GROUP_IDX_W = (L > 1) ? $clog2(L) : 1;
  parameter int ROW_GROUP_W = (ROW_GROUP_DEPTH > 1) ? $clog2(ROW_GROUP_DEPTH) : 1;
  parameter int ENTRY_POS_W = (RAM_LANE_DEPTH > 1) ? $clog2(RAM_LANE_DEPTH) : 1;
  parameter int GROUP_COUNT_W = (RAM_LANE_DEPTH > 1) ? $clog2(RAM_LANE_DEPTH + 1) : 1;
  parameter int ITER_W = $clog2(I_MAX + 1);
  parameter int S_WORD_W = W;
  parameter int S_WORD_DEPTH = N;
  parameter int S_WORD_ADDR_W = COL_W;
  parameter int M_ROW_BANKS = {row_bank_count};
  parameter int M_ROW_BANK_IDX_W = (M_ROW_BANKS > 1) ? $clog2(M_ROW_BANKS) : 1;
  parameter int M_ROW_BANK_DEPTH = (R + M_ROW_BANKS - 1) / M_ROW_BANKS;
  parameter int M_ROW_BANK_ADDR_W = (M_ROW_BANK_DEPTH > 1) ? $clog2(M_ROW_BANK_DEPTH) : 1;
  parameter int M_BANKS = 2 * M_ROW_BANKS;
  parameter int M_BANK_IDX_W = (M_BANKS > 1) ? $clog2(M_BANKS) : 1;

  localparam int DEC_STATE_W = 4;
  localparam logic [DEC_STATE_W-1:0] DEC_WAIT_START       = 4'd0;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_C2V_PRIME   = 4'd4;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_OVERLAP     = 4'd5;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_V2C_DRAIN   = 4'd6;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_CHECK       = 4'd8;
  localparam logic [DEC_STATE_W-1:0] DEC_DONE             = 4'd9;

  localparam int MSG_MAG_LSB = 0;
  localparam int MSG_SIGN_BIT = D;

  localparam int COMP_C2V_MIN1_LSB = 0;
  localparam int COMP_C2V_MIN2_LSB = COMP_C2V_MIN1_LSB + D;
  localparam int COMP_C2V_MIN_ID_LSB = COMP_C2V_MIN2_LSB + D;
  localparam int COMP_C2V_SIGN_XOR_BIT = COMP_C2V_MIN_ID_LSB + EDGE_ID_W;
  localparam int COMP_C2V_W = COMP_C2V_SIGN_XOR_BIT + 1;
  localparam logic [COMP_C2V_W-1:0] COMP_C2V_INIT = {{
    1'b0,
    EDGE_ID_W'(0),
    D'(MAG_MAX),
    D'(MAG_MAX)
  }};
  localparam logic [COMP_C2V_W-1:0] FIRST_ITER_C2V_COMP = {{
    1'b0,
    EDGE_ID_W'(0),
    D'(C_VAL),
    D'(C_VAL)
  }};

  localparam int I_ENTRY_ROW_IDX_GLOBAL_LSB = 0;
  localparam int I_ENTRY_ROW_IDX_GROUP_LSB = I_ENTRY_ROW_IDX_GLOBAL_LSB;
  localparam int I_ENTRY_W = ROW_IDX_W;
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


def default_ram_lane_depth(w: int, l: int, min_depth: int) -> int:
    return max((w + l - 1) // l, min_depth)


def is_power_of_two(value: int) -> bool:
    return value > 0 and (value & (value - 1)) == 0


def emit_tb(
    path: Path,
    *,
    seed: int,
    timeout_cycles: int,
    syndrome_hex: str,
    target_hex: str,
    ram_i_hex_prefix: str,
    h_base: list[list[int]],
) -> None:
    supports = ",\n    ".join(sv_array(support) for support in h_base)
    path.write_text(
        f"""`timescale 1ns/1ps

module tb_bike_decoder_random;
  import bike_pkg::*;

  localparam int TEST_SEED = {seed};
  localparam int TIMEOUT_CYCLES = {timeout_cycles};
  localparam logic [R-1:0] INPUT_SYNDROME = {syndrome_hex};
  localparam logic [N-1:0] TARGET_ERROR = {target_hex};
  localparam int unsigned TEST_SUPPORTS [0:N0-1][0:W-1] = '{{
    {supports}
  }};

  logic clk;
  logic rst_n;
  logic start;
  logic done;
  logic syndrome_we;
  logic [ROW_IDX_W-1:0] syndrome_addr;
  logic syndrome_wdata;
  logic h_load_start;
  logic h_load_valid;
  logic [ROW_IDX_W-1:0] h_load_row_idx_global[0:L-1];
  /* verilator lint_off UNUSEDSIGNAL */
  logic h_load_ready;
  logic h_load_busy;
  logic h_load_done;
  logic [H_BLOCK_W-1:0] h_load_request_h_block_idx;
  logic [ENTRY_POS_W-1:0] h_load_request_entry_pos;
  /* verilator lint_on UNUSEDSIGNAL */
  logic [COL_W-1:0] e_read_col_idx;
  logic e_rdata;
  logic [N-1:0] e_out;
  logic [ITER_W-1:0] iter_count;

  decoder_top #(
    .RAM_I_HEX_PREFIX("{ram_i_hex_prefix}"),
    .RAM_I_HEX_TAG("")
  ) dut (
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_start(start),
    .i_syndrome_we(syndrome_we),
    .i_syndrome_addr(syndrome_addr),
    .i_syndrome_wdata(syndrome_wdata),
    .i_h_load_start(h_load_start),
    .i_h_load_valid(h_load_valid),
    .i_h_load_row_idx_global(h_load_row_idx_global),
    .i_e_read_col_idx(e_read_col_idx),
    .o_h_load_ready(h_load_ready),
    .o_h_load_busy(h_load_busy),
    .o_h_load_done(h_load_done),
    .o_h_load_request_h_block_idx(h_load_request_h_block_idx),
    .o_h_load_request_entry_pos(h_load_request_entry_pos),
    .o_done(done),
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
            row_idx = ROW_IDX_W'((TEST_SUPPORTS[h_block_idx][edge_idx] + col_idx) % R);
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
    bit exact_match;

    rst_n = 1'b0;
    start = 1'b0;
    h_load_start = 1'b0;
    h_load_valid = 1'b0;
    syndrome_we = 1'b0;
    syndrome_addr = '0;
    syndrome_wdata = 1'b0;
    e_read_col_idx = '0;
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      h_load_row_idx_global[lane_idx] = '0;
    end
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

    for (int clear_idx = 0; clear_idx < N; clear_idx++) begin
      e_out[clear_idx] = 1'b0;
    end
    for (int col_idx = 0; col_idx < N; col_idx++) begin
      e_read_col_idx = COL_W'(col_idx);
      @(posedge clk);
      #1;
      e_out[col_idx] = e_rdata;
    end

    residual = residual_of(e_out);
    exact_match = (e_out === TARGET_ERROR);

    $display(
      "seed=%0d iter=%0d cycles=%0d target_weight=%0d output_weight=%0d residual_weight=%0d exact=%0d",
      TEST_SEED,
      iter_count,
      cycles,
      weight_n(TARGET_ERROR),
      weight_n(e_out),
      weight_r(residual),
      exact_match
    );
    if (residual != '0) begin
      $fatal(1, "seed=%0d residual check failed; residual_weight=%0d", TEST_SEED,
             weight_r(residual));
    end
    if (!exact_match) begin
      $fatal(1, "seed=%0d exact check failed; target_weight=%0d output_weight=%0d", TEST_SEED,
             weight_n(TARGET_ERROR), weight_n(e_out));
    end
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

    n = args.r * args.n0
    if args.error_count < 0 or args.error_count > n:
        raise ValueError(f"--error-count must be between 0 and {n}")
    if args.w < 1 or args.w > args.r:
        raise ValueError("--w must be between 1 and --r")

    h_base = [sample_support(rng, args.r, args.w) for _ in range(args.n0)]
    error_positions = sorted(rng.sample(range(n), args.error_count))
    error_bits = [0 for _ in range(n)]
    for pos in error_positions:
        error_bits[pos] = 1
    syndrome = calc_syndrome(h_base, error_bits, args.r, args.w)
    group_counts, _ = build_first_column_tables(h_base, group_count=args.parallel_l)
    target_lane_depth = default_ram_lane_depth(args.w, args.parallel_l, args.ram_lane_min_depth)
    source_lane_depth = lane_depth_from_counts(group_counts)
    row_bank_count = (
        args.ram_m_row_banks
        if args.ram_m_row_banks is not None
        else select_row_bank_count(h_base, args.r, args.parallel_l, target_lane_depth)
    )
    row_bank_depth = row_bank_schedule_depth(
        h_base,
        args.r,
        row_bank_count,
        args.parallel_l,
    )
    required_lane_depth = max(
        source_lane_depth,
        row_bank_depth,
    )
    lane_depth = (
        args.ram_lane_depth
        if args.ram_lane_depth is not None
        else max(required_lane_depth, target_lane_depth)
    )
    if lane_depth < required_lane_depth:
        raise ValueError(
            f"RAM lane depth {lane_depth} is smaller than required depth {required_lane_depth} "
            f"for seed {seed}"
        )

    pkg_path = out_dir / "bike_pkg.sv"
    tb_path = out_dir / "tb_bike_decoder_random.sv"
    emit_pkg(
        pkg_path,
        n0=args.n0,
        r=args.r,
        w=args.w,
        i_max=args.i_max,
        c_val=args.c_val,
        alpha_shift_0=args.alpha_shift_0,
        alpha_shift_1=args.alpha_shift_1,
        l=args.parallel_l,
        t=args.error_count,
        h_base=h_base,
        lane_depth=lane_depth,
        row_bank_count=row_bank_count,
    )
    generate_hex_files(
        h_base,
        args.r,
        args.w,
        "",
        out_dir,
        group_count=args.parallel_l,
        memory_depth=lane_depth,
    )
    emit_tb(
        tb_path,
        seed=seed,
        timeout_cycles=args.timeout_cycles,
        syndrome_hex=bit_vector_hex(syndrome, args.r),
        target_hex=bit_vector_hex(error_bits, n),
        ram_i_hex_prefix=str((sv_case_dir / "ram_i").as_posix()),
        h_base=h_base,
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
    parser.add_argument(
        "--param-set",
        choices=sorted(PARAM_SETS),
        default=None,
        help="Named decoder parameter set. Explicit command-line values override the preset.",
    )
    parser.add_argument("--error-count", type=int, default=None)
    parser.add_argument("--timeout-cycles", type=int, default=200000)
    parser.add_argument("--out-dir", default="tb/generated/bike_random")
    parser.add_argument("--verilator", default="verilator")
    parser.add_argument("--n0", type=int, default=None)
    parser.add_argument("--r", type=int, default=None)
    parser.add_argument("--w", type=int, default=None)
    parser.add_argument("--i-max", type=int, default=None)
    parser.add_argument("--c-val", type=int, default=None)
    parser.add_argument("--alpha-shift-0", type=int, default=None)
    parser.add_argument("--alpha-shift-1", type=int, default=None)
    parser.add_argument("--parallel-l", type=int, default=8)
    parser.add_argument("--ram-lane-min-depth", type=int, default=3)
    parser.add_argument(
        "--ram-lane-depth",
        type=int,
        default=None,
        help="Fixed RAM-I/S/T lane capacity. Defaults to the speed-safe schedule depth.",
    )
    parser.add_argument(
        "--ram-m-row-banks",
        type=int,
        default=None,
        help="Fixed row-bank count for RAM-M. Defaults to the first speed-safe power of two.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    defaults = PARAM_SETS[args.param_set or "toy"]
    for key, value in defaults.items():
        attr = key.replace("-", "_")
        if getattr(args, attr) is None:
            setattr(args, attr, value)
    repo_root = Path(__file__).resolve().parents[1]
    if args.trials < 1:
        raise ValueError("--trials must be positive")
    if args.parallel_l < 1:
        raise ValueError("--parallel-l must be positive")
    if args.n0 < 1:
        raise ValueError("--n0 must be positive")
    if not is_power_of_two(args.parallel_l):
        raise ValueError("--parallel-l must be a power of two")
    if args.ram_lane_depth is not None and args.ram_lane_depth < 1:
        raise ValueError("--ram-lane-depth must be positive")
    if args.ram_lane_depth is not None and args.ram_lane_depth < 3:
        raise ValueError("--ram-lane-depth must be at least 3")
    if args.ram_lane_min_depth < 3:
        raise ValueError("--ram-lane-min-depth must be at least 3")
    if args.ram_m_row_banks is not None and args.ram_m_row_banks < 1:
        raise ValueError("--ram-m-row-banks must be positive")

    for case_idx in range(args.trials):
        seed = args.base_seed + case_idx
        print(f"== BIKE random case {case_idx + 1}/{args.trials}: seed={seed} ==", flush=True)
        run_case(args, repo_root, case_idx, seed)

    print(f"PASS: ran {args.trials} BIKE random decoder testbench(es) one at a time")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
