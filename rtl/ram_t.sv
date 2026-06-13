`timescale 1ns / 1ps
// RAM T: double-buffered raw C2V tile cache.
module ram_t
  import bike_pkg::*;
(
    input  logic                        i_clk,
    input  logic                        i_fill_buf,
    input  logic                        i_c2v_write_valid[0:L-1],
    input  logic        [ONE_IDX_W-1:0] i_c2v_write_one_idx,
    input  logic        [  Q_SEQ_W-1:0] i_c2v_write_q_seq,
    input  logic signed [    ACC_W-1:0] i_c2v_write_data[0:L-1],
    input  logic                        i_active_buf,
    input  logic                        i_v2c_valid[0:L-1],
    input  logic        [ONE_IDX_W-1:0] i_v2c_one_idx,
    input  logic        [  Q_SEQ_W-1:0] i_v2c_q_seq,
    output logic signed [    ACC_W-1:0] o_v2c_rdata[0:L-1]
);

  localparam int T_DEPTH = W * Q_TILE;
  localparam int T_ADDR_W = (T_DEPTH > 1) ? $clog2(T_DEPTH) : 1;

  logic signed [ACC_W-1:0] bank_rdata[0:1][0:L-1];

  function automatic logic [T_ADDR_W-1:0] t_addr(input  logic [ONE_IDX_W-1:0] one_idx,
                                                 input  logic [Q_SEQ_W-1:0] q_seq);
    begin
      t_addr = T_ADDR_W'((int'(one_idx) * Q_TILE) + int'(q_seq));
    end
  endfunction

  generate
    for (genvar buf_idx = 0; buf_idx < 2; buf_idx++) begin : g_buf
      for (genvar lane_idx = 0; lane_idx < L; lane_idx++) begin : g_lane
        (* ram_style = "block" *) logic signed [   ACC_W-1:0] mem[0:T_DEPTH-1];
        logic                       bank_re;
        logic        [T_ADDR_W-1:0] bank_raddr;
        logic                       bank_we;
        logic        [T_ADDR_W-1:0] bank_waddr;

        always_comb begin
          bank_re = i_v2c_valid[lane_idx] && (int'(i_active_buf) == buf_idx);
          bank_raddr = t_addr(i_v2c_one_idx, i_v2c_q_seq);
          bank_we = i_c2v_write_valid[lane_idx] && (int'(i_fill_buf) == buf_idx);
          bank_waddr = t_addr(i_c2v_write_one_idx, i_c2v_write_q_seq);
        end

        always_ff @(posedge i_clk) begin
          bank_rdata[buf_idx][lane_idx] <= bank_re ? mem[bank_raddr] : '0;
          if (bank_we) begin
            mem[bank_waddr] <= i_c2v_write_data[lane_idx];
          end
        end
      end
    end
  endgenerate

  always_comb begin
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      o_v2c_rdata[lane_idx] = bank_rdata[int'(i_active_buf)][lane_idx];
    end
  end
endmodule
