#include <errno.h>
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BIKE_L1_N0 2
#define BIKE_L1_R 12323
#define BIKE_L1_WH 71
#define BIKE_L1_W (BIKE_L1_N0 * BIKE_L1_WH)
#define BIKE_L1_N (BIKE_L1_N0 * BIKE_L1_R)
#define BIKE_L1_T 134
#define BIKE_L1_L 2
#define BIKE_ALPHA_FRAC_W 6
#define BIKE_MAG_MAX 15

typedef struct {
    int c_val;
    int alpha_shift_0;
    int alpha_shift_1;
    int i_max;
} bike_candidate_t;

static const bike_candidate_t BIKE_CALIBRATION_CANDIDATES[] = {
    {9, 4, 5, 6},
    {9, 4, 6, 6},
    {9, 5, 6, 6},
    {7, 4, 5, 6},
    {7, 4, 6, 6},
    {7, 5, 6, 6},
    {11, 4, 5, 6},
    {11, 4, 6, 6},
    {11, 5, 6, 6},
    {9, 4, 5, 8},
    {9, 4, 6, 8},
    {9, 5, 6, 8},
    {7, 4, 5, 8},
    {7, 4, 6, 8},
    {7, 5, 6, 8},
    {11, 4, 5, 8},
    {11, 4, 6, 8},
    {11, 5, 6, 8},
};

static const bike_candidate_t BIKE_L1_DEFAULTS = {7, 4, 6, 6};

typedef struct {
    uint8_t sign;
    uint8_t mag;
} msg_t;

typedef struct {
    int min1;
    int min2;
    int min_id;
    int sign_xor;
} row_state_t;

typedef struct {
    int valid;
    int row_global;
    int row_local;
    int var_idx;
    int edge_slot;
} lane_edge_t;

typedef struct {
    int var_idx;
    int edge_slot;
} row_edge_t;

typedef struct {
    int n0;
    int r;
    int wh;
    int w;
    int n;
    int t;
    int l;
    int i_max;
    int c_val;
    int alpha_frac_w;
    int alpha_shift_0;
    int alpha_shift_1;
    int mag_max;
    int segment_size;
    int *h_base;
} bike_config_t;

typedef struct {
    int row_count;
    int edge_count;
    int *row_offsets;
    row_edge_t *row_edges;
} bike_graph_t;

typedef struct {
    uint8_t *x_out_bits;
    int success;
    int iterations;
    int final_syndrome_weight;
} bike_result_t;

typedef struct {
    int *syndrome_weight_hist;
    int *syndrome_nonzero_hist;
    int success;
    int iterations;
} bike_trace_t;

typedef struct {
    int success_count;
    int failure_count;
    int total_iterations_success;
    int total_final_syndrome_failure;
    bike_candidate_t candidate;
    int candidate_index;
} bike_calibration_summary_t;

typedef struct {
    enum {
        CMD_NONE = 0,
        CMD_ONCE,
        CMD_BATCH,
        CMD_CALIBRATE,
        CMD_SELF_TEST
    } command;
    uint64_t seed;
    uint64_t base_seed;
    int trials;
    int have_seed;
    int have_base_seed;
    int have_trials;
    int have_c_override;
    int c_override;
    int have_alpha_override;
    int alpha_shift_0;
    int alpha_shift_1;
    int have_i_max_override;
    int i_max_override;
} cli_options_t;

static void bike_config_init_zero(bike_config_t *cfg) {
    memset(cfg, 0, sizeof(*cfg));
}

static void bike_config_free(bike_config_t *cfg) {
    free(cfg->h_base);
    bike_config_init_zero(cfg);
}

static int bike_config_alloc(bike_config_t *cfg) {
    cfg->w = cfg->n0 * cfg->wh;
    cfg->n = cfg->n0 * cfg->r;
    cfg->segment_size = (cfg->r + cfg->l - 1) / cfg->l;
    cfg->h_base = (int *)calloc((size_t)cfg->n0 * (size_t)cfg->wh, sizeof(int));
    return cfg->h_base == NULL ? -1 : 0;
}

static uint64_t splitmix64_next(uint64_t *state) {
    uint64_t z;

    *state += UINT64_C(0x9E3779B97F4A7C15);
    z = *state;
    z = (z ^ (z >> 30)) * UINT64_C(0xBF58476D1CE4E5B9);
    z = (z ^ (z >> 27)) * UINT64_C(0x94D049BB133111EB);
    return z ^ (z >> 31);
}

static int sample_unique_positions(uint64_t *rng_state, int limit, int count, int *out) {
    uint8_t *used;
    int filled = 0;
    int idx;
    int cmp_idx;

    used = (uint8_t *)calloc((size_t)limit, sizeof(uint8_t));
    if (used == NULL) {
        return -1;
    }

    while (filled < count) {
        int candidate = (int)(splitmix64_next(rng_state) % (uint64_t)limit);
        if (!used[candidate]) {
            used[candidate] = 1;
            out[filled++] = candidate;
        }
    }

    for (idx = 0; idx < count; ++idx) {
        for (cmp_idx = idx + 1; cmp_idx < count; ++cmp_idx) {
            if (out[cmp_idx] < out[idx]) {
                int tmp = out[idx];
                out[idx] = out[cmp_idx];
                out[cmp_idx] = tmp;
            }
        }
    }

    free(used);
    return 0;
}

static int bike_config_init(
    bike_config_t *cfg,
    uint64_t seed,
    int r,
    int wh,
    int t,
    const bike_candidate_t *candidate
) {
    int bank;
    uint64_t rng_state = seed;

    bike_config_init_zero(cfg);
    cfg->n0 = BIKE_L1_N0;
    cfg->r = r;
    cfg->wh = wh;
    cfg->t = t;
    cfg->l = BIKE_L1_L;
    cfg->i_max = candidate->i_max;
    cfg->c_val = candidate->c_val;
    cfg->alpha_frac_w = BIKE_ALPHA_FRAC_W;
    cfg->alpha_shift_0 = candidate->alpha_shift_0;
    cfg->alpha_shift_1 = candidate->alpha_shift_1;
    cfg->mag_max = BIKE_MAG_MAX;
    if (bike_config_alloc(cfg) != 0) {
        return -1;
    }

    for (bank = 0; bank < cfg->n0; ++bank) {
        if (sample_unique_positions(&rng_state, cfg->r, cfg->wh, &cfg->h_base[bank * cfg->wh]) != 0) {
            bike_config_free(cfg);
            return -1;
        }
    }
    return 0;
}

