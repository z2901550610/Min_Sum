`timescale 1ns / 1ps

// Narrow-I/O TRIKE-2 Encaps wrapper for Vivado synthesis and implementation.
module trike_encaps_synth_top (
                       input  logic       i_clk,
                       input  logic       i_rst_n,
                       input  logic       i_start,
                       input  logic       i_input_valid,
                       input  logic [7:0] i_input_data,
    (* IOB = "TRUE" *) output logic       o_input_ready,
    (* IOB = "TRUE" *) output logic       o_ciphertext_valid,
    (* IOB = "TRUE" *) output logic [7:0] o_ciphertext_data,
    (* IOB = "TRUE" *) output logic       o_ciphertext_last,
                       input  logic       i_ciphertext_ready,
    (* IOB = "TRUE" *) output logic       o_shared_secret_valid,
    (* IOB = "TRUE" *) output logic [7:0] o_shared_secret_data,
    (* IOB = "TRUE" *) output logic       o_shared_secret_last,
                       input  logic       i_shared_secret_ready,
    (* IOB = "TRUE" *) output logic       o_busy,
    (* IOB = "TRUE" *) output logic       o_done
);

  localparam int INPUT_BYTES = 1948 + 32 + 32;
  localparam logic [10:0] INPUT_LAST = 11'(INPUT_BYTES - 1);

  logic        rst_n_sync;
  logic        core_start_q;
  logic        core_input_valid;
  logic [ 7:0] core_input_data;
  logic        core_input_ready;
  logic        core_ciphertext_valid;
  logic [ 7:0] core_ciphertext_data;
  logic        core_ciphertext_last;
  logic        core_ciphertext_ready;
  logic        core_shared_secret_valid;
  logic [ 7:0] core_shared_secret_data;
  logic        core_shared_secret_last;
  logic        core_shared_secret_ready;
  logic        core_busy;
  /* verilator lint_off UNUSEDSIGNAL */
  logic        core_done;
  /* verilator lint_on UNUSEDSIGNAL */
  logic        input_buffer_valid_q;
  logic [ 7:0] input_buffer_data_q;
  logic        input_complete_q;
  logic [10:0] input_count_q;
  logic        ciphertext_buffer_valid_q;
  logic [ 7:0] ciphertext_buffer_data_q;
  logic        ciphertext_buffer_last_q;
  logic        shared_secret_buffer_valid_q;
  logic [ 7:0] shared_secret_buffer_data_q;
  logic        shared_secret_buffer_last_q;

  reset_sync u_reset_sync (
      .i_clk  (i_clk),
      .i_rst_n(i_rst_n),
      .o_rst_n(rst_n_sync)
  );

  assign core_input_valid = input_buffer_valid_q;
  assign core_input_data = input_buffer_data_q;
  assign core_ciphertext_ready = !ciphertext_buffer_valid_q;
  assign core_shared_secret_ready = !shared_secret_buffer_valid_q;

  always_ff @(posedge i_clk) begin
    if (!rst_n_sync) begin
      core_start_q <= 1'b0;
      input_buffer_valid_q <= 1'b0;
      input_buffer_data_q <= '0;
      input_complete_q <= 1'b0;
      input_count_q <= 0;
      ciphertext_buffer_valid_q <= 1'b0;
      ciphertext_buffer_data_q <= '0;
      ciphertext_buffer_last_q <= 1'b0;
      shared_secret_buffer_valid_q <= 1'b0;
      shared_secret_buffer_data_q <= '0;
      shared_secret_buffer_last_q <= 1'b0;
      o_input_ready <= 1'b0;
      o_ciphertext_valid <= 1'b0;
      o_ciphertext_data <= '0;
      o_ciphertext_last <= 1'b0;
      o_shared_secret_valid <= 1'b0;
      o_shared_secret_data <= '0;
      o_shared_secret_last <= 1'b0;
      o_busy <= 1'b0;
      o_done <= 1'b0;
    end else begin
      core_start_q <= 1'b0;
      o_done <= 1'b0;
      o_busy <= core_busy || core_start_q || input_buffer_valid_q ||
          ciphertext_buffer_valid_q || shared_secret_buffer_valid_q || o_ciphertext_valid ||
          o_shared_secret_valid || i_start;

      if (i_start && !core_busy && !input_buffer_valid_q && !o_ciphertext_valid &&
          !o_shared_secret_valid && !ciphertext_buffer_valid_q &&
          !shared_secret_buffer_valid_q) begin
        core_start_q <= 1'b1;
        input_complete_q <= 1'b0;
        input_count_q <= 0;
      end

      if (input_buffer_valid_q) begin
        o_input_ready <= 1'b0;
        if (core_input_ready) begin
          input_buffer_valid_q <= 1'b0;
          if (!input_complete_q) o_input_ready <= 1'b1;
        end
      end else begin
        o_input_ready <= core_input_ready && !input_complete_q;
        if (o_input_ready && i_input_valid) begin
          input_buffer_valid_q <= 1'b1;
          input_buffer_data_q <= i_input_data;
          o_input_ready <= 1'b0;
          if (input_count_q == INPUT_LAST) begin
            input_complete_q <= 1'b1;
          end else begin
            input_count_q <= input_count_q + 1;
          end
        end
      end

      if (!ciphertext_buffer_valid_q && core_ciphertext_valid) begin
        ciphertext_buffer_valid_q <= 1'b1;
        ciphertext_buffer_data_q  <= core_ciphertext_data;
        ciphertext_buffer_last_q  <= core_ciphertext_last;
      end
      if (!o_ciphertext_valid && ciphertext_buffer_valid_q) begin
        o_ciphertext_valid <= 1'b1;
        o_ciphertext_data <= ciphertext_buffer_data_q;
        o_ciphertext_last <= ciphertext_buffer_last_q;
        ciphertext_buffer_valid_q <= 1'b0;
      end else if (o_ciphertext_valid && i_ciphertext_ready) begin
        o_ciphertext_valid <= 1'b0;
      end

      if (!shared_secret_buffer_valid_q && core_shared_secret_valid) begin
        shared_secret_buffer_valid_q <= 1'b1;
        shared_secret_buffer_data_q  <= core_shared_secret_data;
        shared_secret_buffer_last_q  <= core_shared_secret_last;
      end
      if (!o_shared_secret_valid && shared_secret_buffer_valid_q) begin
        o_shared_secret_valid <= 1'b1;
        o_shared_secret_data <= shared_secret_buffer_data_q;
        o_shared_secret_last <= shared_secret_buffer_last_q;
        shared_secret_buffer_valid_q <= 1'b0;
      end else if (o_shared_secret_valid && i_shared_secret_ready) begin
        o_shared_secret_valid <= 1'b0;
        if (o_shared_secret_last) o_done <= 1'b1;
      end
    end
  end

  trike_encaps_core #(
      .M_BYTES     (32),
      .R_BITS      (15581),
      .ERROR_WEIGHT(263),
      .WORD_W      (64)
  ) u_encaps (
      .i_clk                (i_clk),
      .i_rst_n              (rst_n_sync),
      .i_start              (core_start_q),
      .i_input_valid        (core_input_valid),
      .i_input_data         (core_input_data),
      .o_input_ready        (core_input_ready),
      .o_ciphertext_valid   (core_ciphertext_valid),
      .o_ciphertext_data    (core_ciphertext_data),
      .o_ciphertext_last    (core_ciphertext_last),
      .i_ciphertext_ready   (core_ciphertext_ready),
      .o_shared_secret_valid(core_shared_secret_valid),
      .o_shared_secret_data (core_shared_secret_data),
      .o_shared_secret_last (core_shared_secret_last),
      .i_shared_secret_ready(core_shared_secret_ready),
      .o_busy               (core_busy),
      .o_done               (core_done),
      .o_compress_start     (),
      .o_compress_block     (),
      .o_compress_state     (),
      .i_compress_busy      (1'b0),
      .i_compress_done      (1'b0),
      .i_compress_state     ('0)
  );

endmodule
