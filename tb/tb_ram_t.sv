`timescale 1ns / 1ps

module tb_ram_t;
  import bike_pkg::*;

  logic                        clk;
  logic                        fill_buf;
  logic                        c2v_write_valid[0:L-1];
  logic        [ONE_IDX_W-1:0] c2v_write_one_idx;
  logic        [  Q_SEQ_W-1:0] c2v_write_q_seq;
  logic signed [    ACC_W-1:0] c2v_write_data[0:L-1];
  logic                        active_buf;
  logic                        v2c_valid[0:L-1];
  logic        [ONE_IDX_W-1:0] v2c_one_idx;
  logic        [  Q_SEQ_W-1:0] v2c_q_seq;
  logic signed [    ACC_W-1:0] v2c_rdata[0:L-1];

  ram_t dut (
      .i_clk(clk),
      .i_fill_buf(fill_buf),
      .i_c2v_write_valid(c2v_write_valid),
      .i_c2v_write_one_idx(c2v_write_one_idx),
      .i_c2v_write_q_seq(c2v_write_q_seq),
      .i_c2v_write_data(c2v_write_data),
      .i_active_buf(active_buf),
      .i_v2c_valid(v2c_valid),
      .i_v2c_one_idx(v2c_one_idx),
      .i_v2c_q_seq(v2c_q_seq),
      .o_v2c_rdata(v2c_rdata)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    #10000;
    $fatal(1, "tb_ram_t timeout");
  end

  task automatic clear_inputs;
    begin
      fill_buf = 1'b0;
      active_buf = 1'b0;
      c2v_write_one_idx = '0;
      c2v_write_q_seq = '0;
      v2c_one_idx = '0;
      v2c_q_seq = '0;
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        c2v_write_valid[lane_idx] = 1'b0;
        c2v_write_data[lane_idx] = '0;
        v2c_valid[lane_idx] = 1'b0;
      end
    end
  endtask

  task automatic read_expect(input  logic buf_sel, input  logic signed [ACC_W-1:0] base_value);
    begin
      active_buf  = buf_sel;
      v2c_one_idx = ONE_IDX_W'(1);
      v2c_q_seq   = '0;
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        v2c_valid[lane_idx] = 1'b1;
      end
      @(posedge clk);
      #1;
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        if (v2c_rdata[lane_idx] !== (base_value + ACC_W'(lane_idx))) begin
          $fatal(1, "read mismatch lane=%0d", lane_idx);
        end
      end
    end
  endtask

  initial begin
    clear_inputs();

    fill_buf = 1'b0;
    c2v_write_one_idx = ONE_IDX_W'(1);
    c2v_write_q_seq = '0;
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      c2v_write_valid[lane_idx] = 1'b1;
      c2v_write_data[lane_idx]  = ACC_W'(3 + lane_idx);
    end
    @(posedge clk);
    #1;
    clear_inputs();
    read_expect(1'b0, ACC_W'(3));

    clear_inputs();
    fill_buf = 1'b1;
    c2v_write_one_idx = ONE_IDX_W'(1);
    c2v_write_q_seq = '0;
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      c2v_write_valid[lane_idx] = 1'b1;
      c2v_write_data[lane_idx]  = ACC_W'(9 + lane_idx);
    end
    @(posedge clk);
    #1;
    clear_inputs();
    read_expect(1'b1, ACC_W'(9));

    $display("tb_ram_t PASS");
    $finish;
  end
endmodule