static void bike_result_init_zero(bike_result_t *result) {
    memset(result, 0, sizeof(*result));
}

static int bike_result_init(bike_result_t *result, const bike_config_t *cfg) {
    bike_result_init_zero(result);
    result->x_out_bits = (uint8_t *)calloc((size_t)cfg->n, sizeof(uint8_t));
    return result->x_out_bits == NULL ? -1 : 0;
}

static void bike_result_free(bike_result_t *result) {
    free(result->x_out_bits);
    bike_result_init_zero(result);
}

static void bike_trace_init_zero(bike_trace_t *trace) {
    memset(trace, 0, sizeof(*trace));
}

static int bike_trace_init(bike_trace_t *trace, const bike_config_t *cfg) {
    bike_trace_init_zero(trace);
    trace->syndrome_weight_hist = (int *)calloc((size_t)cfg->i_max, sizeof(int));
    trace->syndrome_nonzero_hist = (int *)calloc((size_t)cfg->i_max, sizeof(int));
    if (trace->syndrome_weight_hist == NULL || trace->syndrome_nonzero_hist == NULL) {
        return -1;
    }
    return 0;
}

static void bike_trace_free(bike_trace_t *trace) {
    free(trace->syndrome_weight_hist);
    free(trace->syndrome_nonzero_hist);
    bike_trace_init_zero(trace);
}

static int clamp_int(int value, int lo, int hi) {
    if (value < lo) {
        return lo;
    }
    if (value > hi) {
        return hi;
    }
    return value;
}

static msg_t msg_from_signed(const bike_config_t *cfg, int value) {
    msg_t msg;
    int abs_value = value < 0 ? -value : value;

    abs_value = clamp_int(abs_value, 0, cfg->mag_max);
    msg.sign = (uint8_t)(value < 0);
    msg.mag = (uint8_t)abs_value;
    return msg;
}

static int msg_to_signed(msg_t msg) {
    return msg.sign ? -(int)msg.mag : (int)msg.mag;
}

static int gamma_from_bit(const bike_config_t *cfg, uint8_t bit_value) {
    return bit_value ? -cfg->c_val : cfg->c_val;
}

static int alpha_scale(const bike_config_t *cfg, int value) {
    int abs_value = value < 0 ? -value : value;
    int scaled_abs = 0;

    scaled_abs += abs_value << (cfg->alpha_frac_w - cfg->alpha_shift_0);
    scaled_abs += abs_value << (cfg->alpha_frac_w - cfg->alpha_shift_1);
    scaled_abs += 1 << (cfg->alpha_frac_w - 1);
    scaled_abs >>= cfg->alpha_frac_w;
    return value < 0 ? -scaled_abs : scaled_abs;
}

static row_state_t row_state_init(const bike_config_t *cfg) {
    row_state_t state;

    state.min1 = cfg->mag_max;
    state.min2 = cfg->mag_max;
    state.min_id = 0;
    state.sign_xor = 0;
    return state;
}

static int edge_row_global(const bike_config_t *cfg, int bank, int col, int edge_slot) {
    return (cfg->h_base[bank * cfg->wh + edge_slot] + col) % cfg->r;
}

static int lane_for_row(const bike_config_t *cfg, int row_global) {
    int lane_idx = row_global / cfg->segment_size;
    if (lane_idx >= cfg->l) {
        lane_idx = cfg->l - 1;
    }
    return lane_idx;
}

static int lane_row_base(const bike_config_t *cfg, int lane_idx) {
    return lane_idx * cfg->segment_size;
}

static void build_lane_edges(const bike_config_t *cfg, int var_idx, lane_edge_t *lane_edges, int *lane_count) {
    int bank = var_idx / cfg->r;
    int col = var_idx % cfg->r;
    int edge_idx;
    int lane_idx;

    memset(lane_count, 0, sizeof(int) * (size_t)cfg->l);
    for (lane_idx = 0; lane_idx < cfg->l * cfg->wh; ++lane_idx) {
        lane_edges[lane_idx].valid = 0;
    }

    for (edge_idx = 0; edge_idx < cfg->wh; ++edge_idx) {
        int row_global = edge_row_global(cfg, bank, col, edge_idx);
        int slot;

        lane_idx = lane_for_row(cfg, row_global);
        slot = lane_count[lane_idx]++;
        lane_edges[lane_idx * cfg->wh + slot].valid = 1;
        lane_edges[lane_idx * cfg->wh + slot].row_global = row_global;
        lane_edges[lane_idx * cfg->wh + slot].row_local = row_global - lane_row_base(cfg, lane_idx);
        lane_edges[lane_idx * cfg->wh + slot].var_idx = var_idx;
        lane_edges[lane_idx * cfg->wh + slot].edge_slot = edge_idx;
    }
}

static void cnu_a_step(msg_t u_in, int var_idx, row_state_t *state) {
    int abs_mag = (int)u_in.mag;

    state->sign_xor ^= (int)u_in.sign;
    if (abs_mag <= state->min1) {
        state->min2 = state->min1;
        state->min1 = abs_mag;
        state->min_id = var_idx;
    } else if (abs_mag < state->min2) {
        state->min2 = abs_mag;
    }
}

static msg_t cnu_b_step(const row_state_t *state, int u_sign, int var_idx) {
    msg_t out;

    out.sign = (uint8_t)(state->sign_xor ^ u_sign);
    out.mag = (uint8_t)((var_idx == state->min_id) ? state->min2 : state->min1);
    return out;
}

static void vnu_step(
    const bike_config_t *cfg,
    uint8_t channel_bit,
    const msg_t *c2v,
    uint8_t *x_out,
    msg_t *u_next
) {
    int edge_idx;
    int sum_c2v = 0;
    int app;

    for (edge_idx = 0; edge_idx < cfg->wh; ++edge_idx) {
        sum_c2v += msg_to_signed(c2v[edge_idx]);
    }

    app = gamma_from_bit(cfg, channel_bit) + alpha_scale(cfg, sum_c2v);
    *x_out = (uint8_t)(app < 0);
    for (edge_idx = 0; edge_idx < cfg->wh; ++edge_idx) {
        int signed_c2v = msg_to_signed(c2v[edge_idx]);
        u_next[edge_idx] = msg_from_signed(cfg, app - alpha_scale(cfg, signed_c2v));
    }
}

