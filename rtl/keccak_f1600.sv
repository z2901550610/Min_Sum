`timescale 1ns / 1ps

// Iterative Keccak-f[1600] permutation. The state uses the FIPS 202 lane
// convention: lane (x, y) occupies bits 64 * (x + 5 * y) +: 64 and the
// least-significant bit of each lane is processed first.
module keccak_f1600 (
    input  logic          i_clk,
    input  logic          i_rst_n,
    input  logic          i_start,
    input  logic [1599:0] i_state,
    output logic          o_busy,
    output logic          o_done,
    output logic [1599:0] o_state
);

  localparam int ROUND_COUNT = 24;
  localparam logic [4:0] LAST_ROUND = 5'(ROUND_COUNT - 1);

  localparam logic [63:0] ROUND_CONSTANTS[0:ROUND_COUNT-1] = '{
      64'h0000000000000001,
      64'h0000000000008082,
      64'h800000000000808a,
      64'h8000000080008000,
      64'h000000000000808b,
      64'h0000000080000001,
      64'h8000000080008081,
      64'h8000000000008009,
      64'h000000000000008a,
      64'h0000000000000088,
      64'h0000000080008009,
      64'h000000008000000a,
      64'h000000008000808b,
      64'h800000000000008b,
      64'h8000000000008089,
      64'h8000000000008003,
      64'h8000000000008002,
      64'h8000000000000080,
      64'h000000000000800a,
      64'h800000008000000a,
      64'h8000000080008081,
      64'h8000000000008080,
      64'h0000000080000001,
      64'h8000000080008008
  };

  localparam int RHO_OFFSETS[0:4][0:4] = '{
      '{0, 36, 3, 41, 18},
      '{1, 44, 10, 45, 2},
      '{62, 6, 43, 15, 61},
      '{28, 55, 25, 21, 56},
      '{27, 20, 39, 8, 14}
  };

  logic   [1599:0] state_q;
  logic   [1599:0] round_state;
  logic   [   4:0] round_idx_q;

  logic   [  63:0] lane_a[0:4][0:4];
  logic   [  63:0] lane_theta[0:4][0:4];
  logic   [  63:0] lane_b[0:4][0:4];
  logic   [  63:0] lane_out[0:4][0:4];
  logic   [  63:0] column_parity[0:4];
  logic   [  63:0] theta_delta[0:4];

  integer          x;
  integer          y;

  function automatic logic [63:0] rotate_left64(input  logic [63:0] value, input int unsigned shift);
    begin
      if (shift == 0) begin
        rotate_left64 = value;
      end else begin
        rotate_left64 = (value << shift) | (value >> (64 - shift));
      end
    end
  endfunction

  always_comb begin
    for (y = 0; y < 5; y++) begin
      for (x = 0; x < 5; x++) begin
        lane_a[x][y] = state_q[64*(x+5*y)+:64];
      end
    end

    for (x = 0; x < 5; x++) begin
      column_parity[x] = lane_a[x][0] ^ lane_a[x][1] ^ lane_a[x][2] ^ lane_a[x][3] ^ lane_a[x][4];
    end

    for (x = 0; x < 5; x++) begin
      theta_delta[x] = column_parity[(x+4)%5] ^ rotate_left64(column_parity[(x+1)%5], 1);
      for (y = 0; y < 5; y++) begin
        lane_theta[x][y] = lane_a[x][y] ^ theta_delta[x];
      end
    end

    for (y = 0; y < 5; y++) begin
      for (x = 0; x < 5; x++) begin
        lane_b[x][y] = '0;
      end
    end

    for (y = 0; y < 5; y++) begin
      for (x = 0; x < 5; x++) begin
        lane_b[y][(2*x+3*y)%5] = rotate_left64(lane_theta[x][y], RHO_OFFSETS[x][y]);
      end
    end

    for (y = 0; y < 5; y++) begin
      for (x = 0; x < 5; x++) begin
        lane_out[x][y] = lane_b[x][y] ^ ((~lane_b[(x+1)%5][y]) & lane_b[(x+2)%5][y]);
      end
    end
    lane_out[0][0] = lane_out[0][0] ^ ROUND_CONSTANTS[round_idx_q];

    round_state = '0;
    for (y = 0; y < 5; y++) begin
      for (x = 0; x < 5; x++) begin
        round_state[64*(x+5*y)+:64] = lane_out[x][y];
      end
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q     <= '0;
      round_idx_q <= '0;
      o_busy      <= 1'b0;
      o_done      <= 1'b0;
      o_state     <= '0;
    end else begin
      o_done <= 1'b0;

      if (!o_busy) begin
        if (i_start) begin
          state_q     <= i_state;
          round_idx_q <= '0;
          o_busy      <= 1'b1;
        end
      end else begin
        state_q <= round_state;
        if (round_idx_q == LAST_ROUND) begin
          o_state <= round_state;
          o_busy  <= 1'b0;
          o_done  <= 1'b1;
        end else begin
          round_idx_q <= round_idx_q + 1'b1;
        end
      end
    end
  end

endmodule
