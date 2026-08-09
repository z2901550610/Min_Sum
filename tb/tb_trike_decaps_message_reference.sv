`timescale 1ns / 1ps

module tb_trike_decaps_message_reference;
  `include "generated/trike_decaps_message_minsum_case.svh"

  localparam int ERROR_ADDR_W = $clog2(REF_ERROR_BYTES);
  localparam int MESSAGE_IDX_W = $clog2(REF_M_BYTES);

  logic                       clk;
  logic                       rst_n;
  logic                       start;
  logic                       c2_valid;
  logic   [              7:0] c2_data;
  logic                       c2_ready;
  logic                       error_re;
  logic   [ ERROR_ADDR_W-1:0] error_raddr;
  logic   [              7:0] error_rdata;
  logic                       message_valid;
  logic   [MESSAGE_IDX_W-1:0] message_index;
  logic   [              7:0] message_data;
  logic                       message_last;
  logic                       message_ready;
  logic                       busy;
  logic                       done;
  logic   [            511:0] l_digest;
  logic                       unused_compress_start;
  logic   [            511:0] unused_compress_block;
  logic   [            255:0] unused_compress_state;
  logic                       use_zero_error;
  logic                       check_message;
  integer                     c2_count;
  integer                     message_count;
  integer                     cycle_count;

  trike_decaps_message_recover #(
      .M_BYTES    (REF_M_BYTES),
      .ERROR_BYTES(REF_ERROR_BYTES)
  ) dut (
      .i_clk           (clk),
      .i_rst_n         (rst_n),
      .i_start         (start),
      .i_c2_valid      (c2_valid),
      .i_c2_data       (c2_data),
      .o_c2_ready      (c2_ready),
      .o_error_re      (error_re),
      .o_error_raddr   (error_raddr),
      .i_error_rdata   (error_rdata),
      .o_message_valid (message_valid),
      .o_message_index (message_index),
      .o_message_data  (message_data),
      .o_message_last  (message_last),
      .i_message_ready (message_ready),
      .o_busy          (busy),
      .o_done          (done),
      .o_l_digest      (l_digest),
      .o_compress_start(unused_compress_start),
      .o_compress_block(unused_compress_block),
      .o_compress_state(unused_compress_state),
      .i_compress_busy (1'b0),
      .i_compress_done (1'b0),
      .i_compress_state('0)
  );

  always #1 clk = ~clk;

  always_comb begin
    c2_valid = c2_count < REF_M_BYTES;
    c2_data = REF_C2[8*((c2_count<REF_M_BYTES)?c2_count : 0)+:8];
    message_ready = 1'b1;
  end

  always_ff @(posedge clk) begin
    if (error_re) begin
      error_rdata <= use_zero_error ? 8'h00 : REF_ERROR_DATA[8*error_raddr+:8];
    end
    if (!rst_n) begin
      c2_count <= 0;
      message_count <= 0;
      cycle_count <= 0;
    end else begin
      cycle_count <= cycle_count + 1;
      if (start) begin
        c2_count <= 0;
        message_count <= 0;
      end else begin
        if (c2_valid && c2_ready) c2_count <= c2_count + 1;
        if (message_valid && message_ready) begin
          if (message_index != MESSAGE_IDX_W'(message_count)) $fatal(1, "message index mismatch");
          if (message_last != (message_count == (REF_M_BYTES - 1)))
            $fatal(1, "message last mismatch");
          if (check_message && (message_data != REF_MESSAGE[8*message_count+:8]))
            $fatal(1, "recovered message mismatch at byte %0d", message_count);
          message_count <= message_count + 1;
        end
      end
    end
  end

  task automatic run_case(input  logic zero_error, input  logic check_data, output integer latency);
    integer start_cycle;
    begin
      use_zero_error = zero_error;
      check_message  = check_data;
      @(negedge clk);
      start = 1'b1;
      start_cycle = cycle_count;
      @(negedge clk);
      start = 1'b0;
      if (!busy) $fatal(1, "message recovery did not become busy");
      while (!done) @(negedge clk);
      latency = cycle_count - start_cycle;
      if (c2_count != REF_M_BYTES) $fatal(1, "c2 byte count mismatch");
      if (message_count != REF_M_BYTES) $fatal(1, "message byte count mismatch");
    end
  endtask

  initial begin
    integer valid_latency;
    integer zero_latency;

    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    use_zero_error = 1'b0;
    check_message = 1'b0;

    repeat (3) @(negedge clk);
    rst_n = 1'b1;
    if ((REF_R_BITS != 12589) || (REF_BLOCKS != 3)) $fatal(1, "fixture profile mismatch");
    run_case(1'b0, 1'b1, valid_latency);
    if (l_digest != REF_L_DIGEST) $fatal(1, "L(e') digest mismatch");
    run_case(1'b1, 1'b0, zero_latency);
    if (valid_latency != zero_latency) $fatal(1, "data-dependent message recovery latency");

    $display("tb_trike_decaps_message_reference PASS cycles=%0d", valid_latency);
    $finish;
  end

  initial begin
    repeat (300000) @(posedge clk);
    $fatal(1, "tb_trike_decaps_message_reference timeout");
  end

endmodule