static int bike_graph_build(const bike_config_t *cfg, bike_graph_t *graph) {
    int *row_counts;
    int *row_fill;
    int var_idx;
    int edge_idx;
    int total_edges = cfg->n * cfg->wh;

    memset(graph, 0, sizeof(*graph));
    graph->row_count = cfg->r;
    graph->edge_count = total_edges;
    graph->row_offsets = (int *)calloc((size_t)cfg->r + 1u, sizeof(int));
    graph->row_edges = (row_edge_t *)calloc((size_t)total_edges, sizeof(row_edge_t));
    row_counts = (int *)calloc((size_t)cfg->r, sizeof(int));
    row_fill = (int *)calloc((size_t)cfg->r, sizeof(int));
    if (graph->row_offsets == NULL || graph->row_edges == NULL || row_counts == NULL || row_fill == NULL) {
        free(row_counts);
        free(row_fill);
        return -1;
    }

    for (var_idx = 0; var_idx < cfg->n; ++var_idx) {
        int bank = var_idx / cfg->r;
        int col = var_idx % cfg->r;
        for (edge_idx = 0; edge_idx < cfg->wh; ++edge_idx) {
            int row = edge_row_global(cfg, bank, col, edge_idx);
            row_counts[row] += 1;
        }
    }

    graph->row_offsets[0] = 0;
    for (var_idx = 0; var_idx < cfg->r; ++var_idx) {
        graph->row_offsets[var_idx + 1] = graph->row_offsets[var_idx] + row_counts[var_idx];
    }

    memcpy(row_fill, graph->row_offsets, sizeof(int) * (size_t)cfg->r);
    for (var_idx = 0; var_idx < cfg->n; ++var_idx) {
        int bank = var_idx / cfg->r;
        int col = var_idx % cfg->r;
        for (edge_idx = 0; edge_idx < cfg->wh; ++edge_idx) {
            int row = edge_row_global(cfg, bank, col, edge_idx);
            int slot = row_fill[row]++;
            graph->row_edges[slot].var_idx = var_idx;
            graph->row_edges[slot].edge_slot = edge_idx;
        }
    }

    free(row_counts);
    free(row_fill);
    return 0;
}

static void bike_graph_free(bike_graph_t *graph) {
    free(graph->row_offsets);
    free(graph->row_edges);
    memset(graph, 0, sizeof(*graph));
}

static int syndrome_weight(const bike_config_t *cfg, const bike_graph_t *graph, const uint8_t *x_bits) {
    int row_idx;
    int weight = 0;

    for (row_idx = 0; row_idx < cfg->r; ++row_idx) {
        int edge_pos;
        int parity = 0;
        for (edge_pos = graph->row_offsets[row_idx]; edge_pos < graph->row_offsets[row_idx + 1]; ++edge_pos) {
            parity ^= x_bits[graph->row_edges[edge_pos].var_idx];
        }
        weight += parity;
    }
    return weight;
}

static int max_lane_count(const int *lane_count, int lane_total) {
    int lane_idx;
    int max_count = 0;
    for (lane_idx = 0; lane_idx < lane_total; ++lane_idx) {
        if (lane_count[lane_idx] > max_count) {
            max_count = lane_count[lane_idx];
        }
    }
    return max_count;
}

static int bike_decode_schedule(
    const bike_config_t *cfg,
    const bike_graph_t *graph,
    const uint8_t *x_in,
    bike_result_t *out,
    bike_trace_t *trace
) {
    row_state_t *row_state_mem;
    msg_t *u_mem;
    msg_t *c2v_mem;
    uint8_t *sign_mem;
    uint8_t *x_work;
    lane_edge_t *lane_edges;
    int *lane_count;
    int iter;

    row_state_mem = (row_state_t *)calloc((size_t)cfg->r, sizeof(row_state_t));
    u_mem = (msg_t *)calloc((size_t)cfg->n * (size_t)cfg->wh, sizeof(msg_t));
    c2v_mem = (msg_t *)calloc((size_t)cfg->n * (size_t)cfg->wh, sizeof(msg_t));
    sign_mem = (uint8_t *)calloc((size_t)cfg->n * (size_t)cfg->wh, sizeof(uint8_t));
    x_work = (uint8_t *)calloc((size_t)cfg->n, sizeof(uint8_t));
    lane_edges = (lane_edge_t *)calloc((size_t)cfg->l * (size_t)cfg->wh, sizeof(lane_edge_t));
    lane_count = (int *)calloc((size_t)cfg->l, sizeof(int));
    if (row_state_mem == NULL || u_mem == NULL || c2v_mem == NULL || sign_mem == NULL ||
        x_work == NULL || lane_edges == NULL || lane_count == NULL) {
        free(row_state_mem);
        free(u_mem);
        free(c2v_mem);
        free(sign_mem);
        free(x_work);
        free(lane_edges);
        free(lane_count);
        return -1;
    }

    memcpy(x_work, x_in, (size_t)cfg->n);
    for (iter = 0; iter < cfg->n; ++iter) {
        int edge_idx;
        for (edge_idx = 0; edge_idx < cfg->wh; ++edge_idx) {
            u_mem[iter * cfg->wh + edge_idx] = msg_from_signed(cfg, gamma_from_bit(cfg, x_in[iter]));
        }
    }

    for (iter = 0; iter < cfg->i_max; ++iter) {
        int var_idx;

        for (var_idx = 0; var_idx < cfg->r; ++var_idx) {
            row_state_mem[var_idx] = row_state_init(cfg);
        }

        for (var_idx = 0; var_idx < cfg->n; ++var_idx) {
            int lane_slot;
            int lane_limit;

            build_lane_edges(cfg, var_idx, lane_edges, lane_count);
            lane_limit = max_lane_count(lane_count, cfg->l);
            for (lane_slot = 0; lane_slot < lane_limit; ++lane_slot) {
                int lane_idx;
                for (lane_idx = 0; lane_idx < cfg->l; ++lane_idx) {
                    if (lane_slot < lane_count[lane_idx]) {
                        const lane_edge_t *edge = &lane_edges[lane_idx * cfg->wh + lane_slot];
                        int flat_idx = var_idx * cfg->wh + edge->edge_slot;
                        cnu_a_step(u_mem[flat_idx], var_idx, &row_state_mem[edge->row_global]);
                        sign_mem[flat_idx] = u_mem[flat_idx].sign;
                    }
                }
            }
        }

        for (var_idx = 0; var_idx < cfg->n; ++var_idx) {
            int lane_slot;
            int lane_limit;

            build_lane_edges(cfg, var_idx, lane_edges, lane_count);
            lane_limit = max_lane_count(lane_count, cfg->l);
            for (lane_slot = 0; lane_slot < lane_limit; ++lane_slot) {
                int lane_idx;
                for (lane_idx = 0; lane_idx < cfg->l; ++lane_idx) {
                    if (lane_slot < lane_count[lane_idx]) {
                        const lane_edge_t *edge = &lane_edges[lane_idx * cfg->wh + lane_slot];
                        int flat_idx = var_idx * cfg->wh + edge->edge_slot;
                        c2v_mem[flat_idx] = cnu_b_step(&row_state_mem[edge->row_global], sign_mem[flat_idx], var_idx);
                    }
                }
            }
        }

        for (var_idx = 0; var_idx < cfg->n; ++var_idx) {
            uint8_t x_next = 0;
            msg_t u_next[cfg->wh];
            int edge_idx;

            vnu_step(cfg, x_in[var_idx], &c2v_mem[var_idx * cfg->wh], &x_next, u_next);
            x_work[var_idx] = x_next;
            for (edge_idx = 0; edge_idx < cfg->wh; ++edge_idx) {
                u_mem[var_idx * cfg->wh + edge_idx] = u_next[edge_idx];
            }
        }

        if (trace != NULL) {
            int weight = syndrome_weight(cfg, graph, x_work);
            trace->syndrome_weight_hist[iter] = weight;
            trace->syndrome_nonzero_hist[iter] = weight != 0;
        }

        if (out != NULL || trace != NULL) {
            int weight = syndrome_weight(cfg, graph, x_work);
            if (weight == 0) {
                if (out != NULL) {
                    out->success = 1;
                    out->iterations = iter + 1;
                    out->final_syndrome_weight = 0;
                    memcpy(out->x_out_bits, x_work, (size_t)cfg->n);
                }
                if (trace != NULL) {
                    trace->success = 1;
                    trace->iterations = iter + 1;
                }
                free(row_state_mem);
                free(u_mem);
                free(c2v_mem);
                free(sign_mem);
                free(x_work);
                free(lane_edges);
                free(lane_count);
                return 0;
            }
            if (iter == cfg->i_max - 1 && out != NULL) {
                out->final_syndrome_weight = weight;
            }
        }
    }

    if (out != NULL) {
        out->success = 0;
        out->iterations = cfg->i_max;
        memcpy(out->x_out_bits, x_work, (size_t)cfg->n);
    }
    if (trace != NULL) {
        trace->success = 0;
        trace->iterations = cfg->i_max;
    }

    free(row_state_mem);
    free(u_mem);
    free(c2v_mem);
    free(sign_mem);
    free(x_work);
    free(lane_edges);
    free(lane_count);
    return 0;
}

