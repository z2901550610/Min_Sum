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
    "rtl/decoder_profile_config.sv",
    "rtl/ram_bram.sv",
    "rtl/ram_i.sv",
    "rtl/barrel_rotate.sv",
    "rtl/edge_addr_gen.sv",
    "rtl/tile_scheduler.sv",
    "rtl/ram_m.sv",
    "rtl/ram_s.sv",
    "rtl/k_sign_update.sv",
    "rtl/k_sign_reconstruct.sv",
    "rtl/k_sign_overlap_scheduler.sv",
    "rtl/ram_k_tile.sv",
    "rtl/k_sign_selector.sv",
    "rtl/ram_k_global.sv",
    "rtl/ram_sign_delta.sv",
    "rtl/ram_syndrome.sv",
    "rtl/ram_accum.sv",
    "rtl/ram_t.sv",
    "rtl/msg_tc_to_signmag_sat.sv",
    "rtl/vnu.sv",
    "rtl/ram_decision.sv",
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
        "n0": 2,
        "r": 12323,
        "w": 71,
        "error_count": 134,
        "i_max": 7,
        "c_val": 5,
        "msg_bits": 5,
        "alpha_shift_0": 3,
        "alpha_shift_1": 4,
        "cols_per_tile": 256,
    },
    "bike192": {
        "n0": 2,
        "r": 24659,
        "w": 103,
        "error_count": 199,
        "i_max": 7,
        "c_val": 5,
        "msg_bits": 5,
        "alpha_shift_0": 3,
        "alpha_shift_1": 4,
        "cols_per_tile": 512,
    },
    "bike256": {
        "n0": 2,
        "r": 40973,
        "w": 137,
        "error_count": 264,
        "i_max": 7,
        "c_val": 5,
        "msg_bits": 5,
        "alpha_shift_0": 3,
        "alpha_shift_1": 4,
        "cols_per_tile": 576,
    },
    "trike128": {
        "n0": 3,
        "r": 8243,
        "w": 27,
        "error_count": 201,
        "i_max": 7,
        "c_val": 4,
        "msg_bits": 5,
        "alpha_shift_0": 3,
        "alpha_shift_1": 4,
        "cols_per_tile": 256,
    },
    "trike160": {
        "n0": 3,
        "r": 12589,
        "w": 35,
        "error_count": 263,
        "i_max": 7,
        "c_val": 4,
        "msg_bits": 5,
        "alpha_shift_0": 3,
        "alpha_shift_1": 4,
        "cols_per_tile": 256,
    },
    "trike256": {
        "n0": 3,
        "r": 30389,
        "w": 55,
        "error_count": 429,
        "i_max": 7,
        "c_val": 5,
        "msg_bits": 5,
        "alpha_shift_0": 3,
        "alpha_shift_1": 4,
        "cols_per_tile": 288,
    },
    "trike384": {
        "n0": 3,
        "r": 63997,
        "w": 83,
        "error_count": 659,
        "i_max": 7,
        "c_val": 5,
        "msg_bits": 5,
        "alpha_shift_0": 3,
        "alpha_shift_1": 6,
        "cols_per_tile": 464,
    },
    "trike512": {
        "n0": 3,
        "r": 106781,
        "w": 111,
        "error_count": 877,
        "i_max": 7,
        "c_val": 7,
        "msg_bits": 5,
        "alpha_shift_0": 4,
        "alpha_shift_1": 0,
        "cols_per_tile": 1168,
    },
}

PROFILE_IDS = {
    "bike128": "PROFILE_BIKE_128",
    "bike192": "PROFILE_BIKE_192",
    "bike256": "PROFILE_BIKE_256",
    "trike128": "PROFILE_TRIKE_128",
    "trike160": "PROFILE_TRIKE_160",
    "trike256": "PROFILE_TRIKE_256",
    "trike384": "PROFILE_TRIKE_384",
    "trike512": "PROFILE_TRIKE_512",
}

