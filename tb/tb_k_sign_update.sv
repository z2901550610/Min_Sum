`timescale 1ns / 1ps

module tb_k_sign_update;
  import bike_pkg::*;

  logic                       clk;
  logic                       rst_n;
  logic [K_SIGN_RECORD_W-1:0] record_q;
  logic [K_SIGN_RECORD_W-1:0] record_next;
  logic                       clear;
  logic                       valid;
  logic [     DIAG_IDX_W-1:0] diag_idx;
  logic [          MSG_W-1:0] v2c_msg;
  logic                       base_sign;
  logic                       recon_sign;

  logic                       c2v_valid[0:L-1];
  logic [          COL_W-1:0] c2v_col_idx[0:L-1];
  logic                       c2v_sign[0:L-1];
  logic                       c2v_hit[0:L-1];
  logic                       v2c_valid[0:L-1];
  logic [          COL_W-1:0] v2c_col_idx[0:L-1];
  logic [          MSG_W-1:0] v2c_msg_lane[0:L-1];
  logic                       v2c_base_sign[0:L-1];

  k_sign_update u_k_sign_update (
      .i_record   (record_q),
      .i_clear    (clear),
      .i_valid    (valid),
      .i_diag_idx (diag_idx),
      .i_v2c_msg  (v2c_msg),
      .i_base_sign(base_sign),
      .o_record   (record_next)
  );

  k_sign_reconstruct u_k_sign_reconstruct (
      .i_record (record_q),
      .i_diag_idx(diag_idx),
      .o_sign   (recon_sign)
  );

  ram_k_sign u_ram_k_sign (
      .i_clk          (clk),
      .i_rst_n        (rst_n),
      .i_c2v_pair_sel (1'b0),
      .i_c2v_valid    (c2v_valid),
      .i_c2v_col_idx  (c2v_col_idx),
      .i_c2v_diag_idx (diag_idx),
      .o_c2v_sign     (c2v_sign),
      .o_c2v_hit      (c2v_hit),
      .i_v2c_pair_sel (1'b0),
      .i_v2c_valid    (v2c_valid),
      .i_v2c_col_idx  (v2c_col_idx),
      .i_v2c_diag_idx (diag_idx),
      .i_v2c_msg      (v2c_msg_lane),
      .i_v2c_base_sign(v2c_base_sign)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  task automatic commit_update(input  logic clr, input  logic [DIAG_IDX_W-1:0] pos, input  logic sign,
                               input  logic [D-1:0] mag);
    begin
      clear = clr;
      valid = 1'b1;
      diag_idx = pos;
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
        v2c_msg_lane[lane_idx] = '0;
        v2c_base_sign[lane_idx] = 1'b0;
      end
      diag_idx = pos;
      v2c_valid[0] = 1'b1;
      v2c_col_idx[0] = '0;
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
      diag_idx = pos;
      c2v_valid[0] = 1'b1;
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
    diag_idx = '0;
    v2c_msg = '0;
    base_sign = 1'b0;
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      c2v_valid[lane_idx] = 1'b0;
      c2v_col_idx[lane_idx] = '0;
      v2c_valid[lane_idx] = 1'b0;
      v2c_col_idx[lane_idx] = '0;
      v2c_msg_lane[lane_idx] = '0;
      v2c_base_sign[lane_idx] = 1'b0;
    end

    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    repeat (2) @(posedge clk);

    base_sign = 1'b0;
    commit_update(1'b1, 3, 1'b1, 2);
    commit_update(1'b0, 1, 1'b1, 7);
    commit_update(1'b0, 2, 1'b1, 7);
    commit_update(1'b0, 0, 1'b0, 15);

    diag_idx = DIAG_IDX_W'(1);
    #1;
    if (recon_sign !== 1'b1) $fatal(1, "expected hit at diag_idx=1");
    diag_idx = DIAG_IDX_W'(2);
    #1;
    if (recon_sign !== 1'b1) $fatal(1, "expected hit at diag_idx=2");
    diag_idx = DIAG_IDX_W'(0);
    #1;
    if (recon_sign !== 1'b0) $fatal(1, "expected base sign at diag_idx=0");

    write_ram_edge(0, 1'b1, 3);
    write_ram_edge(1, 1'b0, 9);
    write_ram_edge(2, 1'b1, 8);

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
