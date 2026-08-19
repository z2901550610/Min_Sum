`timescale 1ns / 1ps

module tb_trike_decaps_decoder_postcheck_core;
  localparam int MAX_R = 521;
  localparam int MAX_W = 5;
  localparam int BLOCKS = 3;
  localparam int PADDED_R_BYTES = 128;
  localparam int N_BITS = BLOCKS * MAX_R;
  localparam int ERROR_BYTES = BLOCKS * PADDED_R_BYTES;
  localparam int ROW_W = $clog2(MAX_R);
  localparam int COL_W = $clog2(N_BITS);
  localparam int BLOCK_W = $clog2(BLOCKS);
  localparam int DIAG_W = $clog2(MAX_W);
  localparam int ERROR_ADDR_W = $clog2(ERROR_BYTES);
  localparam int RESIDUAL_WEIGHT_W = $clog2(MAX_R + 1);

  logic                           clk;
  logic                           rst_n;
  logic                           h_we;
  logic   [          BLOCK_W-1:0] h_block;
  logic   [           DIAG_W-1:0] h_diag;
  logic   [            ROW_W-1:0] h_index;
  logic                           syndrome_we;
  logic   [            ROW_W-1:0] syndrome_addr;
  logic                           syndrome_data;
  logic                           start;
  logic   [                 31:0] runtime_r_bits;
  logic   [                 31:0] runtime_weight;
  logic   [            COL_W-1:0] decision_col;
  logic                           decision_data;
  logic                           error_re;
  logic   [     ERROR_ADDR_W-1:0] error_raddr;
  logic   [                  7:0] error_rdata;
  logic                           residual_zero;
  logic   [RESIDUAL_WEIGHT_W-1:0] residual_weight;
  logic                           busy;
  logic                           done;
  logic   [            ROW_W-1:0] support[0:BLOCKS*MAX_W-1];
  logic                           decisions[      0:N_BITS-1];
  logic                           syndrome[       0:MAX_R-1];
  logic   [                  7:0] expected_bytes[ 0:ERROR_BYTES-1];
  integer                         cycle_count;

  trike_decaps_decoder_postcheck_core #(
      .R_BITS(MAX_R),
      .BLOCKS(BLOCKS),
      .WEIGHT(MAX_W),
      .PADDED_R_BYTES(PADDED_R_BYTES)
  ) dut (
      .i_clk             (clk),
      .i_rst_n           (rst_n),
      .i_h_we            (h_we),
      .i_h_block_idx     (h_block),
      .i_h_diag_idx      (h_diag),
      .i_h_index         (h_index),
      .i_syndrome_we     (syndrome_we),
      .i_syndrome_addr   (syndrome_addr),
      .i_syndrome_data   (syndrome_data),
      .i_start           (start),
      .i_runtime_r_bits  (runtime_r_bits),
      .i_runtime_weight  (runtime_weight),
      .o_decision_col_idx(decision_col),
      .i_decision_data   (decision_data),
      .i_error_re        (error_re),
      .i_error_raddr     (error_raddr),
      .o_error_rdata     (error_rdata),
      .o_residual_zero   (residual_zero),
      .o_residual_weight (residual_weight),
      .o_busy            (busy),
      .o_done            (done)
  );

  always #1 clk = ~clk;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      decision_data <= 1'b0;
      cycle_count   <= 0;
    end else begin
      decision_data <= decisions[decision_col];
      cycle_count   <= cycle_count + 1;
    end
  end

  task automatic prepare_case(input integer active_r, input integer active_w, input integer seed,
                              input  logic flip_syndrome);
    integer variable;
    integer block;
    integer diag;
    integer local_col;
    integer active_padded_r_bytes;
    begin
      for (int idx = 0; idx < (BLOCKS * MAX_W); idx++) support[idx] = '0;
      for (int idx = 0; idx < N_BITS; idx++) decisions[idx] = 1'b0;
      for (int idx = 0; idx < MAX_R; idx++) syndrome[idx] = 1'b0;
      for (int idx = 0; idx < ERROR_BYTES; idx++) expected_bytes[idx] = '0;
      active_padded_r_bytes = ((active_r + 511) / 512) * 64;

      for (block = 0; block < BLOCKS; block++) begin
        for (diag = 0; diag < active_w; diag++) begin
          support[(block*MAX_W)+diag] = ROW_W'((seed + (3 * block) + (5 * diag)) % active_r);
        end
      end

      for (variable = 0; variable < (BLOCKS * active_r); variable++) begin
        decisions[variable] = (((7 * variable) + seed) % 13) < 4;
        if (decisions[variable]) begin
          block = variable / active_r;
          local_col = variable % active_r;
          expected_bytes[(block*active_padded_r_bytes)+(local_col/8)][local_col%8] = 1'b1;
          for (diag = 0; diag < active_w; diag++) begin
            syndrome[(local_col+int'(support[(block*MAX_W)+diag]))%active_r] ^= 1'b1;
          end
        end
      end
      if (flip_syndrome) syndrome[0] ^= 1'b1;
    end
  endtask

  task automatic load_case(input integer active_r, input integer active_w);
    begin
      for (int block = 0; block < BLOCKS; block++) begin
        for (int diag = 0; diag < active_w; diag++) begin
          @(negedge clk);
          h_we = 1'b1;
          h_block = BLOCK_W'(block);
          h_diag = DIAG_W'(diag);
          h_index = support[(block*MAX_W)+diag];
        end
      end
      @(negedge clk);
      h_we = 1'b0;

      for (int row = 0; row < active_r; row++) begin
        @(negedge clk);
        syndrome_we   = 1'b1;
        syndrome_addr = ROW_W'(row);
        syndrome_data = syndrome[row];
      end
      @(negedge clk);
      syndrome_we = 1'b0;
    end
  endtask

  task automatic run_case(input integer active_r, input integer active_w, input integer seed,
                          input  logic flip_syndrome, output integer latency);
    integer start_cycle;
    integer expected_latency;
    integer active_padded_r_bytes;
    integer active_error_bytes;
    begin
      prepare_case(active_r, active_w, seed, flip_syndrome);
      load_case(active_r, active_w);

      @(negedge clk);
      runtime_r_bits = 32'(active_r);
      runtime_weight = 32'(active_w);
      start = 1'b1;
      start_cycle = cycle_count;
      @(negedge clk);
      start = 1'b0;
      runtime_r_bits = 32'(MAX_R);
      runtime_weight = 32'(MAX_W);
      if (!busy) $fatal(1, "postcheck did not become busy");
      while (!done) @(negedge clk);
      latency = cycle_count - start_cycle;

      active_padded_r_bytes = ((active_r + 511) / 512) * 64;
      active_error_bytes = BLOCKS * active_padded_r_bytes;
      expected_latency = active_error_bytes + (BLOCKS * active_r) + 2;
      expected_latency += (active_r * (2 + (2 * BLOCKS * active_w))) + 1;
      expected_latency += 3;
      if (latency != expected_latency) $fatal(1, "runtime postcheck latency mismatch");
      if (residual_zero != !flip_syndrome) $fatal(1, "runtime residual zero mismatch");
      if (residual_weight != (flip_syndrome ? 1 : 0)) $fatal(1, "runtime residual weight mismatch");

      for (int byte_idx = 0; byte_idx < active_error_bytes; byte_idx++) begin
        @(negedge clk);
        error_re = 1'b1;
        error_raddr = ERROR_ADDR_W'(byte_idx);
        @(negedge clk);
        if (error_rdata != expected_bytes[byte_idx]) $fatal(1, "runtime dense error byte mismatch");
      end
      error_re = 1'b0;
      $display("runtime postcheck r=%0d w=%0d seed=%0h flip=%0d cycles=%0d", active_r, active_w,
               seed, flip_syndrome, latency);
    end
  endtask

  initial begin
    integer latency_a;
    integer latency_b;

    clk = 1'b0;
    rst_n = 1'b0;
    h_we = 1'b0;
    h_block = '0;
    h_diag = '0;
    h_index = '0;
    syndrome_we = 1'b0;
    syndrome_addr = '0;
    syndrome_data = 1'b0;
    start = 1'b0;
    runtime_r_bits = '0;
    runtime_weight = '0;
    error_re = 1'b0;
    error_raddr = '0;

    repeat (3) @(negedge clk);
    rst_n = 1'b1;

    run_case(7, 1, 32'h11, 1'b0, latency_a);
    run_case(7, 1, 32'he2, 1'b1, latency_b);
    if (latency_a != latency_b) $fatal(1, "r=7 data-dependent postcheck latency");

    run_case(13, 3, 32'h2d, 1'b0, latency_a);
    run_case(13, 3, 32'hc4, 1'b1, latency_b);
    if (latency_a != latency_b) $fatal(1, "r=13 data-dependent postcheck latency");

    run_case(521, 5, 32'h39, 1'b0, latency_a);
    run_case(521, 5, 32'ha6, 1'b1, latency_b);
    if (latency_a != latency_b) $fatal(1, "r=521 data-dependent postcheck latency");

    $display("tb_trike_decaps_decoder_postcheck_core PASS");
    $finish;
  end

endmodule
