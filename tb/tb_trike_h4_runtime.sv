`timescale 1ns / 1ps

module tb_trike_h4_runtime;
  localparam int M_BYTES = 4;
  localparam int MAX_R_BITS = 521;
  localparam int MAX_ERROR_WEIGHT = 5;
  localparam int MAX_PADDED_R_BYTES = 128;
  localparam int SUPPORT_ADDR_W = $clog2(MAX_ERROR_WEIGHT);
  localparam int GLOBAL_INDEX_W = $clog2(3 * MAX_R_BITS);
  localparam int ERROR_ADDR_W = $clog2(3 * MAX_PADDED_R_BYTES);

  logic                        clk;
  logic                        rst_n;
  logic                        start;
  logic   [              31:0] runtime_r_bits;
  logic   [              31:0] runtime_error_weight;
  logic   [              31:0] runtime_padded_r_bytes;
  logic                        seed_valid;
  logic   [               7:0] seed_data;
  logic                        seed_ready;
  logic                        seed_pass;
  logic                        support_re;
  logic   [SUPPORT_ADDR_W-1:0] support_raddr;
  logic   [GLOBAL_INDEX_W-1:0] support_rdata;
  logic                        error_re;
  logic   [  ERROR_ADDR_W-1:0] error_raddr;
  logic   [               7:0] error_rdata;
  logic                        busy;
  logic                        done;
  integer                      seed_idx;
  integer                      seed_base;
  integer                      busy_cycles;

  assign seed_data = 8'((7 * seed_idx) + seed_base);

  /* verilator lint_off PINCONNECTEMPTY */
  trike_h4_error_vector #(
      .M_BYTES         (M_BYTES),
      .R_BITS          (MAX_R_BITS),
      .ERROR_WEIGHT    (MAX_ERROR_WEIGHT),
      .PADDED_R_BYTES  (MAX_PADDED_R_BYTES),
      .RUNTIME_GEOMETRY(1'b1)
  ) dut (
      .i_clk                         (clk),
      .i_rst_n                       (rst_n),
      .i_start                       (start),
      .i_runtime_r_bits              (runtime_r_bits),
      .i_runtime_error_weight        (runtime_error_weight),
      .i_runtime_padded_r_bytes      (runtime_padded_r_bytes),
      .i_seed_valid                  (seed_valid),
      .i_seed_data                   (seed_data),
      .o_seed_ready                  (seed_ready),
      .o_seed_pass                   (seed_pass),
      .i_support_re                  (support_re),
      .i_support_raddr               (support_raddr),
      .o_support_rdata               (support_rdata),
      .i_error_re                    (error_re),
      .i_error_raddr                 (error_raddr),
      .o_error_rdata                 (error_rdata),
      .o_busy                        (busy),
      .o_done                        (done),
      .o_v                           (),
      .o_c                           (),
      .o_reseed_counter              (),
      .o_compress_start              (),
      .o_compress_block              (),
      .o_compress_state              (),
      .i_compress_busy               (1'b0),
      .i_compress_done               (1'b0),
      .i_compress_state              ('0),
      .o_sampler_start               (),
      .o_sampler_runtime_length      (),
      .o_sampler_runtime_weight      (),
      .o_sampler_v                   (),
      .o_sampler_c                   (),
      .o_sampler_reseed_counter      (),
      .i_sampler_index_valid         (1'b0),
      .i_sampler_index_position      ('0),
      .i_sampler_index               ('0),
      .o_sampler_index_ready         (),
      .i_sampler_done                (1'b0),
      .i_sampler_v                   ('0),
      .i_sampler_c                   ('0),
      .i_sampler_reseed_counter      ('0),
      .o_store_start                 (),
      .o_store_runtime_r_bits        (),
      .o_store_runtime_error_weight  (),
      .o_store_runtime_padded_r_bytes(),
      .o_store_index_valid           (),
      .o_store_index_position        (),
      .o_store_index                 (),
      .i_store_index_ready           (1'b0),
      .o_store_support_re            (),
      .o_store_support_raddr         (),
      .i_store_support_rdata         ('0),
      .o_store_error_re              (),
      .o_store_error_raddr           (),
      .i_store_error_rdata           ('0),
      .i_store_done                  (1'b0)
  );
  /* verilator lint_on PINCONNECTEMPTY */

  function automatic integer expected_index(input integer r_bits, input integer base,
                                            input integer position);
    begin
      expected_index = 0;
      unique case (r_bits)
        7: expected_index = (base == 3) ? 6 : 19;
        13: begin
          if (base == 3) begin
            unique case (position)
              0: expected_index = 25;
              1: expected_index = 17;
              default: expected_index = 29;
            endcase
          end else begin
            unique case (position)
              0: expected_index = 35;
              1: expected_index = 19;
              default: expected_index = 9;
            endcase
          end
        end
        default: begin
          if (base == 3) begin
            unique case (position)
              0: expected_index = 323;
              1: expected_index = 785;
              2: expected_index = 154;
              3: expected_index = 1165;
              default: expected_index = 889;
            endcase
          end else begin
            unique case (position)
              0: expected_index = 915;
              1: expected_index = 439;
              2: expected_index = 1051;
              3: expected_index = 188;
              default: expected_index = 953;
            endcase
          end
        end
      endcase
    end
  endfunction

  function automatic logic [7:0] expected_error_byte(
      input integer r_bits, input integer error_weight, input integer padded_r_bytes,
      input integer base, input integer byte_addr);
    integer       global_index;
    integer       block_idx;
    integer       local_idx;
    integer       mapped_addr;
    logic   [7:0] result;
    begin
      result = '0;
      for (int position = 0; position < MAX_ERROR_WEIGHT; position++) begin
        if (position < error_weight) begin
          global_index = expected_index(r_bits, base, position);
          block_idx = global_index / r_bits;
          local_idx = global_index % r_bits;
          mapped_addr = (block_idx * padded_r_bytes) + (local_idx / 8);
          if (mapped_addr == byte_addr) result[local_idx%8] = 1'b1;
        end
      end
      expected_error_byte = result;
    end
  endfunction

  always #1 clk = ~clk;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) busy_cycles <= 0;
    else if (start) busy_cycles <= 0;
    else if (busy) busy_cycles <= busy_cycles + 1;
  end

  task automatic run_case(input integer r_bits, input integer error_weight, input integer base,
                          output integer latency);
    integer seed_bytes;
    integer padded_r_bytes;
    integer error_bytes;
    begin
      seed_bytes = M_BYTES + ((r_bits + 7) / 8);
      padded_r_bytes = ((r_bits + 511) / 512) * 64;
      error_bytes = 3 * padded_r_bytes;
      seed_base = base;
      runtime_r_bits = 32'(r_bits);
      runtime_error_weight = 32'(error_weight);
      runtime_padded_r_bytes = 32'(padded_r_bytes);
      @(negedge clk);
      start = 1'b1;
      @(negedge clk);
      start = 1'b0;
      runtime_r_bits = MAX_R_BITS;
      runtime_error_weight = MAX_ERROR_WEIGHT;
      runtime_padded_r_bytes = MAX_PADDED_R_BYTES;
      seed_valid = 1'b1;
      for (int pass = 0; pass < 2; pass++) begin
        seed_idx = 0;
        while (seed_idx < seed_bytes) begin
          @(posedge clk);
          if (seed_ready) begin
            if (seed_pass != pass[0]) $fatal(1, "runtime H4 seed pass mismatch");
            @(negedge clk);
            seed_idx++;
          end
        end
      end
      seed_valid = 1'b0;
      while (!done) @(negedge clk);
      latency = busy_cycles;

      support_re = 1'b1;
      for (int position = 0; position < error_weight; position++) begin
        support_raddr = SUPPORT_ADDR_W'(position);
        @(posedge clk);
        @(negedge clk);
        if (support_rdata != GLOBAL_INDEX_W'(expected_index(r_bits, base, position)))
          $fatal(1, "runtime H4 support mismatch r=%0d position=%0d", r_bits, position);
      end
      support_re = 1'b0;

      error_re   = 1'b1;
      for (int byte_addr = 0; byte_addr < error_bytes; byte_addr++) begin
        error_raddr = ERROR_ADDR_W'(byte_addr);
        @(posedge clk);
        @(negedge clk);
        if (error_rdata != expected_error_byte(
                r_bits, error_weight, padded_r_bytes, base, byte_addr
            ))
          $fatal(1, "runtime H4 error mismatch r=%0d byte=%0d", r_bits, byte_addr);
      end
      error_re = 1'b0;
      $display("runtime H4 r=%0d t=%0d base=%0h cycles=%0d", r_bits, error_weight, base, latency);
    end
  endtask

  initial begin
    integer latency_a;
    integer latency_b;
    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    runtime_r_bits = '0;
    runtime_error_weight = '0;
    runtime_padded_r_bytes = '0;
    seed_valid = 1'b0;
    support_re = 1'b0;
    support_raddr = '0;
    error_re = 1'b0;
    error_raddr = '0;
    seed_idx = 0;
    seed_base = 0;
    repeat (3) @(negedge clk);
    rst_n = 1'b1;

    run_case(7, 1, 3, latency_a);
    run_case(7, 1, 166, latency_b);
    if (latency_a != latency_b) $fatal(1, "runtime H4 r=7 data-dependent latency");
    run_case(13, 3, 3, latency_a);
    run_case(13, 3, 166, latency_b);
    if (latency_a != latency_b) $fatal(1, "runtime H4 r=13 data-dependent latency");
    run_case(521, 5, 3, latency_a);
    run_case(521, 5, 166, latency_b);
    if (latency_a != latency_b) $fatal(1, "runtime H4 r=521 data-dependent latency");

    $display("tb_trike_h4_runtime PASS");
    $finish;
  end

  initial begin
    repeat (2000000) @(posedge clk);
    $fatal(1, "tb_trike_h4_runtime timeout");
  end

endmodule
