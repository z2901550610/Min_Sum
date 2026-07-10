`timescale 1ns / 1ps
// Parameterized common-clock simple dual-port block memory.
module ram_bram #(
    parameter int DATA_W = 18,
    parameter int DEPTH  = 1024,
    parameter int ADDR_W = (DEPTH > 1) ? $clog2(DEPTH) : 1
) (
    input  logic              i_clk,
    input  logic              i_we,
    input  logic [ADDR_W-1:0] i_waddr,
    input  logic [DATA_W-1:0] i_wdata,
    input  logic              i_re,
    input  logic [ADDR_W-1:0] i_raddr,
    output logic [DATA_W-1:0] o_rdata
);

`ifdef SYNTHESIS
  xpm_memory_sdpram #(
      .ADDR_WIDTH_A(ADDR_W),
      .ADDR_WIDTH_B(ADDR_W),
      .AUTO_SLEEP_TIME(0),
      .BYTE_WRITE_WIDTH_A(DATA_W),
      .CLOCKING_MODE("common_clock"),
      .ECC_MODE("no_ecc"),
      .MEMORY_INIT_FILE("none"),
      .MEMORY_INIT_PARAM("0"),
      .MEMORY_OPTIMIZATION("true"),
      .MEMORY_PRIMITIVE("block"),
      .MEMORY_SIZE(DEPTH * DATA_W),
      .MESSAGE_CONTROL(0),
      .READ_DATA_WIDTH_B(DATA_W),
      .READ_LATENCY_B(1),
      .READ_RESET_VALUE_B("0"),
      .RST_MODE_A("SYNC"),
      .RST_MODE_B("SYNC"),
      .USE_EMBEDDED_CONSTRAINT(0),
      .USE_MEM_INIT(0),
      .WAKEUP_TIME("disable_sleep"),
      .WRITE_DATA_WIDTH_A(DATA_W),
      .WRITE_MODE_B("read_first")
  ) u_mem (
      .dbiterrb(),
      .doutb(o_rdata),
      .sbiterrb(),
      .addra(i_waddr),
      .addrb(i_raddr),
      .clka(i_clk),
      .clkb(i_clk),
      .dina(i_wdata),
      .ena(i_we),
      .enb(i_re),
      .injectdbiterra(1'b0),
      .injectsbiterra(1'b0),
      .regceb(1'b1),
      .rstb(1'b0),
      .sleep(1'b0),
      .wea(i_we)
  );
`else
  logic [DATA_W-1:0] mem[0:DEPTH-1];

  always_ff @(posedge i_clk) begin
    if (i_re) begin
      o_rdata <= mem[i_raddr];
    end
    if (i_we) begin
      mem[i_waddr] <= i_wdata;
    end
  end
`endif

endmodule
