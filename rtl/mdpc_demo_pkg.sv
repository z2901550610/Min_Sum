package mdpc_demo_pkg;
  parameter int N0 = 2;
  parameter int R = 8;
  parameter int W = 3;
  parameter int N = N0 * R;
  parameter int L = 2;
  parameter int D = 4;
  parameter int I_MAX = 4;
  parameter int C_VAL = 9;
  parameter int ALPHA_FRAC_W = 6;
  parameter int ALPHA_SHIFT_0 = 4;
  parameter int ALPHA_SHIFT_1 = 5;
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
  localparam int ROW_STATE_W = ROW_STATE_SIGN_XOR_BIT + 1;
  localparam logic [ROW_STATE_W-1:0] ROW_STATE_INIT = {
    1'b0,
    VAR_W'(0),
    D'(MAG_MAX),
    D'(MAG_MAX)
  };

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
endpackage
