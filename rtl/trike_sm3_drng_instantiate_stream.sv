`timescale 1ns / 1ps

// ICCS SM3-DRNG Instantiate operation.
//
// The caller replays the seed for the two SM3_df passes. V, C, and the
// reseed counter use big-endian 55-byte integer layout.
module trike_sm3_drng_instantiate_stream #(
    parameter int SEED_BYTES = 32
) (
    input  logic         i_clk,
    input  logic         i_rst_n,
    input  logic         i_start,
    input  logic         i_seed_valid,
    input  logic [  7:0] i_seed_data,
    output logic         o_seed_ready,
    output logic         o_seed_pass,
    output logic         o_busy,
    output logic         o_done,
    output logic [439:0] o_v,
    output logic [439:0] o_c,
    output logic [439:0] o_reseed_counter
);

  typedef enum logic [2:0] {
    ST_IDLE,
    ST_SEED_DF_START,
    ST_SEED_DF_RUN,
    ST_C_DF_START,
    ST_C_DF_RUN
  } state_t;

  state_t         state_q;

  logic   [439:0] v_q;
  logic   [  5:0] c_input_count_q;

  logic           seed_df_start;
  logic           seed_df_input_ready;
  logic           seed_df_input_pass;
  logic           seed_df_done;
  logic   [439:0] seed_df_output;

  logic           c_df_start;
  logic           c_df_input_ready;
  logic           c_df_done;
  logic   [439:0] c_df_output;
  logic   [  7:0] c_df_input_data;

  function automatic logic [7:0] state_byte(input  logic [439:0] value, input  logic [5:0] byte_idx);
    begin
      state_byte = value[439-8*byte_idx-:8];
    end
  endfunction

  assign o_seed_ready = (state_q == ST_SEED_DF_RUN) && seed_df_input_ready;
  assign o_seed_pass = seed_df_input_pass;

  assign seed_df_start = (state_q == ST_SEED_DF_START);
  assign c_df_start = (state_q == ST_C_DF_START);
  assign c_df_input_data = (c_input_count_q == 0) ? 8'h00 : state_byte(v_q, c_input_count_q - 6'd1);

  /* verilator lint_off PINCONNECTEMPTY */
  sm3_df_stream #(
      .INPUT_BYTES(SEED_BYTES)
  ) u_seed_df (
      .i_clk        (i_clk),
      .i_rst_n      (i_rst_n),
      .i_start      (seed_df_start),
      .i_input_valid(i_seed_valid && (state_q == ST_SEED_DF_RUN)),
      .i_input_data (i_seed_data),
      .o_input_ready(seed_df_input_ready),
      .o_input_pass (seed_df_input_pass),
      .o_busy       (),
      .o_done       (seed_df_done),
      .o_seed       (seed_df_output)
  );

  sm3_df_stream #(
      .INPUT_BYTES(56)
  ) u_c_df (
      .i_clk        (i_clk),
      .i_rst_n      (i_rst_n),
      .i_start      (c_df_start),
      .i_input_valid(state_q == ST_C_DF_RUN),
      .i_input_data (c_df_input_data),
      .o_input_ready(c_df_input_ready),
      .o_input_pass (),
      .o_busy       (),
      .o_done       (c_df_done),
      .o_seed       (c_df_output)
  );
  /* verilator lint_on PINCONNECTEMPTY */

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q          <= ST_IDLE;
      v_q              <= '0;
      c_input_count_q  <= '0;
      o_busy           <= 1'b0;
      o_done           <= 1'b0;
      o_v              <= '0;
      o_c              <= '0;
      o_reseed_counter <= '0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            c_input_count_q <= '0;
            o_busy          <= 1'b1;
            state_q         <= ST_SEED_DF_START;
          end
        end

        ST_SEED_DF_START: begin
          state_q <= ST_SEED_DF_RUN;
        end

        ST_SEED_DF_RUN: begin
          if (seed_df_done) begin
            v_q             <= seed_df_output;
            c_input_count_q <= '0;
            state_q         <= ST_C_DF_START;
          end
        end

        ST_C_DF_START: begin
          c_input_count_q <= '0;
          state_q         <= ST_C_DF_RUN;
        end

        ST_C_DF_RUN: begin
          if (c_df_input_ready) begin
            if (c_input_count_q == 6'd55) begin
              c_input_count_q <= '0;
            end else begin
              c_input_count_q <= c_input_count_q + 1'b1;
            end
          end

          if (c_df_done) begin
            o_v              <= v_q;
            o_c              <= c_df_output;
            o_reseed_counter <= 440'd1;
            o_busy           <= 1'b0;
            o_done           <= 1'b1;
            state_q          <= ST_IDLE;
          end
        end

        default: begin
          o_busy  <= 1'b0;
          state_q <= ST_IDLE;
        end
      endcase
    end
  end

`ifndef SYNTHESIS
  initial begin
    if (SEED_BYTES < 1) $error("trike_sm3_drng_instantiate_stream SEED_BYTES must be at least 1");
  end
`endif

endmodule
