#include <errno.h>
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TOY_MDPC_N0 2
#define TOY_MDPC_R 8
#define TOY_MDPC_W 3
#define TOY_MDPC_N (TOY_MDPC_N0 * TOY_MDPC_R)
#define TOY_MDPC_L 2
#define TOY_MDPC_I_MAX 4
#define TOY_MDPC_C_VAL 9
#define TOY_MDPC_ALPHA_FRAC_W 6
#define TOY_MDPC_ALPHA_SHIFT_0 4
#define TOY_MDPC_ALPHA_SHIFT_1 5
#define TOY_MDPC_MAG_MAX 15

#define PAPER80_MDPC_N0 2
#define PAPER80_MDPC_R 4801
#define PAPER80_MDPC_W 45
#define PAPER80_MDPC_N (PAPER80_MDPC_N0 * PAPER80_MDPC_R)
#define PAPER80_MDPC_L 2
#define PAPER80_MDPC_I_MAX 30
#define PAPER80_MDPC_C_VAL 9
#define PAPER80_MDPC_T 84
#define PAPER80_MDPC_MAG_MAX 15

static const int TOY_H_BASE[TOY_MDPC_N0][TOY_MDPC_W] = {
    {0, 1, 3},
    {0, 2, 5},
};

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
    int row_local;
    int row_global;
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
    int w;
    int n;
    int l;
    int i_max;
    int c_val;
    int mag_max;
    int alpha_frac_w;
    int alpha_shift_0;
    int alpha_shift_1;
    int t;
    int segment_size;
    int *h_base;
} mdpc_config_t;

typedef struct {
    int row_count;
    int edge_count;
    int *row_offsets;
    row_edge_t *row_edges;
} mdpc_graph_t;

typedef struct {
    uint8_t *x_out_bits;
    int success;
    int iterations;
    int final_syndrome_weight;
} mdpc_result_t;

typedef struct {
    int capture_first_iter;
    row_state_t *first_row_state;
    msg_t *first_c2v;
    msg_t *first_u_next;
    int *syndrome_weight_hist;
    int *syndrome_nonzero_hist;
    uint64_t *syndrome_bits_hist;
    int success;
    int iterations;
} mdpc_trace_t;

static void mdpc_config_init_zero(mdpc_config_t *cfg) {
    memset(cfg, 0, sizeof(*cfg));
}

static void mdpc_config_free(mdpc_config_t *cfg) {
    free(cfg->h_base);
    mdpc_config_init_zero(cfg);
}

static int mdpc_config_alloc(mdpc_config_t *cfg) {
    cfg->n = cfg->n0 * cfg->r;
    cfg->segment_size = (cfg->r + cfg->l - 1) / cfg->l;
    cfg->h_base = (int *)calloc((size_t)cfg->n0 * (size_t)cfg->w, sizeof(int));
    return cfg->h_base == NULL ? -1 : 0;
}