static int bike_decode_rowcentric(
    const bike_config_t *cfg,
    const bike_graph_t *graph,
    const uint8_t *x_in,
    bike_result_t *out,
    bike_trace_t *trace
) {
    row_state_t *row_state_mem;
    msg_t *u_mem;
    msg_t *c2v_mem;
    uint8_t *x_work;
    int iter;

    row_state_mem = (row_state_t *)calloc((size_t)cfg->r, sizeof(row_state_t));
    u_mem = (msg_t *)calloc((size_t)cfg->n * (size_t)cfg->wh, sizeof(msg_t));
    c2v_mem = (msg_t *)calloc((size_t)cfg->n * (size_t)cfg->wh, sizeof(msg_t));
    x_work = (uint8_t *)calloc((size_t)cfg->n, sizeof(uint8_t));
    if (row_state_mem == NULL || u_mem == NULL || c2v_mem == NULL || x_work == NULL) {
        free(row_state_mem);
        free(u_mem);
        free(c2v_mem);
        free(x_work);
        return -1;
    }

    memcpy(x_work, x_in, (size_t)cfg->n);
    for (iter = 0; iter < cfg->n; ++iter) {
        int edge_idx;
        for (edge_idx = 0; edge_idx < cfg->wh; ++edge_idx) {
            u_mem[iter * cfg->wh + edge_idx] = msg_from_signed(cfg, gamma_from_bit(cfg, x_in[iter]));
        }
    }

    for (iter = 0; iter < cfg->i_max; ++iter) {
        int row_idx;
        int row_pos;

        for (row_idx = 0; row_idx < cfg->r; ++row_idx) {
            row_state_mem[row_idx] = row_state_init(cfg);
            for (row_pos = graph->row_offsets[row_idx]; row_pos < graph->row_offsets[row_idx + 1]; ++row_pos) {
                const row_edge_t *edge = &graph->row_edges[row_pos];
                cnu_a_step(u_mem[edge->var_idx * cfg->wh + edge->edge_slot], edge->var_idx, &row_state_mem[row_idx]);
            }
        }

        for (row_idx = 0; row_idx < cfg->r; ++row_idx) {
            for (row_pos = graph->row_offsets[row_idx]; row_pos < graph->row_offsets[row_idx + 1]; ++row_pos) {
                const row_edge_t *edge = &graph->row_edges[row_pos];
                msg_t u_msg = u_mem[edge->var_idx * cfg->wh + edge->edge_slot];
                c2v_mem[edge->var_idx * cfg->wh + edge->edge_slot] =
                    cnu_b_step(&row_state_mem[row_idx], u_msg.sign, edge->var_idx);
            }
        }

        for (row_idx = 0; row_idx < cfg->n; ++row_idx) {
            uint8_t x_next = 0;
            msg_t u_next[cfg->wh];
            int edge_idx;

            vnu_step(cfg, x_in[row_idx], &c2v_mem[row_idx * cfg->wh], &x_next, u_next);
            x_work[row_idx] = x_next;
            for (edge_idx = 0; edge_idx < cfg->wh; ++edge_idx) {
                u_mem[row_idx * cfg->wh + edge_idx] = u_next[edge_idx];
            }
        }

        if (trace != NULL) {
            int weight = syndrome_weight(cfg, graph, x_work);
            trace->syndrome_weight_hist[iter] = weight;
            trace->syndrome_nonzero_hist[iter] = weight != 0;
        }

        if (out != NULL || trace != NULL) {
            int weight = syndrome_weight(cfg, graph, x_work);
            if (weight == 0) {
                if (out != NULL) {
                    out->success = 1;
                    out->iterations = iter + 1;
                    out->final_syndrome_weight = 0;
                    memcpy(out->x_out_bits, x_work, (size_t)cfg->n);
                }
                if (trace != NULL) {
                    trace->success = 1;
                    trace->iterations = iter + 1;
                }
                free(row_state_mem);
                free(u_mem);
                free(c2v_mem);
                free(x_work);
                return 0;
            }
            if (iter == cfg->i_max - 1 && out != NULL) {
                out->final_syndrome_weight = weight;
            }
        }
    }

    if (out != NULL) {
        out->success = 0;
        out->iterations = cfg->i_max;
        memcpy(out->x_out_bits, x_work, (size_t)cfg->n);
    }
    if (trace != NULL) {
        trace->success = 0;
        trace->iterations = cfg->i_max;
    }

    free(row_state_mem);
    free(u_mem);
    free(c2v_mem);
    free(x_work);
    return 0;
}

