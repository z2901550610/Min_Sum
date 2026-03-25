#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MDPC_N0 2
#define MDPC_R 8
#define MDPC_W 3
#define MDPC_N (MDPC_N0 * MDPC_R)
#define MDPC_L 2
#define MDPC_I_MAX 4
#define MDPC_C_VAL 9
#define MDPC_ALPHA_NUM 3
#define MDPC_ALPHA_SHIFT 5
#define MDPC_MAG_MAX 15
#define MDPC_ROW_SPLIT (MDPC_R / 2)

static const int H_BASE[MDPC_N0][MDPC_W] = {
    {0, 1, 3},
    {0, 2, 5},
};

typedef struct {
    int sign;
    int mag;
} msg_t;

typedef struct {
    int min1;
    int min2;
    int min_id;
    int sign_xor;
    int valid_count;
} row_state_t;

typedef struct {
    int valid;
    int row_local;
    int row_global;
    int var_idx;
    int edge_slot;
} lane_edge_t;

typedef struct {
    int reserved;
} mdpc_config_t;

typedef struct {
    uint16_t x_out_bits;
    int success;
    int iterations;
} mdpc_result_t;

typedef struct {
    row_state_t first_row_state[MDPC_R];
    msg_t first_c2v[MDPC_N][MDPC_W];
    msg_t first_u_next[MDPC_N][MDPC_W];
    int syndrome_hist[MDPC_I_MAX];
    int success;
    int iterations;
} mdpc_trace_t;

static int clamp_int(int value, int lo, int hi) {
    if (value < lo) {
        return lo;
    }
    if (value > hi) {
        return hi;
    }
    return value;
}

static msg_t msg_from_signed(int value) {
    msg_t msg;
    int abs_value = value < 0 ? -value : value;
    abs_value = clamp_int(abs_value, 0, MDPC_MAG_MAX);
    msg.sign = value < 0;
    msg.mag = abs_value;
    return msg;
}

static int msg_to_signed(msg_t msg) {
    return msg.sign ? -msg.mag : msg.mag;
}

static int gamma_from_bit(uint8_t bit_value) {
    return bit_value ? -MDPC_C_VAL : MDPC_C_VAL;
}

static int alpha_scale(int value) {
    int abs_value = value < 0 ? -value : value;
    int scaled_abs = ((MDPC_ALPHA_NUM * abs_value) + (1 << (MDPC_ALPHA_SHIFT - 1))) >> MDPC_ALPHA_SHIFT;
    return value < 0 ? -scaled_abs : scaled_abs;
}

static row_state_t row_state_init(void) {
    row_state_t state;
    state.min1 = MDPC_MAG_MAX;
    state.min2 = MDPC_MAG_MAX;
    state.min_id = 0;
    state.sign_xor = 0;
    state.valid_count = 0;
    return state;
}

static int edge_row_global(int bank, int col, int edge_slot) {
    return (H_BASE[bank][edge_slot] + col) % MDPC_R;
}

static uint16_t pack_bits(const uint8_t bits[MDPC_N]) {
    int idx;
    uint16_t packed = 0;
    for (idx = 0; idx < MDPC_N; ++idx) {
        packed |= ((uint16_t)(bits[idx] & 1u) << idx);
    }
    return packed;
}

static uint8_t syndrome_vector_bits(const uint8_t x_bits[MDPC_N]) {
    int row_idx;
    int var_idx;
    int bank;
    int col;
    int edge_idx;
    uint8_t syndrome = 0;

    for (row_idx = 0; row_idx < MDPC_R; ++row_idx) {
        int parity = 0;
        for (var_idx = 0; var_idx < MDPC_N; ++var_idx) {
            bank = var_idx / MDPC_R;
            col = var_idx % MDPC_R;
            for (edge_idx = 0; edge_idx < MDPC_W; ++edge_idx) {
                if (edge_row_global(bank, col, edge_idx) == row_idx) {
                    parity ^= x_bits[var_idx];
                }
            }
        }
        syndrome |= (uint8_t)((parity & 1) << row_idx);
    }
    return syndrome;
}

