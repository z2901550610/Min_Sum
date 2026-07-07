`timescale 1ns / 1ps

module tb_ram_i;
  import bike_pkg::*;

  logic                  clk;
  logic                  rst_n;
  logic                  clear;
  logic                  we;
  logic [ H_BLOCK_W-1:0] h_block_idx;
  logic [DIAG_IDX_W-1:0] diag_idx_local;
  logic [ ROW_IDX_W-1:0] base_row_idx;
  logic [ ROW_IDX_W-1:0] c2v_base_row_idx;
  logic [ ROW_IDX_W-1:0] v2c_base_row_idx;
  logic                  loaded;
  logic                  error;

  ram_i dut (
      .i_clk(clk),
      .i_rst_n(rst_n),
      .i_clear(clear),
      .i_we(we),
      .i_h_block_idx(h_block_idx),
      .i_diag_idx_local(diag_idx_local),
      .i_base_row_idx(base_row_idx),
      .i_c2v_h_block_idx(H_BLOCK_W'(0)),
      .i_c2v_diag_idx_local(DIAG_IDX_W'(1 % W)),
      .i_v2c_h_block_idx(H_BLOCK_W'(N0 - 1)),
      .i_v2c_diag_idx_local(DIAG_IDX_W'(W - 1)),
      .i_cfg_r(CFG_R_W'(R)),
      .i_cfg_w(CFG_W_W'(W)),
      .o_c2v_base_row_idx(c2v_base_row_idx),
      .o_v2c_base_row_idx(v2c_base_row_idx),
      .o_loaded(loaded),
      .o_error(error)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    rst_n = 1'b0;
    clear = 1'b0;
    we = 1'b0;
    h_block_idx = '0;
    diag_idx_local = '0;
    base_row_idx = '0;
    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);

    for (int h = 0; h < N0; h++) begin
      for (int k = 0; k < W; k++) begin
        we = 1'b1;
        h_block_idx = H_BLOCK_W'(h);
        diag_idx_local = DIAG_IDX_W'(k);
        base_row_idx = ROW_IDX_W'((h * W + k) % R);
        @(posedge clk);
      end
    end
    we = 1'b0;
    while (!loaded && !error) begin
      @(posedge clk);
    end
    #1;
    if (!loaded) $fatal(1, "ram_i loaded flag mismatch");
    if (error) $fatal(1, "ram_i unexpected error");
    if (c2v_base_row_idx != ROW_IDX_W'(1 % R)) $fatal(1, "ram_i c2v read mismatch");
    if (v2c_base_row_idx != ROW_IDX_W'(((N0 - 1) * W + (W - 1)) % R))
      $fatal(1, "ram_i v2c read mismatch");

    clear = 1'b1;
    @(posedge clk);
    clear = 1'b0;
    we = 1'b1;
    h_block_idx = '0;
    diag_idx_local = '0;
    base_row_idx = ROW_IDX_W'(2 % R);
    @(posedge clk);
    diag_idx_local = DIAG_IDX_W'(1 % W);
    base_row_idx   = ROW_IDX_W'(2 % R);
    @(posedge clk);
    we = 1'b0;
    while (!error) begin
      @(posedge clk);
    end
    #1;
    if (!error) $fatal(1, "ram_i duplicate was not detected");

    $display("tb_ram_i PASS");
    $finish;
  end
endmodule
