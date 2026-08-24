`timescale 1ns / 1ps

module tb_trike_decaps_postprocess_reference #(
    parameter bit USE_SHARED_SM3     = 1'b0,
    parameter bit USE_SHARED_SAMPLER = 1'b0
);
  `include "generated/trike_decaps_message_minsum_case.svh"

  localparam int R_BYTES = (REF_R_BITS + 7) / 8;
  localparam int PADDED_R_BYTES = REF_ERROR_BYTES / REF_BLOCKS;
  localparam int ERROR_ADDR_W = $clog2(REF_ERROR_BYTES);
  localparam int R_ADDR_W = $clog2(R_BYTES);
  localparam int CT_ADDR_W = $clog2(REF_CIPHERTEXT_BYTES);
  localparam int SS_IDX_W = $clog2(REF_M_BYTES);
  localparam int SAMPLER_INDEX_W = $clog2(3 * REF_R_BITS);

  logic                         clk;
  logic                         rst_n;
  logic                         start;
  logic                         c2_valid;
  logic   [                7:0] c2_data;
  logic                         c2_ready;
  logic                         reference_re;
  logic   [   ERROR_ADDR_W-1:0] reference_raddr;
  logic   [                7:0] reference_rdata;
  logic                         r2_re;
  logic   [       R_ADDR_W-1:0] r2_raddr;
  logic   [                7:0] r2_rdata;
  logic                         ciphertext_re;
  logic   [      CT_ADDR_W-1:0] ciphertext_raddr;
  logic   [                7:0] ciphertext_rdata;
  logic                         ciphertext_equal;
  logic                         shared_secret_valid;
  logic   [       SS_IDX_W-1:0] shared_secret_index;
  logic   [                7:0] shared_secret_data;
  logic                         shared_secret_last;
  logic                         busy;
  logic                         done;
  /* verilator lint_off UNUSEDSIGNAL */
  logic                         compress_start;
  logic   [              511:0] compress_block;
  logic   [              255:0] compress_input_state;
  logic                         compress_busy;
  logic                         compress_done;
  logic   [              255:0] compress_output_state;
  logic                         selected_compress_start;
  logic   [              511:0] selected_compress_block;
  logic   [              255:0] selected_compress_state;
  logic                         sampler_start;
  logic   [               31:0] sampler_length;
  logic   [               31:0] sampler_weight;
  logic   [              439:0] sampler_input_v;
  logic   [              439:0] sampler_input_c;
  logic   [              439:0] sampler_input_reseed_counter;
  logic                         sampler_index_valid;
  logic   [                8:0] sampler_index_position;
  logic   [SAMPLER_INDEX_W-1:0] sampler_index;
  logic                         sampler_index_ready;
  logic                         sampler_busy;
  logic                         sampler_done;
  logic   [              439:0] sampler_output_v;
  logic   [              439:0] sampler_output_c;
  logic   [              439:0] sampler_output_reseed_counter;
  logic                         sampler_compress_start;
  logic   [              511:0] sampler_compress_block;
  logic   [              255:0] sampler_compress_state;
  /* verilator lint_on UNUSEDSIGNAL */
  logic                         tampered_case;
  integer                       c2_count;
  integer                       shared_secret_count;
  integer                       cycle_count;

  trike_decaps_postprocess_core #(
      .M_BYTES              (REF_M_BYTES),
      .R_BITS               (REF_R_BITS),
      .ERROR_WEIGHT         (263),
      .PADDED_R_BYTES       (PADDED_R_BYTES),
      .CIPHERTEXT_BYTES     (REF_CIPHERTEXT_BYTES),
      .RUNTIME_GEOMETRY     (1'b1),
      .USE_EXTERNAL_COMPRESS(USE_SHARED_SM3),
      .USE_EXTERNAL_SAMPLER (USE_SHARED_SAMPLER)
  ) dut (
      .i_clk                     (clk),
      .i_rst_n                   (rst_n),
      .i_start                   (start),
      .i_runtime_r_bits          (32'(REF_R_BITS)),
      .i_runtime_error_weight    (32'd263),
      .i_runtime_r_bytes         (32'((REF_R_BITS + 7) / 8)),
      .i_runtime_padded_r_bytes  (32'(PADDED_R_BYTES)),
      .i_runtime_error_bytes     (32'(3 * PADDED_R_BYTES)),
      .i_runtime_ciphertext_bytes(32'(REF_CIPHERTEXT_BYTES)),
      .i_decoder_ok              (1'b1),
      .i_sigma2                  (REF_SIGMA2),
      .i_c2_valid                (c2_valid),
      .i_c2_data                 (c2_data),
      .o_c2_ready                (c2_ready),
      .o_reference_re            (reference_re),
      .o_reference_raddr         (reference_raddr),
      .i_reference_rdata         (reference_rdata),
      .o_r2_re                   (r2_re),
      .o_r2_raddr                (r2_raddr),
      .i_r2_rdata                (r2_rdata),
      .o_ciphertext_re           (ciphertext_re),
      .o_ciphertext_raddr        (ciphertext_raddr),
      .i_ciphertext_rdata        (ciphertext_rdata),
      .o_ciphertext_equal        (ciphertext_equal),
      .o_shared_secret_valid     (shared_secret_valid),
      .o_shared_secret_index     (shared_secret_index),
      .o_shared_secret_data      (shared_secret_data),
      .o_shared_secret_last      (shared_secret_last),
      .i_shared_secret_ready     (1'b1),
      .o_busy                    (busy),
      .o_done                    (done),
      .o_compress_start          (compress_start),
      .o_compress_block          (compress_block),
      .o_compress_state          (compress_input_state),
      .i_compress_busy           (compress_busy),
      .i_compress_done           (compress_done),
      .i_compress_state          (compress_output_state),
      .o_sampler_start           (sampler_start),
      .o_sampler_runtime_length  (sampler_length),
      .o_sampler_runtime_weight  (sampler_weight),
      .o_sampler_v               (sampler_input_v),
      .o_sampler_c               (sampler_input_c),
      .o_sampler_reseed_counter  (sampler_input_reseed_counter),
      .i_sampler_index_valid     (sampler_index_valid),
      .i_sampler_index_position  (sampler_index_position),
      .i_sampler_index           (sampler_index),
      .o_sampler_index_ready     (sampler_index_ready),
      .i_sampler_done            (sampler_done),
      .i_sampler_v               (sampler_output_v),
      .i_sampler_c               (sampler_output_c),
      .i_sampler_reseed_counter  (sampler_output_reseed_counter)
  );

  always_comb begin
    selected_compress_start = compress_start;
    selected_compress_block = compress_block;
    selected_compress_state = compress_input_state;
    if (sampler_busy || sampler_start) begin
      selected_compress_start = sampler_compress_start;
      selected_compress_block = sampler_compress_block;
      selected_compress_state = sampler_compress_state;
    end
  end

  generate
    if (USE_SHARED_SM3) begin : g_shared_sm3
      trike_sm3_service u_sm3_service (
          .i_clk  (clk),
          .i_rst_n(rst_n),
          .i_start(selected_compress_start),
          .i_block(selected_compress_block),
          .i_state(selected_compress_state),
          .o_busy (compress_busy),
          .o_done (compress_done),
          .o_state(compress_output_state)
      );
    end else begin : g_local_sm3
      assign compress_busy = 1'b0;
      assign compress_done = 1'b0;
      assign compress_output_state = '0;
    end

    if (USE_SHARED_SAMPLER) begin : g_shared_sampler
      trike_drng_weight_sampler #(
          .LENGTH               (3 * REF_R_BITS),
          .WEIGHT               (263),
          .RUNTIME_GEOMETRY     (1'b1),
          .USE_EXTERNAL_COMPRESS(1'b1)
      ) u_sampler_service (
          .i_clk           (clk),
          .i_rst_n         (rst_n),
          .i_start         (sampler_start),
          .i_runtime_length(sampler_length),
          .i_runtime_weight(sampler_weight),
          .i_v             (sampler_input_v),
          .i_c             (sampler_input_c),
          .i_reseed_counter(sampler_input_reseed_counter),
          .o_index_valid   (sampler_index_valid),
          .o_index_position(sampler_index_position),
          .o_index         (sampler_index),
          .i_index_ready   (sampler_index_ready),
          .o_busy          (sampler_busy),
          .o_done          (sampler_done),
          .o_v             (sampler_output_v),
          .o_c             (sampler_output_c),
          .o_reseed_counter(sampler_output_reseed_counter),
          .o_compress_start(sampler_compress_start),
          .o_compress_block(sampler_compress_block),
          .o_compress_state(sampler_compress_state),
          .i_compress_busy (compress_busy),
          .i_compress_done (compress_done),
          .i_compress_state(compress_output_state)
      );
    end else begin : g_local_sampler
      assign sampler_index_valid = 1'b0;
      assign sampler_index_position = '0;
      assign sampler_index = '0;
      assign sampler_busy = 1'b0;
      assign sampler_done = 1'b0;
      assign sampler_output_v = '0;
      assign sampler_output_c = '0;
      assign sampler_output_reseed_counter = '0;
      assign sampler_compress_start = 1'b0;
      assign sampler_compress_block = '0;
      assign sampler_compress_state = '0;
    end
  endgenerate

  always #1 clk = ~clk;

  always_comb begin
    c2_valid = c2_count < REF_M_BYTES;
    c2_data = tampered_case ?
        REF_TAMPERED_C2[8*((c2_count<REF_M_BYTES)?c2_count:0)+:8] :
        REF_C2[8*((c2_count<REF_M_BYTES)?c2_count:0)+:8];
  end

  always_ff @(posedge clk) begin
    if (reference_re) reference_rdata <= REF_ERROR_DATA[8*reference_raddr+:8];
    if (r2_re) r2_rdata <= REF_R2[8*r2_raddr+:8];
    if (ciphertext_re) begin
      ciphertext_rdata <= tampered_case ?
          REF_TAMPERED_CIPHERTEXT[8*ciphertext_raddr+:8] :
          REF_CIPHERTEXT[8*ciphertext_raddr+:8];
    end
    if (!rst_n) begin
      c2_count <= 0;
      shared_secret_count <= 0;
      cycle_count <= 0;
    end else begin
      cycle_count <= cycle_count + 1;
      if (start) begin
        c2_count <= 0;
        shared_secret_count <= 0;
      end else begin
        if (c2_valid && c2_ready) c2_count <= c2_count + 1;
        if (shared_secret_valid) begin
          if (shared_secret_index != SS_IDX_W'(shared_secret_count))
            $fatal(1, "shared-secret index mismatch");
          if (shared_secret_last != (shared_secret_count == (REF_M_BYTES - 1)))
            $fatal(1, "shared-secret last mismatch");
          if (shared_secret_data !=
              (tampered_case ? REF_TAMPERED_SHARED_SECRET[8*shared_secret_count+:8] :
                               REF_SHARED_SECRET[8*shared_secret_count+:8]))
            $fatal(1, "postprocess shared-secret mismatch at byte %0d", shared_secret_count);
          shared_secret_count <= shared_secret_count + 1;
        end
      end
    end
  end

  task automatic run_case(input  logic tampered, output integer latency);
    integer start_cycle;
    begin
      tampered_case = tampered;
      @(negedge clk);
      start = 1'b1;
      start_cycle = cycle_count;
      @(negedge clk);
      start = 1'b0;
      if (!busy) $fatal(1, "postprocess core did not become busy");
      while (!done) @(negedge clk);
      latency = cycle_count - start_cycle;
      if (c2_count != REF_M_BYTES) $fatal(1, "c2 byte count mismatch");
      if (shared_secret_count != REF_M_BYTES) $fatal(1, "shared-secret byte count mismatch");
      if (ciphertext_equal == tampered) $fatal(1, "postprocess equality mismatch");
    end
  endtask

  initial begin
    integer valid_latency;
    integer tampered_latency;

    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    tampered_case = 1'b0;

    repeat (3) @(negedge clk);
    rst_n = 1'b1;
    run_case(1'b0, valid_latency);
    run_case(1'b1, tampered_latency);
    if (valid_latency != tampered_latency) $fatal(1, "data-dependent postprocess latency");

    $display("tb_trike_decaps_postprocess_reference PASS cycles=%0d", valid_latency);
    $finish;
  end

  initial begin
    repeat (1200000) @(posedge clk);
    $fatal(1, "tb_trike_decaps_postprocess_reference timeout");
  end

endmodule