static void build_lane_edges(int var_idx, lane_edge_t lane_edges[MDPC_L][MDPC_W], int lane_count[MDPC_L]) {
    int bank = var_idx / MDPC_R;
    int col = var_idx % MDPC_R;
    int edge_idx;
    int lane_idx;

    memset(lane_edges, 0, sizeof(lane_edge_t) * MDPC_L * MDPC_W);
    lane_count[0] = 0;
    lane_count[1] = 0;

    for (edge_idx = 0; edge_idx < MDPC_W; ++edge_idx) {
        int row_global = edge_row_global(bank, col, edge_idx);
        int slot;
        lane_idx = row_global < MDPC_ROW_SPLIT ? 0 : 1;
        slot = lane_count[lane_idx]++;
        lane_edges[lane_idx][slot].valid = 1;
        lane_edges[lane_idx][slot].row_global = row_global;
        lane_edges[lane_idx][slot].row_local = lane_idx == 0 ? row_global : (row_global - MDPC_ROW_SPLIT);
        lane_edges[lane_idx][slot].var_idx = var_idx;
        lane_edges[lane_idx][slot].edge_slot = edge_idx;
    }
}

static void cnu_a_step(msg_t u_in, int var_idx, row_state_t *state) {
    int abs_mag = u_in.mag;
    if (state->valid_count == 0) {
        state->min1 = abs_mag;
        state->min2 = MDPC_MAG_MAX;
        state->min_id = var_idx;
        state->sign_xor = u_in.sign;
        state->valid_count = 1;
        return;
    }

    state->sign_xor ^= u_in.sign;
    if (state->valid_count < MDPC_W) {
        state->valid_count += 1;
    }

    if (abs_mag < state->min1) {
        state->min2 = state->min1;
        state->min1 = abs_mag;
        state->min_id = var_idx;
    } else if (abs_mag < state->min2) {
        state->min2 = abs_mag;
    }
}

static msg_t cnu_b_step(const row_state_t *state, int u_sign, int var_idx) {
    msg_t out;
    out.sign = state->sign_xor ^ u_sign;
    out.mag = (var_idx == state->min_id) ? state->min2 : state->min1;
    return out;
}

static void vnu_step(uint8_t channel_bit, const msg_t c2v[MDPC_W], int *app_value, uint8_t *x_out, msg_t u_next[MDPC_W]) {
    int edge_idx;
    int sum_c2v = 0;
    int signed_c2v[MDPC_W];
    int app;

    for (edge_idx = 0; edge_idx < MDPC_W; ++edge_idx) {
        signed_c2v[edge_idx] = msg_to_signed(c2v[edge_idx]);
        sum_c2v += signed_c2v[edge_idx];
    }

    app = gamma_from_bit(channel_bit) + alpha_scale(sum_c2v);
    *app_value = app;
    *x_out = app < 0;

    for (edge_idx = 0; edge_idx < MDPC_W; ++edge_idx) {
        u_next[edge_idx] = msg_from_signed(app - alpha_scale(signed_c2v[edge_idx]));
    }
}

