// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtb_mdpc_decoder_demo.h for the primary calling header

#ifndef VERILATED_VTB_MDPC_DECODER_DEMO___024ROOT_H_
#define VERILATED_VTB_MDPC_DECODER_DEMO___024ROOT_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"
class Vtb_mdpc_decoder_demo_mdpc_demo_pkg;


class Vtb_mdpc_decoder_demo__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vtb_mdpc_decoder_demo___024root final {
  public:
    // CELLS
    Vtb_mdpc_decoder_demo_mdpc_demo_pkg* __PVT__mdpc_demo_pkg;

    // DESIGN SPECIFIC STATE
    // Anonymous structures to workaround compiler member-count bugs
    struct {
        CData/*0:0*/ tb_mdpc_decoder_demo__DOT__clk;
        CData/*0:0*/ tb_mdpc_decoder_demo__DOT__rst_n;
        CData/*0:0*/ tb_mdpc_decoder_demo__DOT__start;
        CData/*0:0*/ tb_mdpc_decoder_demo__DOT__done;
        CData/*0:0*/ tb_mdpc_decoder_demo__DOT__success;
        CData/*2:0*/ tb_mdpc_decoder_demo__DOT__iter_count;
        CData/*2:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__state;
        CData/*3:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx;
        CData/*1:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__scan_slot;
        CData/*0:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__cnu_a_sign0;
        CData/*0:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__cnu_a_sign1;
        CData/*0:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__vnu_x_out;
        CData/*7:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_next;
        CData/*0:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__advance_var;
        CData/*2:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__next_iter_count;
        CData/*0:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__stop_decode;
        CData/*0:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__m_clear_en;
        CData/*0:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__m_wr_en0;
        CData/*0:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__m_wr_en1;
        CData/*0:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__i_shift_en;
        CData/*4:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__1;
        CData/*4:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_hd74e08e1__0;
        CData/*4:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__0;
        CData/*4:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h22a87440__0;
        CData/*4:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_6__i_entry_pack;
        CData/*1:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_5__i_entry_edge_slot;
        CData/*2:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_4__row_local_from_global;
        CData/*2:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_3__row_global_from_lane_local;
        CData/*2:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_2__i_entry_row_local;
        CData/*0:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT____Vlvbound_h6bd7c583__0;
        CData/*0:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT____Vlvbound_hfe6829d9__0;
        CData/*4:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT____Vlvbound_h88b19d0e__0;
        CData/*4:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT____Vlvbound_h72129cb2__0;
        CData/*4:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hd4376c56__0;
        CData/*4:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
        CData/*4:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
        CData/*3:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_13__mag_from_int;
        CData/*3:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_12__row_state_min2;
        CData/*3:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_11__mag_from_int;
        CData/*3:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_10__row_state_min1;
        CData/*3:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_9__row_state_min1;
        CData/*0:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_8__msg_sign;
        CData/*0:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_7__row_state_sign_xor;
        CData/*1:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_6__row_state_valid_count;
        CData/*0:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_5__msg_sign;
        CData/*3:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_4__mag_from_int;
        CData/*3:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_3__mag_from_int;
        CData/*3:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_13__mag_from_int;
        CData/*3:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_12__row_state_min2;
        CData/*3:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_11__mag_from_int;
        CData/*3:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_10__row_state_min1;
        CData/*3:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_9__row_state_min1;
        CData/*0:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_8__msg_sign;
        CData/*0:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_7__row_state_sign_xor;
        CData/*1:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_6__row_state_valid_count;
        CData/*0:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_5__msg_sign;
        CData/*3:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_4__mag_from_int;
        CData/*3:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_3__mag_from_int;
        CData/*7:0*/ __Vfunc_syndrome_vector__17__syndrome;
        CData/*0:0*/ __Vfunc_syndrome_vector__17__parity;
        CData/*4:0*/ __Vfunc_i_entry_row_local__42__i_entry;
        CData/*2:0*/ __Vfunc_row_global_from_lane_local__43__row_local;
        CData/*4:0*/ __Vfunc_i_entry_edge_slot__46__i_entry;
        CData/*2:0*/ __Vfunc_i_entry_pack__47__row_local;
    };
    struct {
        CData/*1:0*/ __Vfunc_i_entry_pack__47__edge_slot;
        CData/*2:0*/ __Vfunc_i_entry_row_local__48__Vfuncout;
        CData/*4:0*/ __Vfunc_i_entry_row_local__48__i_entry;
        CData/*2:0*/ __Vfunc_row_global_from_lane_local__49__Vfuncout;
        CData/*2:0*/ __Vfunc_row_global_from_lane_local__49__row_local;
        CData/*1:0*/ __Vfunc_i_entry_edge_slot__50__Vfuncout;
        CData/*4:0*/ __Vfunc_i_entry_edge_slot__50__i_entry;
        CData/*2:0*/ __Vfunc_lane_edge_pack__51__row_local;
        CData/*2:0*/ __Vfunc_lane_edge_pack__51__row_global;
        CData/*3:0*/ __Vfunc_lane_edge_pack__51__var_idx;
        CData/*1:0*/ __Vfunc_lane_edge_pack__51__edge_slot;
        CData/*3:0*/ __Vfunc_mag_from_int__85__result;
        CData/*3:0*/ __Vfunc_mag_from_int__87__result;
        CData/*4:0*/ __Vfunc_msg_sign__89__msg;
        CData/*3:0*/ __Vfunc_row_state_pack__90__min1;
        CData/*3:0*/ __Vfunc_row_state_pack__90__min2;
        CData/*3:0*/ __Vfunc_row_state_pack__90__min_id;
        CData/*0:0*/ __Vfunc_row_state_pack__90__sign_xor;
        CData/*4:0*/ __Vfunc_msg_sign__93__msg;
        CData/*0:0*/ __Vfunc_row_state_set_sign_xor__94__sign_xor;
        CData/*1:0*/ __Vfunc_row_state_set_valid_count__95__valid_count;
        CData/*3:0*/ __Vfunc_row_state_set_min2__98__min2;
        CData/*3:0*/ __Vfunc_mag_from_int__99__result;
        CData/*3:0*/ __Vfunc_row_state_set_min1__101__min1;
        CData/*3:0*/ __Vfunc_row_state_set_min_id__102__min_id;
        CData/*3:0*/ __Vfunc_mag_from_int__104__result;
        CData/*3:0*/ __Vfunc_row_state_set_min2__106__min2;
        CData/*3:0*/ __Vfunc_mag_from_int__111__result;
        CData/*3:0*/ __Vfunc_mag_from_int__113__result;
        CData/*4:0*/ __Vfunc_msg_sign__115__msg;
        CData/*3:0*/ __Vfunc_row_state_pack__116__min1;
        CData/*3:0*/ __Vfunc_row_state_pack__116__min2;
        CData/*3:0*/ __Vfunc_row_state_pack__116__min_id;
        CData/*0:0*/ __Vfunc_row_state_pack__116__sign_xor;
        CData/*4:0*/ __Vfunc_msg_sign__119__msg;
        CData/*0:0*/ __Vfunc_row_state_set_sign_xor__120__sign_xor;
        CData/*1:0*/ __Vfunc_row_state_set_valid_count__121__valid_count;
        CData/*3:0*/ __Vfunc_row_state_set_min2__124__min2;
        CData/*3:0*/ __Vfunc_mag_from_int__125__result;
        CData/*3:0*/ __Vfunc_row_state_set_min1__127__min1;
        CData/*3:0*/ __Vfunc_row_state_set_min_id__128__min_id;
        CData/*3:0*/ __Vfunc_mag_from_int__130__result;
        CData/*3:0*/ __Vfunc_row_state_set_min2__132__min2;
        CData/*0:0*/ __Vfunc_msg_to_signed__143____VlefCall_1__msg_sign;
        CData/*3:0*/ __Vfunc_msg_to_signed__143____VlefCall_0__msg_mag;
        CData/*3:0*/ __Vfunc_msg_mag__144__Vfuncout;
        CData/*4:0*/ __Vfunc_msg_mag__144__msg;
        CData/*0:0*/ __Vfunc_msg_sign__145__Vfuncout;
        CData/*4:0*/ __Vfunc_msg_sign__145__msg;
        CData/*0:0*/ __VstlFirstIteration;
        CData/*0:0*/ __VstlPhaseResult;
        CData/*0:0*/ __Vtrigprevexpr___TOP__tb_mdpc_decoder_demo__DOT__clk__0;
        CData/*0:0*/ __Vtrigprevexpr___TOP__tb_mdpc_decoder_demo__DOT__rst_n__0;
        CData/*0:0*/ __Vtrigprevexpr___TOP__tb_mdpc_decoder_demo__DOT__done__0;
        CData/*0:0*/ __Vtrigprevexpr_h95049e09__1;
        CData/*0:0*/ __Vtrigprevexpr_h4f3ec4ef__1;
        CData/*0:0*/ __Vtrigprevexpr_h87f7365b__1;
        CData/*0:0*/ __VactPhaseResult;
        CData/*0:0*/ __VinactPhaseResult;
        CData/*0:0*/ __VnbaPhaseResult;
        SData/*15:0*/ tb_mdpc_decoder_demo__DOT__x_in;
        SData/*15:0*/ tb_mdpc_decoder_demo__DOT__x_out;
        SData/*12:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge0;
        SData/*12:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge1;
    };
    struct {
        SData/*14:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__m_row_state_a0;
        SData/*14:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__m_row_state_a1;
        SData/*12:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT____Vlvbound_hd03a4323__0;
        SData/*12:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT____VlemCall_0__lane_edge_pack;
        SData/*15:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_c0_ram__DOT__mem;
        SData/*15:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_c1_ram__DOT__mem;
        SData/*14:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__next_state;
        SData/*14:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__next_state;
        SData/*15:0*/ __Vfunc_syndrome_vector__17__x_bits;
        SData/*14:0*/ __Vfunc_row_state_pack__90__Vfuncout;
        SData/*14:0*/ __Vfunc_row_state_valid_count__91__state;
        SData/*14:0*/ __Vfunc_row_state_sign_xor__92__state;
        SData/*14:0*/ __Vfunc_row_state_set_sign_xor__94__Vfuncout;
        SData/*14:0*/ __Vfunc_row_state_set_sign_xor__94__state;
        SData/*14:0*/ __Vfunc_row_state_set_sign_xor__94__next_state;
        SData/*14:0*/ __Vfunc_row_state_set_valid_count__95__Vfuncout;
        SData/*14:0*/ __Vfunc_row_state_set_valid_count__95__state;
        SData/*14:0*/ __Vfunc_row_state_set_valid_count__95__next_state;
        SData/*14:0*/ __Vfunc_row_state_min1__96__state;
        SData/*14:0*/ __Vfunc_row_state_min1__97__state;
        SData/*14:0*/ __Vfunc_row_state_set_min2__98__Vfuncout;
        SData/*14:0*/ __Vfunc_row_state_set_min2__98__state;
        SData/*14:0*/ __Vfunc_row_state_set_min2__98__next_state;
        SData/*14:0*/ __Vfunc_row_state_set_min1__101__Vfuncout;
        SData/*14:0*/ __Vfunc_row_state_set_min1__101__state;
        SData/*14:0*/ __Vfunc_row_state_set_min1__101__next_state;
        SData/*14:0*/ __Vfunc_row_state_set_min_id__102__Vfuncout;
        SData/*14:0*/ __Vfunc_row_state_set_min_id__102__state;
        SData/*14:0*/ __Vfunc_row_state_set_min_id__102__next_state;
        SData/*14:0*/ __Vfunc_row_state_min2__103__state;
        SData/*14:0*/ __Vfunc_row_state_set_min2__106__Vfuncout;
        SData/*14:0*/ __Vfunc_row_state_set_min2__106__state;
        SData/*14:0*/ __Vfunc_row_state_set_min2__106__next_state;
        SData/*14:0*/ __Vfunc_row_state_pack__116__Vfuncout;
        SData/*14:0*/ __Vfunc_row_state_valid_count__117__state;
        SData/*14:0*/ __Vfunc_row_state_sign_xor__118__state;
        SData/*14:0*/ __Vfunc_row_state_set_sign_xor__120__Vfuncout;
        SData/*14:0*/ __Vfunc_row_state_set_sign_xor__120__state;
        SData/*14:0*/ __Vfunc_row_state_set_sign_xor__120__next_state;
        SData/*14:0*/ __Vfunc_row_state_set_valid_count__121__Vfuncout;
        SData/*14:0*/ __Vfunc_row_state_set_valid_count__121__state;
        SData/*14:0*/ __Vfunc_row_state_set_valid_count__121__next_state;
        SData/*14:0*/ __Vfunc_row_state_min1__122__state;
        SData/*14:0*/ __Vfunc_row_state_min1__123__state;
        SData/*14:0*/ __Vfunc_row_state_set_min2__124__Vfuncout;
        SData/*14:0*/ __Vfunc_row_state_set_min2__124__state;
        SData/*14:0*/ __Vfunc_row_state_set_min2__124__next_state;
        SData/*14:0*/ __Vfunc_row_state_set_min1__127__Vfuncout;
        SData/*14:0*/ __Vfunc_row_state_set_min1__127__state;
        SData/*14:0*/ __Vfunc_row_state_set_min1__127__next_state;
        SData/*14:0*/ __Vfunc_row_state_set_min_id__128__Vfuncout;
        SData/*14:0*/ __Vfunc_row_state_set_min_id__128__state;
        SData/*14:0*/ __Vfunc_row_state_set_min_id__128__next_state;
        SData/*14:0*/ __Vfunc_row_state_min2__129__state;
        SData/*14:0*/ __Vfunc_row_state_set_min2__132__Vfuncout;
        SData/*14:0*/ __Vfunc_row_state_set_min2__132__state;
        SData/*14:0*/ __Vfunc_row_state_set_min2__132__next_state;
        IData/*31:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
        IData/*31:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_2__alpha_scale;
        IData/*31:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_1__alpha_scale;
        IData/*31:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_0__msg_to_signed;
        IData/*31:0*/ __Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global;
        IData/*31:0*/ __Vfunc_row_global_from_lane_local__43__row_value;
        IData/*31:0*/ __Vfunc_row_segment__44__Vfuncout;
    };
    struct {
        IData/*31:0*/ __Vfunc_row_segment__44__row_value;
        IData/*31:0*/ __Vfunc_row_local_from_global__45__row_value;
        IData/*31:0*/ __Vfunc_row_local_from_global__45__local_value;
        IData/*31:0*/ __Vfunc_row_global_from_lane_local__49__row_value;
        IData/*31:0*/ __Vfunc_mag_from_int__85__value;
        IData/*31:0*/ __Vfunc_mag_from_int__85__clamped_value;
        IData/*31:0*/ __Vfunc_clamp_int__86__Vfuncout;
        IData/*31:0*/ __Vfunc_clamp_int__86__value;
        IData/*31:0*/ __Vfunc_clamp_int__86__lo;
        IData/*31:0*/ __Vfunc_clamp_int__86__hi;
        IData/*31:0*/ __Vfunc_mag_from_int__87__clamped_value;
        IData/*31:0*/ __Vfunc_clamp_int__88__Vfuncout;
        IData/*31:0*/ __Vfunc_clamp_int__88__value;
        IData/*31:0*/ __Vfunc_clamp_int__88__lo;
        IData/*31:0*/ __Vfunc_clamp_int__88__hi;
        IData/*31:0*/ __Vfunc_mag_from_int__99__value;
        IData/*31:0*/ __Vfunc_mag_from_int__99__clamped_value;
        IData/*31:0*/ __Vfunc_clamp_int__100__Vfuncout;
        IData/*31:0*/ __Vfunc_clamp_int__100__value;
        IData/*31:0*/ __Vfunc_clamp_int__100__lo;
        IData/*31:0*/ __Vfunc_clamp_int__100__hi;
        IData/*31:0*/ __Vfunc_mag_from_int__104__value;
        IData/*31:0*/ __Vfunc_mag_from_int__104__clamped_value;
        IData/*31:0*/ __Vfunc_clamp_int__105__Vfuncout;
        IData/*31:0*/ __Vfunc_clamp_int__105__value;
        IData/*31:0*/ __Vfunc_clamp_int__105__lo;
        IData/*31:0*/ __Vfunc_clamp_int__105__hi;
        IData/*31:0*/ __Vfunc_mag_from_int__111__value;
        IData/*31:0*/ __Vfunc_mag_from_int__111__clamped_value;
        IData/*31:0*/ __Vfunc_clamp_int__112__Vfuncout;
        IData/*31:0*/ __Vfunc_clamp_int__112__value;
        IData/*31:0*/ __Vfunc_clamp_int__112__lo;
        IData/*31:0*/ __Vfunc_clamp_int__112__hi;
        IData/*31:0*/ __Vfunc_mag_from_int__113__clamped_value;
        IData/*31:0*/ __Vfunc_clamp_int__114__Vfuncout;
        IData/*31:0*/ __Vfunc_clamp_int__114__value;
        IData/*31:0*/ __Vfunc_clamp_int__114__lo;
        IData/*31:0*/ __Vfunc_clamp_int__114__hi;
        IData/*31:0*/ __Vfunc_mag_from_int__125__value;
        IData/*31:0*/ __Vfunc_mag_from_int__125__clamped_value;
        IData/*31:0*/ __Vfunc_clamp_int__126__Vfuncout;
        IData/*31:0*/ __Vfunc_clamp_int__126__value;
        IData/*31:0*/ __Vfunc_clamp_int__126__lo;
        IData/*31:0*/ __Vfunc_clamp_int__126__hi;
        IData/*31:0*/ __Vfunc_mag_from_int__130__value;
        IData/*31:0*/ __Vfunc_mag_from_int__130__clamped_value;
        IData/*31:0*/ __Vfunc_clamp_int__131__Vfuncout;
        IData/*31:0*/ __Vfunc_clamp_int__131__value;
        IData/*31:0*/ __Vfunc_clamp_int__131__lo;
        IData/*31:0*/ __Vfunc_clamp_int__131__hi;
        IData/*31:0*/ __Vfunc_msg_to_signed__143__mag_value;
        IData/*31:0*/ __Vfunc_alpha_scale__146__abs_value;
        IData/*31:0*/ __Vfunc_alpha_scale__146__scaled_abs;
        IData/*31:0*/ __Vfunc_alpha_scale__148__abs_value;
        IData/*31:0*/ __Vfunc_alpha_scale__148__scaled_abs;
        IData/*31:0*/ __Vfunc_clamp_int__151__Vfuncout;
        IData/*31:0*/ __VactIterCount;
        IData/*31:0*/ __VinactIterCount;
        IData/*31:0*/ __Vi;
        VlUnpacked<IData/*31:0*/, 4> tb_mdpc_decoder_demo__DOT__unnamedblk1__DOT__case0_hist;
        VlUnpacked<IData/*31:0*/, 4> tb_mdpc_decoder_demo__DOT__unnamedblk1__DOT__case1_hist;
        VlUnpacked<CData/*7:0*/, 4> tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist;
        VlUnpacked<VlUnpacked<CData/*4:0*/, 3>, 2> tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_entries;
        VlUnpacked<CData/*1:0*/, 2> tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_count;
    };
    struct {
        VlUnpacked<VlUnpacked<SData/*12:0*/, 3>, 2> tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_edges;
        VlUnpacked<CData/*4:0*/, 3> tb_mdpc_decoder_demo__DOT__dut__DOT__t_msgs;
        VlUnpacked<CData/*4:0*/, 3> tb_mdpc_decoder_demo__DOT__dut__DOT__vnu_u_next;
        VlUnpacked<VlUnpacked<VlUnpacked<CData/*4:0*/, 3>, 2>, 2> tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem;
        VlUnpacked<VlUnpacked<CData/*1:0*/, 2>, 2> tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem;
        VlUnpacked<VlUnpacked<VlUnpacked<CData/*4:0*/, 3>, 2>, 2> tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_entries;
        VlUnpacked<VlUnpacked<CData/*1:0*/, 2>, 2> tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_count;
        VlUnpacked<VlUnpacked<CData/*4:0*/, 3>, 2> tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_entries;
        VlUnpacked<CData/*1:0*/, 2> tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_count;
        VlUnpacked<SData/*14:0*/, 8> tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem;
        VlUnpacked<VlUnpacked<CData/*0:0*/, 3>, 16> tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem;
        VlUnpacked<VlUnpacked<CData/*4:0*/, 3>, 16> tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem;
        VlUnpacked<VlUnpacked<CData/*4:0*/, 3>, 16> tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem;
        VlUnpacked<IData/*31:0*/, 3> tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__signed_c2v;
        VlUnpacked<QData/*63:0*/, 1> __VstlTriggered;
        VlUnpacked<QData/*63:0*/, 1> __VactTriggered;
        VlUnpacked<QData/*63:0*/, 1> __VactTriggeredAcc;
        VlUnpacked<QData/*63:0*/, 1> __VnbaTriggered;
    };
    VlDelayScheduler __VdlySched;
    VlTriggerScheduler __VtrigSched_h5ea129b9__0;
    VlTriggerScheduler __VtrigSched_h0d62a7d4__0;
    VlTriggerScheduler __VtrigSched_h10b28a8e__0;
    VlTriggerScheduler __VtrigSched_hd708b578__0;
    VlTriggerScheduler __VtrigSched_hdfc022cc__0;

    // INTERNAL VARIABLES
    Vtb_mdpc_decoder_demo__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    Vtb_mdpc_decoder_demo___024root(Vtb_mdpc_decoder_demo__Syms* symsp, const char* namep);
    ~Vtb_mdpc_decoder_demo___024root();
    VL_UNCOPYABLE(Vtb_mdpc_decoder_demo___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
