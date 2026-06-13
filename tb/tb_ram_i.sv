`timescale 1ns / 1ps

module tb_ram_i;
  import bike_pkg::*;

  logic                 clk;
  logic                 rst_n;
  logic                 clear;
  logic                 we;
  logic [H_BLOCK_W-1:0] h_block_idx;
  logic [ONE_IDX_W-1:0] one_idx;
  logic [ROW_IDX_W-1:0] base_row;
  logic [ROW_IDX_W-1:0] c2v_base_row;
  logic [EDGE_ID_W-1:0] c2v_edge_id;
  logic [ROW_IDX_W-1:0] v2c_base_row;
  logic [EDGE_ID_W-1:0] v2c_edge_id;
  logic                 loaded;
  logic                 error;

  ram_i dut (
      .i_clk(clk),
      .i_rst_n(rst_n),
      .i_clear(clear),
      .i_we(we),
      .i_h_block_idx(h_block_idx),
      .i_one_idx(one_idx),
      .i_base_row(base_row),
      .i_c2v_h_block_idx(H_BLOCK_W'(0)),
      .i_c2v_one_idx(ONE_IDX_W'(1 % W)),
      .i_v2c_h_block_idx(H_BLOCK_W'(N0 - 1)),
      .i_v2c_one_idx(ONE_IDX_W'(W - 1)),
      .o_c2v_base_row(c2v_base_row),
      .o_c2v_edge_id(c2v_edge_id),
      .o_v2c_base_row(v2c_base_row),
      .o_v2c_edge_id(v2c_edge_id),
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
    one_idx = '0;
    base_row = '0;
    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);

    for (int h = 0; h < N0; h++) begin
      for (int k = 0; k < W; k++) begin
        we = 1'b1;
        h_block_idx = H_BLOCK_W'(h);
        one_idx = ONE_IDX_W'(k);
        base_row = ROW_IDX_W'((h * W + k) % R);
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
    if (c2v_base_row != ROW_IDX_W'(1 % R)) $fatal(1, "ram_i c2v read mismatch");
    if (c2v_edge_id != EDGE_ID_W'(1 % W)) $fatal(1, "ram_i c2v edge mismatch");
    if (v2c_base_row != ROW_IDX_W'(((N0 - 1) * W + (W - 1)) % R))
      $fatal(1, "ram_i v2c read mismatch");
    if (v2c_edge_id != EDGE_ID_W'((N0 - 1) * W + (W - 1))) $fatal(1, "ram_i v2c edge mismatch");

    clear = 1'b1;
    @(posedge clk);
    clear = 1'b0;
    we = 1'b1;
    h_block_idx = '0;
    one_idx = '0;
    base_row = ROW_IDX_W'(2 % R);
    @(posedge clk);
    one_idx  = ONE_IDX_W'(1 % W);
    base_row = ROW_IDX_W'(2 % R);
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
