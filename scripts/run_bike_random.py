#!/usr/bin/env python3
"""Generate and run small BIKE-shaped decoder simulations one seed at a time."""

from __future__ import annotations

import argparse
import random
import shlex
import subprocess
from pathlib import Path

RTL_CORE = [
    "rtl/reset_sync.sv",
    "rtl/h_matrix_mem.sv",
    "rtl/edge_addr_gen.sv",
    "rtl/tile_scheduler.sv",
    "rtl/check_state_ram.sv",
    "rtl/msg_sign_ram.sv",
    "rtl/tile_accum_ram.sv",
    "rtl/c2v_cache_ram.sv",
    "rtl/msg_tc_to_signmag_sat.sv",
    "rtl/vnu_update.sv",
    "rtl/decision_ram.sv",
    "rtl/cnu_a.sv",
    "rtl/cnu_b.sv",
    "rtl/msg_signmag_to_tc.sv",
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
        "msg_bits": 5,
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
        "msg_bits": 5,
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
        "msg_bits": 5,
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
        "msg_bits": 5,
        "alpha_shift_0": 3,
        "alpha_shift_1": 4,
    },
    "bike384": {
        "n0": 3,
        "r": 59069,
        "w": 83,
        "error_count": 659,
        "i_max": 7,
        "c_val": 5,
        "msg_bits": 5,
        "alpha_shift_0": 3,
        "alpha_shift_1": 6,
    },
    "bike512": {
        "n0": 3,
        "r": 108587,
        "w": 111,
        "error_count": 877,
        "i_max": 7,
        "c_val": 7,
        "msg_bits": 5,
        "alpha_shift_0": 4,
        "alpha_shift_1": 0,
    },
}


