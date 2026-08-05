`timescale 1ns / 1ps

module tb_trike_encaps_hash_reference;

  /* verilator lint_off UNUSEDPARAM */
  `include "generated/trike_encaps_reference_case.svh"
  /* verilator lint_on UNUSEDPARAM */

  localparam int REF_ERROR_BYTES = 3 * REF_PADDED_R_BYTES;
  localparam int REF_K_BYTES = REF_M_BYTES + (2 * REF_R_BYTES) + REF_M_BYTES;
  localparam int REF_L_BUSY_CYCLES = 34916;
  localparam int REF_K_BUSY_CYCLES = 23616;

  logic         clk;
  logic         rst_n;

  logic         l_start;
  logic         l_input_valid;
  logic [  7:0] l_input_data;
  logic         l_input_ready;
  logic         l_input_pass;
  logic         l_busy;
  logic         l_done;
  logic [511:0] l_digest;

  logic         k_start;
  logic         k_input_valid;
  logic [  7:0] k_input_data;
  logic         k_input_ready;
  logic         k_input_pass;
  logic         k_busy;
  logic         k_done;
  logic [511:0] k_digest;

  int           l_busy_cycles;
  int           k_busy_cycles;

  /* verilator lint_off PINCONNECTEMPTY */
  trike_pseudohash512_stream #(
      .MESSAGE_BYTES(REF_ERROR_BYTES)
  ) u_l (
      .i_clk           (clk),
      .i_rst_n         (rst_n),
      .i_start         (l_start),
      .i_input_valid   (l_input_valid),
      .i_input_data    (l_input_data),
      .o_input_ready   (l_input_ready),
      .o_input_pass    (l_input_pass),
      .o_busy          (l_busy),
      .o_done          (l_done),
      .o_digest        (l_digest),
      .o_compress_start(),
      .o_compress_block(),
      .o_compress_state(),
      .i_compress_busy (1'b0),
      .i_compress_done (1'b0),
      .i_compress_state('0)
  );

  trike_pseudohash512_stream #(
      .MESSAGE_BYTES(REF_K_BYTES)
  ) u_k (
      .i_clk           (clk),
      .i_rst_n         (rst_n),
      .i_start         (k_start),
      .i_input_valid   (k_input_valid),
      .i_input_data    (k_input_data),
      .o_input_ready   (k_input_ready),
      .o_input_pass    (k_input_pass),
      .o_busy          (k_busy),
      .o_done          (k_done),
      .o_digest        (k_digest),
      .o_compress_start(),
      .o_compress_block(),
      .o_compress_state(),
      .i_compress_busy (1'b0),
      .i_compress_done (1'b0),
      .i_compress_state('0)
  );
  /* verilator lint_on PINCONNECTEMPTY */

  always #5 clk = ~clk;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      l_busy_cycles <= 0;
      k_busy_cycles <= 0;
    end else begin
      if (l_busy) l_busy_cycles <= l_busy_cycles + 1;
      if (k_busy) k_busy_cycles <= k_busy_cycles + 1;
    end
  end

  function automatic logic [7:0] k_message_byte(input int byte_idx);
    begin
      if (byte_idx < REF_M_BYTES) begin
        k_message_byte = REF_MESSAGE[byte_idx];
      end else begin
        k_message_byte = REF_CIPHERTEXT[byte_idx-REF_M_BYTES];
      end
    end
  endfunction

  task automatic run_l;
    int input_idx;
    begin
      l_input_valid = 1'b0;
      l_start = 1'b1;
      @(negedge clk);
      l_start = 1'b0;
      l_input_valid = 1'b1;
      for (int pass = 0; pass < 2; pass++) begin
        input_idx = 0;
        while (input_idx < REF_ERROR_BYTES) begin
          l_input_data = REF_ERROR_PADDED[input_idx];
          @(posedge clk);
          if (l_input_valid && l_input_ready) begin
            if (l_input_pass != pass[0]) $fatal(1, "L input pass mismatch");
            @(negedge clk);
            input_idx++;
          end
        end
      end
      l_input_valid = 1'b0;
      wait (l_done);
      if (l_digest != {
            REF_L_DIGEST[0], REF_L_DIGEST[1], REF_L_DIGEST[2], REF_L_DIGEST[3],
            REF_L_DIGEST[4], REF_L_DIGEST[5], REF_L_DIGEST[6], REF_L_DIGEST[7],
            REF_L_DIGEST[8], REF_L_DIGEST[9], REF_L_DIGEST[10], REF_L_DIGEST[11],
            REF_L_DIGEST[12], REF_L_DIGEST[13], REF_L_DIGEST[14], REF_L_DIGEST[15],
            REF_L_DIGEST[16], REF_L_DIGEST[17], REF_L_DIGEST[18], REF_L_DIGEST[19],
            REF_L_DIGEST[20], REF_L_DIGEST[21], REF_L_DIGEST[22], REF_L_DIGEST[23],
            REF_L_DIGEST[24], REF_L_DIGEST[25], REF_L_DIGEST[26], REF_L_DIGEST[27],
            REF_L_DIGEST[28], REF_L_DIGEST[29], REF_L_DIGEST[30], REF_L_DIGEST[31],
            REF_L_DIGEST[32], REF_L_DIGEST[33], REF_L_DIGEST[34], REF_L_DIGEST[35],
            REF_L_DIGEST[36], REF_L_DIGEST[37], REF_L_DIGEST[38], REF_L_DIGEST[39],
            REF_L_DIGEST[40], REF_L_DIGEST[41], REF_L_DIGEST[42], REF_L_DIGEST[43],
            REF_L_DIGEST[44], REF_L_DIGEST[45], REF_L_DIGEST[46], REF_L_DIGEST[47],
            REF_L_DIGEST[48], REF_L_DIGEST[49], REF_L_DIGEST[50], REF_L_DIGEST[51],
            REF_L_DIGEST[52], REF_L_DIGEST[53], REF_L_DIGEST[54], REF_L_DIGEST[55],
            REF_L_DIGEST[56], REF_L_DIGEST[57], REF_L_DIGEST[58], REF_L_DIGEST[59],
            REF_L_DIGEST[60], REF_L_DIGEST[61], REF_L_DIGEST[62], REF_L_DIGEST[63]
          }) begin
        $fatal(1, "official L digest mismatch");
      end
    end
  endtask

  task automatic run_k;
    int input_idx;
    begin
      k_input_valid = 1'b0;
      k_start = 1'b1;
      @(negedge clk);
      k_start = 1'b0;
      k_input_valid = 1'b1;
      for (int pass = 0; pass < 2; pass++) begin
        input_idx = 0;
        while (input_idx < REF_K_BYTES) begin
          k_input_data = k_message_byte(input_idx);
          @(posedge clk);
          if (k_input_valid && k_input_ready) begin
            if (k_input_pass != pass[0]) $fatal(1, "K input pass mismatch");
            @(negedge clk);
            input_idx++;
          end
        end
      end
      k_input_valid = 1'b0;
      wait (k_done);
      if (k_digest != {
            REF_K_DIGEST[0], REF_K_DIGEST[1], REF_K_DIGEST[2], REF_K_DIGEST[3],
            REF_K_DIGEST[4], REF_K_DIGEST[5], REF_K_DIGEST[6], REF_K_DIGEST[7],
            REF_K_DIGEST[8], REF_K_DIGEST[9], REF_K_DIGEST[10], REF_K_DIGEST[11],
            REF_K_DIGEST[12], REF_K_DIGEST[13], REF_K_DIGEST[14], REF_K_DIGEST[15],
            REF_K_DIGEST[16], REF_K_DIGEST[17], REF_K_DIGEST[18], REF_K_DIGEST[19],
            REF_K_DIGEST[20], REF_K_DIGEST[21], REF_K_DIGEST[22], REF_K_DIGEST[23],
            REF_K_DIGEST[24], REF_K_DIGEST[25], REF_K_DIGEST[26], REF_K_DIGEST[27],
            REF_K_DIGEST[28], REF_K_DIGEST[29], REF_K_DIGEST[30], REF_K_DIGEST[31],
            REF_K_DIGEST[32], REF_K_DIGEST[33], REF_K_DIGEST[34], REF_K_DIGEST[35],
            REF_K_DIGEST[36], REF_K_DIGEST[37], REF_K_DIGEST[38], REF_K_DIGEST[39],
            REF_K_DIGEST[40], REF_K_DIGEST[41], REF_K_DIGEST[42], REF_K_DIGEST[43],
            REF_K_DIGEST[44], REF_K_DIGEST[45], REF_K_DIGEST[46], REF_K_DIGEST[47],
            REF_K_DIGEST[48], REF_K_DIGEST[49], REF_K_DIGEST[50], REF_K_DIGEST[51],
            REF_K_DIGEST[52], REF_K_DIGEST[53], REF_K_DIGEST[54], REF_K_DIGEST[55],
            REF_K_DIGEST[56], REF_K_DIGEST[57], REF_K_DIGEST[58], REF_K_DIGEST[59],
            REF_K_DIGEST[60], REF_K_DIGEST[61], REF_K_DIGEST[62], REF_K_DIGEST[63]
          }) begin
        $fatal(1, "official K digest mismatch");
      end
    end
  endtask

  initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    l_start = 1'b0;
    l_input_valid = 1'b0;
    l_input_data = '0;
    k_start = 1'b0;
    k_input_valid = 1'b0;
    k_input_data = '0;

    repeat (3) @(posedge clk);
    @(negedge clk);
    rst_n = 1'b1;
    @(negedge clk);

    fork
      run_l();
      run_k();
    join

    if (l_busy_cycles != REF_L_BUSY_CYCLES) $fatal(1, "L cycle mismatch");
    if (k_busy_cycles != REF_K_BUSY_CYCLES) $fatal(1, "K cycle mismatch");

    $display("tb_trike_encaps_hash_reference PASS l=%0d k=%0d", l_busy_cycles, k_busy_cycles);
    $finish;
  end

  initial begin
    repeat (200000) @(posedge clk);
    $fatal(1, "tb_trike_encaps_hash_reference timeout");
  end

endmodule
