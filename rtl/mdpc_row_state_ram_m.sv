module mdpc_row_state_ram_m (
  input  logic clk,
  input  logic rst_n,
  input  logic clear_en,
  input  logic [ROW_W-1:0] rd_addr_a0,
  input  logic [ROW_W-1:0] rd_addr_a1,
  input  logic [ROW_W-1:0] rd_addr_b0,
  input  logic [ROW_W-1:0] rd_addr_b1,
  output logic [ROW_STATE_W-1:0] rd_data_a0,
  output logic [ROW_STATE_W-1:0] rd_data_a1,
  output logic [ROW_STATE_W-1:0] rd_data_b0,
  output logic [ROW_STATE_W-1:0] rd_data_b1,
  input  logic wr_en0,
  input  logic [ROW_W-1:0] wr_addr0,
  input  logic [ROW_STATE_W-1:0] wr_data0,
  input  logic wr_en1,
  input  logic [ROW_W-1:0] wr_addr1,
  input  logic [ROW_STATE_W-1:0] wr_data1
);

  import mdpc_demo_pkg::*;

  logic [ROW_STATE_W-1:0] mem [0:R-1];
  integer row_idx;

  assign rd_data_a0 = mem[rd_addr_a0];
  assign rd_data_a1 = mem[rd_addr_a1];
  assign rd_data_b0 = mem[rd_addr_b0];
  assign rd_data_b1 = mem[rd_addr_b1];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (row_idx = 0; row_idx < R; row_idx++) begin
        mem[row_idx] <= ROW_STATE_INIT;
      end
    end else if (clear_en) begin
      for (row_idx = 0; row_idx < R; row_idx++) begin
        mem[row_idx] <= ROW_STATE_INIT;
      end
    end else begin
      if (wr_en0) begin
        mem[wr_addr0] <= wr_data0;
      end
      if (wr_en1) begin
        mem[wr_addr1] <= wr_data1;
      end
    end
  end
endmodule
