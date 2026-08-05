`timescale 1ns / 1ps

module tb_trike_encaps_components_reference;

  /* verilator lint_off UNUSEDPARAM */
  `include "generated/trike_encaps_reference_case.svh"
  /* verilator lint_on UNUSEDPARAM */

  localparam int REF_ERROR_ADDR_W = $clog2(REF_ERROR_WEIGHT);
  localparam int REF_WORD_ADDR_W = $clog2(REF_WORDS);
  localparam int REF_H123_BUSY_CYCLES = 44640;
  localparam int REF_H4_BUSY_CYCLES = 207017;
  localparam int REF_UV_BUSY_CYCLES = 1805550;

  logic                          clk;
  logic                          rst_n;

  logic                          h123_start;
  logic                          h123_seed_valid;
  logic [                   7:0] h123_seed_data;
  logic                          h123_seed_ready;
  logic                          h123_seed_pass;
  logic                          h123_vector_valid;
  logic [                   1:0] h123_vector_select;
  logic [                  10:0] h123_vector_byte;
  logic [                   7:0] h123_vector_data;
  logic                          h123_vector_ready;
  logic                          h123_busy;
  logic                          h123_done;

  logic                          h4_start;
  logic                          h4_seed_valid;
  logic [                   7:0] h4_seed_data;
  logic                          h4_seed_ready;
  logic                          h4_seed_pass;
  logic                          h4_index_valid;
  logic [  REF_ERROR_ADDR_W-1:0] h4_index_position;
  logic [REF_GLOBAL_INDEX_W-1:0] h4_index;
  logic                          h4_index_ready;
  logic                          h4_busy;
  logic                          h4_done;

  logic                          uv_start;
  logic                          uv_error_valid;
  logic [  REF_ERROR_ADDR_W-1:0] uv_error_position;
  logic [REF_GLOBAL_INDEX_W-1:0] uv_error_index;
  logic                          uv_error_ready;
  logic [                   1:0] uv_operand_select;
  logic [   REF_WORD_ADDR_W-1:0] uv_operand_word;
  logic                          uv_operand_valid;
  logic [                  63:0] uv_operand_data;
  logic                          uv_operand_ready;
  logic                          uv_result_valid;
  logic                          uv_result_select;
  logic [                  63:0] uv_result_data;
  logic                          uv_result_last;
  logic                          uv_result_ready;
  logic                          uv_busy;
  logic                          uv_done;

  int                            h123_busy_cycles;
  int                            h4_busy_cycles;
  int                            uv_busy_cycles;

  /* verilator lint_off PINCONNECTEMPTY */
  trike_h123_vectors #(
      .M_BYTES(REF_M_BYTES),
      .R_BITS (REF_R_BITS)
  ) u_h123 (
      .i_clk           (clk),
      .i_rst_n         (rst_n),
      .i_start         (h123_start),
      .i_seed_valid    (h123_seed_valid),
      .i_seed_data     (h123_seed_data),
      .o_seed_ready    (h123_seed_ready),
      .o_seed_pass     (h123_seed_pass),
      .o_vector_valid  (h123_vector_valid),
      .o_vector_select (h123_vector_select),
      .o_vector_byte   (h123_vector_byte),
      .o_vector_data   (h123_vector_data),
      .i_vector_ready  (h123_vector_ready),
      .o_busy          (h123_busy),
      .o_done          (h123_done),
      .o_v             (),
      .o_c             (),
      .o_reseed_counter(),
      .o_compress_start(),
      .o_compress_block(),
      .o_compress_state(),
      .i_compress_busy (1'b0),
      .i_compress_done (1'b0),
      .i_compress_state('0)
  );

  trike_h4_error_sampler #(
      .M_BYTES     (REF_M_BYTES),
      .R_BITS      (REF_R_BITS),
      .ERROR_WEIGHT(REF_ERROR_WEIGHT)
  ) u_h4 (
      .i_clk           (clk),
      .i_rst_n         (rst_n),
      .i_start         (h4_start),
      .i_seed_valid    (h4_seed_valid),
      .i_seed_data     (h4_seed_data),
      .o_seed_ready    (h4_seed_ready),
      .o_seed_pass     (h4_seed_pass),
      .o_index_valid   (h4_index_valid),
      .o_index_position(h4_index_position),
      .o_index         (h4_index),
      .i_index_ready   (h4_index_ready),
      .o_busy          (h4_busy),
      .o_done          (h4_done),
      .o_v             (),
      .o_c             (),
      .o_reseed_counter(),
      .o_compress_start(),
      .o_compress_block(),
      .o_compress_state(),
      .i_compress_busy (1'b0),
      .i_compress_done (1'b0),
      .i_compress_state('0)
  );
  /* verilator lint_on PINCONNECTEMPTY */

  trike_encaps_uv_core #(
      .R_BITS      (REF_R_BITS),
      .WORD_W      (64),
      .ERROR_WEIGHT(REF_ERROR_WEIGHT)
  ) u_uv (
      .i_clk           (clk),
      .i_rst_n         (rst_n),
      .i_start         (uv_start),
      .i_error_valid   (uv_error_valid),
      .i_error_position(uv_error_position),
      .i_error_index   (uv_error_index),
      .o_error_ready   (uv_error_ready),
      .o_operand_select(uv_operand_select),
      .o_operand_word  (uv_operand_word),
      .i_operand_valid (uv_operand_valid),
      .i_operand_data  (uv_operand_data),
      .o_operand_ready (uv_operand_ready),
      .o_result_valid  (uv_result_valid),
      .o_result_select (uv_result_select),
      .o_result_data   (uv_result_data),
      .o_result_last   (uv_result_last),
      .i_result_ready  (uv_result_ready),
      .o_busy          (uv_busy),
      .o_done          (uv_done)
  );

  always #5 clk = ~clk;

  always_comb begin
    unique case (uv_operand_select)
      2'd0: uv_operand_data = REF_R1_WORDS[uv_operand_word];
      2'd1: uv_operand_data = REF_R2_WORDS[uv_operand_word];
      2'd2: uv_operand_data = REF_T1_WORDS[uv_operand_word];
      default: uv_operand_data = REF_T2_WORDS[uv_operand_word];
    endcase
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      h123_busy_cycles <= 0;
      h4_busy_cycles   <= 0;
      uv_busy_cycles   <= 0;
    end else begin
      if (h123_busy) h123_busy_cycles <= h123_busy_cycles + 1;
      if (h4_busy) h4_busy_cycles <= h4_busy_cycles + 1;
      if (uv_busy) uv_busy_cycles <= uv_busy_cycles + 1;
    end
  end

  task automatic run_h123;
    int         seed_idx;
    int         vector_count;
    logic [7:0] expected_byte;
    begin
      h123_seed_valid = 1'b0;
      h123_vector_ready = 1'b0;
      h123_start = 1'b1;
      @(negedge clk);
      h123_start = 1'b0;
      h123_seed_valid = 1'b1;
      for (int pass = 0; pass < 2; pass++) begin
        seed_idx = 0;
        while (seed_idx < REF_M_BYTES) begin
          h123_seed_data = REF_SIGMA[seed_idx];
          @(posedge clk);
          if (h123_seed_valid && h123_seed_ready) begin
            if (h123_seed_pass != pass[0]) $fatal(1, "H123 seed pass mismatch");
            @(negedge clk);
            seed_idx++;
          end
        end
      end
      h123_seed_valid = 1'b0;
      h123_vector_ready = 1'b1;
      vector_count = 0;
      while (vector_count < (3 * REF_R_BYTES)) begin
        @(posedge clk);
        if (h123_vector_valid && h123_vector_ready) begin
          unique case (h123_vector_select)
            2'd0: expected_byte = REF_T1[h123_vector_byte];
            2'd1: expected_byte = REF_T2[h123_vector_byte];
            default: expected_byte = REF_R1[h123_vector_byte];
          endcase
          if (h123_vector_data != expected_byte) begin
            $fatal(1, "H123 mismatch vector=%0d byte=%0d", h123_vector_select, h123_vector_byte);
          end
          vector_count++;
        end
      end
      wait (h123_done);
      h123_vector_ready = 1'b0;
    end
  endtask

  task automatic run_h4;
    int seed_idx;
    int index_count;
    begin
      h4_seed_valid = 1'b0;
      h4_index_ready = 1'b0;
      h4_start = 1'b1;
      @(negedge clk);
      h4_start = 1'b0;
      h4_seed_valid = 1'b1;
      for (int pass = 0; pass < 2; pass++) begin
        seed_idx = 0;
        while (seed_idx < (REF_M_BYTES + REF_R_BYTES)) begin
          if (seed_idx < REF_M_BYTES) begin
            h4_seed_data = REF_MESSAGE[seed_idx];
          end else begin
            h4_seed_data = REF_R2[seed_idx-REF_M_BYTES];
          end
          @(posedge clk);
          if (h4_seed_valid && h4_seed_ready) begin
            if (h4_seed_pass != pass[0]) $fatal(1, "H4 seed pass mismatch");
            @(negedge clk);
            seed_idx++;
          end
        end
      end
      h4_seed_valid = 1'b0;
      h4_index_ready = 1'b1;
      index_count = 0;
      while (index_count < REF_ERROR_WEIGHT) begin
        @(posedge clk);
        if (h4_index_valid && h4_index_ready) begin
          if (h4_index != REF_ERROR_INDICES[h4_index_position]) begin
            $fatal(1, "H4 support mismatch position=%0d got=%0d expected=%0d", h4_index_position,
                   h4_index, REF_ERROR_INDICES[h4_index_position]);
          end
          index_count++;
        end
      end
      wait (h4_done);
      h4_index_ready = 1'b0;
    end
  endtask

  task automatic run_uv;
    int          error_count;
    int          operand_count;
    int          result_count  [0:1];
    logic [63:0] expected_word;
    begin
      uv_error_valid = 1'b1;
      uv_operand_valid = 1'b1;
      uv_result_ready = 1'b1;
      error_count = 0;
      operand_count = 0;
      result_count[0] = 0;
      result_count[1] = 0;
      uv_error_position = REF_ERROR_ADDR_W'(REF_ERROR_WEIGHT - 1);
      uv_error_index = REF_ERROR_INDICES[REF_ERROR_WEIGHT-1];
      uv_start = 1'b1;
      @(negedge clk);
      uv_start = 1'b0;
      while (!uv_done) begin
        @(posedge clk);
        if (uv_error_valid && uv_error_ready) error_count++;
        if (uv_operand_valid && uv_operand_ready) operand_count++;
        if (uv_result_valid && uv_result_ready) begin
          expected_word = uv_result_select ? REF_V_WORDS[result_count[1]] :
              REF_U_WORDS[result_count[0]];
          if (uv_result_data != expected_word) begin
            $fatal(1, "UV mismatch select=%0d word=%0d", uv_result_select,
                   result_count[uv_result_select]);
          end
          result_count[uv_result_select]++;
          if (uv_result_last != (result_count[uv_result_select] == REF_WORDS)) begin
            $fatal(1, "UV last mismatch");
          end
        end
        @(negedge clk);
        if (error_count == REF_ERROR_WEIGHT) begin
          uv_error_valid = 1'b0;
        end else begin
          uv_error_position = REF_ERROR_ADDR_W'(REF_ERROR_WEIGHT - 1 - error_count);
          uv_error_index = REF_ERROR_INDICES[REF_ERROR_WEIGHT-1-error_count];
        end
      end
      if (error_count != REF_ERROR_WEIGHT) $fatal(1, "UV error transfer mismatch");
      if (operand_count != (4 * REF_WORDS)) $fatal(1, "UV operand transfer mismatch");
      if ((result_count[0] != REF_WORDS) || (result_count[1] != REF_WORDS)) begin
        $fatal(1, "UV result count mismatch");
      end
      uv_error_valid   = 1'b0;
      uv_operand_valid = 1'b0;
      uv_result_ready  = 1'b0;
    end
  endtask

  initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    h123_start = 1'b0;
    h123_seed_valid = 1'b0;
    h123_seed_data = '0;
    h123_vector_ready = 1'b0;
    h4_start = 1'b0;
    h4_seed_valid = 1'b0;
    h4_seed_data = '0;
    h4_index_ready = 1'b0;
    uv_start = 1'b0;
    uv_error_valid = 1'b0;
    uv_error_position = '0;
    uv_error_index = '0;
    uv_operand_valid = 1'b0;
    uv_result_ready = 1'b0;

    repeat (3) @(posedge clk);
    @(negedge clk);
    rst_n = 1'b1;
    @(negedge clk);

    fork
      run_h123();
      run_h4();
      run_uv();
    join

    if (h123_busy_cycles != REF_H123_BUSY_CYCLES) begin
      $fatal(1, "H123 cycle mismatch got=%0d expected=%0d", h123_busy_cycles, REF_H123_BUSY_CYCLES);
    end
    if (h4_busy_cycles != REF_H4_BUSY_CYCLES) $fatal(1, "H4 cycle mismatch");
    if (uv_busy_cycles != REF_UV_BUSY_CYCLES) $fatal(1, "UV cycle mismatch");

    $display("tb_trike_encaps_components_reference PASS h123=%0d h4=%0d uv=%0d", h123_busy_cycles,
             h4_busy_cycles, uv_busy_cycles);
    $finish;
  end

  initial begin
    repeat (2000000) @(posedge clk);
    $fatal(1, "tb_trike_encaps_components_reference timeout");
  end

endmodule