UNIFIED_PROFILE_IDS = {
    "bike128": "PROFILE_BIKE_128",
    "bike192": "PROFILE_BIKE_192",
    "bike256": "PROFILE_BIKE_256",
    "trike128": "PROFILE_TRIKE_128",
    "trike160": "PROFILE_TRIKE_160",
    "trike256": "PROFILE_TRIKE_256",
    "trike384": "PROFILE_TRIKE_384",
    "trike512": "PROFILE_TRIKE_512",
}

TRIKE_PARAM_SETS = {"trike128", "trike160", "trike256", "trike384", "trike512"}


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
        for diag_idx_local in range(w):
            row_idx = (h_base[h_block_idx][diag_idx_local] + col) % r
            syndrome[row_idx] ^= 1
    return syndrome


def write_fixture(
    path: Path,
    *,
    seed: int,
    n0: int,
    r: int,
    w: int,
    error_positions: list[int],
    iterations: int,
    msg_bits: int,
    c_val: int,
    alpha_shift_0: int,
    alpha_shift_1: int,
    h_base: list[list[int]],
    syndrome_positions: list[int],
) -> None:
    lines = [
        "MIN_SUM_FIXTURE_V1",
        f"seed {seed}",
        f"n0 {n0}",
        f"r {r}",
        f"w {w}",
        f"error_count {len(error_positions)}",
        f"iterations {iterations}",
        f"msg_bits {msg_bits}",
        f"c_val {c_val}",
        f"alpha_shift_0 {alpha_shift_0}",
        f"alpha_shift_1 {alpha_shift_1}",
    ]
    for block_idx, rows in enumerate(h_base):
        lines.append(f"h {block_idx} " + " ".join(str(value) for value in rows))
    lines.append("error_positions " + " ".join(str(value) for value in error_positions))
    lines.append(f"syndrome_weight {len(syndrome_positions)}")
    lines.append("syndrome_positions " + " ".join(str(value) for value in syndrome_positions))
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def read_fixture(path: Path) -> dict[str, object]:
    lines = [
        line.strip()
        for line in path.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    if not lines or lines[0] != "MIN_SUM_FIXTURE_V1":
        raise ValueError(f"{path}: unsupported fixture header")

    scalar_keys = {
        "seed",
        "n0",
        "r",
        "w",
        "error_count",
        "iterations",
        "msg_bits",
        "c_val",
        "alpha_shift_0",
        "alpha_shift_1",
        "syndrome_weight",
    }
    values: dict[str, object] = {"h": {}}
    for line in lines[1:]:
        fields = line.split()
        key = fields[0]
        if key in scalar_keys:
            if len(fields) != 2:
                raise ValueError(f"{path}: malformed {key} line")
            values[key] = int(fields[1])
        elif key == "h":
            if len(fields) < 3:
                raise ValueError(f"{path}: malformed h line")
            h_rows = values["h"]
            assert isinstance(h_rows, dict)
            h_rows[int(fields[1])] = [int(value) for value in fields[2:]]
        elif key in {"error_positions", "syndrome_positions"}:
            values[key] = [int(value) for value in fields[1:]]
        else:
            raise ValueError(f"{path}: unknown fixture key {key}")

    required = scalar_keys | {"error_positions", "syndrome_positions"}
    missing = sorted(required - values.keys())
    if missing:
        raise ValueError(f"{path}: missing fixture fields: {', '.join(missing)}")

    n0 = int(values["n0"])
    r = int(values["r"])
    w = int(values["w"])
    error_count = int(values["error_count"])
    syndrome_weight = int(values["syndrome_weight"])
    h_rows = values["h"]
    assert isinstance(h_rows, dict)
    if sorted(h_rows) != list(range(n0)):
        raise ValueError(f"{path}: h block indices must cover 0..{n0 - 1}")
    h_base = [h_rows[block_idx] for block_idx in range(n0)]
    if any(len(rows) != w for rows in h_base):
        raise ValueError(f"{path}: each h block must contain exactly w rows")
    error_positions = values["error_positions"]
    syndrome_positions = values["syndrome_positions"]
    assert isinstance(error_positions, list)
    assert isinstance(syndrome_positions, list)
    if len(error_positions) != error_count:
        raise ValueError(f"{path}: error position count mismatch")
    if len(syndrome_positions) != syndrome_weight:
        raise ValueError(f"{path}: syndrome position count mismatch")
    if any(position < 0 or position >= n0 * r for position in error_positions):
        raise ValueError(f"{path}: error position out of range")
    if any(position < 0 or position >= r for position in syndrome_positions):
        raise ValueError(f"{path}: syndrome position out of range")
    values["h_base"] = h_base
    return values


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
    cols_per_tile: int,
    t: int,
) -> None:
    if n0 == 3:
        profile_constants = """  parameter int PROFILE_COUNT = 5;
  parameter int PROFILE_ID_W = 3;
  localparam logic [PROFILE_ID_W-1:0] PROFILE_TRIKE_128 = 3'd0;
  localparam logic [PROFILE_ID_W-1:0] PROFILE_TRIKE_160 = 3'd1;
  localparam logic [PROFILE_ID_W-1:0] PROFILE_TRIKE_256 = 3'd2;
  localparam logic [PROFILE_ID_W-1:0] PROFILE_TRIKE_384 = 3'd3;
  localparam logic [PROFILE_ID_W-1:0] PROFILE_TRIKE_512 = 3'd4;
  localparam logic [PROFILE_ID_W-1:0] PROFILE_DEFAULT = PROFILE_TRIKE_128;"""
    else:
        profile_constants = """  parameter int PROFILE_COUNT = 3;
  parameter int PROFILE_ID_W = 2;
  localparam logic [PROFILE_ID_W-1:0] PROFILE_BIKE_128 = 2'd0;
  localparam logic [PROFILE_ID_W-1:0] PROFILE_BIKE_192 = 2'd1;
  localparam logic [PROFILE_ID_W-1:0] PROFILE_BIKE_256 = 2'd2;
  localparam logic [PROFILE_ID_W-1:0] PROFILE_DEFAULT = PROFILE_BIKE_128;"""

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
  parameter int K_SIGN_K_CONFIG = 3;
  parameter bit K_SIGN_ENABLE = {1 if n0 == 3 else 0};
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
  parameter int COLS_PER_TILE_CONFIG = {cols_per_tile};
  parameter int COLS_PER_TILE = (COLS_PER_TILE_CONFIG > R) ? R : COLS_PER_TILE_CONFIG;
  parameter int Q_BASE = (COLS_PER_TILE + L - 1) / L;
  parameter int Q_TILE = Q_BASE + 3;
  parameter int TILE_COUNT = (R + COLS_PER_TILE - 1) / COLS_PER_TILE;
  parameter int TILES_TOTAL = N0 * TILE_COUNT;
  parameter int TILE_ID_W = (TILES_TOTAL > 1) ? $clog2(TILES_TOTAL + 1) : 1;
  parameter int TILE_IDX_W = (TILE_COUNT > 1) ? $clog2(TILE_COUNT + 1) : 1;
  parameter int TILE_OFF_W = (COLS_PER_TILE > 1) ? $clog2(COLS_PER_TILE) : 1;
  parameter int LANE_GROUP_IDX_W = (Q_TILE > 1) ? $clog2(Q_TILE) : 1;
  parameter int ROW_BANK_AW = (ROW_SEG_SIZE > 1) ? $clog2(ROW_SEG_SIZE) : 1;
  parameter int ACC_W = VNU_TC_W;
  parameter int COL_W = (N > 1) ? $clog2(N) : 1;
  parameter int H_BLOCK_W = (N0 > 1) ? $clog2(N0) : 1;
  parameter int DIAG_GLOBAL_COUNT = N0 * W;

  parameter int DIAG_IDX_W = (W > 1) ? $clog2(W) : 1;
  parameter int K_SIGN_K = K_SIGN_K_CONFIG;
  parameter int K_SIGN_SLOT_IDX_W = (K_SIGN_K > 1) ? $clog2(K_SIGN_K) : 1;
  parameter int K_SIGN_WORK_SLOT_W = DIAG_IDX_W + D;
  parameter int K_SIGN_WORK_RECORD_W = 1 + (K_SIGN_K * K_SIGN_WORK_SLOT_W);
  parameter int K_SIGN_RECORD_W = 1 + (K_SIGN_K * DIAG_IDX_W);
  parameter int K_SIGN_POS_RECORD_W = K_SIGN_K * DIAG_IDX_W;
  parameter int K_SIGN_WORK_DEPTH = Q_BASE;
  parameter int K_SIGN_WORK_AW = (K_SIGN_WORK_DEPTH > 1) ? $clog2(K_SIGN_WORK_DEPTH) : 1;
  parameter int K_SIGN_OVERLAP_DRAIN_CYCLES = 7;
  localparam logic [DIAG_IDX_W-1:0] K_SIGN_DIAG_INVALID = '1;
  parameter int DIAG_GLOBAL_W = (DIAG_GLOBAL_COUNT > 1) ? $clog2(DIAG_GLOBAL_COUNT) : 1;
  parameter int ROW_IDX_W = (R > 1) ? $clog2(R) : 1;
  parameter int LANE_IDX_W = (L > 1) ? $clog2(L) : 1;
  parameter int L_SHIFT = (L > 1) ? $clog2(L) : 0;
  parameter int ITER_W = $clog2(I_MAX + 1);

