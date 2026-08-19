`timescale 1ns / 1ps

// Public-length HMAC-SM3 engine for a 64-byte key.
//
// i_key uses network byte order: key byte zero occupies i_key[511:504].
// MESSAGE_BYTES allocates the maximum public length. The message stream is
// consumed once; the inner and outer SM3 passes have data-independent work.
module hmac_sm3_64byte_key_stream #(
    parameter int MESSAGE_BYTES         = 32,
    parameter bit RUNTIME_LENGTH        = 1'b0,
    parameter bit USE_EXTERNAL_COMPRESS = 1'b0
) (
    input  logic         i_clk,
    input  logic         i_rst_n,
    input  logic         i_start,
    input  logic [ 31:0] i_runtime_message_bytes,
    input  logic [511:0] i_key,
    input  logic         i_input_valid,
    input  logic [  7:0] i_input_data,
    output logic         o_input_ready,
    output logic         o_busy,
    output logic         o_done,
    output logic [255:0] o_digest,
    output logic         o_compress_start,
    output logic [511:0] o_compress_block,
    output logic [255:0] o_compress_state,
    input  logic         i_compress_busy,
    input  logic         i_compress_done,
    input  logic [255:0] i_compress_state
);

  localparam int MESSAGE_COUNT_W = (MESSAGE_BYTES > 1) ? $clog2(MESSAGE_BYTES) : 1;

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

  logic                         inner_compress_start;
  logic   [              511:0] inner_compress_block;
  logic   [              255:0] inner_compress_state;
  logic                         outer_compress_start;
  logic   [              511:0] outer_compress_block;
  logic   [              255:0] outer_compress_state;
  logic                         shared_compress_busy;
  logic                         shared_compress_done;
  logic   [              255:0] shared_compress_result;
  logic                         internal_compress_busy;
  logic                         internal_compress_done;
  logic   [              255:0] internal_compress_result;
  logic                         select_outer_compress;
  integer                       active_message_bytes_q;

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

  assign select_outer_compress = (state_q == ST_OUTER_START) ||
                                 (state_q == ST_OUTER_KEY) ||
                                 (state_q == ST_OUTER_DIGEST) ||
                                 (state_q == ST_OUTER_WAIT);
  assign shared_compress_busy = USE_EXTERNAL_COMPRESS ? i_compress_busy : internal_compress_busy;
  assign shared_compress_done = USE_EXTERNAL_COMPRESS ? i_compress_done : internal_compress_done;
  assign shared_compress_result =
      USE_EXTERNAL_COMPRESS ? i_compress_state : internal_compress_result;
  assign o_compress_start = select_outer_compress ? outer_compress_start : inner_compress_start;
  assign o_compress_block = select_outer_compress ? outer_compress_block : inner_compress_block;
  assign o_compress_state = select_outer_compress ? outer_compress_state : inner_compress_state;

  sm3_hash_stream #(
      .INPUT_BYTES          (64 + MESSAGE_BYTES),
      .RUNTIME_LENGTH       (RUNTIME_LENGTH),
      .USE_EXTERNAL_COMPRESS(1'b1)
  ) u_inner_hash (
      .i_clk                (i_clk),
      .i_rst_n              (i_rst_n),
      .i_start              (inner_start),
      .i_runtime_input_bytes(32'(64 + active_message_bytes_q)),
      .i_input_valid        (inner_input_valid),
      .i_input_data         (inner_input_data),
      .o_input_ready        (inner_input_ready),
      .o_busy               (),
      .o_done               (inner_done),
      .o_digest             (inner_digest),
      .o_compress_start     (inner_compress_start),
      .o_compress_block     (inner_compress_block),
      .o_compress_state     (inner_compress_state),
      .i_compress_busy      (shared_compress_busy),
      .i_compress_done      (shared_compress_done),
      .i_compress_state     (shared_compress_result)
  );

  sm3_hash_stream #(
      .INPUT_BYTES          (96),
      .USE_EXTERNAL_COMPRESS(1'b1)
  ) u_outer_hash (
      .i_clk                (i_clk),
      .i_rst_n              (i_rst_n),
      .i_start              (outer_start),
      .i_runtime_input_bytes('0),
      .i_input_valid        (outer_input_valid),
      .i_input_data         (outer_input_data),
      .o_input_ready        (outer_input_ready),
      .o_busy               (),
      .o_done               (outer_done),
      .o_digest             (outer_digest),
      .o_compress_start     (outer_compress_start),
      .o_compress_block     (outer_compress_block),
      .o_compress_state     (outer_compress_state),
      .i_compress_busy      (shared_compress_busy),
      .i_compress_done      (shared_compress_done),
      .i_compress_state     (shared_compress_result)
  );

  generate
    if (!USE_EXTERNAL_COMPRESS) begin : g_internal_compress
      trike_sm3_service u_sm3_service (
          .i_clk  (i_clk),
          .i_rst_n(i_rst_n),
          .i_start(o_compress_start),
          .i_block(o_compress_block),
          .i_state(o_compress_state),
          .o_busy (internal_compress_busy),
          .o_done (internal_compress_done),
          .o_state(internal_compress_result)
      );
    end else begin : g_external_compress
      assign internal_compress_busy   = 1'b0;
      assign internal_compress_done   = 1'b0;
      assign internal_compress_result = '0;
    end
  endgenerate

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q                <= ST_IDLE;
      key_q                  <= '0;
      key_byte_idx_q         <= '0;
      message_count_q        <= '0;
      digest_byte_idx_q      <= '0;
      inner_digest_q         <= '0;
      active_message_bytes_q <= MESSAGE_BYTES;
      o_busy                 <= 1'b0;
      o_done                 <= 1'b0;
      o_digest               <= '0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            key_q             <= i_key;
            key_byte_idx_q    <= '0;
            message_count_q   <= '0;
            digest_byte_idx_q <= '0;
            if (RUNTIME_LENGTH) active_message_bytes_q <= int'(i_runtime_message_bytes);
            else active_message_bytes_q <= MESSAGE_BYTES;
            o_busy  <= 1'b1;
            state_q <= ST_INNER_START;
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
            if (message_count_q == MESSAGE_COUNT_W'(active_message_bytes_q - 1)) begin
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

  always_ff @(posedge i_clk) begin
    if (i_rst_n && (state_q == ST_IDLE) && i_start && RUNTIME_LENGTH) begin
      if ((i_runtime_message_bytes < 1) || (i_runtime_message_bytes > MESSAGE_BYTES))
        $fatal(1, "hmac_sm3_64byte_key_stream runtime length out of range");
    end
  end
`endif

endmodule
