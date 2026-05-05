`timescale 1ns/1ps
// RAM T — streams cached c2v messages for one processing group.
module ram_t
  import bike_pkg::*;
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_push,
  input  logic i_pop,
  input  logic [MSG_W-1:0] i_wdata,
  output logic [MSG_W-1:0] o_rdata,
  output logic [MSG_W-1:0] o_debug_mem [0:W-1]
);

  logic [MSG_W-1:0] mem [0:W-1];
  logic [ONE_IDX_W-1:0] read_ptr;
  logic [ONE_IDX_W-1:0] write_ptr;
  logic [GROUP_COUNT_W-1:0] item_count;

  function automatic logic [ONE_IDX_W-1:0] ptr_next(
    input logic [ONE_IDX_W-1:0] ptr
  );
    begin
      if (int'(ptr) == (W - 1)) begin
        ptr_next = '0;
      end else begin
        ptr_next = ptr + ONE_IDX_W'(1);
      end
    end
  endfunction

  assign o_debug_mem = mem;
  assign o_rdata = mem[read_ptr];

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      read_ptr <= '0;
      write_ptr <= '0;
      item_count <= '0;
      for (int entry_pos = 0; entry_pos < W; entry_pos++) begin
        mem[entry_pos] <= '0;
      end
    end else begin
      if (i_push) begin
        mem[write_ptr] <= i_wdata;
        write_ptr <= ptr_next(write_ptr);
      end
      if (i_pop) begin
        read_ptr <= ptr_next(read_ptr);
      end
      case ({i_push, i_pop})
        2'b10: item_count <= item_count + GROUP_COUNT_W'(1);
        2'b01: item_count <= item_count - GROUP_COUNT_W'(1);
        default: item_count <= item_count;
      endcase
      if (!i_push && !i_pop && (item_count == '0)) begin
        read_ptr <= write_ptr;
      end
    end
  end
endmodule
