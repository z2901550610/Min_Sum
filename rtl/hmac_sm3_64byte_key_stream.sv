`timescale 1ns / 1ps

// Fixed-length HMAC-SM3 engine for a 64-byte key.
//
// i_key uses network byte order: key byte zero occupies i_key[511:504].
// MESSAGE_BYTES is public and fixed at elaboration time. The message stream is
// consumed once; the inner and outer SM3 passes have data-independent work.
module hmac_sm3_64byte_key_stream #(
    parameter int MESSAGE_BYTES = 32
) (
    input  logic         i_clk,
    input  logic         i_rst_n,
    input  logic         i_start,
    input  logic [511:0] i_key,
    input  logic         i_input_valid,
    input  logic [  7:0] i_input_data,
    output logic         o_input_ready,
    output logic         o_busy,
    output logic         o_done,
    output logic [255:0] o_digest
);

  localparam int MESSAGE_COUNT_W = (MESSAGE_BYTES > 1) ? $clog2(MESSAGE_BYTES) : 1;
  localparam logic [MESSAGE_COUNT_W-1:0] MESSAGE_LAST = MESSAGE_COUNT_W'(MESSAGE_BYTES - 1);

  typedef enum logic [3:0] {
    ST_IDLE,
    ST_INNER_START,
    ST_INNER_KEY,
    ST_INNER_MESSAGE,
    ST_INNER_WAIT,
    ST_OUTER_START,
    ST_OUTER_KEY,
    ST_OUTER_DIGEST,
    ST_OUTER_WAIT
  } state_t;

  state_t                       state_q;

  logic   [              511:0] key_q;
  logic   [                5:0] key_byte_idx_q;
  logic   [MESSAGE_COUNT_W-1:0] message_count_q;
  logic   [                5:0] digest_byte_idx_q;
  logic   [              255:0] inner_digest_q;

  logic                         inner_start;
  logic                         inner_input_valid;
  logic   [                7:0] inner_input_data;
  logic                         inner_input_ready;
  logic                         inner_done;
  logic   [              255:0] inner_digest;

  logic                         outer_start;
  logic                         outer_input_valid;
  logic   [                7:0] outer_input_data;
  logic                         outer_input_ready;
  logic                         outer_done;
  logic   [              255:0] outer_digest;

  assign o_input_ready = (state_q == ST_INNER_MESSAGE) && inner_input_ready;

  assign inner_start = (state_q == ST_INNER_START);
  assign inner_input_valid =
      (state_q == ST_INNER_KEY) || ((state_q == ST_INNER_MESSAGE) && i_input_valid);
  assign inner_input_data =
      (state_q == ST_INNER_KEY) ? (key_q[511-8*key_byte_idx_q-:8] ^ 8'h36) : i_input_data;

  assign outer_start = (state_q == ST_OUTER_START);
  assign outer_input_valid = (state_q == ST_OUTER_KEY) || (state_q == ST_OUTER_DIGEST);
  assign outer_input_data = (state_q == ST_OUTER_KEY) ?
      (key_q[511-8*key_byte_idx_q-:8] ^ 8'h5c) :
      inner_digest_q[255-8*digest_byte_idx_q-:8];

  /* verilator lint_off PINCONNECTEMPTY */
  sm3_hash_stream #(
      .INPUT_BYTES(64 + MESSAGE_BYTES)
  ) u_inner_hash (
      .i_clk        (i_clk),
      .i_rst_n      (i_rst_n),
      .i_start      (inner_start),
      .i_input_valid(inner_input_valid),
      .i_input_data (inner_input_data),
      .o_input_ready(inner_input_ready),
      .o_busy       (),
      .o_done       (inner_done),
      .o_digest     (inner_digest)
  );

  sm3_hash_stream #(
      .INPUT_BYTES(96)
  ) u_outer_hash (
      .i_clk        (i_clk),
      .i_rst_n      (i_rst_n),
      .i_start      (outer_start),
      .i_input_valid(outer_input_valid),
      .i_input_data (outer_input_data),
      .o_input_ready(outer_input_ready),
      .o_busy       (),
      .o_done       (outer_done),
      .o_digest     (outer_digest)
  );
  /* verilator lint_on PINCONNECTEMPTY */

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q           <= ST_IDLE;
      key_q             <= '0;
      key_byte_idx_q    <= '0;
      message_count_q   <= '0;
      digest_byte_idx_q <= '0;
      inner_digest_q    <= '0;
      o_busy            <= 1'b0;
      o_done            <= 1'b0;
      o_digest          <= '0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            key_q             <= i_key;
            key_byte_idx_q    <= '0;
            message_count_q   <= '0;
            digest_byte_idx_q <= '0;
            o_busy            <= 1'b1;
            state_q           <= ST_INNER_START;
          end
        end

        ST_INNER_START: begin
          state_q <= ST_INNER_KEY;
        end

        ST_INNER_KEY: begin
          if (inner_input_valid && inner_input_ready) begin
            if (key_byte_idx_q == 6'd63) begin
              key_byte_idx_q <= '0;
              state_q        <= ST_INNER_MESSAGE;
            end else begin
              key_byte_idx_q <= key_byte_idx_q + 1'b1;
            end
          end
        end

        ST_INNER_MESSAGE: begin
          if (i_input_valid && o_input_ready) begin
            if (message_count_q == MESSAGE_LAST) begin
              state_q <= ST_INNER_WAIT;
            end else begin
              message_count_q <= message_count_q + 1'b1;
            end
          end
        end

        ST_INNER_WAIT: begin
          if (inner_done) begin
            inner_digest_q <= inner_digest;
            key_byte_idx_q <= '0;
            state_q        <= ST_OUTER_START;
          end
        end

        ST_OUTER_START: begin
          state_q <= ST_OUTER_KEY;
        end

        ST_OUTER_KEY: begin
          if (outer_input_valid && outer_input_ready) begin
            if (key_byte_idx_q == 6'd63) begin
              key_byte_idx_q    <= '0;
              digest_byte_idx_q <= '0;
              state_q           <= ST_OUTER_DIGEST;
            end else begin
              key_byte_idx_q <= key_byte_idx_q + 1'b1;
            end
          end
        end

        ST_OUTER_DIGEST: begin
          if (outer_input_valid && outer_input_ready) begin
            if (digest_byte_idx_q == 6'd31) begin
              state_q <= ST_OUTER_WAIT;
            end else begin
              digest_byte_idx_q <= digest_byte_idx_q + 1'b1;
            end
          end
        end

        ST_OUTER_WAIT: begin
          if (outer_done) begin
            o_digest <= outer_digest;
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
    if (MESSAGE_BYTES < 1) $error("hmac_sm3_64byte_key_stream MESSAGE_BYTES must be at least 1");
  end
`endif

endmodule
