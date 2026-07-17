`timescale 1ns / 1ps

module tb_ram_syndrome;
  import bike_pkg::*;

  logic                   clk;
  logic                   rst_n;
  logic                   we;
  logic [  ROW_IDX_W-1:0] wr_addr;
  logic                   wr_data;
  logic                   rd_valid[0:L-1];
  logic [ROW_BANK_AW-1:0] rd_row_addr[0:L-1];
  logic                   rd_data[0:L-1];

  ram_syndrome dut (
      .i_clk        (clk),
      .i_rst_n      (rst_n),
      .i_we         (we),
      .i_wr_addr    (wr_addr),
      .i_wr_data    (wr_data),
      .i_rd_valid   (rd_valid),
      .i_rd_row_addr(rd_row_addr),
      .o_rd_data    (rd_data)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    #10000;
    $fatal(1, "tb_ram_syndrome timeout");
  end

  task automatic clear_inputs;
    begin
      we = 1'b0;
      wr_addr = '0;
      wr_data = 1'b0;
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        rd_valid[lane_idx] = 1'b0;
        rd_row_addr[lane_idx] = '0;
      end
    end
  endtask

  function automatic logic [LANE_IDX_W-1:0] row_bank_of(input  logic [ROW_IDX_W-1:0] row_idx);
    row_bank_of = LANE_IDX_W'(int'(row_idx) & (L - 1));
  endfunction

  function automatic logic [ROW_BANK_AW-1:0] row_addr_of(input  logic [ROW_IDX_W-1:0] row_idx);
    row_addr_of = ROW_BANK_AW'(row_idx >> L_SHIFT);
  endfunction

  initial begin
    logic [  ROW_IDX_W-1:0] test_addr;
    logic [ LANE_IDX_W-1:0] bank;
    logic [ROW_BANK_AW-1:0] local_addr;

    clear_inputs();
    rst_n = 1'b0;
    repeat (2) @(negedge clk);
    rst_n = 1'b1;

    // Write value 1 to address 5.
    test_addr = ROW_IDX_W'(5);
    bank = row_bank_of(test_addr);
    local_addr = row_addr_of(test_addr);

    @(negedge clk);
    we = 1'b1;
    wr_addr = test_addr;
    wr_data = 1'b1;
    @(negedge clk);
    clear_inputs();

    // Read back: assert valid for the target bank, check data.
    rd_valid[bank] = 1'b1;
    rd_row_addr[bank] = local_addr;
    @(posedge clk);
    #1;
    if (rd_data[bank] !== 1'b1) begin
      $fatal(1, "syndrome write/read mismatch: expected 1 at addr %0d", test_addr);
    end

    // Other banks should read 0.
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      if (lane_idx != int'(bank)) begin
        rd_valid[lane_idx] = 1'b1;
        rd_row_addr[lane_idx] = '0;
      end
    end
    @(posedge clk);
    #1;
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      if (lane_idx != int'(bank)) begin
        if (rd_data[lane_idx] !== 1'b0) begin
          $fatal(1, "syndrome bank %0d unexpected data", lane_idx);
        end
      end
    end
    clear_inputs();

    // When valid is deasserted, output should be 0.
    @(posedge clk);
    #1;
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      if (rd_data[lane_idx] !== 1'b0) begin
        $fatal(1, "syndrome read non-zero when valid deasserted");
      end
    end

    $display("tb_ram_syndrome PASS");
    $finish;
  end
endmodule