def bit_vector_hex(bits: list[int], width: int) -> str:
    value = 0
    for idx, bit in enumerate(bits):
        if bit:
            value |= 1 << idx
    hex_digits = max(1, (width + 3) // 4)
    return f"{width}'h{value:0{hex_digits}x}"


def sample_h_base_rows(rng: random.Random, r: int, w: int) -> list[int]:
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


def sv_int_array(values: list[int]) -> str:
    if not values:
        return "'{0}"
    chunks = []
    for idx in range(0, len(values), 32):
        chunks.append("    " + ", ".join(str(value) for value in values[idx : idx + 32]))
    return "'{\n" + ",\n".join(chunks) + "\n  }"


def emit_pkg(
    path: Path,
    *,
    n0: int,
    r: int,
    w: int,
    i_max: int,
    c_val: int,
    msg_bits: int,
    alpha_shift_0: int,
    alpha_shift_1: int,
    l: int,
    c_tile: int,
    t: int,
) -> None:
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
  parameter int MSG_BITS_CONFIG = {msg_bits};
  parameter int ALPHA_SHIFT_0 = {alpha_shift_0};
  parameter int ALPHA_SHIFT_1 = {alpha_shift_1};

  parameter int N = N0 * R;
  parameter int L = {l};
  parameter int D = (MSG_BITS_CONFIG > 1) ? (MSG_BITS_CONFIG - 1) : 1;
  parameter int ALPHA_FRAC_W = 6;
  parameter int MAG_MAX = (1 << D) - 1;
  parameter int MSG_W = D + 1;
  parameter int ROW_SEG_SIZE = (R + L - 1) / L;
  parameter int VNU_TC_W = MSG_W + ((W > 1) ? $clog2(W + 1) : 1);
  parameter int C_TILE_CONFIG = {c_tile};
  parameter int C_TILE = (C_TILE_CONFIG > R) ? R : C_TILE_CONFIG;
  parameter int Q_BASE = (C_TILE + L - 1) / L;
  parameter int Q_TILE = Q_BASE + 1;
  parameter int TILE_COUNT = (R + C_TILE - 1) / C_TILE;
  parameter int TILES_TOTAL = N0 * TILE_COUNT;
  parameter int TILE_ID_W = (TILES_TOTAL > 1) ? $clog2(TILES_TOTAL) : 1;
  parameter int TILE_IDX_W = (TILE_COUNT > 1) ? $clog2(TILE_COUNT) : 1;
  parameter int TILE_OFF_W = (C_TILE > 1) ? $clog2(C_TILE) : 1;
  parameter int Q_SEQ_W = (Q_TILE > 1) ? $clog2(Q_TILE) : 1;
  parameter int ROW_BANK_AW = (ROW_SEG_SIZE > 1) ? $clog2(ROW_SEG_SIZE) : 1;
  parameter int ACC_W = VNU_TC_W;
  parameter int COL_W = (N > 1) ? $clog2(N) : 1;
  parameter int H_BLOCK_W = (N0 > 1) ? $clog2(N0) : 1;
  parameter int ROW_EDGE_COUNT = N0 * W;

  parameter int ONE_IDX_W = (W > 1) ? $clog2(W) : 1;
  parameter int EDGE_ID_W = (ROW_EDGE_COUNT > 1) ? $clog2(ROW_EDGE_COUNT) : 1;
  parameter int ROW_IDX_W = (R > 1) ? $clog2(R) : 1;
  parameter int LANE_IDX_W = (L > 1) ? $clog2(L) : 1;
  parameter int L_SHIFT = (L > 1) ? $clog2(L) : 0;
  parameter int ITER_W = $clog2(I_MAX + 1);

  localparam int DEC_STATE_W = 4;
  localparam logic [DEC_STATE_W-1:0] DEC_WAIT_START       = 4'd0;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_CLEAR       = 4'd3;
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

  /* verilator lint_on UNUSEDPARAM */
endpackage
""",
        encoding="utf-8",
    )


def is_power_of_two(value: int) -> bool:
    return value > 0 and (value & (value - 1)) == 0


def emit_tb(
    path: Path,
    *,
    seed: int,
    timeout_cycles: int,
    syndrome_positions: list[int],
    error_positions: list[int],
    h_base: list[list[int]],
) -> None:
    h_base_rows = ",\n    ".join(sv_array(row_list) for row_list in h_base)
    syndrome_array_depth = max(1, len(syndrome_positions))
    error_array_depth = max(1, len(error_positions))
    path.write_text(
        f"""`timescale 1ns/1ps

module tb_bike_decoder_random;
  import bike_pkg::*;

  localparam int TEST_SEED = {seed};
  localparam int TIMEOUT_CYCLES = {timeout_cycles};
  localparam int SYNDROME_WEIGHT = {len(syndrome_positions)};
  localparam int ERROR_WEIGHT = {len(error_positions)};
  localparam int unsigned SYNDROME_POS [0:{syndrome_array_depth - 1}] = {sv_int_array(syndrome_positions)};
  localparam int unsigned ERROR_POS [0:{error_array_depth - 1}] = {sv_int_array(error_positions)};
  localparam int unsigned TEST_H_BASE_ROWS [0:N0-1][0:W-1] = '{{
    {h_base_rows}
  }};

  logic clk;
  logic rst_n;
  logic start;
  logic done;
  logic syndrome_we;
  logic [ROW_IDX_W-1:0] syndrome_addr;
  logic syndrome_wdata;
  logic h_we;
  logic [H_BLOCK_W-1:0] h_load_block_idx;
  logic [ONE_IDX_W-1:0] h_load_one_idx;
  logic [ROW_IDX_W-1:0] h_base_row;
  logic h_loaded;
  logic h_error;
  logic [COL_W-1:0] e_read_col_idx;
  logic e_rdata;
  logic [N-1:0] e_out;
  logic [ITER_W-1:0] iter_count;

  decoder_top dut (
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_start(start),
    .i_syndrome_we(syndrome_we),
    .i_syndrome_addr(syndrome_addr),
    .i_syndrome_wdata(syndrome_wdata),
    .i_h_we(h_we),
    .i_h_block_idx(h_load_block_idx),
    .i_h_one_idx(h_load_one_idx),
    .i_h_base_row(h_base_row),
    .i_e_read_col_idx(e_read_col_idx),
    .o_h_loaded(h_loaded),
    .o_h_error(h_error),
    .o_done(done),
    .o_e_rdata(e_rdata),
    .o_iter_count(iter_count)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  function automatic logic syndrome_bit_at(input int row_idx);
    begin
      syndrome_bit_at = 1'b0;
      for (int idx = 0; idx < SYNDROME_WEIGHT; idx++) begin
        if (SYNDROME_POS[idx] == row_idx) begin
          syndrome_bit_at = 1'b1;
        end
      end
    end
  endfunction

  function automatic logic target_bit_at(input int col_idx);
    begin
      target_bit_at = 1'b0;
      for (int idx = 0; idx < ERROR_WEIGHT; idx++) begin
        if (ERROR_POS[idx] == col_idx) begin
          target_bit_at = 1'b1;
        end
      end
    end
  endfunction

  function automatic logic candidate_matches_target(input logic [N-1:0] candidate);
    begin
      candidate_matches_target = 1'b1;
      for (int col_idx = 0; col_idx < N; col_idx++) begin
        if (candidate[col_idx] != target_bit_at(col_idx)) begin
          candidate_matches_target = 1'b0;
        end
      end
    end
  endfunction

  task automatic load_syndrome;
    begin
      for (int row_idx = 0; row_idx < R; row_idx++) begin
        syndrome_we = 1'b1;
        syndrome_addr = ROW_IDX_W'(row_idx);
        syndrome_wdata = syndrome_bit_at(row_idx);
        @(posedge clk);
      end
      syndrome_we = 1'b0;
      syndrome_addr = '0;
      syndrome_wdata = 1'b0;
      @(posedge clk);
    end
  endtask

  task automatic load_h_matrix;
    begin
      for (int h_block_idx = 0; h_block_idx < N0; h_block_idx++) begin
        for (int one_idx = 0; one_idx < W; one_idx++) begin
          h_we = 1'b1;
          h_load_block_idx = H_BLOCK_W'(h_block_idx);
          h_load_one_idx = ONE_IDX_W'(one_idx);
          h_base_row = ROW_IDX_W'(TEST_H_BASE_ROWS[h_block_idx][one_idx]);
          @(posedge clk);
        end
      end
      h_we = 1'b0;
      while (!h_loaded && !h_error) begin
        @(posedge clk);
      end
      if (!h_loaded || h_error) begin
        $fatal(1, "H matrix load failed loaded=%0b error=%0b", h_loaded, h_error);
      end
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
      residual = '0;
      for (int idx = 0; idx < SYNDROME_WEIGHT; idx++) begin
        residual[SYNDROME_POS[idx]] = 1'b1;
      end
      for (var_idx = 0; var_idx < N; var_idx++) begin
        if (candidate[var_idx]) begin
          h_block_idx = H_BLOCK_W'(var_idx / R);
          col_idx = var_idx % R;
          for (edge_idx = 0; edge_idx < W; edge_idx++) begin
            row_idx = ROW_IDX_W'((TEST_H_BASE_ROWS[h_block_idx][edge_idx] + col_idx) % R);
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
    h_we = 1'b0;
    h_load_block_idx = '0;
    h_load_one_idx = '0;
    h_base_row = '0;
    syndrome_we = 1'b0;
    syndrome_addr = '0;
    syndrome_wdata = 1'b0;
    e_read_col_idx = '0;
    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    repeat (3) @(posedge clk);

    load_h_matrix();
    load_syndrome();

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
    exact_match = candidate_matches_target(e_out);

    $display(
      "seed=%0d iter=%0d cycles=%0d target_weight=%0d output_weight=%0d residual_weight=%0d exact=%0d",
      TEST_SEED,
      iter_count,
      cycles,
      ERROR_WEIGHT,
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
             ERROR_WEIGHT, weight_n(e_out));
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

    h_base = [sample_h_base_rows(rng, args.r, args.w) for _ in range(args.n0)]
    error_positions = sorted(rng.sample(range(n), args.error_count))
    error_bits = [0 for _ in range(n)]
    for pos in error_positions:
        error_bits[pos] = 1
    syndrome = calc_syndrome(h_base, error_bits, args.r, args.w)

    pkg_path = out_dir / "bike_pkg.sv"
    tb_path = out_dir / "tb_bike_decoder_random.sv"
    emit_pkg(
        pkg_path,
        n0=args.n0,
        r=args.r,
        w=args.w,
        i_max=args.i_max,
        c_val=args.c_val,
        msg_bits=args.msg_bits,
        alpha_shift_0=args.alpha_shift_0,
        alpha_shift_1=args.alpha_shift_1,
        l=args.parallel_l,
        c_tile=args.c_tile,
        t=args.error_count,
    )
    emit_tb(
        tb_path,
        seed=seed,
        timeout_cycles=args.timeout_cycles,
        syndrome_positions=[idx for idx, bit in enumerate(syndrome) if bit],
        error_positions=error_positions,
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
    parser.add_argument("--msg-bits", type=int, default=None)
    parser.add_argument("--alpha-shift-0", type=int, default=None)
    parser.add_argument("--alpha-shift-1", type=int, default=None)
    parser.add_argument("--parallel-l", type=int, default=8)
    parser.add_argument("--c-tile", type=int, default=256)
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
    if args.c_tile < 1:
        raise ValueError("--c-tile must be positive")
    if args.c_tile % args.parallel_l != 0:
        raise ValueError("--c-tile must be a multiple of --parallel-l")
    if args.msg_bits < 2:
        raise ValueError("--msg-bits must be at least 2")
    if args.c_val < 0 or args.c_val > ((1 << (args.msg_bits - 1)) - 1):
        raise ValueError("--c-val must fit in the configured sign-magnitude message magnitude")

    for case_idx in range(args.trials):
        seed = args.base_seed + case_idx
        print(f"== BIKE random case {case_idx + 1}/{args.trials}: seed={seed} ==", flush=True)
        run_case(args, repo_root, case_idx, seed)

    print(f"PASS: ran {args.trials} BIKE random decoder testbench(es) one at a time")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