static int generate_error_vector(const bike_config_t *cfg, uint64_t seed, uint8_t *x_in) {
    int *positions;
    uint64_t rng_state = seed ^ UINT64_C(0xB1CEB1CEB1CEB1CE);
    int idx;

    memset(x_in, 0, (size_t)cfg->n);
    positions = (int *)calloc((size_t)cfg->t, sizeof(int));
    if (positions == NULL) {
        return -1;
    }
    if (sample_unique_positions(&rng_state, cfg->n, cfg->t, positions) != 0) {
        free(positions);
        return -1;
    }
    for (idx = 0; idx < cfg->t; ++idx) {
        x_in[positions[idx]] = 1;
    }
    free(positions);
    return 0;
}

static int results_match(
    const bike_config_t *cfg,
    const bike_result_t *schedule_result,
    const bike_trace_t *schedule_trace,
    const bike_result_t *row_result,
    const bike_trace_t *row_trace
) {
    int bit_idx;
    int iter;

    if (schedule_result->success != row_result->success) {
        fprintf(stderr, "model mismatch: success differs (%d vs %d)\n", schedule_result->success, row_result->success);
        return 0;
    }
    if (schedule_result->iterations != row_result->iterations) {
        fprintf(stderr, "model mismatch: iterations differ (%d vs %d)\n", schedule_result->iterations, row_result->iterations);
        return 0;
    }
    if (schedule_result->final_syndrome_weight != row_result->final_syndrome_weight) {
        fprintf(stderr, "model mismatch: final syndrome differs (%d vs %d)\n",
            schedule_result->final_syndrome_weight, row_result->final_syndrome_weight);
        return 0;
    }
    for (bit_idx = 0; bit_idx < cfg->n; ++bit_idx) {
        if (schedule_result->x_out_bits[bit_idx] != row_result->x_out_bits[bit_idx]) {
            fprintf(stderr, "model mismatch: output bit %d differs (%d vs %d)\n",
                bit_idx, schedule_result->x_out_bits[bit_idx], row_result->x_out_bits[bit_idx]);
            return 0;
        }
    }
    for (iter = 0; iter < cfg->i_max; ++iter) {
        if (schedule_trace->syndrome_nonzero_hist[iter] != row_trace->syndrome_nonzero_hist[iter]) {
            fprintf(stderr, "model mismatch: syndrome history differs at iter %d (%d vs %d)\n",
                iter, schedule_trace->syndrome_nonzero_hist[iter], row_trace->syndrome_nonzero_hist[iter]);
            return 0;
        }
    }
    return 1;
}

static bike_candidate_t bike_candidate_with_overrides(const cli_options_t *options) {
    bike_candidate_t candidate = BIKE_L1_DEFAULTS;

    if (options->have_c_override) {
        candidate.c_val = options->c_override;
    }
    if (options->have_alpha_override) {
        candidate.alpha_shift_0 = options->alpha_shift_0;
        candidate.alpha_shift_1 = options->alpha_shift_1;
    }
    if (options->have_i_max_override) {
        candidate.i_max = options->i_max_override;
    }
    return candidate;
}

static void print_alpha(FILE *stream, const bike_candidate_t *candidate) {
    fprintf(stream, "2^-%d + 2^-%d", candidate->alpha_shift_0, candidate->alpha_shift_1);
}

static void print_candidate_summary(FILE *stream, const bike_candidate_t *candidate) {
    fprintf(stream, "C=%d alpha=", candidate->c_val);
    print_alpha(stream, candidate);
    fprintf(stream, " Imax=%d", candidate->i_max);
}

static int run_single_case(
    uint64_t seed,
    int r,
    int wh,
    int t,
    const bike_candidate_t *candidate,
    bike_result_t *schedule_result,
    bike_trace_t *schedule_trace,
    bike_result_t *row_result,
    bike_trace_t *row_trace
) {
    bike_config_t cfg;
    bike_graph_t graph;
    uint8_t *x_in;
    int rc = -1;

    bike_config_init_zero(&cfg);
    memset(&graph, 0, sizeof(graph));
    x_in = NULL;

    if (bike_config_init(&cfg, seed, r, wh, t, candidate) != 0) {
        fprintf(stderr, "failed to initialize BIKE config\n");
        goto done;
    }
    if (bike_graph_build(&cfg, &graph) != 0) {
        fprintf(stderr, "failed to build BIKE graph\n");
        goto done;
    }
    if (bike_result_init(schedule_result, &cfg) != 0 || bike_result_init(row_result, &cfg) != 0 ||
        bike_trace_init(schedule_trace, &cfg) != 0 || bike_trace_init(row_trace, &cfg) != 0) {
        fprintf(stderr, "failed to allocate BIKE run buffers\n");
        goto done;
    }
    x_in = (uint8_t *)calloc((size_t)cfg.n, sizeof(uint8_t));
    if (x_in == NULL || generate_error_vector(&cfg, seed, x_in) != 0) {
        fprintf(stderr, "failed to generate BIKE error vector\n");
        goto done;
    }
    if (bike_decode_schedule(&cfg, &graph, x_in, schedule_result, schedule_trace) != 0 ||
        bike_decode_rowcentric(&cfg, &graph, x_in, row_result, row_trace) != 0) {
        fprintf(stderr, "BIKE decoder execution failed\n");
        goto done;
    }
    if (!results_match(&cfg, schedule_result, schedule_trace, row_result, row_trace)) {
        goto done;
    }

    rc = 0;

done:
    free(x_in);
    bike_graph_free(&graph);
    bike_config_free(&cfg);
    return rc;
}

