`timescale 1ns / 1ps

// Iterative SM3 compression function.
//
// i_block and i_state use network byte order. The first message word occupies
// i_block[511:480], and the first chaining word occupies i_state[255:224].
// Each accepted start executes 52 message-expansion cycles followed by
// 64 compression rounds.
module sm3_compress (
    input  logic         i_clk,
    input  logic         i_rst_n,
    input  logic         i_start,
    input  logic [511:0] i_block,
    input  logic [255:0] i_state,
    output logic         o_busy,
    output logic         o_done,
    output logic [255:0] o_state
);

  localparam logic [6:0] EXPAND_FIRST = 7'd16;
  localparam logic [6:0] EXPAND_LAST = 7'd67;
  localparam logic [5:0] ROUND_LAST = 6'd63;

  typedef enum logic [1:0] {
    ST_IDLE,
    ST_EXPAND,
    ST_ROUND
  } state_t;

  state_t         state_q;

  logic   [ 31:0] schedule_q[0:67];
  logic   [255:0] initial_state_q;
  logic   [  6:0] expand_idx_q;
  logic   [  5:0] round_idx_q;

  logic   [ 31:0] a_q;
  logic   [ 31:0] b_q;
  logic   [ 31:0] c_q;
  logic   [ 31:0] d_q;
  logic   [ 31:0] e_q;
  logic   [ 31:0] f_q;
  logic   [ 31:0] g_q;
  logic   [ 31:0] h_q;

  logic   [ 31:0] schedule_next;
  logic   [ 31:0] round_constant;
  logic   [ 31:0] a_rot12;
  logic   [ 31:0] ss1;
  logic   [ 31:0] ss2;
  logic   [ 31:0] tt1;
  logic   [ 31:0] tt2;
  logic   [ 31:0] ff_value;
  logic   [ 31:0] gg_value;

  logic   [ 31:0] a_next;
  logic   [ 31:0] b_next;
  logic   [ 31:0] c_next;
  logic   [ 31:0] d_next;
  logic   [ 31:0] e_next;
  logic   [ 31:0] f_next;
  logic   [ 31:0] g_next;
  logic   [ 31:0] h_next;

  integer         word_idx;

  function automatic logic [31:0] rotate_left32(input  logic [31:0] value, input  logic [4:0] shift);
    begin
      if (shift == 0) begin
        rotate_left32 = value;
      end else begin
        rotate_left32 = (value << shift) | (value >> (32 - shift));
      end
    end
  endfunction

  function automatic logic [31:0] permutation_p0(input  logic [31:0] value);
    begin
      permutation_p0 = value ^ rotate_left32(value, 5'd9) ^ rotate_left32(value, 5'd17);
    end
  endfunction

  function automatic logic [31:0] permutation_p1(input  logic [31:0] value);
    begin
      permutation_p1 = value ^ rotate_left32(value, 5'd15) ^ rotate_left32(value, 5'd23);
    end
  endfunction

  always_comb begin
    schedule_next = permutation_p1(
      schedule_q[expand_idx_q-16] ^ schedule_q[expand_idx_q-9] ^ rotate_left32(
        schedule_q[expand_idx_q-3], 5'd15)
    ) ^ rotate_left32(
      schedule_q[expand_idx_q-13], 5'd7
    ) ^ schedule_q[expand_idx_q-6];

    if (round_idx_q < 16) begin
      round_constant = 32'h79cc4519;
      ff_value       = a_q ^ b_q ^ c_q;
      gg_value       = e_q ^ f_q ^ g_q;
    end else begin
      round_constant = 32'h7a879d8a;
      ff_value       = (a_q & b_q) | (a_q & c_q) | (b_q & c_q);
      gg_value       = (e_q & f_q) | ((~e_q) & g_q);
    end

    a_rot12 = rotate_left32(a_q, 5'd12);
    ss1 = rotate_left32(a_rot12 + e_q + rotate_left32(round_constant, round_idx_q[4:0]), 5'd7);
    ss2 = ss1 ^ a_rot12;
    tt1 = ff_value + d_q + ss2 +
        (schedule_q[{1'b0, round_idx_q}] ^ schedule_q[{1'b0, round_idx_q}+7'd4]);
    tt2 = gg_value + h_q + ss1 + schedule_q[{1'b0, round_idx_q}];

    a_next = tt1;
    b_next = a_q;
    c_next = rotate_left32(b_q, 5'd9);
    d_next = c_q;
    e_next = permutation_p0(tt2);
    f_next = e_q;
    g_next = rotate_left32(f_q, 5'd19);
    h_next = g_q;
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q         <= ST_IDLE;
      initial_state_q <= '0;
      expand_idx_q    <= EXPAND_FIRST;
      round_idx_q     <= '0;
      a_q             <= '0;
      b_q             <= '0;
      c_q             <= '0;
      d_q             <= '0;
      e_q             <= '0;
      f_q             <= '0;
      g_q             <= '0;
      h_q             <= '0;
      o_busy          <= 1'b0;
      o_done          <= 1'b0;
      o_state         <= '0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            for (word_idx = 0; word_idx < 16; word_idx++) begin
              schedule_q[word_idx] <= i_block[511-32*word_idx-:32];
            end
            initial_state_q <= i_state;
            expand_idx_q    <= EXPAND_FIRST;
            o_busy          <= 1'b1;
            state_q         <= ST_EXPAND;
          end
        end

        ST_EXPAND: begin
          schedule_q[expand_idx_q] <= schedule_next;
          if (expand_idx_q == EXPAND_LAST) begin
            a_q         <= initial_state_q[255:224];
            b_q         <= initial_state_q[223:192];
            c_q         <= initial_state_q[191:160];
            d_q         <= initial_state_q[159:128];
            e_q         <= initial_state_q[127:96];
            f_q         <= initial_state_q[95:64];
            g_q         <= initial_state_q[63:32];
            h_q         <= initial_state_q[31:0];
            round_idx_q <= '0;
            state_q     <= ST_ROUND;
          end else begin
            expand_idx_q <= expand_idx_q + 1'b1;
          end
        end

        ST_ROUND: begin
          a_q <= a_next;
          b_q <= b_next;
          c_q <= c_next;
          d_q <= d_next;
          e_q <= e_next;
          f_q <= f_next;
          g_q <= g_next;
          h_q <= h_next;

          if (round_idx_q == ROUND_LAST) begin
            o_state <= {
              initial_state_q[255:224] ^ a_next,
              initial_state_q[223:192] ^ b_next,
              initial_state_q[191:160] ^ c_next,
              initial_state_q[159:128] ^ d_next,
              initial_state_q[127:96] ^ e_next,
              initial_state_q[95:64] ^ f_next,
              initial_state_q[63:32] ^ g_next,
              initial_state_q[31:0] ^ h_next
            };
            o_busy <= 1'b0;
            o_done <= 1'b1;
            state_q <= ST_IDLE;
          end else begin
            round_idx_q <= round_idx_q + 1'b1;
          end
        end

        default: begin
          state_q <= ST_IDLE;
          o_busy  <= 1'b0;
        end
      endcase
    end
  end

endmodule
