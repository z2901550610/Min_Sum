`timescale 1ns / 1ps

module tb_ram_sign_delta;
  import bike_pkg::*;

  localparam int TEST_ROW = 0;

  logic                   clk;
  logic                   rst_n;
  logic                   clear_valid;
  logic                   clear_pair_sel;
  logic [ROW_BANK_AW-1:0] clear_row_addr;
  logic                   read_pair_sel;
  logic                   read_valid[0:L-1];
  logic [ROW_BANK_AW-1:0] read_row_addr[0:L-1];
  logic                   read_delta[0:L-1];
  logic                   flip_pair_sel;
  logic                   flip_valid[0:L-1];
  logic [ROW_BANK_AW-1:0] flip_row_addr[0:L-1];

  ram_sign_delta dut (
      .i_clk(clk),
      .i_rst_n(rst_n),
      .i_clear_valid(clear_valid),
      .i_clear_pair_sel(clear_pair_sel),
      .i_clear_row_addr(clear_row_addr),
      .i_read_pair_sel(read_pair_sel),
      .i_read_valid(read_valid),
      .i_read_row_addr(read_row_addr),
      .o_read_delta(read_delta),
      .i_flip_pair_sel(flip_pair_sel),
      .i_flip_valid(flip_valid),
      .i_flip_row_addr(flip_row_addr)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  task automatic clear_pair(input  logic pair_sel);
    clear_pair_sel = pair_sel;
    clear_valid = 1'b1;
    for (int row = 0; row < ROW_SEG_SIZE; row++) begin
      clear_row_addr = ROW_BANK_AW'(row);
      @(posedge clk);
    end
    @(negedge clk);
    clear_valid = 1'b0;
  endtask

  task automatic read_bank0(input  logic pair_sel, input int row, input  logic expected);
    @(negedge clk);
    read_pair_sel = pair_sel;
    read_valid[0] = 1'b1;
    read_row_addr[0] = ROW_BANK_AW'(row);
    @(posedge clk);
    #1;
    if (read_delta[0] != expected) begin
      $fatal(1, "ram_sign_delta pair=%0d row=%0d expected=%0d got=%0d", pair_sel, row, expected,
             read_delta[0]);
    end
    @(negedge clk);
    read_valid[0] = 1'b0;
  endtask

  initial begin
    rst_n = 1'b0;
    clear_valid = 1'b0;
    clear_pair_sel = 1'b0;
    clear_row_addr = '0;
    read_pair_sel = 1'b0;
    flip_pair_sel = 1'b0;
    for (int bank = 0; bank < L; bank++) begin
      read_valid[bank] = 1'b0;
      read_row_addr[bank] = '0;
      flip_valid[bank] = 1'b0;
      flip_row_addr[bank] = '0;
    end

    repeat (2) @(posedge clk);
    @(negedge clk);
    rst_n = 1'b1;

    clear_pair(1'b0);
    clear_pair(1'b1);
    read_bank0(1'b0, TEST_ROW, 1'b0);
    read_bank0(1'b1, TEST_ROW, 1'b0);

    // One retained deviation toggles the selected check parity once.
    @(negedge clk);
    flip_pair_sel = 1'b0;
    flip_valid[0] = 1'b1;
    flip_row_addr[0] = ROW_BANK_AW'(TEST_ROW);
    @(negedge clk);
    flip_valid[0] = 1'b0;
    @(posedge clk);
    read_bank0(1'b0, TEST_ROW, 1'b1);

    // Back-to-back hits on one address cancel and exercise the RMW bypass.
    @(negedge clk);
    flip_valid[0] = 1'b1;
    repeat (2) @(negedge clk);
    flip_valid[0] = 1'b0;
    @(posedge clk);
    read_bank0(1'b0, TEST_ROW, 1'b1);

    // The read and write pairs are independent and may operate concurrently.
    @(negedge clk);
    read_pair_sel = 1'b0;
    read_valid[0] = 1'b1;
    read_row_addr[0] = ROW_BANK_AW'(TEST_ROW);
    flip_pair_sel = 1'b1;
    flip_valid[0] = 1'b1;
    flip_row_addr[0] = ROW_BANK_AW'(TEST_ROW);
    @(posedge clk);
    #1;
    if (read_delta[0] != 1'b1) $fatal(1, "ram_sign_delta concurrent read mismatch");
    @(negedge clk);
    read_valid[0] = 1'b0;
    flip_valid[0] = 1'b0;
    @(posedge clk);
    read_bank0(1'b1, TEST_ROW, 1'b1);

    $display("tb_ram_sign_delta PASS");
    $finish;
  end
endmodule