static int compare_calibration_summary(
    const bike_calibration_summary_t *lhs,
    const bike_calibration_summary_t *rhs
) {
    if (lhs->success_count != rhs->success_count) {
        return lhs->success_count > rhs->success_count;
    }
    if (lhs->total_final_syndrome_failure != rhs->total_final_syndrome_failure) {
        return lhs->total_final_syndrome_failure < rhs->total_final_syndrome_failure;
    }
    if (lhs->total_iterations_success != rhs->total_iterations_success) {
        return lhs->total_iterations_success < rhs->total_iterations_success;
    }
    return lhs->candidate_index < rhs->candidate_index;
}

static int evaluate_candidate(
    const bike_candidate_t *candidate,
    int candidate_index,
    uint64_t base_seed,
    int trials,
    bike_calibration_summary_t *summary
) {
    int trial_idx;

    memset(summary, 0, sizeof(*summary));
    summary->candidate = *candidate;
    summary->candidate_index = candidate_index;

    for (trial_idx = 0; trial_idx < trials; ++trial_idx) {
        uint64_t seed = base_seed + (uint64_t)trial_idx;
        bike_result_t schedule_result;
        bike_result_t row_result;
        bike_trace_t schedule_trace;
        bike_trace_t row_trace;

        bike_result_init_zero(&schedule_result);
        bike_result_init_zero(&row_result);
        bike_trace_init_zero(&schedule_trace);
        bike_trace_init_zero(&row_trace);

        if (run_single_case(
                seed,
                BIKE_L1_R,
                BIKE_L1_WH,
                BIKE_L1_T,
                candidate,
                &schedule_result,
                &schedule_trace,
                &row_result,
                &row_trace
            ) != 0) {
            bike_result_free(&schedule_result);
            bike_result_free(&row_result);
            bike_trace_free(&schedule_trace);
            bike_trace_free(&row_trace);
            return -1;
        }

        if (schedule_result.success) {
            summary->success_count += 1;
            summary->total_iterations_success += schedule_result.iterations;
        } else {
            summary->failure_count += 1;
            summary->total_final_syndrome_failure += schedule_result.final_syndrome_weight;
        }

        bike_result_free(&schedule_result);
        bike_result_free(&row_result);
        bike_trace_free(&schedule_trace);
        bike_trace_free(&row_trace);
    }
    return 0;
}

static int run_bike_l1_once(const cli_options_t *options) {
    bike_candidate_t candidate = bike_candidate_with_overrides(options);
    bike_result_t schedule_result;
    bike_result_t row_result;
    bike_trace_t schedule_trace;
    bike_trace_t row_trace;
    int rc = 1;

    bike_result_init_zero(&schedule_result);
    bike_result_init_zero(&row_result);
    bike_trace_init_zero(&schedule_trace);
    bike_trace_init_zero(&row_trace);

    if (run_single_case(
            options->seed,
            BIKE_L1_R,
            BIKE_L1_WH,
            BIKE_L1_T,
            &candidate,
            &schedule_result,
            &schedule_trace,
            &row_result,
            &row_trace
        ) != 0) {
        goto done;
    }

    printf("bike-l1 seed=%" PRIu64 " models_agree=yes success=%d iterations=%d final_syndrome_weight=%d ",
        options->seed, schedule_result.success, schedule_result.iterations, schedule_result.final_syndrome_weight);
    print_candidate_summary(stdout, &candidate);
    printf("\n");
    rc = 0;

done:
    bike_result_free(&schedule_result);
    bike_result_free(&row_result);
    bike_trace_free(&schedule_trace);
    bike_trace_free(&row_trace);
    return rc;
}

static int run_bike_l1_batch(const cli_options_t *options) {
    bike_candidate_t candidate = bike_candidate_with_overrides(options);
    int trial_idx;
    int success_count = 0;
    int failure_count = 0;
    int first_success_iterations = 0;
    int have_first_success = 0;
    uint64_t first_success_seed = 0;

    printf("bike-l1 batch base_seed=%" PRIu64 " trials=%d ", options->base_seed, options->trials);
    print_candidate_summary(stdout, &candidate);
    printf("\n");

    for (trial_idx = 0; trial_idx < options->trials; ++trial_idx) {
        uint64_t seed = options->base_seed + (uint64_t)trial_idx;
        bike_result_t schedule_result;
        bike_result_t row_result;
        bike_trace_t schedule_trace;
        bike_trace_t row_trace;

        bike_result_init_zero(&schedule_result);
        bike_result_init_zero(&row_result);
        bike_trace_init_zero(&schedule_trace);
        bike_trace_init_zero(&row_trace);

        if (run_single_case(
                seed,
                BIKE_L1_R,
                BIKE_L1_WH,
                BIKE_L1_T,
                &candidate,
                &schedule_result,
                &schedule_trace,
                &row_result,
                &row_trace
            ) != 0) {
            bike_result_free(&schedule_result);
            bike_result_free(&row_result);
            bike_trace_free(&schedule_trace);
            bike_trace_free(&row_trace);
            return 1;
        }

        if (schedule_result.success) {
            success_count += 1;
            if (!have_first_success) {
                have_first_success = 1;
                first_success_seed = seed;
                first_success_iterations = schedule_result.iterations;
            }
        } else {
            failure_count += 1;
        }

        printf("  seed=%" PRIu64 " success=%d iterations=%d final_syndrome_weight=%d\n",
            seed, schedule_result.success, schedule_result.iterations, schedule_result.final_syndrome_weight);

        bike_result_free(&schedule_result);
        bike_result_free(&row_result);
        bike_trace_free(&schedule_trace);
        bike_trace_free(&row_trace);
    }

    printf("bike-l1 batch summary: successes=%d failures=%d\n", success_count, failure_count);
    if (have_first_success) {
        printf("first_success_seed=%" PRIu64 " first_success_iterations=%d\n",
            first_success_seed, first_success_iterations);
    } else {
        printf("first_success_seed=none\n");
    }
    return 0;
}

