`timescale 1ns / 1ps
// Asynchronous assert, synchronous deassert reset synchronizer.
module reset_sync (
    input  logic i_clk,
    input  logic i_rst_n,
    output logic o_rst_n
);

  (* ASYNC_REG = "TRUE" *) logic rst_meta_n;
  (* ASYNC_REG = "TRUE" *) logic rst_sync_n;

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      rst_meta_n <= 1'b0;
      rst_sync_n <= 1'b0;
    end else begin
      rst_meta_n <= 1'b1;
      rst_sync_n <= rst_meta_n;
    end
  end

  assign o_rst_n = rst_sync_n;
endmodule
