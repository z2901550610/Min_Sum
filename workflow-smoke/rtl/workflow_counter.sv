module workflow_counter #(
    parameter int unsigned WIDTH = 4
) (
    input  logic                 i_clk,
    input  logic                 i_rst_n,
    input  logic                 i_enable,
    input  logic                 i_load,
    input  logic [WIDTH - 1 : 0] i_load_value,
    output logic [WIDTH - 1 : 0] o_count,
    output logic                 o_wrap
);

  typedef enum logic {
    COUNT_HOLD,
    COUNT_STEP
  } count_action_t;

  count_action_t count_action;

  always_comb begin
    count_action = COUNT_HOLD;
    if (i_enable) begin
      count_action = COUNT_STEP;
    end
  end

  always_ff @(posedge i_clk) begin
    if (!i_rst_n) begin
      o_count <= '0;
      o_wrap  <= 1'b0;
    end else if (i_load) begin
      o_count <= i_load_value;
      o_wrap  <= 1'b0;
    end else begin
      o_wrap <= 1'b0;
      unique case (count_action)
        COUNT_HOLD: o_count <= o_count;
        COUNT_STEP: begin
          o_count <= o_count + 1'b1;
          o_wrap  <= &o_count;
        end
        default: begin
          o_count <= '0;
          o_wrap  <= 1'b0;
        end
      endcase
    end
  end

endmodule