static int mdpc_config_init_toy(mdpc_config_t *cfg) {
    int bank;
    int edge_idx;

    mdpc_config_init_zero(cfg);
    cfg->n0 = TOY_MDPC_N0;
    cfg->r = TOY_MDPC_R;
    cfg->w = TOY_MDPC_W;
    cfg->l = TOY_MDPC_L;
    cfg->i_max = TOY_MDPC_I_MAX;
    cfg->c_val = TOY_MDPC_C_VAL;
    cfg->mag_max = TOY_MDPC_MAG_MAX;
    cfg->alpha_frac_w = TOY_MDPC_ALPHA_FRAC_W;
    cfg->alpha_shift_0 = TOY_MDPC_ALPHA_SHIFT_0;
    cfg->alpha_shift_1 = TOY_MDPC_ALPHA_SHIFT_1;
    cfg->t = 1;
    if (mdpc_config_alloc(cfg) != 0) {
        return -1;
    }

    for (bank = 0; bank < cfg->n0; ++bank) {
        for (edge_idx = 0; edge_idx < cfg->w; ++edge_idx) {
            cfg->h_base[bank * cfg->w + edge_idx] = TOY_H_BASE[bank][edge_idx];
        }
    }
    return 0;
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

static int mdpc_config_init_paper80(mdpc_config_t *cfg, uint64_t seed) {
    int bank;
    uint64_t rng_state = seed;

    mdpc_config_init_zero(cfg);
    cfg->n0 = PAPER80_MDPC_N0;
    cfg->r = PAPER80_MDPC_R;
    cfg->w = PAPER80_MDPC_W;
    cfg->l = PAPER80_MDPC_L;
    cfg->i_max = PAPER80_MDPC_I_MAX;
    cfg->c_val = PAPER80_MDPC_C_VAL;
    cfg->mag_max = PAPER80_MDPC_MAG_MAX;
    cfg->alpha_frac_w = TOY_MDPC_ALPHA_FRAC_W;
    cfg->alpha_shift_0 = TOY_MDPC_ALPHA_SHIFT_0;
    cfg->alpha_shift_1 = TOY_MDPC_ALPHA_SHIFT_1;
    cfg->t = PAPER80_MDPC_T;
    if (mdpc_config_alloc(cfg) != 0) {
        return -1;
    }

    for (bank = 0; bank < cfg->n0; ++bank) {
        if (sample_unique_positions(&rng_state, cfg->r, cfg->w, &cfg->h_base[bank * cfg->w]) != 0) {
            mdpc_config_free(cfg);
            return -1;
        }
    }
    return 0;
}

static void mdpc_result_init_zero(mdpc_result_t *result) {
    memset(result, 0, sizeof(*result));
}

static int mdpc_result_init(mdpc_result_t *result, const mdpc_config_t *cfg) {
    mdpc_result_init_zero(result);
    result->x_out_bits = (uint8_t *)calloc((size_t)cfg->n, sizeof(uint8_t));
    return result->x_out_bits == NULL ? -1 : 0;
}

static void mdpc_result_free(mdpc_result_t *result) {
    free(result->x_out_bits);
    mdpc_result_init_zero(result);
}

static void mdpc_trace_init_zero(mdpc_trace_t *trace) {
    memset(trace, 0, sizeof(*trace));
}

static int mdpc_trace_init(mdpc_trace_t *trace, const mdpc_config_t *cfg, int capture_first_iter) {
    mdpc_trace_init_zero(trace);
    trace->capture_first_iter = capture_first_iter;
    trace->syndrome_weight_hist = (int *)calloc((size_t)cfg->i_max, sizeof(int));
    trace->syndrome_nonzero_hist = (int *)calloc((size_t)cfg->i_max, sizeof(int));
    if (trace->syndrome_weight_hist == NULL || trace->syndrome_nonzero_hist == NULL) {
        return -1;
    }
    if (cfg->r <= 64) {
        trace->syndrome_bits_hist = (uint64_t *)calloc((size_t)cfg->i_max, sizeof(uint64_t));
        if (trace->syndrome_bits_hist == NULL) {
            return -1;
        }
    }
    if (capture_first_iter) {
        trace->first_row_state = (row_state_t *)calloc((size_t)cfg->r, sizeof(row_state_t));
        trace->first_c2v = (msg_t *)calloc((size_t)cfg->n * (size_t)cfg->w, sizeof(msg_t));
        trace->first_u_next = (msg_t *)calloc((size_t)cfg->n * (size_t)cfg->w, sizeof(msg_t));
        if (trace->first_row_state == NULL || trace->first_c2v == NULL || trace->first_u_next == NULL) {
            return -1;
        }
    }
    return 0;
}

static void mdpc_trace_free(mdpc_trace_t *trace) {
    free(trace->first_row_state);
    free(trace->first_c2v);
    free(trace->first_u_next);
    free(trace->syndrome_weight_hist);
    free(trace->syndrome_nonzero_hist);
    free(trace->syndrome_bits_hist);
    mdpc_trace_init_zero(trace);
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

static msg_t msg_from_signed(const mdpc_config_t *cfg, int value) {
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

static int gamma_from_bit(const mdpc_config_t *cfg, uint8_t bit_value) {
    return bit_value ? -cfg->c_val : cfg->c_val;
}

static int alpha_scale(const mdpc_config_t *cfg, int value) {
    int abs_value = value < 0 ? -value : value;
    int scaled_abs = 0;

    scaled_abs += abs_value << (cfg->alpha_frac_w - cfg->alpha_shift_0);
    scaled_abs += abs_value << (cfg->alpha_frac_w - cfg->alpha_shift_1);
    scaled_abs += 1 << (cfg->alpha_frac_w - 1);
    scaled_abs >>= cfg->alpha_frac_w;
    return value < 0 ? -scaled_abs : scaled_abs;
}

static row_state_t row_state_init(const mdpc_config_t *cfg) {
    row_state_t state;

    state.min1 = cfg->mag_max;
    state.min2 = cfg->mag_max;
    state.min_id = 0;
    state.sign_xor = 0;
    return state;
}

static int edge_row_global(const mdpc_config_t *cfg, int bank, int col, int edge_slot) {
    return (cfg->h_base[bank * cfg->w + edge_slot] + col) % cfg->r;
}

static int lane_for_row(const mdpc_config_t *cfg, int row_global) {
    int lane_idx = row_global / cfg->segment_size;
    if (lane_idx >= cfg->l) {
        lane_idx = cfg->l - 1;
    }
    return lane_idx;
}

static int lane_row_base(const mdpc_config_t *cfg, int lane_idx) {
    return lane_idx * cfg->segment_size;
}

static void build_lane_edges(
    const mdpc_config_t *cfg,
    int var_idx,
    lane_edge_t *lane_edges,
    int *lane_count
) {
    int bank = var_idx / cfg->r;
    int col = var_idx % cfg->r;
    int edge_idx;
    int lane_idx;

    memset(lane_count, 0, sizeof(int) * (size_t)cfg->l);
    for (lane_idx = 0; lane_idx < cfg->l * cfg->w; ++lane_idx) {
        lane_edges[lane_idx].valid = 0;
    }

    for (edge_idx = 0; edge_idx < cfg->w; ++edge_idx) {
        int row_global = edge_row_global(cfg, bank, col, edge_idx);
        int slot;

        lane_idx = lane_for_row(cfg, row_global);
        slot = lane_count[lane_idx]++;
        lane_edges[lane_idx * cfg->w + slot].valid = 1;
        lane_edges[lane_idx * cfg->w + slot].row_global = row_global;
        lane_edges[lane_idx * cfg->w + slot].row_local = row_global - lane_row_base(cfg, lane_idx);
        lane_edges[lane_idx * cfg->w + slot].var_idx = var_idx;
        lane_edges[lane_idx * cfg->w + slot].edge_slot = edge_idx;
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
    const mdpc_config_t *cfg,
    uint8_t channel_bit,
    const msg_t *c2v,
    uint8_t *x_out,
    msg_t *u_next
) {
    int edge_idx;
    int sum_c2v = 0;
    int app;

    for (edge_idx = 0; edge_idx < cfg->w; ++edge_idx) {
        sum_c2v += msg_to_signed(c2v[edge_idx]);
    }

    app = gamma_from_bit(cfg, channel_bit) + alpha_scale(cfg, sum_c2v);
    *x_out = (uint8_t)(app < 0);

    for (edge_idx = 0; edge_idx < cfg->w; ++edge_idx) {
        int signed_c2v = msg_to_signed(c2v[edge_idx]);
        u_next[edge_idx] = msg_from_signed(cfg, app - alpha_scale(cfg, signed_c2v));
    }
}

static int mdpc_graph_build(const mdpc_config_t *cfg, mdpc_graph_t *graph) {
    int *row_counts;
    int *row_fill;
    int var_idx;
    int edge_idx;
    int total_edges = cfg->n * cfg->w;

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
        for (edge_idx = 0; edge_idx < cfg->w; ++edge_idx) {
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
        for (edge_idx = 0; edge_idx < cfg->w; ++edge_idx) {
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

static void mdpc_graph_free(mdpc_graph_t *graph) {
    free(graph->row_offsets);
    free(graph->row_edges);
    memset(graph, 0, sizeof(*graph));
}

static int syndrome_weight(
    const mdpc_config_t *cfg,
    const mdpc_graph_t *graph,
    const uint8_t *x_bits,
    uint64_t *syndrome_bits_out
) {
    int row_idx;
    int weight = 0;
    uint64_t syndrome_bits = 0;

    for (row_idx = 0; row_idx < cfg->r; ++row_idx) {
        int edge_pos;
        int parity = 0;
        for (edge_pos = graph->row_offsets[row_idx]; edge_pos < graph->row_offsets[row_idx + 1]; ++edge_pos) {
            parity ^= x_bits[graph->row_edges[edge_pos].var_idx];
        }
        if (parity) {
            weight += 1;
            if (cfg->r <= 64) {
                syndrome_bits |= (UINT64_C(1) << row_idx);
            }
        }
    }

    if (syndrome_bits_out != NULL) {
        *syndrome_bits_out = syndrome_bits;
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

static int mdpc_decode_schedule(
    const mdpc_config_t *cfg,
    const mdpc_graph_t *graph,
    const uint8_t *x_in,
    mdpc_result_t *out,
    mdpc_trace_t *trace
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
    u_mem = (msg_t *)calloc((size_t)cfg->n * (size_t)cfg->w, sizeof(msg_t));
    c2v_mem = (msg_t *)calloc((size_t)cfg->n * (size_t)cfg->w, sizeof(msg_t));
    sign_mem = (uint8_t *)calloc((size_t)cfg->n * (size_t)cfg->w, sizeof(uint8_t));
    x_work = (uint8_t *)calloc((size_t)cfg->n, sizeof(uint8_t));
    lane_edges = (lane_edge_t *)calloc((size_t)cfg->l * (size_t)cfg->w, sizeof(lane_edge_t));
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
        for (edge_idx = 0; edge_idx < cfg->w; ++edge_idx) {
            u_mem[iter * cfg->w + edge_idx] = msg_from_signed(cfg, gamma_from_bit(cfg, x_in[iter]));
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
                        const lane_edge_t *edge = &lane_edges[lane_idx * cfg->w + lane_slot];
                        int flat_idx = var_idx * cfg->w + edge->edge_slot;
                        cnu_a_step(u_mem[flat_idx], var_idx, &row_state_mem[edge->row_global]);
                        sign_mem[flat_idx] = u_mem[flat_idx].sign;
                    }
                }
            }
        }

        if (trace != NULL && trace->capture_first_iter && iter == 0) {
            memcpy(trace->first_row_state, row_state_mem, sizeof(row_state_t) * (size_t)cfg->r);
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
                        const lane_edge_t *edge = &lane_edges[lane_idx * cfg->w + lane_slot];
                        int flat_idx = var_idx * cfg->w + edge->edge_slot;
                        c2v_mem[flat_idx] = cnu_b_step(&row_state_mem[edge->row_global], sign_mem[flat_idx], var_idx);
                    }
                }
            }
        }

        if (trace != NULL && trace->capture_first_iter && iter == 0) {
            memcpy(trace->first_c2v, c2v_mem, sizeof(msg_t) * (size_t)cfg->n * (size_t)cfg->w);
        }

        for (var_idx = 0; var_idx < cfg->n; ++var_idx) {
            uint8_t x_next = 0;
            msg_t *c2v_row = &c2v_mem[var_idx * cfg->w];
            msg_t *u_row = &u_mem[var_idx * cfg->w];
            msg_t u_next[cfg->w];
            int edge_idx;

            vnu_step(cfg, x_in[var_idx], c2v_row, &x_next, u_next);
            x_work[var_idx] = x_next;
            for (edge_idx = 0; edge_idx < cfg->w; ++edge_idx) {
                u_row[edge_idx] = u_next[edge_idx];
            }
        }

        if (trace != NULL && trace->capture_first_iter && iter == 0) {
            memcpy(trace->first_u_next, u_mem, sizeof(msg_t) * (size_t)cfg->n * (size_t)cfg->w);
        }

        if (trace != NULL) {
            uint64_t syndrome_bits = 0;
            int weight = syndrome_weight(cfg, graph, x_work, &syndrome_bits);
            trace->syndrome_weight_hist[iter] = weight;
            trace->syndrome_nonzero_hist[iter] = weight != 0;
            if (trace->syndrome_bits_hist != NULL) {
                trace->syndrome_bits_hist[iter] = syndrome_bits;
            }
            if (weight == 0) {
                trace->success = 1;
                trace->iterations = iter + 1;
            }
        }

        if (out != NULL || trace != NULL) {
            int weight = syndrome_weight(cfg, graph, x_work, NULL);
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

static int mdpc_decode_rowcentric(
    const mdpc_config_t *cfg,
    const mdpc_graph_t *graph,
    const uint8_t *x_in,
    mdpc_result_t *out,
    mdpc_trace_t *trace
) {
    row_state_t *row_state_mem;
    msg_t *u_mem;
    msg_t *c2v_mem;
    uint8_t *x_work;
    int iter;

    row_state_mem = (row_state_t *)calloc((size_t)cfg->r, sizeof(row_state_t));
    u_mem = (msg_t *)calloc((size_t)cfg->n * (size_t)cfg->w, sizeof(msg_t));
    c2v_mem = (msg_t *)calloc((size_t)cfg->n * (size_t)cfg->w, sizeof(msg_t));
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
        for (edge_idx = 0; edge_idx < cfg->w; ++edge_idx) {
            u_mem[iter * cfg->w + edge_idx] = msg_from_signed(cfg, gamma_from_bit(cfg, x_in[iter]));
        }
    }

    for (iter = 0; iter < cfg->i_max; ++iter) {
        int row_idx;
        int var_idx;

        for (row_idx = 0; row_idx < cfg->r; ++row_idx) {
            row_state_mem[row_idx] = row_state_init(cfg);
            for (var_idx = graph->row_offsets[row_idx]; var_idx < graph->row_offsets[row_idx + 1]; ++var_idx) {
                const row_edge_t *edge = &graph->row_edges[var_idx];
                cnu_a_step(u_mem[edge->var_idx * cfg->w + edge->edge_slot], edge->var_idx, &row_state_mem[row_idx]);
            }
        }

        for (row_idx = 0; row_idx < cfg->r; ++row_idx) {
            for (var_idx = graph->row_offsets[row_idx]; var_idx < graph->row_offsets[row_idx + 1]; ++var_idx) {
                const row_edge_t *edge = &graph->row_edges[var_idx];
                msg_t u_msg = u_mem[edge->var_idx * cfg->w + edge->edge_slot];
                c2v_mem[edge->var_idx * cfg->w + edge->edge_slot] =
                    cnu_b_step(&row_state_mem[row_idx], u_msg.sign, edge->var_idx);
            }
        }

        for (var_idx = 0; var_idx < cfg->n; ++var_idx) {
            uint8_t x_next = 0;
            msg_t u_next[cfg->w];
            int edge_idx;
            vnu_step(cfg, x_in[var_idx], &c2v_mem[var_idx * cfg->w], &x_next, u_next);
            x_work[var_idx] = x_next;
            for (edge_idx = 0; edge_idx < cfg->w; ++edge_idx) {
                u_mem[var_idx * cfg->w + edge_idx] = u_next[edge_idx];
            }
        }

        if (trace != NULL) {
            int weight = syndrome_weight(cfg, graph, x_work, NULL);
            trace->syndrome_weight_hist[iter] = weight;
            trace->syndrome_nonzero_hist[iter] = weight != 0;
            if (weight == 0) {
                trace->success = 1;
                trace->iterations = iter + 1;
            }
        }

        if (out != NULL || trace != NULL) {
            int weight = syndrome_weight(cfg, graph, x_work, NULL);
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

static uint16_t pack_bits16(const uint8_t *bits, int bit_count) {
    int idx;
    uint16_t packed = 0;

    for (idx = 0; idx < bit_count; ++idx) {
        packed |= (uint16_t)((bits[idx] & 1u) << idx);
    }
    return packed;
}

static void emit_logic_vector(FILE *fp, const char *name, uint16_t value, int bit_count) {
    fprintf(fp, "localparam logic [%d:0] %s = %d'h%04X;\n", bit_count - 1, name, bit_count, value);
}

static void emit_int_array(FILE *fp, const char *name, const int *values, int len) {
    int idx;
    fprintf(fp, "localparam int %s [0:%d] = '{", name, len - 1);
    for (idx = 0; idx < len; ++idx) {
        fprintf(fp, "%s%d", idx == 0 ? "" : ", ", values[idx]);
    }
    fprintf(fp, "};\n");
}

static void emit_u64_array_as_int(FILE *fp, const char *name, const uint64_t *values, int len) {
    int *tmp = (int *)calloc((size_t)len, sizeof(int));
    int idx;

    if (tmp == NULL) {
        fprintf(stderr, "allocation failure while emitting syndrome history\n");
        exit(1);
    }
    for (idx = 0; idx < len; ++idx) {
        tmp[idx] = (int)values[idx];
    }
    emit_int_array(fp, name, tmp, len);
    free(tmp);
}

static void emit_row_state_arrays(FILE *fp, const mdpc_config_t *cfg, const mdpc_trace_t *trace) {
    int idx;
    int *min1 = (int *)calloc((size_t)cfg->r, sizeof(int));
    int *min2 = (int *)calloc((size_t)cfg->r, sizeof(int));
    int *min_id = (int *)calloc((size_t)cfg->r, sizeof(int));
    int *sign_xor = (int *)calloc((size_t)cfg->r, sizeof(int));

    if (min1 == NULL || min2 == NULL || min_id == NULL || sign_xor == NULL) {
        fprintf(stderr, "allocation failure while emitting row-state arrays\n");
        exit(1);
    }

    for (idx = 0; idx < cfg->r; ++idx) {
        min1[idx] = trace->first_row_state[idx].min1;
        min2[idx] = trace->first_row_state[idx].min2;
        min_id[idx] = trace->first_row_state[idx].min_id;
        sign_xor[idx] = trace->first_row_state[idx].sign_xor;
    }
    emit_int_array(fp, "CASE1_FIRST_ROW_MIN1", min1, cfg->r);
    emit_int_array(fp, "CASE1_FIRST_ROW_MIN2", min2, cfg->r);
    emit_int_array(fp, "CASE1_FIRST_ROW_MIN_ID", min_id, cfg->r);
    emit_int_array(fp, "CASE1_FIRST_ROW_SIGN_XOR", sign_xor, cfg->r);

    free(min1);
    free(min2);
    free(min_id);
    free(sign_xor);
}

static void emit_msg_arrays(FILE *fp, const char *sign_name, const char *mag_name, const msg_t *values, int flat_len) {
    int *sign_values = (int *)calloc((size_t)flat_len, sizeof(int));
    int *mag_values = (int *)calloc((size_t)flat_len, sizeof(int));
    int flat_idx;

    if (sign_values == NULL || mag_values == NULL) {
        fprintf(stderr, "allocation failure while emitting message arrays\n");
        exit(1);
    }

    for (flat_idx = 0; flat_idx < flat_len; ++flat_idx) {
        sign_values[flat_idx] = values[flat_idx].sign;
        mag_values[flat_idx] = values[flat_idx].mag;
    }

    emit_int_array(fp, sign_name, sign_values, flat_len);
    emit_int_array(fp, mag_name, mag_values, flat_len);
    free(sign_values);
    free(mag_values);
}

static int mdpc_emit_svh(const mdpc_config_t *cfg, const mdpc_graph_t *graph, const char *path) {
    uint8_t case0_bits[TOY_MDPC_N] = {0};
    uint8_t case1_bits[TOY_MDPC_N] = {0};
    mdpc_result_t case0_result;
    mdpc_result_t case1_result;
    mdpc_trace_t case0_trace;
    mdpc_trace_t case1_trace;
    int found_success = 0;
    int bit_idx;
    FILE *fp;

    if (cfg->n != TOY_MDPC_N || cfg->r > 64) {
        fprintf(stderr, "--emit-svh is only supported for the toy demo configuration\n");
        return 1;
    }

    mdpc_result_init(&case0_result, cfg);
    mdpc_result_init(&case1_result, cfg);
    mdpc_trace_init(&case0_trace, cfg, 1);
    mdpc_trace_init(&case1_trace, cfg, 1);
    mdpc_decode_schedule(cfg, graph, case0_bits, &case0_result, &case0_trace);

    for (bit_idx = 0; bit_idx < cfg->n; ++bit_idx) {
        uint8_t trial_bits[TOY_MDPC_N] = {0};
        mdpc_result_t trial_result;
        mdpc_trace_t trial_trace;
        trial_bits[bit_idx] = 1;
        mdpc_result_init(&trial_result, cfg);
        mdpc_trace_init(&trial_trace, cfg, 1);
        mdpc_decode_schedule(cfg, graph, trial_bits, &trial_result, &trial_trace);
        if (bit_idx == 0 || (!found_success && trial_result.success)) {
            memcpy(case1_bits, trial_bits, sizeof(case1_bits));
            mdpc_result_free(&case1_result);
            mdpc_trace_free(&case1_trace);
            case1_result = trial_result;
            case1_trace = trial_trace;
        } else {
            mdpc_result_free(&trial_result);
            mdpc_trace_free(&trial_trace);
        }
        if (trial_result.success) {
            found_success = 1;
            break;
        }
    }

    fp = fopen(path, "w");
    if (fp == NULL) {
        perror("fopen");
        mdpc_result_free(&case0_result);
        mdpc_result_free(&case1_result);
        mdpc_trace_free(&case0_trace);
        mdpc_trace_free(&case1_trace);
        return 1;
    }

    fprintf(fp, "`ifndef MDPC_DEMO_VECTORS_SVH\n");
    fprintf(fp, "`define MDPC_DEMO_VECTORS_SVH\n\n");

    emit_logic_vector(fp, "CASE0_INPUT", pack_bits16(case0_bits, cfg->n), cfg->n);
    emit_logic_vector(fp, "CASE0_OUTPUT", pack_bits16(case0_result.x_out_bits, cfg->n), cfg->n);
    fprintf(fp, "localparam int CASE0_SUCCESS = %d;\n", case0_result.success);
    fprintf(fp, "localparam int CASE0_ITERATIONS = %d;\n", case0_result.iterations);
    emit_u64_array_as_int(fp, "CASE0_SYNDROME_HIST", case0_trace.syndrome_bits_hist, cfg->i_max);
    fprintf(fp, "\n");

    emit_logic_vector(fp, "CASE1_INPUT", pack_bits16(case1_bits, cfg->n), cfg->n);
    emit_logic_vector(fp, "CASE1_OUTPUT", pack_bits16(case1_result.x_out_bits, cfg->n), cfg->n);
    fprintf(fp, "localparam int CASE1_SUCCESS = %d;\n", case1_result.success);
    fprintf(fp, "localparam int CASE1_ITERATIONS = %d;\n", case1_result.iterations);
    fprintf(fp, "localparam int CASE1_IS_CONVERGED_VECTOR = %d;\n", found_success);
    emit_u64_array_as_int(fp, "CASE1_SYNDROME_HIST", case1_trace.syndrome_bits_hist, cfg->i_max);
    emit_row_state_arrays(fp, cfg, &case1_trace);
    emit_msg_arrays(fp, "CASE1_FIRST_C2V_SIGN", "CASE1_FIRST_C2V_MAG", case1_trace.first_c2v, cfg->n * cfg->w);
    emit_msg_arrays(fp, "CASE1_FIRST_U_SIGN", "CASE1_FIRST_U_MAG", case1_trace.first_u_next, cfg->n * cfg->w);
    fprintf(fp, "\n`endif\n");

    fclose(fp);
    mdpc_result_free(&case0_result);
    mdpc_result_free(&case1_result);
    mdpc_trace_free(&case0_trace);
    mdpc_trace_free(&case1_trace);
    return 0;
}

static int results_match(
    const mdpc_config_t *cfg,
    const mdpc_result_t *schedule_result,
    const mdpc_trace_t *schedule_trace,
    const mdpc_result_t *row_result,
    const mdpc_trace_t *row_trace
) {
    int iter;
    int bit_idx;

    if (schedule_result->success != row_result->success) {
        fprintf(stderr, "model mismatch: success differs (%d vs %d)\n", schedule_result->success, row_result->success);
        return 0;
    }
    if (schedule_result->iterations != row_result->iterations) {
        fprintf(stderr, "model mismatch: iterations differ (%d vs %d)\n", schedule_result->iterations, row_result->iterations);
        return 0;
    }
    if (schedule_result->final_syndrome_weight != row_result->final_syndrome_weight) {
        fprintf(stderr, "model mismatch: final syndrome weight differs (%d vs %d)\n",
            schedule_result->final_syndrome_weight, row_result->final_syndrome_weight);
        return 0;
    }
    for (bit_idx = 0; bit_idx < cfg->n; ++bit_idx) {
        if (schedule_result->x_out_bits[bit_idx] != row_result->x_out_bits[bit_idx]) {
            fprintf(stderr, "model mismatch: x_out bit %d differs (%d vs %d)\n",
                bit_idx, schedule_result->x_out_bits[bit_idx], row_result->x_out_bits[bit_idx]);
            return 0;
        }
    }
    for (iter = 0; iter < cfg->i_max; ++iter) {
        if (schedule_trace->syndrome_nonzero_hist[iter] != row_trace->syndrome_nonzero_hist[iter]) {
            fprintf(stderr, "model mismatch: syndrome nonzero hist differs at iter %d (%d vs %d)\n",
                iter, schedule_trace->syndrome_nonzero_hist[iter], row_trace->syndrome_nonzero_hist[iter]);
            return 0;
        }
    }
    return 1;
}

static int generate_error_vector(const mdpc_config_t *cfg, uint64_t seed, uint8_t *x_in) {
    int *positions;
    uint64_t rng_state = seed ^ UINT64_C(0xA5A5A5A5A5A5A5A5);
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

static void print_positions(const mdpc_config_t *cfg, int bank_limit) {
    int bank;
    int edge_idx;
    for (bank = 0; bank < bank_limit; ++bank) {
        printf("H%d first-column support:", bank);
        for (edge_idx = 0; edge_idx < cfg->w; ++edge_idx) {
            printf("%s%d", edge_idx == 0 ? " " : ", ", cfg->h_base[bank * cfg->w + edge_idx]);
        }
        printf("\n");
    }
}

static int run_paper80_once(uint64_t seed) {
    mdpc_config_t cfg;
    mdpc_graph_t graph;
    mdpc_result_t schedule_result;
    mdpc_result_t row_result;
    mdpc_trace_t schedule_trace;
    mdpc_trace_t row_trace;
    uint8_t *x_in;
    int rc = 1;

    mdpc_config_init_zero(&cfg);
    memset(&graph, 0, sizeof(graph));
    mdpc_result_init_zero(&schedule_result);
    mdpc_result_init_zero(&row_result);
    mdpc_trace_init_zero(&schedule_trace);
    mdpc_trace_init_zero(&row_trace);

    if (mdpc_config_init_paper80(&cfg, seed) != 0) {
        fprintf(stderr, "failed to initialize paper80 config\n");
        goto done;
    }
    if (mdpc_graph_build(&cfg, &graph) != 0) {
        fprintf(stderr, "failed to build graph\n");
        goto done;
    }
    if (mdpc_result_init(&schedule_result, &cfg) != 0 || mdpc_result_init(&row_result, &cfg) != 0) {
        fprintf(stderr, "failed to allocate result buffers\n");
        goto done;
    }
    if (mdpc_trace_init(&schedule_trace, &cfg, 0) != 0 || mdpc_trace_init(&row_trace, &cfg, 0) != 0) {
        fprintf(stderr, "failed to allocate trace buffers\n");
        goto done;
    }

    x_in = (uint8_t *)calloc((size_t)cfg.n, sizeof(uint8_t));
    if (x_in == NULL) {
        fprintf(stderr, "failed to allocate input buffer\n");
        goto done;
    }
    if (generate_error_vector(&cfg, seed, x_in) != 0) {
        fprintf(stderr, "failed to generate deterministic error vector\n");
        free(x_in);
        goto done;
    }

    if (mdpc_decode_schedule(&cfg, &graph, x_in, &schedule_result, &schedule_trace) != 0) {
        fprintf(stderr, "schedule-aware decode failed\n");
        free(x_in);
        goto done;
    }
    if (mdpc_decode_rowcentric(&cfg, &graph, x_in, &row_result, &row_trace) != 0) {
        fprintf(stderr, "row-centric decode failed\n");
        free(x_in);
        goto done;
    }
    free(x_in);

    if (!results_match(&cfg, &schedule_result, &schedule_trace, &row_result, &row_trace)) {
        goto done;
    }

    printf("paper80 seed=%" PRIu64 " models_agree=yes success=%d iterations=%d final_syndrome_weight=%d\n",
        seed, schedule_result.success, schedule_result.iterations, schedule_result.final_syndrome_weight);
    print_positions(&cfg, cfg.n0);
    rc = 0;

done:
    mdpc_result_free(&schedule_result);
    mdpc_result_free(&row_result);
    mdpc_trace_free(&schedule_trace);
    mdpc_trace_free(&row_trace);
    mdpc_graph_free(&graph);
    mdpc_config_free(&cfg);
    return rc;
}

static int run_paper80_batch(uint64_t base_seed, int trials) {
    int trial_idx;
    int success_count = 0;
    int failure_count = 0;
    int first_success_iterations = 0;
    int have_first_success = 0;
    uint64_t first_success_seed = 0;

    printf("paper80 batch base_seed=%" PRIu64 " trials=%d\n", base_seed, trials);
    for (trial_idx = 0; trial_idx < trials; ++trial_idx) {
        uint64_t seed = base_seed + (uint64_t)trial_idx;
        mdpc_config_t cfg;
        mdpc_graph_t graph;
        mdpc_result_t schedule_result;
        mdpc_result_t row_result;
        mdpc_trace_t schedule_trace;
        mdpc_trace_t row_trace;
        uint8_t *x_in;

        mdpc_config_init_zero(&cfg);
        memset(&graph, 0, sizeof(graph));
        mdpc_result_init_zero(&schedule_result);
        mdpc_result_init_zero(&row_result);
        mdpc_trace_init_zero(&schedule_trace);
        mdpc_trace_init_zero(&row_trace);

        if (mdpc_config_init_paper80(&cfg, seed) != 0 || mdpc_graph_build(&cfg, &graph) != 0 ||
            mdpc_result_init(&schedule_result, &cfg) != 0 || mdpc_result_init(&row_result, &cfg) != 0 ||
            mdpc_trace_init(&schedule_trace, &cfg, 0) != 0 || mdpc_trace_init(&row_trace, &cfg, 0) != 0) {
            fprintf(stderr, "batch setup failed for seed %" PRIu64 "\n", seed);
            mdpc_result_free(&schedule_result);
            mdpc_result_free(&row_result);
            mdpc_trace_free(&schedule_trace);
            mdpc_trace_free(&row_trace);
            mdpc_graph_free(&graph);
            mdpc_config_free(&cfg);
            return 1;
        }

        x_in = (uint8_t *)calloc((size_t)cfg.n, sizeof(uint8_t));
        if (x_in == NULL || generate_error_vector(&cfg, seed, x_in) != 0 ||
            mdpc_decode_schedule(&cfg, &graph, x_in, &schedule_result, &schedule_trace) != 0 ||
            mdpc_decode_rowcentric(&cfg, &graph, x_in, &row_result, &row_trace) != 0) {
            fprintf(stderr, "batch execution failed for seed %" PRIu64 "\n", seed);
            free(x_in);
            mdpc_result_free(&schedule_result);
            mdpc_result_free(&row_result);
            mdpc_trace_free(&schedule_trace);
            mdpc_trace_free(&row_trace);
            mdpc_graph_free(&graph);
            mdpc_config_free(&cfg);
            return 1;
        }
        free(x_in);

        if (!results_match(&cfg, &schedule_result, &schedule_trace, &row_result, &row_trace)) {
            mdpc_result_free(&schedule_result);
            mdpc_result_free(&row_result);
            mdpc_trace_free(&schedule_trace);
            mdpc_trace_free(&row_trace);
            mdpc_graph_free(&graph);
            mdpc_config_free(&cfg);
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

        printf(
            "  seed=%" PRIu64 " success=%d iterations=%d final_syndrome_weight=%d\n",
            seed,
            schedule_result.success,
            schedule_result.iterations,
            schedule_result.final_syndrome_weight
        );

        mdpc_result_free(&schedule_result);
        mdpc_result_free(&row_result);
        mdpc_trace_free(&schedule_trace);
        mdpc_trace_free(&row_trace);
        mdpc_graph_free(&graph);
        mdpc_config_free(&cfg);
    }

    printf("paper80 batch summary: successes=%d failures=%d\n", success_count, failure_count);
    if (have_first_success) {
        printf("first_success_seed=%" PRIu64 " first_success_iterations=%d\n",
            first_success_seed, first_success_iterations);
    } else {
        printf("first_success_seed=none\n");
    }
    return 0;
}

static int run_self_test(void) {
    mdpc_config_t cfg;
    mdpc_graph_t graph;
    uint8_t *x_in;
    int rc = 1;
    int bit_idx;

    mdpc_config_init_zero(&cfg);
    memset(&graph, 0, sizeof(graph));
    if (mdpc_config_init_toy(&cfg) != 0 || mdpc_graph_build(&cfg, &graph) != 0) {
        fprintf(stderr, "self-test setup failed\n");
        goto done;
    }

    if (alpha_scale(&cfg, 31) != 3 || alpha_scale(&cfg, -31) != -3) {
        fprintf(stderr, "self-test failed: alpha_scale mismatch\n");
        goto done;
    }
    {
        msg_t sat_pos = msg_from_signed(&cfg, 27);
        msg_t sat_neg = msg_from_signed(&cfg, -27);
        if (sat_pos.sign != 0 || sat_pos.mag != cfg.mag_max || sat_neg.sign != 1 || sat_neg.mag != cfg.mag_max) {
            fprintf(stderr, "self-test failed: saturation mismatch\n");
            goto done;
        }
    }

    x_in = (uint8_t *)calloc((size_t)cfg.n, sizeof(uint8_t));
    if (x_in == NULL) {
        fprintf(stderr, "self-test allocation failed\n");
        goto done;
    }

    for (bit_idx = 0; bit_idx < cfg.n; ++bit_idx) {
        mdpc_result_t schedule_result;
        mdpc_result_t row_result;
        mdpc_trace_t schedule_trace;
        mdpc_trace_t row_trace;
        memset(x_in, 0, (size_t)cfg.n);
        x_in[bit_idx] = 1;
        mdpc_result_init_zero(&schedule_result);
        mdpc_result_init_zero(&row_result);
        mdpc_trace_init_zero(&schedule_trace);
        mdpc_trace_init_zero(&row_trace);
        if (mdpc_result_init(&schedule_result, &cfg) != 0 || mdpc_result_init(&row_result, &cfg) != 0 ||
            mdpc_trace_init(&schedule_trace, &cfg, 0) != 0 || mdpc_trace_init(&row_trace, &cfg, 0) != 0 ||
            mdpc_decode_schedule(&cfg, &graph, x_in, &schedule_result, &schedule_trace) != 0 ||
            mdpc_decode_rowcentric(&cfg, &graph, x_in, &row_result, &row_trace) != 0 ||
            !results_match(&cfg, &schedule_result, &schedule_trace, &row_result, &row_trace)) {
            fprintf(stderr, "self-test failed: toy single-bit case %d mismatch\n", bit_idx);
            mdpc_result_free(&schedule_result);
            mdpc_result_free(&row_result);
            mdpc_trace_free(&schedule_trace);
            mdpc_trace_free(&row_trace);
            free(x_in);
            goto done;
        }
        mdpc_result_free(&schedule_result);
        mdpc_result_free(&row_result);
        mdpc_trace_free(&schedule_trace);
        mdpc_trace_free(&row_trace);
    }

    memset(x_in, 0, (size_t)cfg.n);
    x_in[0] = 1;
    x_in[5] = 1;
    {
        mdpc_result_t schedule_result;
        mdpc_result_t row_result;
        mdpc_trace_t schedule_trace;
        mdpc_trace_t row_trace;
        mdpc_result_init_zero(&schedule_result);
        mdpc_result_init_zero(&row_result);
        mdpc_trace_init_zero(&schedule_trace);
        mdpc_trace_init_zero(&row_trace);
        if (mdpc_result_init(&schedule_result, &cfg) != 0 || mdpc_result_init(&row_result, &cfg) != 0 ||
            mdpc_trace_init(&schedule_trace, &cfg, 0) != 0 || mdpc_trace_init(&row_trace, &cfg, 0) != 0 ||
            mdpc_decode_schedule(&cfg, &graph, x_in, &schedule_result, &schedule_trace) != 0 ||
            mdpc_decode_rowcentric(&cfg, &graph, x_in, &row_result, &row_trace) != 0 ||
            !results_match(&cfg, &schedule_result, &schedule_trace, &row_result, &row_trace)) {
            fprintf(stderr, "self-test failed: toy two-bit case mismatch\n");
            mdpc_result_free(&schedule_result);
            mdpc_result_free(&row_result);
            mdpc_trace_free(&schedule_trace);
            mdpc_trace_free(&row_trace);
            free(x_in);
            goto done;
        }
        mdpc_result_free(&schedule_result);
        mdpc_result_free(&row_result);
        mdpc_trace_free(&schedule_trace);
        mdpc_trace_free(&row_trace);
    }

    free(x_in);
    printf("golden self-test PASS\n");
    rc = 0;

done:
    mdpc_graph_free(&graph);
    mdpc_config_free(&cfg);
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
        "  %s --emit-svh <path>\n"
        "  %s --paper80-once --seed <u64>\n"
        "  %s --paper80-batch --base-seed <u64> --trials <n>\n"
        "  %s --self-test\n",
        argv0, argv0, argv0, argv0);
}

int main(int argc, char **argv) {
    if (argc == 3 && strcmp(argv[1], "--emit-svh") == 0) {
        mdpc_config_t cfg;
        mdpc_graph_t graph;
        int rc;
        mdpc_config_init_zero(&cfg);
        memset(&graph, 0, sizeof(graph));
        if (mdpc_config_init_toy(&cfg) != 0 || mdpc_graph_build(&cfg, &graph) != 0) {
            fprintf(stderr, "failed to initialize toy config\n");
            mdpc_graph_free(&graph);
            mdpc_config_free(&cfg);
            return 1;
        }
        rc = mdpc_emit_svh(&cfg, &graph, argv[2]);
        mdpc_graph_free(&graph);
        mdpc_config_free(&cfg);
        return rc;
    }

    if (argc == 4 && strcmp(argv[1], "--paper80-once") == 0 && strcmp(argv[2], "--seed") == 0) {
        uint64_t seed;
        if (parse_u64(argv[3], &seed) != 0) {
            usage(argv[0]);
            return 1;
        }
        return run_paper80_once(seed);
    }

    if (argc == 6 && strcmp(argv[1], "--paper80-batch") == 0) {
        uint64_t base_seed = 0;
        int trials = 0;
        int idx;
        for (idx = 2; idx < argc; idx += 2) {
            if (strcmp(argv[idx], "--base-seed") == 0) {
                if (parse_u64(argv[idx + 1], &base_seed) != 0) {
                    usage(argv[0]);
                    return 1;
                }
            } else if (strcmp(argv[idx], "--trials") == 0) {
                if (parse_int(argv[idx + 1], &trials) != 0 || trials <= 0) {
                    usage(argv[0]);
                    return 1;
                }
            } else {
                usage(argv[0]);
                return 1;
            }
        }
        return run_paper80_batch(base_seed, trials);
    }

    if (argc == 2 && strcmp(argv[1], "--self-test") == 0) {
        return run_self_test();
    }

    usage(argv[0]);
    return 1;
}
