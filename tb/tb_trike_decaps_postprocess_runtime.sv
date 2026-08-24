`timescale 1ns / 1ps

module tb_trike_decaps_postprocess_runtime;
  localparam int M_BYTES = 4;
  localparam int MAX_R_BITS = 521;
  localparam int MAX_ERROR_WEIGHT = 5;
  localparam int MAX_R_BYTES = 66;
  localparam int MAX_PADDED_R_BYTES = 128;
  localparam int MAX_ERROR_BYTES = 3 * MAX_PADDED_R_BYTES;
  localparam int MAX_CIPHERTEXT_BYTES = (2 * MAX_R_BYTES) + M_BYTES;
  localparam int ERROR_ADDR_W = $clog2(MAX_ERROR_BYTES);
  localparam int R_ADDR_W = $clog2(MAX_R_BYTES);
  localparam int CT_ADDR_W = $clog2(MAX_CIPHERTEXT_BYTES);

  logic                      clk;
  logic                      rst_n;
  logic                      start;
  logic   [            31:0] runtime_r_bits;
  logic   [            31:0] runtime_error_weight;
  logic   [            31:0] runtime_r_bytes;
  logic   [            31:0] runtime_padded_r_bytes;
  logic   [            31:0] runtime_error_bytes;
  logic   [            31:0] runtime_ciphertext_bytes;
  logic                      c2_valid;
  logic   [             7:0] c2_data;
  logic                      c2_ready;
  logic                      reference_re;
  logic   [ERROR_ADDR_W-1:0] reference_raddr;
  logic   [             7:0] reference_rdata;
  logic                      r2_re;
  logic   [    R_ADDR_W-1:0] r2_raddr;
  logic   [             7:0] r2_rdata;
  logic                      ciphertext_re;
  logic   [   CT_ADDR_W-1:0] ciphertext_raddr;
  logic   [             7:0] ciphertext_rdata;
  logic                      ciphertext_equal;
  logic                      shared_secret_valid;
  logic   [             1:0] shared_secret_index;
  logic   [             7:0] shared_secret_data;
  logic                      shared_secret_last;
  logic                      busy;
  logic                      done;
  integer                    active_r_bits;
  integer                    active_error_weight;
  integer                    active_r_bytes;
  integer                    active_padded_r_bytes;
  integer                    active_ciphertext_bytes;
  logic                      active_tamper;
  integer                    c2_count;
  integer                    shared_secret_count;
  integer                    busy_cycles;

  trike_decaps_postprocess_core #(
      .M_BYTES         (M_BYTES),
      .R_BITS          (MAX_R_BITS),
      .ERROR_WEIGHT    (MAX_ERROR_WEIGHT),
      .PADDED_R_BYTES  (MAX_PADDED_R_BYTES),
      .CIPHERTEXT_BYTES(MAX_CIPHERTEXT_BYTES),
      .RUNTIME_GEOMETRY(1'b1)
  ) dut (
      .i_clk                     (clk),
      .i_rst_n                   (rst_n),
      .i_start                   (start),
      .i_runtime_r_bits          (runtime_r_bits),
      .i_runtime_error_weight    (runtime_error_weight),
      .i_runtime_r_bytes         (runtime_r_bytes),
      .i_runtime_padded_r_bytes  (runtime_padded_r_bytes),
      .i_runtime_error_bytes     (runtime_error_bytes),
      .i_runtime_ciphertext_bytes(runtime_ciphertext_bytes),
      .i_decoder_ok              (1'b1),
      .i_sigma2                  (32'hd4c3b2a1),
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
      .o_compress_start          (),
      .o_compress_block          (),
      .o_compress_state          (),
      .i_compress_busy           (1'b0),
      .i_compress_done           (1'b0),
      .i_compress_state          ('0)
  );

  function automatic integer expected_index(input integer r_bits, input integer position);
    begin
      expected_index = 0;
      unique case (r_bits)
        7: expected_index = 3;
        13: begin
          unique case (position)
            0: expected_index = 10;
            1: expected_index = 11;
            default: expected_index = 12;
          endcase
        end
        default: begin
          unique case (position)
            0: expected_index = 1260;
            1: expected_index = 571;
            2: expected_index = 985;
            3: expected_index = 354;
            default: expected_index = 1282;
          endcase
        end
      endcase
    end
  endfunction

  function automatic logic [7:0] expected_error_byte(input integer byte_addr);
    integer       global_index;
    integer       block_idx;
    integer       local_idx;
    integer       mapped_addr;
    logic   [7:0] result;
    begin
      result = '0;
      for (int position = 0; position < MAX_ERROR_WEIGHT; position++) begin
        if (position < active_error_weight) begin
          global_index = expected_index(active_r_bits, position);
          block_idx = global_index / active_r_bits;
          local_idx = global_index % active_r_bits;
          mapped_addr = (block_idx * active_padded_r_bytes) + (local_idx / 8);
          if (mapped_addr == byte_addr) result[local_idx%8] = 1'b1;
        end
      end
      expected_error_byte = result;
    end
  endfunction

  function automatic logic [31:0] base_c2(input integer r_bits);
    begin
      unique case (r_bits)
        7: base_c2 = 32'h7fac8d63;
        13: base_c2 = 32'hfc97e217;
        default: base_c2 = 32'hfe195c33;
      endcase
    end
  endfunction

  function automatic logic [31:0] expected_shared_secret(input integer r_bits, input  logic tamper);
    begin
      unique case (r_bits)
        7: expected_shared_secret = tamper ? 32'h4e0344bf : 32'h45d5a58d;
        13: expected_shared_secret = tamper ? 32'h51c293ad : 32'h2c928527;
        default: expected_shared_secret = tamper ? 32'h6f6fe5f8 : 32'h46dc20c1;
      endcase
    end
  endfunction

  always #1 clk = ~clk;

  always_comb begin
    c2_valid = c2_count < M_BYTES;
    c2_data  = base_c2(active_r_bits) [8*((c2_count<M_BYTES)?c2_count : 0)+:8];
    if (active_tamper && (c2_count == 0)) c2_data = c2_data ^ 8'h01;
  end

  always_ff @(posedge clk) begin
    if (reference_re) reference_rdata <= expected_error_byte(int'(reference_raddr));
    if (r2_re) r2_rdata <= 8'((11 * int'(r2_raddr)) + 5);
    if (ciphertext_re) begin
      if (int'(ciphertext_raddr) < (active_ciphertext_bytes - M_BYTES)) begin
        ciphertext_rdata <= 8'((13 * int'(ciphertext_raddr)) + 7);
      end else begin
        ciphertext_rdata <= base_c2(
            active_r_bits
        ) [8*(int'(ciphertext_raddr)-(active_ciphertext_bytes-M_BYTES))+:8];
        if (active_tamper && (int'(ciphertext_raddr) == (active_ciphertext_bytes - M_BYTES)))
          ciphertext_rdata <= base_c2(active_r_bits) [7:0] ^ 8'h01;
      end
    end

    if (!rst_n) begin
      c2_count <= 0;
      shared_secret_count <= 0;
      busy_cycles <= 0;
    end else begin
      if (start) begin
        c2_count <= 0;
        shared_secret_count <= 0;
        busy_cycles <= 0;
      end else begin
        if (busy) busy_cycles <= busy_cycles + 1;
        if (c2_valid && c2_ready) c2_count <= c2_count + 1;
        if (shared_secret_valid) begin
          if (shared_secret_index != 2'(shared_secret_count))
            $fatal(1, "runtime postprocess shared-secret index mismatch");
          if (shared_secret_data != expected_shared_secret(
                  active_r_bits, active_tamper
              ) [8*shared_secret_count+:8])
            $fatal(1, "runtime postprocess shared-secret byte mismatch");
          if (shared_secret_last != (shared_secret_count == (M_BYTES - 1)))
            $fatal(1, "runtime postprocess shared-secret last mismatch");
          shared_secret_count <= shared_secret_count + 1;
        end
      end
    end
  end

  task automatic run_case(input integer r_bits, input integer error_weight, input  logic tamper,
                          output integer latency);
    begin
      active_r_bits = r_bits;
      active_error_weight = error_weight;
      active_r_bytes = (r_bits + 7) / 8;
      active_padded_r_bytes = ((r_bits + 511) / 512) * 64;
      active_ciphertext_bytes = (2 * active_r_bytes) + M_BYTES;
      active_tamper = tamper;
      runtime_r_bits = 32'(active_r_bits);
      runtime_error_weight = 32'(active_error_weight);
      runtime_r_bytes = 32'(active_r_bytes);
      runtime_padded_r_bytes = 32'(active_padded_r_bytes);
      runtime_error_bytes = 32'(3 * active_padded_r_bytes);
      runtime_ciphertext_bytes = 32'(active_ciphertext_bytes);
      @(negedge clk);
      start = 1'b1;
      @(negedge clk);
      start = 1'b0;
      runtime_r_bits = MAX_R_BITS;
      runtime_error_weight = MAX_ERROR_WEIGHT;
      runtime_r_bytes = MAX_R_BYTES;
      runtime_padded_r_bytes = MAX_PADDED_R_BYTES;
      runtime_error_bytes = MAX_ERROR_BYTES;
      runtime_ciphertext_bytes = MAX_CIPHERTEXT_BYTES;
      while (!done) @(negedge clk);
      latency = busy_cycles;
      if (c2_count != M_BYTES) $fatal(1, "runtime postprocess c2 count mismatch");
      if (shared_secret_count != M_BYTES)
        $fatal(1, "runtime postprocess shared-secret count mismatch");
      if (ciphertext_equal == tamper)
        $fatal(1, "runtime postprocess ciphertext comparison mismatch");
      $display("runtime postprocess r=%0d t=%0d tamper=%0d cycles=%0d", r_bits, error_weight,
               tamper, latency);
    end
  endtask

  initial begin
    integer valid_latency;
    integer reject_latency;
    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    runtime_r_bits = '0;
    runtime_error_weight = '0;
    runtime_r_bytes = '0;
    runtime_padded_r_bytes = '0;
    runtime_error_bytes = '0;
    runtime_ciphertext_bytes = '0;
    active_r_bits = 7;
    active_error_weight = 1;
    active_r_bytes = 1;
    active_padded_r_bytes = 64;
    active_ciphertext_bytes = 6;
    active_tamper = 1'b0;
    repeat (3) @(negedge clk);
    rst_n = 1'b1;

    run_case(7, 1, 1'b0, valid_latency);
    run_case(7, 1, 1'b1, reject_latency);
    if (valid_latency != reject_latency) $fatal(1, "runtime postprocess r=7 latency mismatch");
    run_case(13, 3, 1'b0, valid_latency);
    run_case(13, 3, 1'b1, reject_latency);
    if (valid_latency != reject_latency) $fatal(1, "runtime postprocess r=13 latency mismatch");
    run_case(521, 5, 1'b0, valid_latency);
    run_case(521, 5, 1'b1, reject_latency);
    if (valid_latency != reject_latency) $fatal(1, "runtime postprocess r=521 latency mismatch");

    $display("tb_trike_decaps_postprocess_runtime PASS");
    $finish;
  end

  initial begin
    repeat (3000000) @(posedge clk);
    $fatal(1, "tb_trike_decaps_postprocess_runtime timeout");
  end

endmodule
