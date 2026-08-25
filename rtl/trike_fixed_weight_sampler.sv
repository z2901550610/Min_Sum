`timescale 1ns / 1ps

// Fixed-schedule TRIKE generate_random_idx implementation.
//
// Positions are processed from WEIGHT-1 down to zero. Each position consumes
// exactly one 32-bit random word and scans all WEIGHT stored indices. A match
// with an already selected index chooses the public current position, matching
// the Reference C without rejection sampling.
module trike_fixed_weight_sampler #(
    parameter int LENGTH           = 46743,
    parameter int WEIGHT           = 263,
    parameter bit RUNTIME_GEOMETRY = 1'b0
) (
    input  logic                                           i_clk,
    input  logic                                           i_rst_n,
    input  logic                                           i_start,
    input  logic [                                   31:0] i_runtime_length,
    input  logic [                                   31:0] i_runtime_weight,
    input  logic                                           i_random_valid,
    input  logic [                                   31:0] i_random_data,
    output logic                                           o_random_ready,
    output logic                                           o_index_valid,
    output logic [((WEIGHT > 1) ? $clog2(WEIGHT) : 1)-1:0] o_index_position,
    output logic [((LENGTH > 1) ? $clog2(LENGTH) : 1)-1:0] o_index,
    input  logic                                           i_index_ready,
    output logic                                           o_busy,
    output logic                                           o_done
);

  localparam int INDEX_W = (LENGTH > 1) ? $clog2(LENGTH) : 1;
  localparam int POSITION_W = (WEIGHT > 1) ? $clog2(WEIGHT) : 1;

  typedef enum logic [1:0] {
    ST_IDLE,
    ST_WAIT_RANDOM,
    ST_SCAN,
    ST_OUTPUT
  } state_t;

  state_t                  state_q;

  logic   [POSITION_W-1:0] position_q;
  logic   [POSITION_W-1:0] scan_issue_idx_q;
  logic   [POSITION_W-1:0] scan_read_idx_q;
  logic                    scan_read_valid_q;
  logic   [   INDEX_W-1:0] scan_read_data_q;
  logic   [   INDEX_W-1:0] candidate_q;
  logic   [   INDEX_W-1:0] candidate_value;
  logic                    duplicate_q;
  logic   [   INDEX_W-1:0] output_index_q;
  logic   [          31:0] active_length_q;
  logic   [POSITION_W-1:0] active_last_position_q;

  logic   [          31:0] position_32;
  logic                    duplicate_match;
  logic                    duplicate_with_match;
  logic                    index_mem_re;
  logic                    index_mem_we;
  logic   [   INDEX_W-1:0] index_mem_wdata;

  assign position_32 = {{(32 - POSITION_W) {1'b0}}, position_q};

  trike_sampler_candidate #(
      .OUTPUT_W(INDEX_W)
  ) u_candidate (
      .i_random(i_random_data),
      .i_position(position_32),
      .i_length(active_length_q),
      .o_candidate(candidate_value)
  );

  assign duplicate_match = scan_read_valid_q && (scan_read_idx_q > position_q) &&
                           (scan_read_data_q == candidate_q);
  assign duplicate_with_match = duplicate_q | duplicate_match;
  assign index_mem_we = (state_q == ST_SCAN) && scan_read_valid_q &&
                        (scan_read_idx_q == active_last_position_q);
  assign index_mem_re = (state_q == ST_SCAN) && !index_mem_we;
  assign index_mem_wdata = duplicate_with_match ? INDEX_W'(position_q) : candidate_q;

  assign o_random_ready = (state_q == ST_WAIT_RANDOM);
  assign o_index_valid = (state_q == ST_OUTPUT);
  assign o_index_position = position_q;
  assign o_index = output_index_q;
  assign o_busy = (state_q != ST_IDLE);

  ram_bram #(
      .DATA_W(INDEX_W),
      .DEPTH (WEIGHT),
      .ADDR_W(POSITION_W)
  ) u_index_mem (
      .i_clk  (i_clk),
      .i_we   (index_mem_we),
      .i_waddr(position_q),
      .i_wdata(index_mem_wdata),
      .i_re   (index_mem_re),
      .i_raddr(scan_issue_idx_q),
      .o_rdata(scan_read_data_q)
  );

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q                <= ST_IDLE;
      position_q             <= '0;
      scan_issue_idx_q       <= '0;
      scan_read_idx_q        <= '0;
      scan_read_valid_q      <= 1'b0;
      candidate_q            <= '0;
      duplicate_q            <= 1'b0;
      output_index_q         <= '0;
      active_length_q        <= 32'(LENGTH);
      active_last_position_q <= POSITION_W'(WEIGHT - 1);
      o_done                 <= 1'b0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            if (RUNTIME_GEOMETRY) begin
              active_length_q        <= i_runtime_length;
              active_last_position_q <= POSITION_W'(i_runtime_weight - 1'b1);
              position_q             <= POSITION_W'(i_runtime_weight - 1'b1);
            end else begin
              active_length_q        <= 32'(LENGTH);
              active_last_position_q <= POSITION_W'(WEIGHT - 1);
              position_q             <= POSITION_W'(WEIGHT - 1);
            end
            state_q <= ST_WAIT_RANDOM;
          end
        end

        ST_WAIT_RANDOM: begin
          if (i_random_valid) begin
            candidate_q       <= candidate_value;
            duplicate_q       <= 1'b0;
            scan_issue_idx_q  <= '0;
            scan_read_valid_q <= 1'b0;
            state_q           <= ST_SCAN;
          end
        end

        ST_SCAN: begin
          if (scan_read_valid_q) begin
            duplicate_q <= duplicate_with_match;
          end

          if (scan_read_valid_q && (scan_read_idx_q == active_last_position_q)) begin
            output_index_q    <= index_mem_wdata;
            scan_read_valid_q <= 1'b0;
            state_q           <= ST_OUTPUT;
          end else begin
            scan_read_idx_q   <= scan_issue_idx_q;
            scan_read_valid_q <= 1'b1;
            if (scan_issue_idx_q != active_last_position_q) begin
              scan_issue_idx_q <= scan_issue_idx_q + 1'b1;
            end
          end
        end

        ST_OUTPUT: begin
          if (i_index_ready) begin
            if (position_q == 0) begin
              o_done  <= 1'b1;
              state_q <= ST_IDLE;
            end else begin
              position_q <= position_q - 1'b1;
              state_q    <= ST_WAIT_RANDOM;
            end
          end
        end

        default: begin
          state_q <= ST_IDLE;
        end
      endcase
    end
  end

`ifndef SYNTHESIS
  initial begin
    if (LENGTH < 1) $error("trike_fixed_weight_sampler LENGTH must be at least 1");
    if (WEIGHT < 1) $error("trike_fixed_weight_sampler WEIGHT must be at least 1");
    if (WEIGHT > LENGTH) $error("trike_fixed_weight_sampler WEIGHT must not exceed LENGTH");
    if (POSITION_W > 32) $error("trike_fixed_weight_sampler WEIGHT width must fit 32 bits");
    if (INDEX_W > 32) $error("trike_fixed_weight_sampler LENGTH width must fit 32 bits");
  end

  always_ff @(posedge i_clk) begin
    if (i_rst_n && (state_q == ST_IDLE) && i_start && RUNTIME_GEOMETRY) begin
      if ((i_runtime_length < 1) || (i_runtime_length > LENGTH))
        $fatal(1, "trike_fixed_weight_sampler runtime length out of range");
      if ((i_runtime_weight < 1) || (i_runtime_weight > WEIGHT) ||
          (i_runtime_weight > i_runtime_length))
        $fatal(1, "trike_fixed_weight_sampler runtime weight out of range");
    end
  end
`endif

endmodule
