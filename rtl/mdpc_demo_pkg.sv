package mdpc_demo_pkg;
  parameter int N0 = 2;
  parameter int R = 8;
  parameter int W = 3;
  parameter int N = N0 * R;
  parameter int L = 2;
  parameter int D = 4;
  parameter int I_MAX = 4;
  parameter int C_VAL = 9;
  parameter int ALPHA_NUM = 3;
  parameter int ALPHA_SHIFT = 5;
  parameter int MAG_MAX = (1 << D) - 1;
  parameter int ROW_SPLIT = R / 2;
  parameter int APP_W = 8;
  parameter int VAR_W = 4;
  parameter int ROW_W = 3;
  parameter int EDGE_W = 2;
  localparam int DEC_STATE_W = 3;
  localparam logic [DEC_STATE_W-1:0] DEC_IDLE  = 3'd0;
  localparam logic [DEC_STATE_W-1:0] DEC_LOAD  = 3'd1;
  localparam logic [DEC_STATE_W-1:0] DEC_CNU_A = 3'd2;
  localparam logic [DEC_STATE_W-1:0] DEC_CNU_B = 3'd3;
  localparam logic [DEC_STATE_W-1:0] DEC_VNU   = 3'd4;
  localparam logic [DEC_STATE_W-1:0] DEC_CHECK = 3'd5;
  localparam logic [DEC_STATE_W-1:0] DEC_DONE  = 3'd6;

  localparam int MSG_W = D + 1;
  localparam int MSG_MAG_LSB = 0;
  localparam int MSG_SIGN_BIT = D;

  localparam int ROW_STATE_MIN1_LSB = 0;
  localparam int ROW_STATE_MIN2_LSB = ROW_STATE_MIN1_LSB + D;
  localparam int ROW_STATE_MIN_ID_LSB = ROW_STATE_MIN2_LSB + D;
  localparam int ROW_STATE_SIGN_XOR_BIT = ROW_STATE_MIN_ID_LSB + VAR_W;
  localparam int ROW_STATE_VALID_COUNT_LSB = ROW_STATE_SIGN_XOR_BIT + 1;
  localparam int ROW_STATE_W = ROW_STATE_VALID_COUNT_LSB + 2;

  localparam int LANE_EDGE_VALID_BIT = 0;
  localparam int LANE_EDGE_ROW_LOCAL_LSB = LANE_EDGE_VALID_BIT + 1;
  localparam int LANE_EDGE_ROW_GLOBAL_LSB = LANE_EDGE_ROW_LOCAL_LSB + ROW_W;
  localparam int LANE_EDGE_VAR_IDX_LSB = LANE_EDGE_ROW_GLOBAL_LSB + ROW_W;
  localparam int LANE_EDGE_EDGE_SLOT_LSB = LANE_EDGE_VAR_IDX_LSB + VAR_W;
  localparam int LANE_EDGE_W = LANE_EDGE_EDGE_SLOT_LSB + EDGE_W;
  localparam int I_ENTRY_ROW_LOCAL_LSB = 0;
  localparam int I_ENTRY_EDGE_SLOT_LSB = I_ENTRY_ROW_LOCAL_LSB + ROW_W;
  localparam int I_ENTRY_W = I_ENTRY_EDGE_SLOT_LSB + EDGE_W;

  localparam int unsigned H_BASE [0:N0-1][0:W-1] = '{
    '{0, 1, 3},
    '{0, 2, 5}
  };

  function automatic int clamp_int(input int value, input int lo, input int hi);
    if (value < lo) begin
      return lo;
    end
    if (value > hi) begin
      return hi;
    end
    return value;
  endfunction

  function automatic logic [D-1:0] mag_from_int(input int value);
    int clamped_value;
    logic [D-1:0] result;
    begin
      clamped_value = clamp_int(value, 0, MAG_MAX);
      result = clamped_value[D-1:0];
      return result;
    end
  endfunction

  function automatic logic [VAR_W-1:0] var_idx_from_int(input int value);
    begin
      return value[VAR_W-1:0];
    end
  endfunction

  function automatic logic msg_sign(input logic [MSG_W-1:0] msg);
    return msg[MSG_SIGN_BIT];
  endfunction

  function automatic logic [D-1:0] msg_mag(input logic [MSG_W-1:0] msg);
    return msg[MSG_MAG_LSB +: D];
  endfunction

  function automatic logic [MSG_W-1:0] msg_pack(
    input logic sign,
    input logic [D-1:0] mag
  );
    return {sign, mag};
  endfunction

  function automatic int msg_to_signed(input logic [MSG_W-1:0] msg);
    int mag_value;
    begin
      mag_value = int'(msg_mag(msg));
      if (msg_sign(msg)) begin
        return -mag_value;
      end
      return mag_value;
    end
  endfunction

  function automatic logic [MSG_W-1:0] msg_from_signed(input int value);
    logic [MSG_W-1:0] msg;
    int abs_value;
    begin
      abs_value = (value < 0) ? -value : value;
      msg = msg_pack((value < 0), mag_from_int(abs_value));
      return msg;
    end
  endfunction

  function automatic logic signed [APP_W-1:0] app_from_int(input int value);
    int app_value_int;
    logic signed [APP_W-1:0] result;
    begin
      app_value_int = value;
      result = app_value_int[APP_W-1:0];
      return result;
    end
  endfunction

  function automatic int gamma_from_bit(input logic bit_value);
    if (bit_value) begin
      return -C_VAL;
    end
    return C_VAL;
  endfunction

  function automatic int alpha_scale(input int value);
    int abs_value;
    int scaled_abs;
    begin
      abs_value = (value < 0) ? -value : value;
      scaled_abs = ((ALPHA_NUM * abs_value) + (1 << (ALPHA_SHIFT - 1))) >>> ALPHA_SHIFT;
      if (value < 0) begin
        return -scaled_abs;
      end
      return scaled_abs;
    end
  endfunction

  function automatic logic [ROW_STATE_W-1:0] row_state_pack(
    input logic [D-1:0] min1,
    input logic [D-1:0] min2,
    input logic [VAR_W-1:0] min_id,
    input logic sign_xor,
    input logic [1:0] valid_count
  );
    return {valid_count, sign_xor, min_id, min2, min1};
  endfunction

  function automatic logic [D-1:0] row_state_min1(input logic [ROW_STATE_W-1:0] state);
    return state[ROW_STATE_MIN1_LSB +: D];
  endfunction

  function automatic logic [D-1:0] row_state_min2(input logic [ROW_STATE_W-1:0] state);
    return state[ROW_STATE_MIN2_LSB +: D];
  endfunction

  function automatic logic [VAR_W-1:0] row_state_min_id(input logic [ROW_STATE_W-1:0] state);
    return state[ROW_STATE_MIN_ID_LSB +: VAR_W];
  endfunction

  function automatic logic row_state_sign_xor(input logic [ROW_STATE_W-1:0] state);
    return state[ROW_STATE_SIGN_XOR_BIT];
  endfunction

  function automatic logic [1:0] row_state_valid_count(input logic [ROW_STATE_W-1:0] state);
    return state[ROW_STATE_VALID_COUNT_LSB +: 2];
  endfunction

  function automatic logic [ROW_STATE_W-1:0] row_state_set_min1(
    input logic [ROW_STATE_W-1:0] state,
    input logic [D-1:0] min1
  );
    logic [ROW_STATE_W-1:0] next_state;
    begin
      next_state = state;
      next_state[ROW_STATE_MIN1_LSB +: D] = min1;
      return next_state;
    end
  endfunction

  function automatic logic [ROW_STATE_W-1:0] row_state_set_min2(
    input logic [ROW_STATE_W-1:0] state,
    input logic [D-1:0] min2
  );
    logic [ROW_STATE_W-1:0] next_state;
    begin
      next_state = state;
      next_state[ROW_STATE_MIN2_LSB +: D] = min2;
      return next_state;
    end
  endfunction

  function automatic logic [ROW_STATE_W-1:0] row_state_set_min_id(
    input logic [ROW_STATE_W-1:0] state,
    input logic [VAR_W-1:0] min_id
  );
    logic [ROW_STATE_W-1:0] next_state;
    begin
      next_state = state;
      next_state[ROW_STATE_MIN_ID_LSB +: VAR_W] = min_id;
      return next_state;
    end
  endfunction

  function automatic logic [ROW_STATE_W-1:0] row_state_set_sign_xor(
    input logic [ROW_STATE_W-1:0] state,
    input logic sign_xor
  );
    logic [ROW_STATE_W-1:0] next_state;
    begin
      next_state = state;
      next_state[ROW_STATE_SIGN_XOR_BIT] = sign_xor;
      return next_state;
    end
  endfunction

  function automatic logic [ROW_STATE_W-1:0] row_state_set_valid_count(
    input logic [ROW_STATE_W-1:0] state,
    input logic [1:0] valid_count
  );
    logic [ROW_STATE_W-1:0] next_state;
    begin
      next_state = state;
      next_state[ROW_STATE_VALID_COUNT_LSB +: 2] = valid_count;
      return next_state;
    end
  endfunction

  function automatic logic [ROW_STATE_W-1:0] row_state_init();
    begin
      return row_state_pack(
        mag_from_int(MAG_MAX),
        mag_from_int(MAG_MAX),
        '0,
        1'b0,
        2'd0
      );
    end
  endfunction

  function automatic logic [LANE_EDGE_W-1:0] lane_edge_pack(
    input logic valid,
    input logic [ROW_W-1:0] row_local,
    input logic [ROW_W-1:0] row_global,
    input logic [VAR_W-1:0] var_idx,
    input logic [EDGE_W-1:0] edge_slot
  );
    return {edge_slot, var_idx, row_global, row_local, valid};
  endfunction

  function automatic logic lane_edge_valid(input logic [LANE_EDGE_W-1:0] lane_edge);
    return lane_edge[LANE_EDGE_VALID_BIT];
  endfunction

  function automatic logic [ROW_W-1:0] lane_edge_row_local(input logic [LANE_EDGE_W-1:0] lane_edge);
    return lane_edge[LANE_EDGE_ROW_LOCAL_LSB +: ROW_W];
  endfunction

  function automatic logic [ROW_W-1:0] lane_edge_row_global(input logic [LANE_EDGE_W-1:0] lane_edge);
    return lane_edge[LANE_EDGE_ROW_GLOBAL_LSB +: ROW_W];
  endfunction

  function automatic logic [VAR_W-1:0] lane_edge_var_idx(input logic [LANE_EDGE_W-1:0] lane_edge);
    return lane_edge[LANE_EDGE_VAR_IDX_LSB +: VAR_W];
  endfunction

  function automatic logic [EDGE_W-1:0] lane_edge_edge_slot(input logic [LANE_EDGE_W-1:0] lane_edge);
    return lane_edge[LANE_EDGE_EDGE_SLOT_LSB +: EDGE_W];
  endfunction

  function automatic int row_segment(input int row_value);
    if (row_value < ROW_SPLIT) begin
      return 0;
    end
    return 1;
  endfunction

  function automatic logic [ROW_W-1:0] row_local_from_global(input int row_value);
    int local_value;
    begin
      if (row_value < ROW_SPLIT) begin
        local_value = row_value;
      end else begin
        local_value = row_value - ROW_SPLIT;
      end
      return local_value[ROW_W-1:0];
    end
  endfunction

  function automatic logic [ROW_W-1:0] row_global_from_lane_local(
    input int lane_idx,
    input logic [ROW_W-1:0] row_local
  );
    int row_value;
    begin
      if (lane_idx == 0) begin
        row_value = int'(row_local);
      end else begin
        row_value = ROW_SPLIT + int'(row_local);
      end
      return row_value[ROW_W-1:0];
    end
  endfunction

  function automatic logic [I_ENTRY_W-1:0] i_entry_pack(
    input logic [ROW_W-1:0] row_local,
    input logic [EDGE_W-1:0] edge_slot
  );
    return {edge_slot, row_local};
  endfunction

  function automatic logic [ROW_W-1:0] i_entry_row_local(input logic [I_ENTRY_W-1:0] i_entry);
    return i_entry[I_ENTRY_ROW_LOCAL_LSB +: ROW_W];
  endfunction

  function automatic logic [EDGE_W-1:0] i_entry_edge_slot(input logic [I_ENTRY_W-1:0] i_entry);
    return i_entry[I_ENTRY_EDGE_SLOT_LSB +: EDGE_W];
  endfunction

  function automatic int edge_row_global(
    input int bank,
    input int col,
    input int edge_slot
  );
    return (H_BASE[bank][edge_slot] + col) % R;
  endfunction

  function automatic logic [R-1:0] syndrome_vector(input logic [N-1:0] x_bits);
    logic [R-1:0] syndrome;
    logic parity;
    int row_idx;
    int var_idx;
    int bank;
    int col;
    int edge_idx;
    begin
      syndrome = '0;
      for (row_idx = 0; row_idx < R; row_idx++) begin
        parity = 1'b0;
        for (var_idx = 0; var_idx < N; var_idx++) begin
          bank = var_idx / R;
          col = var_idx % R;
          for (edge_idx = 0; edge_idx < W; edge_idx++) begin
            if (edge_row_global(bank, col, edge_idx) == row_idx) begin
              parity ^= x_bits[var_idx];
            end
          end
        end
        syndrome[row_idx] = parity;
      end
      return syndrome;
    end
  endfunction

  function automatic int syndrome_weight(input logic [R-1:0] syndrome);
    int idx;
    int weight;
    begin
      weight = 0;
      for (idx = 0; idx < R; idx++) begin
        weight += syndrome[idx];
      end
      return weight;
    end
  endfunction
endpackage
