`timescale 1ns / 1ps

// Fixed-length streaming SHAKE256 engine.
//
// INPUT_BYTES and OUTPUT_BYTES are public elaboration-time parameters. Input
// and output bytes follow FIPS 202 order. The engine absorbs and emits one byte
// per accepted valid/ready transfer and invokes Keccak-f[1600] as required.
// TRIKE function identifiers and serialization are intentionally outside this
// module.
module shake256_stream #(
    parameter int INPUT_BYTES  = 32,
    parameter int OUTPUT_BYTES = 32
) (
    input  logic       i_clk,
    input  logic       i_rst_n,
    input  logic       i_start,
    input  logic       i_input_valid,
    input  logic [7:0] i_input_data,
    output logic       o_input_ready,
    input  logic       i_output_ready,
    output logic       o_output_valid,
    output logic [7:0] o_output_data,
    output logic       o_busy,
    output logic       o_done
);

  localparam int RATE_BYTES = 136;
  localparam int INPUT_COUNT_W = (INPUT_BYTES > 1) ? $clog2(INPUT_BYTES) : 1;
  localparam int OUTPUT_COUNT_W = (OUTPUT_BYTES > 1) ? $clog2(OUTPUT_BYTES) : 1;
  localparam logic [7:0] RATE_LAST = 8'(RATE_BYTES - 1);
  localparam logic [INPUT_COUNT_W-1:0] INPUT_LAST = INPUT_COUNT_W'(INPUT_BYTES - 1);
  localparam logic [OUTPUT_COUNT_W-1:0] OUTPUT_LAST = OUTPUT_COUNT_W'(OUTPUT_BYTES - 1);

  typedef enum logic [3:0] {
    ST_IDLE,
    ST_ABSORB,
    ST_BLOCK_PERM_START,
    ST_BLOCK_PERM_WAIT,
    ST_PAD_PERM_START,
    ST_PAD_PERM_WAIT,
    ST_SQUEEZE,
    ST_SQUEEZE_PERM_START,
    ST_SQUEEZE_PERM_WAIT
  } state_t;

  state_t                      state_q;

  logic   [            1599:0] sponge_q;
  logic   [            1599:0] perm_input;
  logic   [            1599:0] perm_output;
  logic                        perm_start;
  logic                        perm_busy;
  logic                        perm_done;

  logic   [ INPUT_COUNT_W-1:0] input_count_q;
  logic   [OUTPUT_COUNT_W-1:0] output_count_q;
  logic   [               7:0] rate_index_q;
  logic                        message_ended_on_full_block_q;

  function automatic logic [1599:0] xor_state_byte(
      input  logic [1599:0] state_i, input  logic [7:0] byte_idx, input  logic [7:0] byte_value);
    logic [1599:0] state_o;
    begin
      state_o = state_i;
      state_o[8*byte_idx+:8] = state_o[8*byte_idx+:8] ^ byte_value;
      xor_state_byte = state_o;
    end
  endfunction

  function automatic logic [1599:0] apply_shake_padding(input  logic [1599:0] state_i,
                                                        input  logic [7:0] suffix_byte_idx);
    logic [1599:0] state_o;
    begin
      state_o = state_i;
      state_o[8*suffix_byte_idx+:8] = state_o[8*suffix_byte_idx+:8] ^ 8'h1f;
      state_o[8*(RATE_BYTES-1)+:8] = state_o[8*(RATE_BYTES-1)+:8] ^ 8'h80;
      apply_shake_padding = state_o;
    end
  endfunction

  assign o_input_ready = (state_q == ST_ABSORB);
  assign o_output_valid = (state_q == ST_SQUEEZE);
  assign o_output_data = sponge_q[8*rate_index_q+:8];

  assign perm_start =
      !perm_busy &&
      ((state_q == ST_BLOCK_PERM_START) || (state_q == ST_PAD_PERM_START) ||
       (state_q == ST_SQUEEZE_PERM_START));
  assign perm_input = sponge_q;

  keccak_f1600 u_keccak_f1600 (
      .i_clk  (i_clk),
      .i_rst_n(i_rst_n),
      .i_start(perm_start),
      .i_state(perm_input),
      .o_busy (perm_busy),
      .o_done (perm_done),
      .o_state(perm_output)
  );

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q                       <= ST_IDLE;
      sponge_q                      <= '0;
      input_count_q                 <= '0;
      output_count_q                <= '0;
      rate_index_q                  <= '0;
      message_ended_on_full_block_q <= 1'b0;
      o_busy                        <= 1'b0;
      o_done                        <= 1'b0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            sponge_q                      <= '0;
            input_count_q                 <= '0;
            output_count_q                <= '0;
            rate_index_q                  <= '0;
            message_ended_on_full_block_q <= 1'b0;
            o_busy                        <= 1'b1;
            state_q                       <= ST_ABSORB;
          end
        end

        ST_ABSORB: begin
          if (i_input_valid && o_input_ready) begin
            sponge_q <= xor_state_byte(sponge_q, rate_index_q, i_input_data);

            if (input_count_q == INPUT_LAST) begin
              if (rate_index_q == RATE_LAST) begin
                message_ended_on_full_block_q <= 1'b1;
                state_q                       <= ST_BLOCK_PERM_START;
              end else begin
                sponge_q <= apply_shake_padding(
                    xor_state_byte(sponge_q, rate_index_q, i_input_data), rate_index_q + 1'b1
                );
                state_q <= ST_PAD_PERM_START;
              end
            end else begin
              input_count_q <= input_count_q + 1'b1;
              if (rate_index_q == RATE_LAST) begin
                message_ended_on_full_block_q <= 1'b0;
                state_q                       <= ST_BLOCK_PERM_START;
              end else begin
                rate_index_q <= rate_index_q + 1'b1;
              end
            end
          end
        end

        ST_BLOCK_PERM_START: begin
          state_q <= ST_BLOCK_PERM_WAIT;
        end

        ST_BLOCK_PERM_WAIT: begin
          if (perm_done) begin
            if (message_ended_on_full_block_q) begin
              sponge_q <= apply_shake_padding(perm_output, 0);
              state_q  <= ST_PAD_PERM_START;
            end else begin
              sponge_q     <= perm_output;
              rate_index_q <= '0;
              state_q      <= ST_ABSORB;
            end
          end
        end

        ST_PAD_PERM_START: begin
          state_q <= ST_PAD_PERM_WAIT;
        end

        ST_PAD_PERM_WAIT: begin
          if (perm_done) begin
            sponge_q       <= perm_output;
            output_count_q <= '0;
            rate_index_q   <= '0;
            state_q        <= ST_SQUEEZE;
          end
        end

        ST_SQUEEZE: begin
          if (o_output_valid && i_output_ready) begin
            if (output_count_q == OUTPUT_LAST) begin
              o_busy  <= 1'b0;
              o_done  <= 1'b1;
              state_q <= ST_IDLE;
            end else begin
              output_count_q <= output_count_q + 1'b1;
              if (rate_index_q == RATE_LAST) begin
                rate_index_q <= '0;
                state_q      <= ST_SQUEEZE_PERM_START;
              end else begin
                rate_index_q <= rate_index_q + 1'b1;
              end
            end
          end
        end

        ST_SQUEEZE_PERM_START: begin
          state_q <= ST_SQUEEZE_PERM_WAIT;
        end

        ST_SQUEEZE_PERM_WAIT: begin
          if (perm_done) begin
            sponge_q <= perm_output;
            state_q  <= ST_SQUEEZE;
          end
        end

        default: begin
          state_q <= ST_IDLE;
          o_busy  <= 1'b0;
        end
      endcase
    end
  end

`ifndef SYNTHESIS
  initial begin
    if (INPUT_BYTES < 1) $error("shake256_stream INPUT_BYTES must be at least 1");
    if (OUTPUT_BYTES < 1) $error("shake256_stream OUTPUT_BYTES must be at least 1");
  end
`endif

endmodule
