`timescale 1ns / 1ps

// Persistent t1/t2/r1 word storage for one H1/H2/H3 transaction.
// The vector stream is byte-ordered and each bank has an independent
// synchronous read port so KeyGen may read t1 and r1 in the same cycle.
module trike_h123_vector_store #(
    parameter int R_BITS = 15581,
    parameter int WORD_W = 64,
    parameter int WORD_ADDR_W = ((((R_BITS + WORD_W - 1) / WORD_W) > 1) ? $clog2(
        (R_BITS + WORD_W - 1) / WORD_W
    ) : 1)
) (
    input  logic                                                                 i_clk,
    input  logic                                                                 i_rst_n,
    input  logic                                                                 i_vector_valid,
    input  logic [                                                          1:0] i_vector_select,
    input  logic [((((R_BITS + 7) / 8) > 1) ? $clog2((R_BITS + 7) / 8) : 1)-1:0] i_vector_byte,
    input  logic [                                                          7:0] i_vector_data,
    output logic                                                                 o_vector_ready,
    input  logic                                                                 i_t1_re,
    input  logic [                                              WORD_ADDR_W-1:0] i_t1_raddr,
    output logic [                                                   WORD_W-1:0] o_t1_rdata,
    input  logic                                                                 i_t2_re,
    input  logic [                                              WORD_ADDR_W-1:0] i_t2_raddr,
    output logic [                                                   WORD_W-1:0] o_t2_rdata,
    input  logic                                                                 i_r1_re,
    input  logic [                                              WORD_ADDR_W-1:0] i_r1_raddr,
    output logic [                                                   WORD_W-1:0] o_r1_rdata
);

  localparam int R_BYTES = (R_BITS + 7) / 8;
  localparam int WORDS = (R_BITS + WORD_W - 1) / WORD_W;
  localparam int WORD_BYTES = WORD_W / 8;

  logic [     WORD_W-1:0] vector_pack_q;
  logic [     WORD_W-1:0] vector_word_c;
  logic                   vector_word_end_c;
  logic                   t1_we;
  logic                   t2_we;
  logic                   r1_we;
  logic [WORD_ADDR_W-1:0] vector_waddr;

  assign o_vector_ready = 1'b1;

  always_comb begin
    vector_word_c = ((int'(i_vector_byte) % WORD_BYTES) == 0) ? '0 : vector_pack_q;
    vector_word_c[8*(int'(i_vector_byte)%WORD_BYTES)+:8] = i_vector_data;
    vector_word_end_c = ((int'(i_vector_byte) % WORD_BYTES) == (WORD_BYTES - 1)) ||
                        (int'(i_vector_byte) == (R_BYTES - 1));
    vector_waddr = WORD_ADDR_W'(int'(i_vector_byte) / WORD_BYTES);
    t1_we = i_vector_valid && o_vector_ready && vector_word_end_c && (i_vector_select == 2'd0);
    t2_we = i_vector_valid && o_vector_ready && vector_word_end_c && (i_vector_select == 2'd1);
    r1_we = i_vector_valid && o_vector_ready && vector_word_end_c && (i_vector_select == 2'd2);
  end

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (WORDS)
  ) u_t1_mem (
      .i_clk  (i_clk),
      .i_we   (t1_we),
      .i_waddr(vector_waddr),
      .i_wdata(vector_word_c),
      .i_re   (i_t1_re),
      .i_raddr(i_t1_raddr),
      .o_rdata(o_t1_rdata)
  );

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (WORDS)
  ) u_t2_mem (
      .i_clk  (i_clk),
      .i_we   (t2_we),
      .i_waddr(vector_waddr),
      .i_wdata(vector_word_c),
      .i_re   (i_t2_re),
      .i_raddr(i_t2_raddr),
      .o_rdata(o_t2_rdata)
  );

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (WORDS)
  ) u_r1_mem (
      .i_clk  (i_clk),
      .i_we   (r1_we),
      .i_waddr(vector_waddr),
      .i_wdata(vector_word_c),
      .i_re   (i_r1_re),
      .i_raddr(i_r1_raddr),
      .o_rdata(o_r1_rdata)
  );

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      vector_pack_q <= '0;
    end else if (i_vector_valid && o_vector_ready) begin
      vector_pack_q <= vector_word_c;
    end
  end

`ifndef SYNTHESIS
  initial begin
    if ((WORD_W < 8) || ((WORD_W % 8) != 0))
      $error("trike_h123_vector_store WORD_W must be a positive byte multiple");
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
    end else if (i_vector_valid) begin
      if (i_vector_select > 2'd2) $error("trike_h123_vector_store vector select invalid");
      if (int'(i_vector_byte) >= R_BYTES)
        $error("trike_h123_vector_store vector byte out of range");
    end
  end
`endif

endmodule