int mdpc_decode(const mdpc_config_t *cfg, const uint8_t x_in[MDPC_N], mdpc_result_t *out, mdpc_trace_t *trace) {
    row_state_t row_state_mem[MDPC_R];
    msg_t u_mem[MDPC_N][MDPC_W];
    msg_t c2v_mem[MDPC_N][MDPC_W];
    int sign_mem[MDPC_N][MDPC_W];
    uint8_t x_work[MDPC_N];
    int iter;
    (void)cfg;

    memset(c2v_mem, 0, sizeof(c2v_mem));
    memset(sign_mem, 0, sizeof(sign_mem));
    memcpy(x_work, x_in, sizeof(x_work));

    if (trace != NULL) {
        memset(trace, 0, sizeof(*trace));
    }

    for (iter = 0; iter < MDPC_N; ++iter) {
        int edge_idx;
        for (edge_idx = 0; edge_idx < MDPC_W; ++edge_idx) {
            u_mem[iter][edge_idx] = msg_from_signed(gamma_from_bit(x_in[iter]));
        }
    }

    for (iter = 0; iter < MDPC_I_MAX; ++iter) {
        int var_idx;
        for (var_idx = 0; var_idx < MDPC_R; ++var_idx) {
            row_state_mem[var_idx] = row_state_init();
        }

        for (var_idx = 0; var_idx < MDPC_N; ++var_idx) {
            lane_edge_t lane_edges[MDPC_L][MDPC_W];
            int lane_count[MDPC_L];
            int lane_slot;
            int lane_limit;
            build_lane_edges(var_idx, lane_edges, lane_count);
            lane_limit = lane_count[0] > lane_count[1] ? lane_count[0] : lane_count[1];
            for (lane_slot = 0; lane_slot < lane_limit; ++lane_slot) {
                int lane_idx;
                for (lane_idx = 0; lane_idx < MDPC_L; ++lane_idx) {
                    if (lane_edges[lane_idx][lane_slot].valid) {
                        int edge_slot = lane_edges[lane_idx][lane_slot].edge_slot;
                        int row = lane_edges[lane_idx][lane_slot].row_global;
                        cnu_a_step(u_mem[var_idx][edge_slot], var_idx, &row_state_mem[row]);
                        sign_mem[var_idx][edge_slot] = u_mem[var_idx][edge_slot].sign;
                    }
                }
            }
        }

        if (trace != NULL && iter == 0) {
            memcpy(trace->first_row_state, row_state_mem, sizeof(row_state_mem));
        }

        for (var_idx = 0; var_idx < MDPC_N; ++var_idx) {
            lane_edge_t lane_edges[MDPC_L][MDPC_W];
            int lane_count[MDPC_L];
            int lane_slot;
            int lane_limit;
            build_lane_edges(var_idx, lane_edges, lane_count);
            lane_limit = lane_count[0] > lane_count[1] ? lane_count[0] : lane_count[1];
            for (lane_slot = 0; lane_slot < lane_limit; ++lane_slot) {
                int lane_idx;
                for (lane_idx = 0; lane_idx < MDPC_L; ++lane_idx) {
                    if (lane_edges[lane_idx][lane_slot].valid) {
                        int edge_slot = lane_edges[lane_idx][lane_slot].edge_slot;
                        int row = lane_edges[lane_idx][lane_slot].row_global;
                        c2v_mem[var_idx][edge_slot] = cnu_b_step(&row_state_mem[row], sign_mem[var_idx][edge_slot], var_idx);
                    }
                }
            }
        }

        if (trace != NULL && iter == 0) {
            memcpy(trace->first_c2v, c2v_mem, sizeof(c2v_mem));
        }

        for (var_idx = 0; var_idx < MDPC_N; ++var_idx) {
            int app_value = 0;
            uint8_t x_next = 0;
            msg_t u_next[MDPC_W];
            int edge_idx;
            vnu_step(x_in[var_idx], c2v_mem[var_idx], &app_value, &x_next, u_next);
            x_work[var_idx] = x_next;
            for (edge_idx = 0; edge_idx < MDPC_W; ++edge_idx) {
                u_mem[var_idx][edge_idx] = u_next[edge_idx];
            }
        }

        if (trace != NULL && iter == 0) {
            memcpy(trace->first_u_next, u_mem, sizeof(u_mem));
        }

        if (trace != NULL) {
            trace->syndrome_hist[iter] = syndrome_vector_bits(x_work);
        }

        if (syndrome_vector_bits(x_work) == 0) {
            if (trace != NULL) {
                trace->success = 1;
                trace->iterations = iter + 1;
            }
            if (out != NULL) {
                out->success = 1;
                out->iterations = iter + 1;
                out->x_out_bits = pack_bits(x_work);
            }
            return 0;
        }
    }

    if (trace != NULL) {
        trace->success = 0;
        trace->iterations = MDPC_I_MAX;
    }
    if (out != NULL) {
        out->success = 0;
        out->iterations = MDPC_I_MAX;
        out->x_out_bits = pack_bits(x_work);
    }
    return 0;
}

static void emit_logic_vector(FILE *fp, const char *name, uint16_t value) {
    fprintf(fp, "localparam logic [%d:0] %s = %d'h%04X;\n", MDPC_N - 1, name, MDPC_N, value);
}

static void emit_int_array(FILE *fp, const char *name, const int *values, int len) {
    int idx;
    fprintf(fp, "localparam int %s [0:%d] = '{", name, len - 1);
    for (idx = 0; idx < len; ++idx) {
        fprintf(fp, "%s%d", idx == 0 ? "" : ", ", values[idx]);
    }
    fprintf(fp, "};\n");
}

static void emit_row_state_arrays(FILE *fp, const mdpc_trace_t *trace) {
    int idx;
    int min1[MDPC_R];
    int min2[MDPC_R];
    int min_id[MDPC_R];
    int sign_xor[MDPC_R];
    int valid_count[MDPC_R];
    for (idx = 0; idx < MDPC_R; ++idx) {
        min1[idx] = trace->first_row_state[idx].min1;
        min2[idx] = trace->first_row_state[idx].min2;
        min_id[idx] = trace->first_row_state[idx].min_id;
        sign_xor[idx] = trace->first_row_state[idx].sign_xor;
        valid_count[idx] = trace->first_row_state[idx].valid_count;
    }
    emit_int_array(fp, "CASE1_FIRST_ROW_MIN1", min1, MDPC_R);
    emit_int_array(fp, "CASE1_FIRST_ROW_MIN2", min2, MDPC_R);
    emit_int_array(fp, "CASE1_FIRST_ROW_MIN_ID", min_id, MDPC_R);
    emit_int_array(fp, "CASE1_FIRST_ROW_SIGN_XOR", sign_xor, MDPC_R);
    emit_int_array(fp, "CASE1_FIRST_ROW_VALID_COUNT", valid_count, MDPC_R);
}

