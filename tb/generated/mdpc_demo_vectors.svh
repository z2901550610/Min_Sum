`ifndef MDPC_DEMO_VECTORS_SVH
`define MDPC_DEMO_VECTORS_SVH

localparam logic [15:0] CASE0_INPUT = 16'h0000;
localparam logic [15:0] CASE0_OUTPUT = 16'h0000;
localparam int CASE0_SUCCESS = 1;
localparam int CASE0_ITERATIONS = 1;
localparam int CASE0_SYNDROME_HIST [0:3] = '{0, 0, 0, 0};

localparam logic [15:0] CASE1_INPUT = 16'h0001;
localparam logic [15:0] CASE1_OUTPUT = 16'h0001;
localparam int CASE1_SUCCESS = 0;
localparam int CASE1_ITERATIONS = 4;
localparam int CASE1_IS_CONVERGED_VECTOR = 0;
localparam int CASE1_SYNDROME_HIST [0:3] = '{11, 11, 11, 11};
localparam int CASE1_FIRST_ROW_MIN1 [0:7] = '{9, 9, 9, 9, 9, 9, 9, 9};
localparam int CASE1_FIRST_ROW_MIN2 [0:7] = '{9, 9, 9, 9, 9, 9, 9, 9};
localparam int CASE1_FIRST_ROW_MIN_ID [0:7] = '{0, 0, 1, 0, 1, 2, 3, 4};
localparam int CASE1_FIRST_ROW_SIGN_XOR [0:7] = '{1, 1, 0, 1, 0, 0, 0, 0};
localparam int CASE1_FIRST_ROW_VALID_COUNT [0:7] = '{3, 3, 3, 3, 3, 3, 3, 3};
localparam int CASE1_FIRST_C2V_SIGN [0:47] = '{0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 1, 0};
localparam int CASE1_FIRST_C2V_MAG [0:47] = '{9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9};
localparam int CASE1_FIRST_U_SIGN [0:47] = '{1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
localparam int CASE1_FIRST_U_MAG [0:47] = '{7, 7, 7, 11, 9, 9, 9, 11, 9, 11, 9, 9, 11, 11, 11, 9, 9, 11, 9, 9, 11, 9, 11, 9, 11, 9, 9, 9, 9, 7, 11, 11, 11, 9, 7, 9, 9, 9, 11, 11, 11, 11, 7, 9, 9, 9, 11, 9};

`endif
