`timescale 1ns / 1ps

module tb_ram_t_accum;
  import bike_pkg::*;

  logic                         clk;
  logic                         c2v_read_buf;
  logic                         c2v_read_valid[0:L-1];
  logic        [TILE_OFF_W-1:0] c2v_read_tile_offset[0:L-1];
  logic signed [     ACC_W-1:0] c2v_rdata[0:L-1];
  logic                         c2v_write_buf;
  logic                         c2v_write_valid[0:L-1];
  logic        [TILE_OFF_W-1:0] c2v_write_tile_offset[0:L-1];
  logic signed [     ACC_W-1:0] c2v_wdata[0:L-1];
  logic                         active_buf;
  logic                         v2c_valid[0:L-1];
  logic        [TILE_OFF_W-1:0] v2c_tile_offset[0:L-1];
  logic signed [     ACC_W-1:0] v2c_rdata[0:L-1];

  ram_t_accum dut (
      .i_clk(clk),
      .i_c2v_read_buf(c2v_read_buf),
      .i_c2v_read_valid(c2v_read_valid),
      .i_c2v_read_tile_offset(c2v_read_tile_offset),
      .o_c2v_rdata(c2v_rdata),
      .i_c2v_write_buf(c2v_write_buf),
      .i_c2v_write_valid(c2v_write_valid),
      .i_c2v_write_tile_offset(c2v_write_tile_offset),
      .i_c2v_wdata(c2v_wdata),
      .i_active_buf(active_buf),
      .i_v2c_valid(v2c_valid),
      .i_v2c_tile_offset(v2c_tile_offset),
      .o_v2c_rdata(v2c_rdata)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    #10000;
    $fatal(1, "tb_ram_t_accum timeout");
  end

  task automatic clear_inputs;
    begin
      c2v_read_buf = 1'b0;
      c2v_write_buf = 1'b0;
      active_buf = 1'b0;
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        c2v_read_valid[lane_idx] = 1'b0;
        c2v_read_tile_offset[lane_idx] = TILE_OFF_W'(lane_idx);
        c2v_write_valid[lane_idx] = 1'b0;
        c2v_write_tile_offset[lane_idx] = TILE_OFF_W'(lane_idx);
        c2v_wdata[lane_idx] = '0;
        v2c_valid[lane_idx] = 1'b0;
        v2c_tile_offset[lane_idx] = TILE_OFF_W'(lane_idx);
      end
    end
  endtask

  task automatic expect_buf(input  logic buf_sel, input  logic signed [ACC_W-1:0] base_value);
    begin
      c2v_read_buf = buf_sel;
      active_buf   = buf_sel;
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        c2v_read_valid[lane_idx] = 1'b1;
        c2v_read_tile_offset[lane_idx] = TILE_OFF_W'(lane_idx);
        v2c_valid[lane_idx] = 1'b1;
        v2c_tile_offset[lane_idx] = TILE_OFF_W'(lane_idx);
      end
      #1;
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        if (c2v_rdata[lane_idx] !== (base_value + ACC_W'(lane_idx))) begin
          $fatal(1, "c2v read mismatch lane=%0d", lane_idx);
        end
        if (v2c_rdata[lane_idx] !== (base_value + ACC_W'(lane_idx))) begin
          $fatal(1, "v2c read mismatch lane=%0d", lane_idx);
        end
      end
    end
  endtask

  initial begin
    clear_inputs();

    c2v_write_buf = 1'b0;
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      c2v_write_valid[lane_idx] = 1'b1;
      c2v_write_tile_offset[lane_idx] = TILE_OFF_W'(lane_idx);
      c2v_wdata[lane_idx] = ACC_W'(4 + lane_idx);
    end
    @(posedge clk);
    #1;
    clear_inputs();
    expect_buf(1'b0, ACC_W'(4));

    clear_inputs();
    c2v_write_buf = 1'b1;
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      c2v_write_valid[lane_idx] = 1'b1;
      c2v_write_tile_offset[lane_idx] = TILE_OFF_W'(lane_idx);
      c2v_wdata[lane_idx] = ACC_W'(12 + lane_idx);
    end
    @(posedge clk);
    #1;
    clear_inputs();
    expect_buf(1'b1, ACC_W'(12));

    $display("tb_ram_t_accum PASS");
    $finish;
  end
endmodule