static int run_bike_l1_calibrate(const cli_options_t *options) {
    bike_calibration_summary_t summaries[sizeof(BIKE_CALIBRATION_CANDIDATES) / sizeof(BIKE_CALIBRATION_CANDIDATES[0])];
    bike_calibration_summary_t *best = NULL;
    size_t candidate_count = sizeof(BIKE_CALIBRATION_CANDIDATES) / sizeof(BIKE_CALIBRATION_CANDIDATES[0]);
    size_t order[sizeof(BIKE_CALIBRATION_CANDIDATES) / sizeof(BIKE_CALIBRATION_CANDIDATES[0])];
    size_t idx;
    size_t rank_idx;

    printf("bike-l1 calibrate base_seed=%" PRIu64 " trials=%d\n", options->base_seed, options->trials);
    for (idx = 0; idx < candidate_count; ++idx) {
        if (evaluate_candidate(
                &BIKE_CALIBRATION_CANDIDATES[idx],
                (int)idx,
                options->base_seed,
                options->trials,
                &summaries[idx]
            ) != 0) {
            return 1;
        }
        order[idx] = idx;
        if (best == NULL || compare_calibration_summary(&summaries[idx], best)) {
            best = &summaries[idx];
        }
    }

    for (rank_idx = 0; rank_idx < candidate_count; ++rank_idx) {
        size_t best_pos = rank_idx;
        for (idx = rank_idx + 1; idx < candidate_count; ++idx) {
            if (compare_calibration_summary(&summaries[order[idx]], &summaries[order[best_pos]])) {
                best_pos = idx;
            }
        }
        if (best_pos != rank_idx) {
            size_t tmp = order[rank_idx];
            order[rank_idx] = order[best_pos];
            order[best_pos] = tmp;
        }
    }

    for (rank_idx = 0; rank_idx < candidate_count; ++rank_idx) {
        const bike_calibration_summary_t *summary = &summaries[order[rank_idx]];
        printf(
            "  rank %zu: successes=%d failures=%d total_success_iterations=%d total_failure_syndrome=%d ",
            rank_idx + 1,
            summary->success_count,
            summary->failure_count,
            summary->total_iterations_success,
            summary->total_final_syndrome_failure
        );
        print_candidate_summary(stdout, &summary->candidate);
        printf("\n");
    }

    if (best == NULL) {
        fprintf(stderr, "no calibration candidates evaluated\n");
        return 1;
    }

    printf("bike-l1 calibration best: ");
    print_candidate_summary(stdout, &best->candidate);
    printf(" successes=%d failures=%d total_success_iterations=%d total_failure_syndrome=%d\n",
        best->success_count,
        best->failure_count,
        best->total_iterations_success,
        best->total_final_syndrome_failure);
    return 0;
}

static int run_self_test(void) {
    bike_candidate_t candidate = BIKE_L1_DEFAULTS;
    bike_result_t schedule_result;
    bike_result_t row_result;
    bike_trace_t schedule_trace;
    bike_trace_t row_trace;
    bike_config_t small_cfg;
    bike_graph_t small_graph;
    uint8_t *x_in = NULL;
    int rc = 1;

    bike_result_init_zero(&schedule_result);
    bike_result_init_zero(&row_result);
    bike_trace_init_zero(&schedule_trace);
    bike_trace_init_zero(&row_trace);
    bike_config_init_zero(&small_cfg);
    memset(&small_graph, 0, sizeof(small_graph));

    if (alpha_scale(&(bike_config_t){
            .alpha_frac_w = BIKE_ALPHA_FRAC_W,
            .alpha_shift_0 = BIKE_L1_DEFAULTS.alpha_shift_0,
            .alpha_shift_1 = BIKE_L1_DEFAULTS.alpha_shift_1
        }, 31) != 2) {
        fprintf(stderr, "self-test failed: positive alpha_scale mismatch\n");
        goto done;
    }
    if (alpha_scale(&(bike_config_t){
            .alpha_frac_w = BIKE_ALPHA_FRAC_W,
            .alpha_shift_0 = BIKE_L1_DEFAULTS.alpha_shift_0,
            .alpha_shift_1 = BIKE_L1_DEFAULTS.alpha_shift_1
        }, -31) != -2) {
        fprintf(stderr, "self-test failed: negative alpha_scale mismatch\n");
        goto done;
    }
    {
        bike_config_t sat_cfg = { .mag_max = BIKE_MAG_MAX };
        msg_t sat_pos = msg_from_signed(&sat_cfg, 27);
        msg_t sat_neg = msg_from_signed(&sat_cfg, -27);
        if (sat_pos.sign != 0 || sat_pos.mag != BIKE_MAG_MAX || sat_neg.sign != 1 || sat_neg.mag != BIKE_MAG_MAX) {
            fprintf(stderr, "self-test failed: saturation mismatch\n");
            goto done;
        }
    }

    if (run_single_case(
            1,
            127,
            9,
            7,
            &candidate,
            &schedule_result,
            &schedule_trace,
            &row_result,
            &row_trace
        ) != 0) {
        fprintf(stderr, "self-test failed: reduced config case 1 mismatch\n");
        goto done;
    }
    bike_result_free(&schedule_result);
    bike_result_free(&row_result);
    bike_trace_free(&schedule_trace);
    bike_trace_free(&row_trace);
    bike_result_init_zero(&schedule_result);
    bike_result_init_zero(&row_result);
    bike_trace_init_zero(&schedule_trace);
    bike_trace_init_zero(&row_trace);

    if (run_single_case(
            2,
            191,
            11,
            9,
            &candidate,
            &schedule_result,
            &schedule_trace,
            &row_result,
            &row_trace
        ) != 0) {
        fprintf(stderr, "self-test failed: reduced config case 2 mismatch\n");
        goto done;
    }
    bike_result_free(&schedule_result);
    bike_result_free(&row_result);
    bike_trace_free(&schedule_trace);
    bike_trace_free(&row_trace);
    bike_result_init_zero(&schedule_result);
    bike_result_init_zero(&row_result);
    bike_trace_init_zero(&schedule_trace);
    bike_trace_init_zero(&row_trace);

    if (bike_config_init(&small_cfg, 3, 63, 7, 5, &candidate) != 0 || bike_graph_build(&small_cfg, &small_graph) != 0) {
        fprintf(stderr, "self-test failed: small config init\n");
        goto done;
    }
    if (bike_result_init(&schedule_result, &small_cfg) != 0 || bike_result_init(&row_result, &small_cfg) != 0 ||
        bike_trace_init(&schedule_trace, &small_cfg) != 0 || bike_trace_init(&row_trace, &small_cfg) != 0) {
        fprintf(stderr, "self-test failed: small config buffers\n");
        goto done;
    }
    x_in = (uint8_t *)calloc((size_t)small_cfg.n, sizeof(uint8_t));
    if (x_in == NULL) {
        fprintf(stderr, "self-test failed: input allocation\n");
        goto done;
    }
    x_in[0] = 1;
    x_in[3] = 1;
    x_in[small_cfg.r + 4] = 1;
    if (bike_decode_schedule(&small_cfg, &small_graph, x_in, &schedule_result, &schedule_trace) != 0 ||
        bike_decode_rowcentric(&small_cfg, &small_graph, x_in, &row_result, &row_trace) != 0 ||
        !results_match(&small_cfg, &schedule_result, &schedule_trace, &row_result, &row_trace)) {
        fprintf(stderr, "self-test failed: deterministic small-pattern mismatch\n");
        goto done;
    }

    printf("bike golden self-test PASS\n");
    rc = 0;

done:
    free(x_in);
    bike_result_free(&schedule_result);
    bike_result_free(&row_result);
    bike_trace_free(&schedule_trace);
    bike_trace_free(&row_trace);
    bike_graph_free(&small_graph);
    bike_config_free(&small_cfg);
    return rc;
}