{profile_constants}
  parameter bit PROFILE_RUNTIME_SELECT = 1'b0;
  parameter int CFG_R_W = ROW_IDX_W + 1;
  parameter int CFG_W_W = DIAG_IDX_W + 1;
  parameter int CFG_CVAL_W = MSG_W;
  parameter int CFG_ALPHA_SHIFT_W = 3;

  localparam int DEC_STATE_W = 4;
  localparam logic [DEC_STATE_W-1:0] DEC_WAIT_START       = 4'd0;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_CLEAR       = 4'd3;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_C2V_PRIME   = 4'd4;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_OVERLAP     = 4'd5;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_V2C_DRAIN   = 4'd6;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_KSIGN_CORR  = 4'd7;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_CHECK       = 4'd8;
  localparam logic [DEC_STATE_W-1:0] DEC_DONE             = 4'd9;

  localparam int MSG_MAG_LSB = 0;
  localparam int MSG_SIGN_BIT = D;

  localparam int COMP_C2V_MIN1_LSB = 0;
  localparam int COMP_C2V_MIN2_LSB = COMP_C2V_MIN1_LSB + D;
  localparam int COMP_C2V_MIN_DIAG_GLOBAL_LSB = COMP_C2V_MIN2_LSB + D;
  localparam int COMP_C2V_SIGN_XOR_BIT = COMP_C2V_MIN_DIAG_GLOBAL_LSB + DIAG_GLOBAL_W;
  localparam int COMP_C2V_W = COMP_C2V_SIGN_XOR_BIT + 1;
  localparam logic [COMP_C2V_W-1:0] COMP_C2V_INIT = {{
    1'b0,
    DIAG_GLOBAL_W'(0),
    D'(MAG_MAX),
    D'(MAG_MAX)
  }};
  localparam logic [COMP_C2V_W-1:0] FIRST_ITER_C2V_COMP = {{
    1'b0,
    DIAG_GLOBAL_W'(0),
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
    test_r: int,
    test_w: int,
    profile_id: str,
    syndrome_positions: list[int],
    error_positions: list[int],
    h_base: list[list[int]],
    result_path: Path | None,
    require_success: bool,
) -> None:
    h_base_rows = ",\n    ".join(sv_array(row_list) for row_list in h_base)
    syndrome_array_depth = max(1, len(syndrome_positions))
    error_array_depth = max(1, len(error_positions))
    result_path_sv = str(result_path.resolve()) if result_path is not None else ""
    result_write = ""
    if result_path is not None:
        result_write = f"""
    begin
      int result_fd;
      result_fd = $fopen("{result_path_sv}", "w");
      if (result_fd == 0) begin
        $fatal(1, "cannot open result output");
      end
      $fdisplay(result_fd, "MIN_SUM_DECISION_V1");
      for (int col_idx = 0; col_idx < TEST_N; col_idx++) begin
        if (e_out[col_idx]) begin
          $fdisplay(result_fd, "%0d", col_idx);
        end
      end
      $fclose(result_fd);
    end
"""
    success_checks = ""
    if require_success:
        success_checks = """
    if (weight_r(residual) != 0) begin
      $fatal(1, "seed=%0d residual check failed; residual_weight=%0d", TEST_SEED,
             weight_r(residual));
    end
    if (!exact_match) begin
      $fatal(1, "seed=%0d exact check failed; target_weight=%0d output_weight=%0d", TEST_SEED,
             ERROR_WEIGHT, weight_n(e_out));
    end
"""
    path.write_text(
        f"""`timescale 1ns/1ps

module tb_bike_decoder_random;
  import bike_pkg::*;

  localparam int TEST_SEED = {seed};
  localparam int TIMEOUT_CYCLES = {timeout_cycles};
  localparam int TEST_R = {test_r};
  localparam int TEST_W = {test_w};
  localparam int TEST_N = N0 * TEST_R;
  localparam int TEST_ROW_IDX_W = (TEST_R > 1) ? $clog2(TEST_R) : 1;
  localparam logic [PROFILE_ID_W-1:0] TEST_PROFILE_ID = {profile_id};
  localparam int TEST_ROW_SEG_SIZE = (TEST_R + L - 1) / L;
  localparam int TEST_TILE_COUNT = (TEST_R + COLS_PER_TILE - 1) / COLS_PER_TILE;
  localparam int TEST_KSIGN_SCAN_CYCLES = TEST_W * Q_TILE;
  localparam int TEST_DECODE_CYCLES = I_MAX * (
      TEST_ROW_SEG_SIZE + (((N0 * TEST_TILE_COUNT) + 1) * TEST_W * Q_TILE)
      + (K_SIGN_ENABLE ? (8 + TEST_KSIGN_SCAN_CYCLES) : 0)
  ) + 6;
  localparam int SYNDROME_WEIGHT = {len(syndrome_positions)};
  localparam int ERROR_WEIGHT = {len(error_positions)};
  localparam int unsigned SYNDROME_POS [0:{syndrome_array_depth - 1}] = {sv_int_array(syndrome_positions)};
  localparam int unsigned ERROR_POS [0:{error_array_depth - 1}] = {sv_int_array(error_positions)};
  localparam int unsigned TEST_H_BASE_ROW_IDXS [0:N0-1][0:TEST_W-1] = '{{
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
  logic [DIAG_IDX_W-1:0] h_load_diag_idx_local;
  logic [ROW_IDX_W-1:0] h_base_row_idx;
  logic h_loaded;
  logic h_error;
  logic [COL_W-1:0] e_read_col_idx;
  logic e_rdata;
  logic [TEST_N-1:0] e_out;
  logic [ITER_W-1:0] iter_count;

  decoder_top dut (
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_start(start),
    .i_param_level(TEST_PROFILE_ID),
    .i_syndrome_we(syndrome_we),
    .i_syndrome_addr(syndrome_addr),
    .i_syndrome_wdata(syndrome_wdata),
    .i_h_we(h_we),
    .i_h_block_idx(h_load_block_idx),
    .i_h_diag_idx_local(h_load_diag_idx_local),
    .i_h_base_row_idx(h_base_row_idx),
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

  function automatic logic candidate_matches_target(input logic [TEST_N-1:0] candidate);
    begin
      candidate_matches_target = 1'b1;
      for (int col_idx = 0; col_idx < TEST_N; col_idx++) begin
        if (candidate[col_idx] != target_bit_at(col_idx)) begin
          candidate_matches_target = 1'b0;
        end
      end
    end
  endfunction

  task automatic load_syndrome;
    begin
      for (int row_idx = 0; row_idx < TEST_R; row_idx++) begin
        @(negedge clk);
        syndrome_we = 1'b1;
        syndrome_addr = ROW_IDX_W'(row_idx);
        syndrome_wdata = syndrome_bit_at(row_idx);
      end
      @(negedge clk);
      syndrome_we = 1'b0;
      syndrome_addr = '0;
      syndrome_wdata = 1'b0;
    end
  endtask

  task automatic load_h_matrix;
    begin
      for (int h_block_idx = 0; h_block_idx < N0; h_block_idx++) begin
        for (int diag_idx_local = 0; diag_idx_local < TEST_W; diag_idx_local++) begin
          @(negedge clk);
          h_we = 1'b1;
          h_load_block_idx = H_BLOCK_W'(h_block_idx);
          h_load_diag_idx_local = DIAG_IDX_W'(diag_idx_local);
          h_base_row_idx = ROW_IDX_W'(TEST_H_BASE_ROW_IDXS[h_block_idx][diag_idx_local]);
        end
      end
      @(negedge clk);
      h_we = 1'b0;
      while (!h_loaded && !h_error) begin
        @(posedge clk);
      end
      if (!h_loaded || h_error) begin
        $fatal(1, "H matrix load failed loaded=%0b error=%0b", h_loaded, h_error);
      end
    end
  endtask

  function automatic logic [TEST_R-1:0] residual_of(input logic [TEST_N-1:0] candidate);
    logic [TEST_R-1:0] residual;
    int var_idx;
    logic [H_BLOCK_W-1:0] h_block_idx;
    int col_idx;
    int diag_idx_local;
    logic [TEST_ROW_IDX_W-1:0] row_idx;
    begin
      for (int row_clear_idx = 0; row_clear_idx < TEST_R; row_clear_idx++) begin
        residual[row_clear_idx] = 1'b0;
      end
      for (int idx = 0; idx < SYNDROME_WEIGHT; idx++) begin
        residual[SYNDROME_POS[idx]] = 1'b1;
      end
      for (var_idx = 0; var_idx < TEST_N; var_idx++) begin
        if (candidate[var_idx]) begin
          h_block_idx = H_BLOCK_W'(var_idx / TEST_R);
          col_idx = var_idx % TEST_R;
          for (diag_idx_local = 0; diag_idx_local < TEST_W; diag_idx_local++) begin
            row_idx = TEST_ROW_IDX_W'((TEST_H_BASE_ROW_IDXS[h_block_idx][diag_idx_local] + col_idx) %
                                      TEST_R);
            residual[row_idx] = residual[row_idx] ^ 1'b1;
          end
        end
      end
      return residual;
    end
  endfunction

  function automatic int weight_r(input logic [TEST_R-1:0] bits);
    int idx;
    begin
      weight_r = 0;
      for (idx = 0; idx < TEST_R; idx++) begin
        weight_r += bits[idx] ? 1 : 0;
      end
    end
  endfunction

  function automatic int weight_n(input logic [TEST_N-1:0] bits);
    int idx;
    begin
      weight_n = 0;
      for (idx = 0; idx < TEST_N; idx++) begin
        weight_n += bits[idx] ? 1 : 0;
      end
    end
  endfunction

  initial begin
    int cycles;
    logic [TEST_R-1:0] residual;
    bit exact_match;

    rst_n = 1'b0;
    start = 1'b0;
    h_we = 1'b0;
    h_load_block_idx = '0;
    h_load_diag_idx_local = '0;
    h_base_row_idx = '0;
    syndrome_we = 1'b0;
    syndrome_addr = '0;
    syndrome_wdata = 1'b0;
    e_read_col_idx = '0;
    repeat (2) @(posedge clk);
    @(negedge clk);
    rst_n = 1'b1;
    repeat (3) @(posedge clk);

    load_h_matrix();
    load_syndrome();

    @(negedge clk);
    start = 1'b1;
    @(negedge clk);
    start = 1'b0;

    cycles = 0;
    while ((done !== 1'b1) && (cycles < TIMEOUT_CYCLES)) begin
      @(posedge clk);
      #1;
      cycles += 1;
    end
    if (done !== 1'b1) begin
      $fatal(1, "seed=%0d timeout after %0d cycles", TEST_SEED, cycles);
    end

    if (cycles != TEST_DECODE_CYCLES) begin
      $fatal(1, "seed=%0d cycle mismatch: got %0d exp %0d", TEST_SEED, cycles,
             TEST_DECODE_CYCLES);
    end

    for (int clear_idx = 0; clear_idx < TEST_N; clear_idx++) begin
      e_out[clear_idx] = 1'b0;
    end
    for (int col_idx = 0; col_idx < TEST_N; col_idx++) begin
      e_read_col_idx = COL_W'(col_idx);
      @(posedge clk);
      #1;
      e_out[col_idx] = e_rdata;
    end

    residual = residual_of(e_out);
    exact_match = candidate_matches_target(e_out);
{result_write}

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
{success_checks}
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

    fixture = read_fixture(Path(args.fixture_in)) if args.fixture_in else None
    if fixture is not None:
        seed = int(fixture["seed"])
        args.n0 = int(fixture["n0"])
        args.r = int(fixture["r"])
        args.w = int(fixture["w"])
        args.error_count = int(fixture["error_count"])
        args.i_max = int(fixture["iterations"])
        args.msg_bits = int(fixture["msg_bits"])
        args.c_val = int(fixture["c_val"])
        args.alpha_shift_0 = int(fixture["alpha_shift_0"])
        args.alpha_shift_1 = int(fixture["alpha_shift_1"])

    n = args.r * args.n0
    if args.error_count < 0 or args.error_count > n:
        raise ValueError(f"--error-count must be between 0 and {n}")
    if args.w < 1 or args.w > args.r:
        raise ValueError("--w must be between 1 and --r")

    if fixture is not None:
        h_base = fixture["h_base"]
        error_positions = fixture["error_positions"]
        syndrome_positions = fixture["syndrome_positions"]
        assert isinstance(h_base, list)
        assert isinstance(error_positions, list)
        assert isinstance(syndrome_positions, list)
    else:
        h_base = [sample_h_base_rows(rng, args.r, args.w) for _ in range(args.n0)]
        error_positions = sorted(rng.sample(range(n), args.error_count))
        error_bits = [0 for _ in range(n)]
        for pos in error_positions:
            error_bits[pos] = 1
        syndrome = calc_syndrome(h_base, error_bits, args.r, args.w)
        syndrome_positions = [idx for idx, bit in enumerate(syndrome) if bit]
        if args.fixture_out:
            fixture_out = Path(args.fixture_out)
            if not fixture_out.is_absolute():
                fixture_out = repo_root / fixture_out
            write_fixture(
                fixture_out,
                seed=seed,
                n0=args.n0,
                r=args.r,
                w=args.w,
                error_positions=error_positions,
                iterations=args.i_max,
                msg_bits=args.msg_bits,
                c_val=args.c_val,
                alpha_shift_0=args.alpha_shift_0,
                alpha_shift_1=args.alpha_shift_1,
                h_base=h_base,
                syndrome_positions=syndrome_positions,
            )
        if args.generate_only:
            return True

    pkg_path = out_dir / "bike_pkg.sv"
    tb_path = out_dir / "tb_bike_decoder_random.sv"
    if not args.unified:
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
            cols_per_tile=args.cols_per_tile,
            t=args.error_count,
        )
    emit_tb(
        tb_path,
        seed=seed,
        timeout_cycles=args.timeout_cycles,
        test_r=args.r,
        test_w=args.w,
        profile_id=PROFILE_IDS.get(args.param_set or "", "PROFILE_BIKE_128"),
        syndrome_positions=syndrome_positions,
        error_positions=error_positions,
        h_base=h_base,
        result_path=Path(args.result_out) if args.result_out else None,
        require_success=not args.allow_decode_failure,
    )

    command = [args.verilator, "--binary", "--sv"]
    if args.unified:
        unified_define = "-DTRIKE_UNIFIED_PARAMS" if args.param_set in TRIKE_PARAM_SETS else "-DBIKE_UNIFIED_PARAMS"
        command.extend(
            [
                unified_define,
                f"-DBIKE_PARALLEL_L={args.parallel_l}",
                f"-DBIKE_COLS_PER_TILE={args.cols_per_tile}",
                f"-DBIKE_MSG_BITS={args.msg_bits}",
                f"-DBIKE_K_SIGN_K={args.k_sign_k}",
                "-DBIKE_SIM_DEBUG",
                "-Wall",
                "-Wno-fatal",
                "-I./tb",
                "--Mdir",
                str(obj_dir),
                "--top-module",
                "tb_bike_decoder_random",
                "rtl/bike_pkg.sv",
                *RTL_CORE,
                str(tb_path),
            ]
        )
    else:
        command.extend(
            [
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
        )
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
    parser.add_argument("--fixture-in", default=None)
    parser.add_argument("--fixture-out", default=None)
    parser.add_argument("--result-out", default=None)
    parser.add_argument("--allow-decode-failure", action="store_true")
    parser.add_argument("--generate-only", action="store_true")
    parser.add_argument(
        "--unified",
        action="store_true",
        help="Compile the shared BIKE or TRIKE unified RTL package and select the named public profile.",
    )
    parser.add_argument("--n0", type=int, default=None)
    parser.add_argument("--r", type=int, default=None)
    parser.add_argument("--w", type=int, default=None)
    parser.add_argument("--i-max", type=int, default=None)
    parser.add_argument("--c-val", type=int, default=None)
    parser.add_argument("--msg-bits", type=int, default=None)
    parser.add_argument("--k-sign-k", type=int, default=3)
    parser.add_argument("--alpha-shift-0", type=int, default=None)
    parser.add_argument("--alpha-shift-1", type=int, default=None)
    parser.add_argument("--parallel-l", type=int, default=8)
    parser.add_argument("--cols-per-tile", type=int, default=None)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    defaults = PARAM_SETS[args.param_set or "toy"]
    for key, value in defaults.items():
        if key == "cols_per_tile":
            continue
        attr = key.replace("-", "_")
        if getattr(args, attr) is None:
            setattr(args, attr, value)
    if args.cols_per_tile is None:
        if args.unified:
            args.cols_per_tile = 1168 if args.param_set in TRIKE_PARAM_SETS else 576
        else:
            args.cols_per_tile = defaults.get("cols_per_tile", 256)
    repo_root = Path(__file__).resolve().parents[1]
    if args.trials < 1:
        raise ValueError("--trials must be positive")
    if args.parallel_l < 1:
        raise ValueError("--parallel-l must be positive")
    if args.n0 < 1:
        raise ValueError("--n0 must be positive")
    if not is_power_of_two(args.parallel_l):
        raise ValueError("--parallel-l must be a power of two")
    if args.cols_per_tile < 1:
        raise ValueError("--cols-per-tile must be positive")
    if args.cols_per_tile % args.parallel_l != 0:
        raise ValueError("--cols-per-tile must be a multiple of --parallel-l")
    if args.msg_bits < 2:
        raise ValueError("--msg-bits must be at least 2")
    if args.k_sign_k < 1:
        raise ValueError("--k-sign-k must be positive")
    if not args.unified and args.k_sign_k != 3:
        raise ValueError("--k-sign-k is supported by the unified RTL package flow")
    if args.c_val < 0 or args.c_val > ((1 << (args.msg_bits - 1)) - 1):
        raise ValueError("--c-val must fit in the configured sign-magnitude message magnitude")
    if args.unified and (args.param_set not in UNIFIED_PROFILE_IDS):
        raise ValueError("--unified requires --param-set to be one of the public profile names")
    if args.fixture_in and args.trials != 1:
        raise ValueError("--fixture-in requires --trials 1")
    if args.fixture_in and args.unified:
        raise ValueError("--fixture-in is supported by the generated external package flow")
    if args.generate_only and not args.fixture_out:
        raise ValueError("--generate-only requires --fixture-out")

    for case_idx in range(args.trials):
        seed = args.base_seed + case_idx
        if args.fixture_in:
            seed = int(read_fixture(Path(args.fixture_in))["seed"])
        print(f"== decoder random case {case_idx + 1}/{args.trials}: seed={seed} ==", flush=True)
        run_case(args, repo_root, case_idx, seed)

    print(f"PASS: ran {args.trials} random decoder testbench(es) one at a time")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
