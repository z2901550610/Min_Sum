`timescale 1ns / 1ps

module tb_trike_decaps_verify_reference;
  `include "generated/trike_decaps_message_minsum_case.svh"

  localparam int R_BYTES = (REF_R_BITS + 7) / 8;
  localparam int SEED_BYTES = REF_M_BYTES + R_BYTES;
  localparam int PADDED_R_BYTES = REF_ERROR_BYTES / REF_BLOCKS;
  localparam int ERROR_ADDR_W = $clog2(REF_ERROR_BYTES);

  logic                      clk;
  logic                      rst_n;
  logic                      start;
  logic                      decoder_ok;
  logic                      seed_valid;
  logic   [             7:0] seed_data;
  logic                      seed_ready;
  logic                      seed_pass;
  logic                      reference_re;
  logic   [ERROR_ADDR_W-1:0] reference_raddr;
  logic   [             7:0] reference_rdata;
  logic                      equal;
  logic   [           255:0] selected_data;
  logic                      busy;
  logic                      done;
  logic                      corrupt_seed;
  integer                    seed_index;
  integer                    seed_total_count;
  integer                    cycle_count;

  /* verilator lint_off PINCONNECTEMPTY */
  trike_decaps_reencrypt_verify #(
      .M_BYTES         (REF_M_BYTES),
      .R_BITS          (REF_R_BITS),
      .ERROR_WEIGHT    (263),
      .PADDED_R_BYTES  (PADDED_R_BYTES),
      .RUNTIME_GEOMETRY(1'b1)
  ) dut (
      .i_clk                   (clk),
      .i_rst_n                 (rst_n),
      .i_start                 (start),
      .i_runtime_r_bits        (32'(REF_R_BITS)),
      .i_runtime_error_weight  (32'd263),
      .i_runtime_padded_r_bytes(32'(PADDED_R_BYTES)),
      .i_runtime_error_bytes   (32'(3 * PADDED_R_BYTES)),
      .i_decoder_ok            (decoder_ok),
      .i_seed_valid            (seed_valid),
      .i_seed_data             (seed_data),
      .o_seed_ready            (seed_ready),
      .o_seed_pass             (seed_pass),
      .o_reference_re          (reference_re),
      .o_reference_raddr       (reference_raddr),
      .i_reference_rdata       (reference_rdata),
      .i_match_data            (REF_MESSAGE),
      .i_mismatch_data         (REF_SIGMA2),
      .o_equal                 (equal),
      .o_selected_data         (selected_data),
      .o_busy                  (busy),
      .o_done                  (done),
      .o_compress_start        (),
      .o_compress_block        (),
      .o_compress_state        (),
      .i_compress_busy         (1'b0),
      .i_compress_done         (1'b0),
      .i_compress_state        ('0)
  );
  /* verilator lint_on PINCONNECTEMPTY */

  always #1 clk = ~clk;

  always_comb begin
    seed_valid = seed_total_count < (2 * SEED_BYTES);
    if (seed_index < REF_M_BYTES) seed_data = REF_MESSAGE[8*seed_index+:8];
    else seed_data = REF_R2[8*(seed_index-REF_M_BYTES)+:8];
    if (corrupt_seed && (seed_index == 0)) seed_data ^= 8'h01;
  end

  always_ff @(posedge clk) begin
    if (reference_re) reference_rdata <= REF_ERROR_DATA[8*reference_raddr+:8];
    if (!rst_n) begin
      seed_index <= 0;
      seed_total_count <= 0;
      cycle_count <= 0;
    end else begin
      cycle_count <= cycle_count + 1;
      if (start) begin
        seed_index <= 0;
        seed_total_count <= 0;
      end else if (seed_valid && seed_ready) begin
        if (seed_pass != (seed_total_count >= SEED_BYTES)) $fatal(1, "H4 seed pass mismatch");
        seed_total_count <= seed_total_count + 1;
        seed_index <= (seed_index == (SEED_BYTES - 1)) ? 0 : seed_index + 1;
      end
    end
  end

  task automatic run_case(input  logic corrupt, output integer latency);
    integer start_cycle;
    begin
      corrupt_seed = corrupt;
      @(negedge clk);
      start = 1'b1;
      start_cycle = cycle_count;
      @(negedge clk);
      start = 1'b0;
      if (!busy) $fatal(1, "reencryption verifier did not become busy");
      while (!done) @(negedge clk);
      latency = cycle_count - start_cycle;
      if (seed_total_count != (2 * SEED_BYTES)) $fatal(1, "H4 seed byte count mismatch");
      if (equal == corrupt) $fatal(1, "reencryption equality mismatch");
      if (selected_data != (corrupt ? REF_SIGMA2 : REF_MESSAGE))
        $fatal(1, "implicit rejection selection mismatch");
    end
  endtask

  initial begin
    integer valid_latency;
    integer corrupt_latency;

    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    decoder_ok = 1'b1;
    corrupt_seed = 1'b0;

    repeat (3) @(negedge clk);
    rst_n = 1'b1;
    run_case(1'b0, valid_latency);
    run_case(1'b1, corrupt_latency);
    if (valid_latency != corrupt_latency) $fatal(1, "data-dependent verification latency");

    $display("tb_trike_decaps_verify_reference PASS cycles=%0d", valid_latency);
    $finish;
  end

  initial begin
    repeat (2000000) @(posedge clk);
    $fatal(1, "tb_trike_decaps_verify_reference timeout");
  end

endmodule