static void emit_msg_arrays(FILE *fp, const char *sign_name, const char *mag_name, msg_t values[MDPC_N][MDPC_W]) {
    int sign_values[MDPC_N * MDPC_W];
    int mag_values[MDPC_N * MDPC_W];
    int flat_idx = 0;
    int var_idx;
    int edge_idx;
    for (var_idx = 0; var_idx < MDPC_N; ++var_idx) {
        for (edge_idx = 0; edge_idx < MDPC_W; ++edge_idx) {
            sign_values[flat_idx] = values[var_idx][edge_idx].sign;
            mag_values[flat_idx] = values[var_idx][edge_idx].mag;
            flat_idx += 1;
        }
    }
    emit_int_array(fp, sign_name, sign_values, MDPC_N * MDPC_W);
    emit_int_array(fp, mag_name, mag_values, MDPC_N * MDPC_W);
}

int mdpc_emit_svh(const mdpc_config_t *cfg, const char *path) {
    uint8_t case0_bits[MDPC_N] = {0};
    uint8_t case1_bits[MDPC_N] = {0};
    mdpc_result_t case0_result;
    mdpc_result_t case1_result;
    mdpc_trace_t case0_trace;
    mdpc_trace_t case1_trace;
    int found_success = 0;
    int bit_idx;
    FILE *fp;

    mdpc_decode(cfg, case0_bits, &case0_result, &case0_trace);

    for (bit_idx = 0; bit_idx < MDPC_N; ++bit_idx) {
        uint8_t trial_bits[MDPC_N] = {0};
        mdpc_result_t trial_result;
        mdpc_trace_t trial_trace;
        trial_bits[bit_idx] = 1;
        mdpc_decode(cfg, trial_bits, &trial_result, &trial_trace);
        if (bit_idx == 0 || (!found_success && trial_result.success)) {
            memcpy(case1_bits, trial_bits, sizeof(case1_bits));
            case1_result = trial_result;
            case1_trace = trial_trace;
        }
        if (trial_result.success) {
            found_success = 1;
            break;
        }
    }

    fp = fopen(path, "w");
    if (fp == NULL) {
        perror("fopen");
        return 1;
    }

    fprintf(fp, "`ifndef MDPC_DEMO_VECTORS_SVH\n");
    fprintf(fp, "`define MDPC_DEMO_VECTORS_SVH\n\n");

    emit_logic_vector(fp, "CASE0_INPUT", pack_bits(case0_bits));
    emit_logic_vector(fp, "CASE0_OUTPUT", case0_result.x_out_bits);
    fprintf(fp, "localparam int CASE0_SUCCESS = %d;\n", case0_result.success);
    fprintf(fp, "localparam int CASE0_ITERATIONS = %d;\n", case0_result.iterations);
    emit_int_array(fp, "CASE0_SYNDROME_HIST", case0_trace.syndrome_hist, MDPC_I_MAX);
    fprintf(fp, "\n");

    emit_logic_vector(fp, "CASE1_INPUT", pack_bits(case1_bits));
    emit_logic_vector(fp, "CASE1_OUTPUT", case1_result.x_out_bits);
    fprintf(fp, "localparam int CASE1_SUCCESS = %d;\n", case1_result.success);
    fprintf(fp, "localparam int CASE1_ITERATIONS = %d;\n", case1_result.iterations);
    fprintf(fp, "localparam int CASE1_IS_CONVERGED_VECTOR = %d;\n", found_success);
    emit_int_array(fp, "CASE1_SYNDROME_HIST", case1_trace.syndrome_hist, MDPC_I_MAX);
    emit_row_state_arrays(fp, &case1_trace);
    emit_msg_arrays(fp, "CASE1_FIRST_C2V_SIGN", "CASE1_FIRST_C2V_MAG", case1_trace.first_c2v);
    emit_msg_arrays(fp, "CASE1_FIRST_U_SIGN", "CASE1_FIRST_U_MAG", case1_trace.first_u_next);
    fprintf(fp, "\n`endif\n");

    fclose(fp);
    return 0;
}

static void usage(const char *argv0) {
    fprintf(stderr, "Usage: %s --emit-svh <path>\n", argv0);
}

int main(int argc, char **argv) {
    mdpc_config_t cfg = {0};
    if (argc == 3 && strcmp(argv[1], "--emit-svh") == 0) {
        return mdpc_emit_svh(&cfg, argv[2]);
    }
    usage(argv[0]);
    return 1;
}
