`ifdef MDPC_PAPER_CFG
import mdpc_paper_pkg::*;
`else
import mdpc_demo_pkg::*;
`endif

module mdpc_cnu_a (
  input  logic clk,
  input  logic rst_n,
  input  logic clear_en,
  input  logic in_valid,
  input  logic [MSG_W-1:0] v2c_msg_in,
  input  logic [VAR_W-1:0] src_var_idx,
  input  logic [ROW_STATE_W-1:0] c2v_compact_msg_in,
  output logic [ROW_STATE_W-1:0] c2v_compact_msg_out,
  output logic v2c_sign_out,
  output logic out_valid
);

`ifdef MDPC_PAPER_CFG
  import mdpc_paper_pkg::*;
`else
  import mdpc_demo_pkg::*;
`endif

  // CNU_A compresses one check row into {min1, min2, min_id, sign_xor}. The
  // sign-magnitude v2c/u format lets sign feed sign_xor and magnitude feed the
  // min1/min2 update without conversion.

  logic               v2c_sign;
  logic [D-1:0]       v2c_mag;
  logic [D-1:0]       c2v_min1_mag;
  logic [D-1:0]       c2v_min2_mag;
  logic               c2v_sign_xor;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_next;

  assign v2c_sign = v2c_msg_in[MSG_SIGN_BIT];
  assign v2c_mag = v2c_msg_in[MSG_MAG_LSB +: D];

  assign c2v_min1_mag = c2v_compact_msg_in[ROW_STATE_MIN1_LSB +: D];
  assign c2v_min2_mag = c2v_compact_msg_in[ROW_STATE_MIN2_LSB +: D];
  assign c2v_sign_xor = c2v_compact_msg_in[ROW_STATE_SIGN_XOR_BIT];

  always_comb begin
    c2v_compact_msg_next = c2v_compact_msg_in;
    c2v_compact_msg_next[ROW_STATE_SIGN_XOR_BIT] = c2v_sign_xor ^ v2c_sign;

    if (v2c_mag <= c2v_min1_mag) begin
      c2v_compact_msg_next[ROW_STATE_MIN2_LSB +: D] = c2v_min1_mag;
      c2v_compact_msg_next[ROW_STATE_MIN1_LSB +: D] = v2c_mag;
      c2v_compact_msg_next[ROW_STATE_MIN_ID_LSB +: VAR_W] = src_var_idx;
    end else if (v2c_mag < c2v_min2_mag) begin
      c2v_compact_msg_next[ROW_STATE_MIN2_LSB +: D] = v2c_mag;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      c2v_compact_msg_out <= ROW_STATE_INIT;
      v2c_sign_out <= 1'b0;
      out_valid <= 1'b0;
    end else if (clear_en) begin
      c2v_compact_msg_out <= ROW_STATE_INIT;
      v2c_sign_out <= 1'b0;
      out_valid <= 1'b0;
    end else begin
      out_valid <= in_valid;
      if (in_valid) begin
        c2v_compact_msg_out <= c2v_compact_msg_next;
        v2c_sign_out <= v2c_sign;
      end
    end
  end
endmodule
