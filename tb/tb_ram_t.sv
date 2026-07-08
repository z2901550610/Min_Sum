`timescale 1ns / 1ps

module tb_ram_t;
  import bike_pkg::*;

  logic                               clk;
  logic                               fill_buf;
  logic                               c2v_write_valid[0:L-1];
  logic        [      DIAG_IDX_W-1:0] c2v_write_diag_idx_local;
  logic        [LANE_GROUP_IDX_W-1:0] c2v_write_lane_group_idx;
  logic signed [           MSG_W-1:0] c2v_tc[0:L-1];
  logic                               active_buf;
  logic                               v2c_valid[0:L-1];
  logic        [      DIAG_IDX_W-1:0] v2c_diag_idx_local;
  logic        [LANE_GROUP_IDX_W-1:0] v2c_lane_group_idx;
  logic signed [           MSG_W-1:0] c2v_edge[0:L-1];

  ram_t dut (
      .i_clk(clk),
      .i_fill_buf(fill_buf),
      .i_c2v_write_valid(c2v_write_valid),
      .i_c2v_write_diag_idx_local(c2v_write_diag_idx_local),
      .i_c2v_write_lane_group_idx(c2v_write_lane_group_idx),
      .i_c2v_tc(c2v_tc),
      .i_active_buf(active_buf),
      .i_v2c_valid(v2c_valid),
      .i_v2c_diag_idx_local(v2c_diag_idx_local),
      .i_v2c_lane_group_idx(v2c_lane_group_idx),
      .o_c2v_edge(c2v_edge)
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
      c2v_write_diag_idx_local = '0;
      c2v_write_lane_group_idx = '0;
      v2c_diag_idx_local = '0;
      v2c_lane_group_idx = '0;
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        c2v_write_valid[lane_idx] = 1'b0;
        c2v_tc[lane_idx] = '0;
        v2c_valid[lane_idx] = 1'b0;
      end
    end
  endtask

  function automatic logic signed [MSG_W-1:0] test_tc(input int lane_idx, input int base_mag);
    logic [D-1:0] mag;
    begin
      mag = D'((base_mag + lane_idx) & MAG_MAX);
      test_tc = ((lane_idx & 1) != 0) && (mag != '0) ? -$signed({1'b0, mag}) : $signed({1'b0, mag});
    end
  endfunction

  task automatic read_expect(input  logic buf_sel, input int base_mag);
    begin
      active_buf = buf_sel;
      v2c_diag_idx_local = DIAG_IDX_W'(1);
      v2c_lane_group_idx = '0;
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        v2c_valid[lane_idx] = 1'b1;
      end
      @(posedge clk);
      #1;
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        if (c2v_edge[lane_idx] !== test_tc(lane_idx, base_mag)) begin
          $fatal(1, "read mismatch lane=%0d", lane_idx);
        end
      end
    end
  endtask

  initial begin
    clear_inputs();

    fill_buf = 1'b0;
    c2v_write_diag_idx_local = DIAG_IDX_W'(1);
    c2v_write_lane_group_idx = '0;
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      c2v_write_valid[lane_idx] = 1'b1;
      c2v_tc[lane_idx]          = test_tc(lane_idx, 3);
    end
    @(posedge clk);
    #1;
    clear_inputs();
    read_expect(1'b0, 3);

    clear_inputs();
    fill_buf = 1'b1;
    c2v_write_diag_idx_local = DIAG_IDX_W'(1);
    c2v_write_lane_group_idx = '0;
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      c2v_write_valid[lane_idx] = 1'b1;
      c2v_tc[lane_idx]          = test_tc(lane_idx, 9);
    end
    @(posedge clk);
    #1;
    clear_inputs();
    read_expect(1'b1, 9);

    $display("tb_ram_t PASS");
    $finish;
  end
endmodule
