`timescale 1ns / 1ps

module tb_k_sign_update;
  import bike_pkg::*;

  logic                            clk;
  logic                            rst_n;
  logic [K_SIGN_WORK_RECORD_W-1:0] record_q;
  logic [K_SIGN_WORK_RECORD_W-1:0] record_next;
  logic [     K_SIGN_RECORD_W-1:0] compressed_record;
  logic                            clear;
  logic                            valid;
  logic [          DIAG_IDX_W-1:0] diag_idx_local;
  logic [               MSG_W-1:0] v2c_msg;
  logic                            base_sign;
  logic                            recon_sign;
  logic                            recon_hit;

  logic                            c2v_valid[0:L-1];
  logic [               COL_W-1:0] c2v_col_idx[0:L-1];
  logic                            c2v_sign[0:L-1];
  logic                            c2v_hit[0:L-1];
  logic [     K_SIGN_RECORD_W-1:0] c2v_record[0:L-1];
  logic                            v2c_valid[0:L-1];
  logic [               COL_W-1:0] v2c_col_idx[0:L-1];
  logic [          TILE_OFF_W-1:0] v2c_tile_offset[0:L-1];
  logic [               MSG_W-1:0] v2c_msg_lane[0:L-1];
  logic                            v2c_base_sign[0:L-1];
  logic                            commit_valid[0:L-1];
  logic [               COL_W-1:0] commit_col_idx[0:L-1];
  logic [     K_SIGN_RECORD_W-1:0] commit_record[0:L-1];

  k_sign_update u_k_sign_update (
      .i_record        (record_q),
      .i_clear         (clear),
      .i_valid         (valid),
      .i_diag_idx_local(diag_idx_local),
      .i_v2c_msg       (v2c_msg),
      .i_base_sign     (base_sign),
      .o_record        (record_next)
  );

  k_sign_reconstruct u_k_sign_reconstruct (
      .i_record        (compressed_record),
      .i_diag_idx_local(diag_idx_local),
      .o_sign          (recon_sign),
      .o_hit           (recon_hit)
  );

  k_sign_selector u_k_sign_selector (
      .i_clk           (clk),
      .i_rst_n         (rst_n),
      .i_cfg_w         (CFG_W_W'(W)),
      .i_valid         (v2c_valid),
      .i_col_idx       (v2c_col_idx),
      .i_tile_offset   (v2c_tile_offset),
      .i_diag_idx_local(diag_idx_local),
      .i_v2c_msg       (v2c_msg_lane),
      .i_base_sign     (v2c_base_sign),
      .o_commit_valid  (commit_valid),
      .o_commit_col_idx(commit_col_idx),
      .o_commit_record (commit_record)
  );

  ram_k_global u_ram_k_global (
      .i_clk          (clk),
      .i_rst_n        (rst_n),
      .i_read_valid   (c2v_valid),
      .i_read_col_idx (c2v_col_idx),
      .o_read_record  (c2v_record),
      .i_write_valid  (commit_valid),
      .i_write_col_idx(commit_col_idx),
      .i_write_record (commit_record)
  );

  generate
    for (genvar lane_idx = 0; lane_idx < L; lane_idx++) begin : g_ram_reconstruct
      k_sign_reconstruct u_k_sign_reconstruct (
          .i_record        (c2v_record[lane_idx]),
          .i_diag_idx_local(diag_idx_local),
          .o_sign          (c2v_sign[lane_idx]),
          .o_hit           (c2v_hit[lane_idx])
      );
    end
  endgenerate

  initial clk = 1'b0;
  always #5 clk = ~clk;

  always_comb begin
    compressed_record = '0;
    compressed_record[0] = record_q[0];
    for (int slot_idx = 0; slot_idx < K_SIGN_K; slot_idx++) begin
      compressed_record[1+(slot_idx*DIAG_IDX_W)+:DIAG_IDX_W] =
          record_q[1+(slot_idx*K_SIGN_WORK_SLOT_W)+:DIAG_IDX_W];
    end
  end

  task automatic commit_update(input  logic clr, input  logic [DIAG_IDX_W-1:0] pos, input  logic sign,
                               input  logic [D-1:0] mag);
    begin
      clear = clr;
      valid = 1'b1;
      diag_idx_local = pos;
      v2c_msg = {sign, mag};
      #1;
      record_q = record_next;
      #1;
      valid = 1'b0;
      clear = 1'b0;
    end
  endtask

  task automatic write_ram_edge(input  logic [DIAG_IDX_W-1:0] pos, input  logic sign,
                                input  logic [D-1:0] mag);
    begin
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        v2c_valid[lane_idx] = 1'b0;
        v2c_col_idx[lane_idx] = COL_W'(lane_idx);
        v2c_tile_offset[lane_idx] = TILE_OFF_W'(lane_idx);
        v2c_msg_lane[lane_idx] = '0;
        v2c_base_sign[lane_idx] = 1'b0;
      end
      diag_idx_local = pos;
      v2c_valid[0] = 1'b1;
      v2c_col_idx[0] = '0;
      v2c_tile_offset[0] = '0;
      v2c_msg_lane[0] = {sign, mag};
      v2c_base_sign[0] = 1'b0;
      @(posedge clk);
      v2c_valid[0] = 1'b0;
      @(posedge clk);
    end
  endtask

  task automatic read_ram_edge(input  logic [DIAG_IDX_W-1:0] pos, output logic sign);
    begin
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        c2v_valid[lane_idx]   = 1'b0;
        c2v_col_idx[lane_idx] = COL_W'(lane_idx);
      end
      diag_idx_local = pos;
      c2v_valid[0]   = 1'b1;
      c2v_col_idx[0] = '0;
      @(posedge clk);
      #1;
      sign = c2v_sign[0];
      c2v_valid[0] = 1'b0;
    end
  endtask

  initial begin
    logic sign_read;

    rst_n = 1'b0;
    record_q = '0;
    clear = 1'b0;
    valid = 1'b0;
    diag_idx_local = '0;
    v2c_msg = '0;
    base_sign = 1'b0;
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      c2v_valid[lane_idx] = 1'b0;
      c2v_col_idx[lane_idx] = '0;
      v2c_valid[lane_idx] = 1'b0;
      v2c_col_idx[lane_idx] = '0;
      v2c_tile_offset[lane_idx] = '0;
      v2c_msg_lane[lane_idx] = '0;
      v2c_base_sign[lane_idx] = 1'b0;
    end

    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    repeat (2) @(posedge clk);

    base_sign = 1'b0;
    commit_update(1'b1, 0, 1'b1, 7);
    commit_update(1'b0, 1, 1'b1, 7);
    commit_update(1'b0, 2, 1'b1, 9);

    diag_idx_local = DIAG_IDX_W'(1);
    #1;
    if ((K_SIGN_K == 2) && (recon_sign !== 1'b0))
      $fatal(1, "expected equal-magnitude eviction at diag_idx_local=1");
    if ((K_SIGN_K == 2) && (recon_hit !== 1'b0)) $fatal(1, "expected no hit at diag_idx_local=1");
    if ((K_SIGN_K > 2) && (recon_sign !== 1'b1))
      $fatal(1, "expected retained edge at diag_idx_local=1");
    if ((K_SIGN_K > 2) && (recon_hit !== 1'b1)) $fatal(1, "expected hit at diag_idx_local=1");
    diag_idx_local = DIAG_IDX_W'(2);
    #1;
    if (recon_sign !== 1'b1) $fatal(1, "expected hit at diag_idx_local=2");
    diag_idx_local = DIAG_IDX_W'(0);
    #1;
    if (recon_sign !== 1'b1) $fatal(1, "expected hit at diag_idx_local=0");

    write_ram_edge(0, 1'b1, 3);
    write_ram_edge(1, 1'b0, 9);
    write_ram_edge(2, 1'b1, 8);
    @(posedge clk);

    read_ram_edge(0, sign_read);
    if (sign_read !== 1'b1) $fatal(1, "ram sign mismatch at edge 0");
    if (c2v_hit[0] !== 1'b1) $fatal(1, "ram hit mismatch at edge 0");
    read_ram_edge(1, sign_read);
    if (sign_read !== 1'b0) $fatal(1, "ram sign mismatch at edge 1");
    if (c2v_hit[0] !== 1'b0) $fatal(1, "ram hit mismatch at edge 1");
    read_ram_edge(2, sign_read);
    if (sign_read !== 1'b1) $fatal(1, "ram sign mismatch at edge 2");
    if (c2v_hit[0] !== 1'b1) $fatal(1, "ram hit mismatch at edge 2");

    $display("tb_k_sign_update PASS K=%0d record_w=%0d", K_SIGN_K, K_SIGN_RECORD_W);
    $finish;
  end
endmodule