static int parse_u64(const char *text, uint64_t *value_out) {
    char *end_ptr = NULL;
    unsigned long long parsed;

    errno = 0;
    parsed = strtoull(text, &end_ptr, 0);
    if (errno != 0 || end_ptr == text || *end_ptr != '\0') {
        return -1;
    }
    *value_out = (uint64_t)parsed;
    return 0;
}

static int parse_int(const char *text, int *value_out) {
    char *end_ptr = NULL;
    long parsed;

    errno = 0;
    parsed = strtol(text, &end_ptr, 0);
    if (errno != 0 || end_ptr == text || *end_ptr != '\0') {
        return -1;
    }
    *value_out = (int)parsed;
    return 0;
}

static void usage(const char *argv0) {
    fprintf(stderr,
        "Usage:\n"
        "  %s --bike-l1-once --seed <u64> [--c-val <int>] [--alpha-shift0 <int>] [--alpha-shift1 <int>] [--i-max <int>]\n"
        "  %s --bike-l1-batch --base-seed <u64> --trials <n> [--c-val <int>] [--alpha-shift0 <int>] [--alpha-shift1 <int>] [--i-max <int>]\n"
        "  %s --bike-l1-calibrate --base-seed <u64> --trials <n>\n"
        "  %s --self-test\n",
        argv0, argv0, argv0, argv0);
}

static int parse_cli(int argc, char **argv, cli_options_t *options) {
    int idx;

    memset(options, 0, sizeof(*options));
    options->trials = 8;

    for (idx = 1; idx < argc; ++idx) {
        if (strcmp(argv[idx], "--bike-l1-once") == 0) {
            options->command = CMD_ONCE;
        } else if (strcmp(argv[idx], "--bike-l1-batch") == 0) {
            options->command = CMD_BATCH;
        } else if (strcmp(argv[idx], "--bike-l1-calibrate") == 0) {
            options->command = CMD_CALIBRATE;
        } else if (strcmp(argv[idx], "--self-test") == 0) {
            options->command = CMD_SELF_TEST;
        } else if (strcmp(argv[idx], "--seed") == 0 && idx + 1 < argc) {
            options->have_seed = 1;
            if (parse_u64(argv[++idx], &options->seed) != 0) {
                return -1;
            }
        } else if (strcmp(argv[idx], "--base-seed") == 0 && idx + 1 < argc) {
            options->have_base_seed = 1;
            if (parse_u64(argv[++idx], &options->base_seed) != 0) {
                return -1;
            }
        } else if (strcmp(argv[idx], "--trials") == 0 && idx + 1 < argc) {
            options->have_trials = 1;
            if (parse_int(argv[++idx], &options->trials) != 0 || options->trials <= 0) {
                return -1;
            }
        } else if (strcmp(argv[idx], "--c-val") == 0 && idx + 1 < argc) {
            options->have_c_override = 1;
            if (parse_int(argv[++idx], &options->c_override) != 0) {
                return -1;
            }
        } else if (strcmp(argv[idx], "--alpha-shift0") == 0 && idx + 1 < argc) {
            options->have_alpha_override = 1;
            if (parse_int(argv[++idx], &options->alpha_shift_0) != 0) {
                return -1;
            }
        } else if (strcmp(argv[idx], "--alpha-shift1") == 0 && idx + 1 < argc) {
            options->have_alpha_override = 1;
            if (parse_int(argv[++idx], &options->alpha_shift_1) != 0) {
                return -1;
            }
        } else if (strcmp(argv[idx], "--i-max") == 0 && idx + 1 < argc) {
            options->have_i_max_override = 1;
            if (parse_int(argv[++idx], &options->i_max_override) != 0 || options->i_max_override <= 0) {
                return -1;
            }
        } else {
            return -1;
        }
    }

    if (options->have_alpha_override &&
        (options->alpha_shift_0 <= 0 || options->alpha_shift_1 <= 0 || options->alpha_shift_0 == options->alpha_shift_1)) {
        return -1;
    }

    switch (options->command) {
        case CMD_ONCE:
            return options->have_seed ? 0 : -1;
        case CMD_BATCH:
            return (options->have_base_seed && options->have_trials) ? 0 : -1;
        case CMD_CALIBRATE:
            return (options->have_base_seed && options->have_trials &&
                !options->have_c_override && !options->have_alpha_override && !options->have_i_max_override) ? 0 : -1;
        case CMD_SELF_TEST:
            return argc == 2 ? 0 : -1;
        default:
            return -1;
    }
}

int main(int argc, char **argv) {
    cli_options_t options;

    if (parse_cli(argc, argv, &options) != 0) {
        usage(argv[0]);
        return 1;
    }

    switch (options.command) {
        case CMD_ONCE:
            return run_bike_l1_once(&options);
        case CMD_BATCH:
            return run_bike_l1_batch(&options);
        case CMD_CALIBRATE:
            return run_bike_l1_calibrate(&options);
        case CMD_SELF_TEST:
            return run_self_test();
        default:
            usage(argv[0]);
            return 1;
    }
}
