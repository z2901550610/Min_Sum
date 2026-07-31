`timescale 1ns / 1ps

// ICCS pseudohash512 used by TRIKE K and L.
//
// The message stream is consumed twice. Pass 0 computes
// HMAC-SM3(key, 0x02 || 0x00 || message), and pass 1 computes
// SM3(message || 0x02 || 0x00). The final digest is h1 || SM3(k1 || h1).
module trike_pseudohash512_stream #(
    parameter int MESSAGE_BYTES = 32
) (
    input  logic         i_clk,
    input  logic         i_rst_n,
    input  logic         i_start,
    input  logic         i_input_valid,
    input  logic [  7:0] i_input_data,
    output logic         o_input_ready,
    output logic         o_input_pass,
    output logic         o_busy,
    output logic         o_done,
    output logic [511:0] o_digest
);

  localparam int MESSAGE_COUNT_W = (MESSAGE_BYTES > 1) ? $clog2(MESSAGE_BYTES) : 1;
  localparam logic [MESSAGE_COUNT_W-1:0] MESSAGE_LAST = MESSAGE_COUNT_W'(MESSAGE_BYTES - 1);
  localparam logic [511:0] ICCS_HMAC_KEY = {
    256'h5307f6d5eb6a3ced3d24c53cc9c82cce2f8936397023f0695c26c80c1ab182a7,
    256'h1db02ba92f544018115a96e719662ca32b7c7efc0a6d2482150766ba6f655b8e
  };

  typedef enum logic [3:0] {
    ST_IDLE,
    ST_HMAC_START,
    ST_HMAC_PREFIX,
    ST_HMAC_MESSAGE,
    ST_HMAC_WAIT,
    ST_H1_START,
    ST_H1_MESSAGE,
    ST_H1_SUFFIX,
    ST_H1_WAIT,
    ST_H2_START,
    ST_H2_FEED,
    ST_H2_WAIT
  } state_t;

  state_t                       state_q;

  logic                         input_pass_q;
  logic   [                1:0] affix_idx_q;
  logic   [MESSAGE_COUNT_W-1:0] message_count_q;
  logic   [                5:0] h2_feed_idx_q;
  logic   [              255:0] k1_q;
  logic   [              255:0] h1_q;

  logic                         hmac_start;
  logic                         hmac_input_valid;
  logic   [                7:0] hmac_input_data;
  logic                         hmac_input_ready;
  logic                         hmac_done;
  logic   [              255:0] hmac_digest;

  logic                         h1_start;
  logic                         h1_input_valid;
  logic   [                7:0] h1_input_data;
  logic                         h1_input_ready;
  logic                         h1_done;
  logic   [              255:0] h1_digest;

  logic                         h2_start;
  logic   [                7:0] h2_input_data;
  logic                         h2_input_ready;
  logic                         h2_done;
  logic   [              255:0] h2_digest;

  function automatic logic [7:0] digest_byte(input  logic [255:0] value, input  logic [5:0] byte_idx);
    begin
      digest_byte = value[255-8*byte_idx-:8];
    end
  endfunction

  assign o_input_ready =
      ((state_q == ST_HMAC_MESSAGE) && hmac_input_ready) ||
      ((state_q == ST_H1_MESSAGE) && h1_input_ready);
  assign o_input_pass = input_pass_q;

  assign hmac_start = (state_q == ST_HMAC_START);
  assign hmac_input_valid =
      (state_q == ST_HMAC_PREFIX) || ((state_q == ST_HMAC_MESSAGE) && i_input_valid);
  assign hmac_input_data = (state_q == ST_HMAC_PREFIX) ?
      ((affix_idx_q == 0) ? 8'h02 : 8'h00) :
      i_input_data;

  assign h1_start = (state_q == ST_H1_START);
  assign h1_input_valid =
      ((state_q == ST_H1_MESSAGE) && i_input_valid) || (state_q == ST_H1_SUFFIX);
  assign h1_input_data =
      (state_q == ST_H1_SUFFIX) ? ((affix_idx_q == 0) ? 8'h02 : 8'h00) : i_input_data;

  assign h2_start = (state_q == ST_H2_START);
  assign h2_input_data = (h2_feed_idx_q < 32) ? digest_byte(
      k1_q, h2_feed_idx_q
  ) : digest_byte(
      h1_q, h2_feed_idx_q - 6'd32
  );

  /* verilator lint_off PINCONNECTEMPTY */
  hmac_sm3_64byte_key_stream #(
      .MESSAGE_BYTES(MESSAGE_BYTES + 2)
  ) u_hmac (
      .i_clk        (i_clk),
      .i_rst_n      (i_rst_n),
      .i_start      (hmac_start),
      .i_key        (ICCS_HMAC_KEY),
      .i_input_valid(hmac_input_valid),
      .i_input_data (hmac_input_data),
      .o_input_ready(hmac_input_ready),
      .o_busy       (),
      .o_done       (hmac_done),
      .o_digest     (hmac_digest)
  );

  sm3_hash_stream #(
      .INPUT_BYTES(MESSAGE_BYTES + 2)
  ) u_h1 (
      .i_clk        (i_clk),
      .i_rst_n      (i_rst_n),
      .i_start      (h1_start),
      .i_input_valid(h1_input_valid),
      .i_input_data (h1_input_data),
      .o_input_ready(h1_input_ready),
      .o_busy       (),
      .o_done       (h1_done),
      .o_digest     (h1_digest)
  );

  sm3_hash_stream #(
      .INPUT_BYTES(64)
  ) u_h2 (
      .i_clk        (i_clk),
      .i_rst_n      (i_rst_n),
      .i_start      (h2_start),
      .i_input_valid(state_q == ST_H2_FEED),
      .i_input_data (h2_input_data),
      .o_input_ready(h2_input_ready),
      .o_busy       (),
      .o_done       (h2_done),
      .o_digest     (h2_digest)
  );
  /* verilator lint_on PINCONNECTEMPTY */

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q         <= ST_IDLE;
      input_pass_q    <= 1'b0;
      affix_idx_q     <= '0;
      message_count_q <= '0;
      h2_feed_idx_q   <= '0;
      k1_q            <= '0;
      h1_q            <= '0;
      o_busy          <= 1'b0;
      o_done          <= 1'b0;
      o_digest        <= '0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            input_pass_q    <= 1'b0;
            affix_idx_q     <= '0;
            message_count_q <= '0;
            o_busy          <= 1'b1;
            state_q         <= ST_HMAC_START;
          end
        end

        ST_HMAC_START: begin
          affix_idx_q <= '0;
          state_q     <= ST_HMAC_PREFIX;
        end

        ST_HMAC_PREFIX: begin
          if (hmac_input_valid && hmac_input_ready) begin
            if (affix_idx_q == 1) begin
              message_count_q <= '0;
              state_q         <= ST_HMAC_MESSAGE;
            end else begin
              affix_idx_q <= affix_idx_q + 1'b1;
            end
          end
        end

        ST_HMAC_MESSAGE: begin
          if (i_input_valid && o_input_ready) begin
            if (message_count_q == MESSAGE_LAST) begin
              state_q <= ST_HMAC_WAIT;
            end else begin
              message_count_q <= message_count_q + 1'b1;
            end
          end
        end

        ST_HMAC_WAIT: begin
          if (hmac_done) begin
            k1_q            <= hmac_digest;
            input_pass_q    <= 1'b1;
            message_count_q <= '0;
            state_q         <= ST_H1_START;
          end
        end

        ST_H1_START: begin
          state_q <= ST_H1_MESSAGE;
        end

        ST_H1_MESSAGE: begin
          if (i_input_valid && o_input_ready) begin
            if (message_count_q == MESSAGE_LAST) begin
              affix_idx_q <= '0;
              state_q     <= ST_H1_SUFFIX;
            end else begin
              message_count_q <= message_count_q + 1'b1;
            end
          end
        end

        ST_H1_SUFFIX: begin
          if (h1_input_valid && h1_input_ready) begin
            if (affix_idx_q == 1) begin
              state_q <= ST_H1_WAIT;
            end else begin
              affix_idx_q <= affix_idx_q + 1'b1;
            end
          end
        end

        ST_H1_WAIT: begin
          if (h1_done) begin
            h1_q          <= h1_digest;
            h2_feed_idx_q <= '0;
            state_q       <= ST_H2_START;
          end
        end

        ST_H2_START: begin
          h2_feed_idx_q <= '0;
          state_q       <= ST_H2_FEED;
        end

        ST_H2_FEED: begin
          if (h2_input_ready) begin
            if (h2_feed_idx_q == 6'd63) begin
              state_q <= ST_H2_WAIT;
            end else begin
              h2_feed_idx_q <= h2_feed_idx_q + 1'b1;
            end
          end
        end

        ST_H2_WAIT: begin
          if (h2_done) begin
            o_digest <= {h1_q, h2_digest};
            o_busy   <= 1'b0;
            o_done   <= 1'b1;
            state_q  <= ST_IDLE;
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
    if (MESSAGE_BYTES < 1) $error("trike_pseudohash512_stream MESSAGE_BYTES must be at least 1");
  end
`endif

endmodule
