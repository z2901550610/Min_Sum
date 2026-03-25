// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_mdpc_decoder_demo.h for the primary calling header

#include "Vtb_mdpc_decoder_demo__pch.h"

void Vtb_mdpc_decoder_demo___024root___nba_sequent__TOP__1(Vtb_mdpc_decoder_demo___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_decoder_demo___024root___nba_sequent__TOP__1\n"); );
    Vtb_mdpc_decoder_demo__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*4:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_msg0;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_msg0 = 0;
    CData/*4:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_msg1;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_msg1 = 0;
    CData/*0:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__continue_decode;
    tb_mdpc_decoder_demo__DOT__dut__DOT__continue_decode = 0;
    CData/*4:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_hf329cb35__0;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_hf329cb35__0 = 0;
    IData/*31:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__row_value_local;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__row_value_local = 0;
    IData/*31:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_row_value_local;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_row_value_local = 0;
    IData/*31:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local = 0;
    IData/*31:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_slot_idx_local;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_slot_idx_local = 0;
    CData/*2:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_local_value;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_local_value = 0;
    CData/*2:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_global_value;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_global_value = 0;
    CData/*1:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__edge_slot_value;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__edge_slot_value = 0;
    CData/*4:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT____Vlvbound_h8ced4821__0;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT____Vlvbound_h8ced4821__0 = 0;
    CData/*1:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_2__row_state_valid_count;
    CData/*1:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_1__row_state_valid_count;
    CData/*3:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_0__msg_mag;
    IData/*31:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__abs_mag;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__abs_mag = 0;
    IData/*31:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__next_count;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__next_count = 0;
    CData/*1:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_2__row_state_valid_count;
    CData/*1:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_1__row_state_valid_count;
    CData/*3:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_0__msg_mag;
    IData/*31:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__abs_mag;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__abs_mag = 0;
    IData/*31:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__next_count;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__next_count = 0;
    CData/*4:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____Vlvbound_h02a35ea2__0;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____Vlvbound_h02a35ea2__0 = 0;
    IData/*31:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____Vlvbound_h619e30fe__0;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____Vlvbound_h619e30fe__0 = 0;
    CData/*4:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_3__msg_from_signed;
    IData/*31:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__sum_c2v;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__sum_c2v = 0;
    IData/*31:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__gamma_value;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__gamma_value = 0;
    IData/*31:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__app_value;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__app_value = 0;
    IData/*31:0*/ tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__u_value;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__u_value = 0;
    CData/*7:0*/ __Vfunc_syndrome_vector__17__Vfuncout;
    __Vfunc_syndrome_vector__17__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = 0;
    CData/*0:0*/ __Vfunc_msg_sign__81__Vfuncout;
    __Vfunc_msg_sign__81__Vfuncout = 0;
    CData/*4:0*/ __Vfunc_msg_sign__81__msg;
    __Vfunc_msg_sign__81__msg = 0;
    CData/*4:0*/ __Vfunc_msg_mag__82__msg;
    __Vfunc_msg_mag__82__msg = 0;
    SData/*14:0*/ __Vfunc_row_state_valid_count__83__state;
    __Vfunc_row_state_valid_count__83__state = 0;
    SData/*14:0*/ __Vfunc_row_state_valid_count__84__state;
    __Vfunc_row_state_valid_count__84__state = 0;
    CData/*0:0*/ __Vfunc_msg_sign__107__Vfuncout;
    __Vfunc_msg_sign__107__Vfuncout = 0;
    CData/*4:0*/ __Vfunc_msg_sign__107__msg;
    __Vfunc_msg_sign__107__msg = 0;
    CData/*4:0*/ __Vfunc_msg_mag__108__msg;
    __Vfunc_msg_mag__108__msg = 0;
    SData/*14:0*/ __Vfunc_row_state_valid_count__109__state;
    __Vfunc_row_state_valid_count__109__state = 0;
    SData/*14:0*/ __Vfunc_row_state_valid_count__110__state;
    __Vfunc_row_state_valid_count__110__state = 0;
    CData/*4:0*/ __Vfunc_msg_to_signed__143__msg;
    __Vfunc_msg_to_signed__143__msg = 0;
    IData/*31:0*/ __Vfunc_alpha_scale__146__value;
    __Vfunc_alpha_scale__146__value = 0;
    IData/*31:0*/ __Vfunc_app_from_int__147__value;
    __Vfunc_app_from_int__147__value = 0;
    IData/*31:0*/ __Vfunc_app_from_int__147__app_value_int;
    __Vfunc_app_from_int__147__app_value_int = 0;
    CData/*7:0*/ __Vfunc_app_from_int__147__result;
    __Vfunc_app_from_int__147__result = 0;
    IData/*31:0*/ __Vfunc_alpha_scale__148__value;
    __Vfunc_alpha_scale__148__value = 0;
    IData/*31:0*/ __Vfunc_msg_from_signed__149__value;
    __Vfunc_msg_from_signed__149__value = 0;
    CData/*3:0*/ __Vfunc_msg_from_signed__149____VlefCall_0__mag_from_int;
    __Vfunc_msg_from_signed__149____VlefCall_0__mag_from_int = 0;
    CData/*4:0*/ __Vfunc_msg_from_signed__149__msg;
    __Vfunc_msg_from_signed__149__msg = 0;
    IData/*31:0*/ __Vfunc_msg_from_signed__149__abs_value;
    __Vfunc_msg_from_signed__149__abs_value = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__150__Vfuncout;
    __Vfunc_mag_from_int__150__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_mag_from_int__150__value;
    __Vfunc_mag_from_int__150__value = 0;
    IData/*31:0*/ __Vfunc_mag_from_int__150__clamped_value;
    __Vfunc_mag_from_int__150__clamped_value = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__150__result;
    __Vfunc_mag_from_int__150__result = 0;
    IData/*31:0*/ __Vfunc_clamp_int__151__value;
    __Vfunc_clamp_int__151__value = 0;
    CData/*4:0*/ __Vfunc_msg_pack__152__Vfuncout;
    __Vfunc_msg_pack__152__Vfuncout = 0;
    CData/*0:0*/ __Vfunc_msg_pack__152__sign;
    __Vfunc_msg_pack__152__sign = 0;
    CData/*3:0*/ __Vfunc_msg_pack__152__mag;
    __Vfunc_msg_pack__152__mag = 0;
    // Body
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 5U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 5U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 5U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 6U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 6U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 6U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 7U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 7U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]);
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 7U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]);
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 8U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]);
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 8U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 8U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 9U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 9U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 9U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0aU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0aU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0aU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0bU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0bU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0bU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0cU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0cU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0cU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0dU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0dU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0dU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0eU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0eU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0eU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
               ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                  >> 0x0000000fU));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
               ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                  >> 0x0000000fU));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
               ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                  >> 0x0000000fU));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17__syndrome 
        = ((0xfbU & (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__syndrome)) 
           | ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
              << 2U));
    vlSelfRef.__Vfunc_syndrome_vector__17__parity = 0U;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]);
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]);
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]);
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 1U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 1U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 1U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 2U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 2U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 2U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 3U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 3U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 3U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 4U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 4U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 4U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 5U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 5U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 5U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 6U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 6U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 6U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 7U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 7U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]);
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 7U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]);
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 8U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]);
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 8U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 8U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 9U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 9U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 9U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0aU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0aU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0aU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0bU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0bU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0bU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0cU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0cU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0cU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0dU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0dU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0dU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0eU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0eU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0eU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
               ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                  >> 0x0000000fU));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
               ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                  >> 0x0000000fU));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    if ((3U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
               ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                  >> 0x0000000fU));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17__syndrome 
        = ((0xf7U & (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__syndrome)) 
           | ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
              << 3U));
    vlSelfRef.__Vfunc_syndrome_vector__17__parity = 0U;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]);
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]);
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]);
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 1U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 1U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 1U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 2U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 2U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 2U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 3U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 3U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 3U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 4U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 4U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 4U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 5U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 5U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 5U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 6U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 6U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 6U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 7U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 7U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]);
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 7U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]);
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 8U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]);
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 8U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 8U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 9U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 9U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 9U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0aU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0aU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0aU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0bU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0bU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0bU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0cU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0cU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0cU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0dU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0dU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0dU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0eU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0eU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0eU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
               ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                  >> 0x0000000fU));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
               ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                  >> 0x0000000fU));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    if ((4U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
               ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                  >> 0x0000000fU));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17__syndrome 
        = ((0xefU & (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__syndrome)) 
           | ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
              << 4U));
    vlSelfRef.__Vfunc_syndrome_vector__17__parity = 0U;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]);
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]);
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]);
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 1U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 1U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 1U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 2U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 2U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 2U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 3U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 3U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 3U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 4U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 4U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 4U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 5U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 5U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 5U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 6U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 6U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 6U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 7U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 7U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]);
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 7U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]);
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 8U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]);
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 8U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 8U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 9U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 9U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 9U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0aU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0aU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0aU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0bU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0bU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0bU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0cU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0cU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0cU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0dU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0dU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0dU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0eU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0eU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0eU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
               ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                  >> 0x0000000fU));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
               ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                  >> 0x0000000fU));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    if ((5U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
               ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                  >> 0x0000000fU));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17__syndrome 
        = ((0xdfU & (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__syndrome)) 
           | ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
              << 5U));
    vlSelfRef.__Vfunc_syndrome_vector__17__parity = 0U;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]);
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]);
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]);
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 1U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 1U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 1U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 2U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 2U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 2U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 3U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 3U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 3U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 4U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 4U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 4U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 5U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 5U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 5U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 6U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 6U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 6U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 7U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 7U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]);
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 7U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]);
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 8U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]);
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 8U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 8U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 9U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 9U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 9U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0aU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0aU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0aU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0bU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0bU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0bU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0cU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0cU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0cU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0dU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0dU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0dU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0eU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0eU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0eU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
               ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                  >> 0x0000000fU));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
               ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                  >> 0x0000000fU));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    if ((6U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
               ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                  >> 0x0000000fU));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17__syndrome 
        = ((0xbfU & (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__syndrome)) 
           | ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
              << 6U));
    vlSelfRef.__Vfunc_syndrome_vector__17__parity = 0U;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]);
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]);
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]);
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 1U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 1U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 1U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 2U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 2U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 2U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 3U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 3U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 3U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 4U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 4U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 4U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 5U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 5U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 5U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 6U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 6U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 6U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 7U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 7U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]);
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 7U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]);
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 8U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]);
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 8U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 8U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 9U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 9U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 9U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0aU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0aU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0aU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0bU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0bU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0bU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0cU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0cU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0cU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0dU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0dU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0dU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0eU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0eU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0eU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
               ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                  >> 0x0000000fU));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
               ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                  >> 0x0000000fU));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    if ((7U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
               ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                  >> 0x0000000fU));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17__syndrome 
        = ((0x7fU & (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__syndrome)) 
           | ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
              << 7U));
    __Vfunc_syndrome_vector__17__Vfuncout = vlSelfRef.__Vfunc_syndrome_vector__17__syndrome;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_next 
        = __Vfunc_syndrome_vector__17__Vfuncout;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__row_value_local = 0U;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_row_value_local = 0U;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local = 0U;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_slot_idx_local = 0U;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_count[0U] = 0U;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_entries[0U][0U] = 0U;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_entries[0U][1U] = 0U;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_entries[0U][2U] = 0U;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_count[1U] = 0U;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_entries[1U][0U] = 0U;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_entries[1U][1U] = 0U;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_entries[1U][2U] = 0U;
    if ((0U < vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem
         [(1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                 >> 3U))][0U])) {
        vlSelfRef.__Vfunc_i_entry_row_local__42__i_entry 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem
            [(1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                    >> 3U))][0U][0U];
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_2__i_entry_row_local 
            = (7U & (IData)(vlSelfRef.__Vfunc_i_entry_row_local__42__i_entry));
        vlSelfRef.__Vfunc_row_global_from_lane_local__43__row_local 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_2__i_entry_row_local;
        vlSelfRef.__Vfunc_row_global_from_lane_local__43__row_value 
            = vlSelfRef.__Vfunc_row_global_from_lane_local__43__row_local;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_3__row_global_from_lane_local 
            = (7U & vlSelfRef.__Vfunc_row_global_from_lane_local__43__row_value);
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__row_value_local 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_3__row_global_from_lane_local;
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_row_value_local 
            = VL_MODDIVS_III(32, ((IData)(1U) + tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__row_value_local), (IData)(8U));
        vlSelfRef.__Vfunc_row_segment__44__row_value 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_row_value_local;
        {
            vlSelfRef.__Vfunc_row_segment__44__Vfuncout = 0U;
            if (VL_GTS_III(32, 4U, vlSelfRef.__Vfunc_row_segment__44__row_value)) {
                vlSelfRef.__Vfunc_row_segment__44__Vfuncout = 0U;
                goto __Vlabel0;
            }
            vlSelfRef.__Vfunc_row_segment__44__Vfuncout = 1U;
            __Vlabel0: ;
        }
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local 
            = vlSelfRef.__Vfunc_row_segment__44__Vfuncout;
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_slot_idx_local 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_count
            [(1U & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local)];
        vlSelfRef.__Vfunc_row_local_from_global__45__row_value 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_row_value_local;
        vlSelfRef.__Vfunc_row_local_from_global__45__local_value 
            = (VL_GTS_III(32, 4U, vlSelfRef.__Vfunc_row_local_from_global__45__row_value)
                ? vlSelfRef.__Vfunc_row_local_from_global__45__row_value
                : (vlSelfRef.__Vfunc_row_local_from_global__45__row_value 
                   - (IData)(4U)));
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_4__row_local_from_global 
            = (7U & vlSelfRef.__Vfunc_row_local_from_global__45__local_value);
        vlSelfRef.__Vfunc_i_entry_edge_slot__46__i_entry 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem
            [(1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                    >> 3U))][0U][0U];
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_5__i_entry_edge_slot 
            = (3U & ((IData)(vlSelfRef.__Vfunc_i_entry_edge_slot__46__i_entry) 
                     >> 3U));
        vlSelfRef.__Vfunc_i_entry_pack__47__edge_slot 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_5__i_entry_edge_slot;
        vlSelfRef.__Vfunc_i_entry_pack__47__row_local 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_4__row_local_from_global;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_6__i_entry_pack 
            = (((IData)(vlSelfRef.__Vfunc_i_entry_pack__47__edge_slot) 
                << 3U) | (IData)(vlSelfRef.__Vfunc_i_entry_pack__47__row_local));
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h22a87440__0 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_6__i_entry_pack;
        if (VL_LIKELY(((2U >= (3U & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_slot_idx_local))))) {
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_entries[(1U 
                                                                                & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local)][(3U 
                                                                                & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_slot_idx_local)] 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h22a87440__0;
        }
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_count[(1U 
                                                                                & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local)] 
            = (3U & ((IData)(1U) + (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_count
                                           [(1U & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local)])));
    }
    if ((1U < vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem
         [(1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                 >> 3U))][0U])) {
        vlSelfRef.__Vfunc_i_entry_row_local__42__i_entry 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem
            [(1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                    >> 3U))][0U][1U];
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_2__i_entry_row_local 
            = (7U & (IData)(vlSelfRef.__Vfunc_i_entry_row_local__42__i_entry));
        vlSelfRef.__Vfunc_row_global_from_lane_local__43__row_local 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_2__i_entry_row_local;
        vlSelfRef.__Vfunc_row_global_from_lane_local__43__row_value 
            = vlSelfRef.__Vfunc_row_global_from_lane_local__43__row_local;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_3__row_global_from_lane_local 
            = (7U & vlSelfRef.__Vfunc_row_global_from_lane_local__43__row_value);
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__row_value_local 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_3__row_global_from_lane_local;
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_row_value_local 
            = VL_MODDIVS_III(32, ((IData)(1U) + tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__row_value_local), (IData)(8U));
        vlSelfRef.__Vfunc_row_segment__44__row_value 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_row_value_local;
        {
            vlSelfRef.__Vfunc_row_segment__44__Vfuncout = 0U;
            if (VL_GTS_III(32, 4U, vlSelfRef.__Vfunc_row_segment__44__row_value)) {
                vlSelfRef.__Vfunc_row_segment__44__Vfuncout = 0U;
                goto __Vlabel1;
            }
            vlSelfRef.__Vfunc_row_segment__44__Vfuncout = 1U;
            __Vlabel1: ;
        }
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local 
            = vlSelfRef.__Vfunc_row_segment__44__Vfuncout;
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_slot_idx_local 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_count
            [(1U & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local)];
        vlSelfRef.__Vfunc_row_local_from_global__45__row_value 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_row_value_local;
        vlSelfRef.__Vfunc_row_local_from_global__45__local_value 
            = (VL_GTS_III(32, 4U, vlSelfRef.__Vfunc_row_local_from_global__45__row_value)
                ? vlSelfRef.__Vfunc_row_local_from_global__45__row_value
                : (vlSelfRef.__Vfunc_row_local_from_global__45__row_value 
                   - (IData)(4U)));
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_4__row_local_from_global 
            = (7U & vlSelfRef.__Vfunc_row_local_from_global__45__local_value);
        vlSelfRef.__Vfunc_i_entry_edge_slot__46__i_entry 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem
            [(1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                    >> 3U))][0U][1U];
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_5__i_entry_edge_slot 
            = (3U & ((IData)(vlSelfRef.__Vfunc_i_entry_edge_slot__46__i_entry) 
                     >> 3U));
        vlSelfRef.__Vfunc_i_entry_pack__47__edge_slot 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_5__i_entry_edge_slot;
        vlSelfRef.__Vfunc_i_entry_pack__47__row_local 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_4__row_local_from_global;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_6__i_entry_pack 
            = (((IData)(vlSelfRef.__Vfunc_i_entry_pack__47__edge_slot) 
                << 3U) | (IData)(vlSelfRef.__Vfunc_i_entry_pack__47__row_local));
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h22a87440__0 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_6__i_entry_pack;
        if (VL_LIKELY(((2U >= (3U & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_slot_idx_local))))) {
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_entries[(1U 
                                                                                & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local)][(3U 
                                                                                & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_slot_idx_local)] 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h22a87440__0;
        }
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_count[(1U 
                                                                                & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local)] 
            = (3U & ((IData)(1U) + (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_count
                                           [(1U & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local)])));
    }
    if ((2U < vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem
         [(1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                 >> 3U))][0U])) {
        vlSelfRef.__Vfunc_i_entry_row_local__42__i_entry 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem
            [(1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                    >> 3U))][0U][2U];
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_2__i_entry_row_local 
            = (7U & (IData)(vlSelfRef.__Vfunc_i_entry_row_local__42__i_entry));
        vlSelfRef.__Vfunc_row_global_from_lane_local__43__row_local 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_2__i_entry_row_local;
        vlSelfRef.__Vfunc_row_global_from_lane_local__43__row_value 
            = vlSelfRef.__Vfunc_row_global_from_lane_local__43__row_local;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_3__row_global_from_lane_local 
            = (7U & vlSelfRef.__Vfunc_row_global_from_lane_local__43__row_value);
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__row_value_local 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_3__row_global_from_lane_local;
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_row_value_local 
            = VL_MODDIVS_III(32, ((IData)(1U) + tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__row_value_local), (IData)(8U));
        vlSelfRef.__Vfunc_row_segment__44__row_value 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_row_value_local;
        {
            vlSelfRef.__Vfunc_row_segment__44__Vfuncout = 0U;
            if (VL_GTS_III(32, 4U, vlSelfRef.__Vfunc_row_segment__44__row_value)) {
                vlSelfRef.__Vfunc_row_segment__44__Vfuncout = 0U;
                goto __Vlabel2;
            }
            vlSelfRef.__Vfunc_row_segment__44__Vfuncout = 1U;
            __Vlabel2: ;
        }
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local 
            = vlSelfRef.__Vfunc_row_segment__44__Vfuncout;
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_slot_idx_local 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_count
            [(1U & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local)];
        vlSelfRef.__Vfunc_row_local_from_global__45__row_value 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_row_value_local;
        vlSelfRef.__Vfunc_row_local_from_global__45__local_value 
            = (VL_GTS_III(32, 4U, vlSelfRef.__Vfunc_row_local_from_global__45__row_value)
                ? vlSelfRef.__Vfunc_row_local_from_global__45__row_value
                : (vlSelfRef.__Vfunc_row_local_from_global__45__row_value 
                   - (IData)(4U)));
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_4__row_local_from_global 
            = (7U & vlSelfRef.__Vfunc_row_local_from_global__45__local_value);
        vlSelfRef.__Vfunc_i_entry_edge_slot__46__i_entry 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem
            [(1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                    >> 3U))][0U][2U];
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_5__i_entry_edge_slot 
            = (3U & ((IData)(vlSelfRef.__Vfunc_i_entry_edge_slot__46__i_entry) 
                     >> 3U));
        vlSelfRef.__Vfunc_i_entry_pack__47__edge_slot 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_5__i_entry_edge_slot;
        vlSelfRef.__Vfunc_i_entry_pack__47__row_local 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_4__row_local_from_global;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_6__i_entry_pack 
            = (((IData)(vlSelfRef.__Vfunc_i_entry_pack__47__edge_slot) 
                << 3U) | (IData)(vlSelfRef.__Vfunc_i_entry_pack__47__row_local));
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h22a87440__0 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_6__i_entry_pack;
        if (VL_LIKELY(((2U >= (3U & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_slot_idx_local))))) {
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_entries[(1U 
                                                                                & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local)][(3U 
                                                                                & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_slot_idx_local)] 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h22a87440__0;
        }
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_count[(1U 
                                                                                & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local)] 
            = (3U & ((IData)(1U) + (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_count
                                           [(1U & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local)])));
    }
    if ((0U < vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem
         [(1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                 >> 3U))][1U])) {
        vlSelfRef.__Vfunc_i_entry_row_local__42__i_entry 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem
            [(1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                    >> 3U))][1U][0U];
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_2__i_entry_row_local 
            = (7U & (IData)(vlSelfRef.__Vfunc_i_entry_row_local__42__i_entry));
        vlSelfRef.__Vfunc_row_global_from_lane_local__43__row_local 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_2__i_entry_row_local;
        vlSelfRef.__Vfunc_row_global_from_lane_local__43__row_value 
            = ((IData)(4U) + (IData)(vlSelfRef.__Vfunc_row_global_from_lane_local__43__row_local));
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_3__row_global_from_lane_local 
            = (7U & vlSelfRef.__Vfunc_row_global_from_lane_local__43__row_value);
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__row_value_local 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_3__row_global_from_lane_local;
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_row_value_local 
            = VL_MODDIVS_III(32, ((IData)(1U) + tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__row_value_local), (IData)(8U));
        vlSelfRef.__Vfunc_row_segment__44__row_value 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_row_value_local;
        {
            vlSelfRef.__Vfunc_row_segment__44__Vfuncout = 0U;
            if (VL_GTS_III(32, 4U, vlSelfRef.__Vfunc_row_segment__44__row_value)) {
                vlSelfRef.__Vfunc_row_segment__44__Vfuncout = 0U;
                goto __Vlabel3;
            }
            vlSelfRef.__Vfunc_row_segment__44__Vfuncout = 1U;
            __Vlabel3: ;
        }
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local 
            = vlSelfRef.__Vfunc_row_segment__44__Vfuncout;
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_slot_idx_local 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_count
            [(1U & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local)];
        vlSelfRef.__Vfunc_row_local_from_global__45__row_value 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_row_value_local;
        vlSelfRef.__Vfunc_row_local_from_global__45__local_value 
            = (VL_GTS_III(32, 4U, vlSelfRef.__Vfunc_row_local_from_global__45__row_value)
                ? vlSelfRef.__Vfunc_row_local_from_global__45__row_value
                : (vlSelfRef.__Vfunc_row_local_from_global__45__row_value 
                   - (IData)(4U)));
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_4__row_local_from_global 
            = (7U & vlSelfRef.__Vfunc_row_local_from_global__45__local_value);
        vlSelfRef.__Vfunc_i_entry_edge_slot__46__i_entry 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem
            [(1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                    >> 3U))][1U][0U];
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_5__i_entry_edge_slot 
            = (3U & ((IData)(vlSelfRef.__Vfunc_i_entry_edge_slot__46__i_entry) 
                     >> 3U));
        vlSelfRef.__Vfunc_i_entry_pack__47__edge_slot 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_5__i_entry_edge_slot;
        vlSelfRef.__Vfunc_i_entry_pack__47__row_local 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_4__row_local_from_global;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_6__i_entry_pack 
            = (((IData)(vlSelfRef.__Vfunc_i_entry_pack__47__edge_slot) 
                << 3U) | (IData)(vlSelfRef.__Vfunc_i_entry_pack__47__row_local));
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h22a87440__0 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_6__i_entry_pack;
        if (VL_LIKELY(((2U >= (3U & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_slot_idx_local))))) {
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_entries[(1U 
                                                                                & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local)][(3U 
                                                                                & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_slot_idx_local)] 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h22a87440__0;
        }
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_count[(1U 
                                                                                & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local)] 
            = (3U & ((IData)(1U) + (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_count
                                           [(1U & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local)])));
    }
    if ((1U < vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem
         [(1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                 >> 3U))][1U])) {
        vlSelfRef.__Vfunc_i_entry_row_local__42__i_entry 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem
            [(1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                    >> 3U))][1U][1U];
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_2__i_entry_row_local 
            = (7U & (IData)(vlSelfRef.__Vfunc_i_entry_row_local__42__i_entry));
        vlSelfRef.__Vfunc_row_global_from_lane_local__43__row_local 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_2__i_entry_row_local;
        vlSelfRef.__Vfunc_row_global_from_lane_local__43__row_value 
            = ((IData)(4U) + (IData)(vlSelfRef.__Vfunc_row_global_from_lane_local__43__row_local));
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_3__row_global_from_lane_local 
            = (7U & vlSelfRef.__Vfunc_row_global_from_lane_local__43__row_value);
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__row_value_local 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_3__row_global_from_lane_local;
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_row_value_local 
            = VL_MODDIVS_III(32, ((IData)(1U) + tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__row_value_local), (IData)(8U));
        vlSelfRef.__Vfunc_row_segment__44__row_value 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_row_value_local;
        {
            vlSelfRef.__Vfunc_row_segment__44__Vfuncout = 0U;
            if (VL_GTS_III(32, 4U, vlSelfRef.__Vfunc_row_segment__44__row_value)) {
                vlSelfRef.__Vfunc_row_segment__44__Vfuncout = 0U;
                goto __Vlabel4;
            }
            vlSelfRef.__Vfunc_row_segment__44__Vfuncout = 1U;
            __Vlabel4: ;
        }
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local 
            = vlSelfRef.__Vfunc_row_segment__44__Vfuncout;
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_slot_idx_local 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_count
            [(1U & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local)];
        vlSelfRef.__Vfunc_row_local_from_global__45__row_value 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_row_value_local;
        vlSelfRef.__Vfunc_row_local_from_global__45__local_value 
            = (VL_GTS_III(32, 4U, vlSelfRef.__Vfunc_row_local_from_global__45__row_value)
                ? vlSelfRef.__Vfunc_row_local_from_global__45__row_value
                : (vlSelfRef.__Vfunc_row_local_from_global__45__row_value 
                   - (IData)(4U)));
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_4__row_local_from_global 
            = (7U & vlSelfRef.__Vfunc_row_local_from_global__45__local_value);
        vlSelfRef.__Vfunc_i_entry_edge_slot__46__i_entry 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem
            [(1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                    >> 3U))][1U][1U];
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_5__i_entry_edge_slot 
            = (3U & ((IData)(vlSelfRef.__Vfunc_i_entry_edge_slot__46__i_entry) 
                     >> 3U));
        vlSelfRef.__Vfunc_i_entry_pack__47__edge_slot 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_5__i_entry_edge_slot;
        vlSelfRef.__Vfunc_i_entry_pack__47__row_local 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_4__row_local_from_global;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_6__i_entry_pack 
            = (((IData)(vlSelfRef.__Vfunc_i_entry_pack__47__edge_slot) 
                << 3U) | (IData)(vlSelfRef.__Vfunc_i_entry_pack__47__row_local));
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h22a87440__0 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_6__i_entry_pack;
        if (VL_LIKELY(((2U >= (3U & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_slot_idx_local))))) {
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_entries[(1U 
                                                                                & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local)][(3U 
                                                                                & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_slot_idx_local)] 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h22a87440__0;
        }
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_count[(1U 
                                                                                & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local)] 
            = (3U & ((IData)(1U) + (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_count
                                           [(1U & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local)])));
    }
    if ((2U < vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem
         [(1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                 >> 3U))][1U])) {
        vlSelfRef.__Vfunc_i_entry_row_local__42__i_entry 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem
            [(1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                    >> 3U))][1U][2U];
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_2__i_entry_row_local 
            = (7U & (IData)(vlSelfRef.__Vfunc_i_entry_row_local__42__i_entry));
        vlSelfRef.__Vfunc_row_global_from_lane_local__43__row_local 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_2__i_entry_row_local;
        vlSelfRef.__Vfunc_row_global_from_lane_local__43__row_value 
            = ((IData)(4U) + (IData)(vlSelfRef.__Vfunc_row_global_from_lane_local__43__row_local));
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_3__row_global_from_lane_local 
            = (7U & vlSelfRef.__Vfunc_row_global_from_lane_local__43__row_value);
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__row_value_local 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_3__row_global_from_lane_local;
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_row_value_local 
            = VL_MODDIVS_III(32, ((IData)(1U) + tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__row_value_local), (IData)(8U));
        vlSelfRef.__Vfunc_row_segment__44__row_value 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_row_value_local;
        {
            vlSelfRef.__Vfunc_row_segment__44__Vfuncout = 0U;
            if (VL_GTS_III(32, 4U, vlSelfRef.__Vfunc_row_segment__44__row_value)) {
                vlSelfRef.__Vfunc_row_segment__44__Vfuncout = 0U;
                goto __Vlabel5;
            }
            vlSelfRef.__Vfunc_row_segment__44__Vfuncout = 1U;
            __Vlabel5: ;
        }
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local 
            = vlSelfRef.__Vfunc_row_segment__44__Vfuncout;
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_slot_idx_local 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_count
            [(1U & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local)];
        vlSelfRef.__Vfunc_row_local_from_global__45__row_value 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_row_value_local;
        vlSelfRef.__Vfunc_row_local_from_global__45__local_value 
            = (VL_GTS_III(32, 4U, vlSelfRef.__Vfunc_row_local_from_global__45__row_value)
                ? vlSelfRef.__Vfunc_row_local_from_global__45__row_value
                : (vlSelfRef.__Vfunc_row_local_from_global__45__row_value 
                   - (IData)(4U)));
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_4__row_local_from_global 
            = (7U & vlSelfRef.__Vfunc_row_local_from_global__45__local_value);
        vlSelfRef.__Vfunc_i_entry_edge_slot__46__i_entry 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem
            [(1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                    >> 3U))][1U][2U];
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_5__i_entry_edge_slot 
            = (3U & ((IData)(vlSelfRef.__Vfunc_i_entry_edge_slot__46__i_entry) 
                     >> 3U));
        vlSelfRef.__Vfunc_i_entry_pack__47__edge_slot 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_5__i_entry_edge_slot;
        vlSelfRef.__Vfunc_i_entry_pack__47__row_local 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_4__row_local_from_global;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_6__i_entry_pack 
            = (((IData)(vlSelfRef.__Vfunc_i_entry_pack__47__edge_slot) 
                << 3U) | (IData)(vlSelfRef.__Vfunc_i_entry_pack__47__row_local));
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h22a87440__0 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____VlemCall_6__i_entry_pack;
        if (VL_LIKELY(((2U >= (3U & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_slot_idx_local))))) {
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_entries[(1U 
                                                                                & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local)][(3U 
                                                                                & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_slot_idx_local)] 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h22a87440__0;
        }
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_count[(1U 
                                                                                & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local)] 
            = (3U & ((IData)(1U) + (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_count
                                           [(1U & tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__unnamedblk2__DOT__next_lane_idx_local)])));
    }
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT____Vlvbound_h8ced4821__0 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem
        [vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx][0U];
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__t_msgs[0U] 
        = tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT____Vlvbound_h8ced4821__0;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT____Vlvbound_h8ced4821__0 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem
        [vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx][1U];
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__t_msgs[1U] 
        = tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT____Vlvbound_h8ced4821__0;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT____Vlvbound_h8ced4821__0 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem
        [vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx][2U];
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__t_msgs[2U] 
        = tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT____Vlvbound_h8ced4821__0;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_hf329cb35__0 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem
        [(1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                >> 3U))][0U][0U];
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_entries[0U][0U] 
        = tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_hf329cb35__0;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_hf329cb35__0 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem
        [(1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                >> 3U))][0U][1U];
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_entries[0U][1U] 
        = tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_hf329cb35__0;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_hf329cb35__0 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem
        [(1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                >> 3U))][0U][2U];
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_entries[0U][2U] 
        = tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_hf329cb35__0;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_hf329cb35__0 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem
        [(1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                >> 3U))][1U][0U];
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_entries[1U][0U] 
        = tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_hf329cb35__0;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_hf329cb35__0 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem
        [(1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                >> 3U))][1U][1U];
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_entries[1U][1U] 
        = tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_hf329cb35__0;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_hf329cb35__0 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem
        [(1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                >> 3U))][1U][2U];
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_entries[1U][2U] 
        = tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_hf329cb35__0;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_count[0U] 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem
        [(1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                >> 3U))][0U];
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_count[1U] 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem
        [(1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                >> 3U))][1U];
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__stop_decode = 0U;
    tb_mdpc_decoder_demo__DOT__dut__DOT__continue_decode = 0U;
    if ((5U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state))) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__stop_decode 
            = ((0U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_next)) 
               | VL_LTES_III(32, 4U, (7U & ((IData)(1U) 
                                            + (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__iter_count)))));
        tb_mdpc_decoder_demo__DOT__dut__DOT__continue_decode 
            = (1U & (~ (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__stop_decode)));
    }
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__gamma_value 
        = VL_EXTENDS_II(32,8, ((1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_c0_ram__DOT__mem) 
                                      >> (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx)))
                                ? 0xf7U : 9U));
    __Vfunc_msg_to_signed__143__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__t_msgs[0U];
    {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_0__msg_to_signed = 0U;
        vlSelfRef.__Vfunc_msg_to_signed__143__mag_value = 0U;
        vlSelfRef.__Vfunc_msg_mag__144__msg = __Vfunc_msg_to_signed__143__msg;
        vlSelf->__Vfunc_msg_mag__144__Vfuncout = 0;
        vlSelfRef.__Vfunc_msg_mag__144__Vfuncout = 
            (0x0000000fU & (IData)(vlSelfRef.__Vfunc_msg_mag__144__msg));
        vlSelfRef.__Vfunc_msg_to_signed__143____VlefCall_0__msg_mag 
            = vlSelfRef.__Vfunc_msg_mag__144__Vfuncout;
        vlSelfRef.__Vfunc_msg_to_signed__143__mag_value 
            = vlSelfRef.__Vfunc_msg_to_signed__143____VlefCall_0__msg_mag;
        vlSelfRef.__Vfunc_msg_sign__145__msg = __Vfunc_msg_to_signed__143__msg;
        vlSelf->__Vfunc_msg_sign__145__Vfuncout = 0;
        vlSelfRef.__Vfunc_msg_sign__145__Vfuncout = 
            (1U & ((IData)(vlSelfRef.__Vfunc_msg_sign__145__msg) 
                   >> 4U));
        vlSelfRef.__Vfunc_msg_to_signed__143____VlefCall_1__msg_sign 
            = vlSelfRef.__Vfunc_msg_sign__145__Vfuncout;
        if (vlSelfRef.__Vfunc_msg_to_signed__143____VlefCall_1__msg_sign) {
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_0__msg_to_signed 
                = (- vlSelfRef.__Vfunc_msg_to_signed__143__mag_value);
            goto __Vlabel6;
        }
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_0__msg_to_signed 
            = vlSelfRef.__Vfunc_msg_to_signed__143__mag_value;
        __Vlabel6: ;
    }
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____Vlvbound_h619e30fe__0 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_0__msg_to_signed;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__signed_c2v[0U] 
        = tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____Vlvbound_h619e30fe__0;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__sum_c2v 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__signed_c2v[0U];
    __Vfunc_msg_to_signed__143__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__t_msgs[1U];
    {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_0__msg_to_signed = 0U;
        vlSelfRef.__Vfunc_msg_to_signed__143__mag_value = 0U;
        vlSelfRef.__Vfunc_msg_mag__144__msg = __Vfunc_msg_to_signed__143__msg;
        vlSelf->__Vfunc_msg_mag__144__Vfuncout = 0;
        vlSelfRef.__Vfunc_msg_mag__144__Vfuncout = 
            (0x0000000fU & (IData)(vlSelfRef.__Vfunc_msg_mag__144__msg));
        vlSelfRef.__Vfunc_msg_to_signed__143____VlefCall_0__msg_mag 
            = vlSelfRef.__Vfunc_msg_mag__144__Vfuncout;
        vlSelfRef.__Vfunc_msg_to_signed__143__mag_value 
            = vlSelfRef.__Vfunc_msg_to_signed__143____VlefCall_0__msg_mag;
        vlSelfRef.__Vfunc_msg_sign__145__msg = __Vfunc_msg_to_signed__143__msg;
        vlSelf->__Vfunc_msg_sign__145__Vfuncout = 0;
        vlSelfRef.__Vfunc_msg_sign__145__Vfuncout = 
            (1U & ((IData)(vlSelfRef.__Vfunc_msg_sign__145__msg) 
                   >> 4U));
        vlSelfRef.__Vfunc_msg_to_signed__143____VlefCall_1__msg_sign 
            = vlSelfRef.__Vfunc_msg_sign__145__Vfuncout;
        if (vlSelfRef.__Vfunc_msg_to_signed__143____VlefCall_1__msg_sign) {
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_0__msg_to_signed 
                = (- vlSelfRef.__Vfunc_msg_to_signed__143__mag_value);
            goto __Vlabel7;
        }
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_0__msg_to_signed 
            = vlSelfRef.__Vfunc_msg_to_signed__143__mag_value;
        __Vlabel7: ;
    }
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____Vlvbound_h619e30fe__0 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_0__msg_to_signed;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__signed_c2v[1U] 
        = tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____Vlvbound_h619e30fe__0;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__sum_c2v 
        = (tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__sum_c2v 
           + vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__signed_c2v[1U]);
    __Vfunc_msg_to_signed__143__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__t_msgs[2U];
    {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_0__msg_to_signed = 0U;
        vlSelfRef.__Vfunc_msg_to_signed__143__mag_value = 0U;
        vlSelfRef.__Vfunc_msg_mag__144__msg = __Vfunc_msg_to_signed__143__msg;
        vlSelf->__Vfunc_msg_mag__144__Vfuncout = 0;
        vlSelfRef.__Vfunc_msg_mag__144__Vfuncout = 
            (0x0000000fU & (IData)(vlSelfRef.__Vfunc_msg_mag__144__msg));
        vlSelfRef.__Vfunc_msg_to_signed__143____VlefCall_0__msg_mag 
            = vlSelfRef.__Vfunc_msg_mag__144__Vfuncout;
        vlSelfRef.__Vfunc_msg_to_signed__143__mag_value 
            = vlSelfRef.__Vfunc_msg_to_signed__143____VlefCall_0__msg_mag;
        vlSelfRef.__Vfunc_msg_sign__145__msg = __Vfunc_msg_to_signed__143__msg;
        vlSelf->__Vfunc_msg_sign__145__Vfuncout = 0;
        vlSelfRef.__Vfunc_msg_sign__145__Vfuncout = 
            (1U & ((IData)(vlSelfRef.__Vfunc_msg_sign__145__msg) 
                   >> 4U));
        vlSelfRef.__Vfunc_msg_to_signed__143____VlefCall_1__msg_sign 
            = vlSelfRef.__Vfunc_msg_sign__145__Vfuncout;
        if (vlSelfRef.__Vfunc_msg_to_signed__143____VlefCall_1__msg_sign) {
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_0__msg_to_signed 
                = (- vlSelfRef.__Vfunc_msg_to_signed__143__mag_value);
            goto __Vlabel8;
        }
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_0__msg_to_signed 
            = vlSelfRef.__Vfunc_msg_to_signed__143__mag_value;
        __Vlabel8: ;
    }
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____Vlvbound_h619e30fe__0 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_0__msg_to_signed;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__signed_c2v[2U] 
        = tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____Vlvbound_h619e30fe__0;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__sum_c2v 
        = (tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__sum_c2v 
           + vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__signed_c2v[2U]);
    __Vfunc_alpha_scale__146__value = tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__sum_c2v;
    {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_1__alpha_scale = 0U;
        vlSelfRef.__Vfunc_alpha_scale__146__abs_value = 0U;
        vlSelfRef.__Vfunc_alpha_scale__146__scaled_abs = 0U;
        vlSelfRef.__Vfunc_alpha_scale__146__abs_value 
            = (VL_GTS_III(32, 0U, __Vfunc_alpha_scale__146__value)
                ? (- __Vfunc_alpha_scale__146__value)
                : __Vfunc_alpha_scale__146__value);
        vlSelfRef.__Vfunc_alpha_scale__146__scaled_abs 
            = VL_SHIFTRS_III(32,32,32, ((IData)(0x00000010U) 
                                        + VL_MULS_III(32, (IData)(3U), vlSelfRef.__Vfunc_alpha_scale__146__abs_value)), 5U);
        if (VL_GTS_III(32, 0U, __Vfunc_alpha_scale__146__value)) {
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_1__alpha_scale 
                = (- vlSelfRef.__Vfunc_alpha_scale__146__scaled_abs);
            goto __Vlabel9;
        }
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_1__alpha_scale 
            = vlSelfRef.__Vfunc_alpha_scale__146__scaled_abs;
        __Vlabel9: ;
    }
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__app_value 
        = (tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__gamma_value 
           + vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_1__alpha_scale);
    __Vfunc_app_from_int__147__value = tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__app_value;
    __Vfunc_app_from_int__147__app_value_int = __Vfunc_app_from_int__147__value;
    __Vfunc_app_from_int__147__result = (0x000000ffU 
                                         & __Vfunc_app_from_int__147__app_value_int);
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__vnu_x_out 
        = VL_GTS_III(32, 0U, tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__app_value);
    __Vfunc_alpha_scale__148__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__signed_c2v[0U];
    {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_2__alpha_scale = 0U;
        vlSelfRef.__Vfunc_alpha_scale__148__abs_value = 0U;
        vlSelfRef.__Vfunc_alpha_scale__148__scaled_abs = 0U;
        vlSelfRef.__Vfunc_alpha_scale__148__abs_value 
            = (VL_GTS_III(32, 0U, __Vfunc_alpha_scale__148__value)
                ? (- __Vfunc_alpha_scale__148__value)
                : __Vfunc_alpha_scale__148__value);
        vlSelfRef.__Vfunc_alpha_scale__148__scaled_abs 
            = VL_SHIFTRS_III(32,32,32, ((IData)(0x00000010U) 
                                        + VL_MULS_III(32, (IData)(3U), vlSelfRef.__Vfunc_alpha_scale__148__abs_value)), 5U);
        if (VL_GTS_III(32, 0U, __Vfunc_alpha_scale__148__value)) {
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_2__alpha_scale 
                = (- vlSelfRef.__Vfunc_alpha_scale__148__scaled_abs);
            goto __Vlabel10;
        }
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_2__alpha_scale 
            = vlSelfRef.__Vfunc_alpha_scale__148__scaled_abs;
        __Vlabel10: ;
    }
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__u_value 
        = (tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__app_value 
           - vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_2__alpha_scale);
    __Vfunc_msg_from_signed__149__value = tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__u_value;
    __Vfunc_msg_from_signed__149__abs_value = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__149__value)
                                                ? (- __Vfunc_msg_from_signed__149__value)
                                                : __Vfunc_msg_from_signed__149__value);
    __Vfunc_mag_from_int__150__value = __Vfunc_msg_from_signed__149__abs_value;
    __Vfunc_clamp_int__151__value = __Vfunc_mag_from_int__150__value;
    {
        vlSelfRef.__Vfunc_clamp_int__151__Vfuncout = 0U;
        if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__151__value)) {
            vlSelfRef.__Vfunc_clamp_int__151__Vfuncout = 0U;
            goto __Vlabel11;
        }
        if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__151__value)) {
            vlSelfRef.__Vfunc_clamp_int__151__Vfuncout = 0x0000000fU;
            goto __Vlabel11;
        }
        vlSelfRef.__Vfunc_clamp_int__151__Vfuncout 
            = __Vfunc_clamp_int__151__value;
        __Vlabel11: ;
    }
    __Vfunc_mag_from_int__150__clamped_value = vlSelfRef.__Vfunc_clamp_int__151__Vfuncout;
    __Vfunc_mag_from_int__150__result = (0x0000000fU 
                                         & __Vfunc_mag_from_int__150__clamped_value);
    __Vfunc_mag_from_int__150__Vfuncout = __Vfunc_mag_from_int__150__result;
    __Vfunc_msg_from_signed__149____VlefCall_0__mag_from_int 
        = __Vfunc_mag_from_int__150__Vfuncout;
    __Vfunc_msg_pack__152__mag = __Vfunc_msg_from_signed__149____VlefCall_0__mag_from_int;
    __Vfunc_msg_pack__152__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__149__value);
    __Vfunc_msg_pack__152__Vfuncout = (((IData)(__Vfunc_msg_pack__152__sign) 
                                        << 4U) | (IData)(__Vfunc_msg_pack__152__mag));
    __Vfunc_msg_from_signed__149__msg = __Vfunc_msg_pack__152__Vfuncout;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_3__msg_from_signed 
        = __Vfunc_msg_from_signed__149__msg;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____Vlvbound_h02a35ea2__0 
        = tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_3__msg_from_signed;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__vnu_u_next[0U] 
        = tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____Vlvbound_h02a35ea2__0;
    __Vfunc_alpha_scale__148__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__signed_c2v[1U];
    {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_2__alpha_scale = 0U;
        vlSelfRef.__Vfunc_alpha_scale__148__abs_value = 0U;
        vlSelfRef.__Vfunc_alpha_scale__148__scaled_abs = 0U;
        vlSelfRef.__Vfunc_alpha_scale__148__abs_value 
            = (VL_GTS_III(32, 0U, __Vfunc_alpha_scale__148__value)
                ? (- __Vfunc_alpha_scale__148__value)
                : __Vfunc_alpha_scale__148__value);
        vlSelfRef.__Vfunc_alpha_scale__148__scaled_abs 
            = VL_SHIFTRS_III(32,32,32, ((IData)(0x00000010U) 
                                        + VL_MULS_III(32, (IData)(3U), vlSelfRef.__Vfunc_alpha_scale__148__abs_value)), 5U);
        if (VL_GTS_III(32, 0U, __Vfunc_alpha_scale__148__value)) {
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_2__alpha_scale 
                = (- vlSelfRef.__Vfunc_alpha_scale__148__scaled_abs);
            goto __Vlabel12;
        }
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_2__alpha_scale 
            = vlSelfRef.__Vfunc_alpha_scale__148__scaled_abs;
        __Vlabel12: ;
    }
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__u_value 
        = (tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__app_value 
           - vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_2__alpha_scale);
    __Vfunc_msg_from_signed__149__value = tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__u_value;
    __Vfunc_msg_from_signed__149__abs_value = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__149__value)
                                                ? (- __Vfunc_msg_from_signed__149__value)
                                                : __Vfunc_msg_from_signed__149__value);
    __Vfunc_mag_from_int__150__value = __Vfunc_msg_from_signed__149__abs_value;
    __Vfunc_clamp_int__151__value = __Vfunc_mag_from_int__150__value;
    {
        vlSelfRef.__Vfunc_clamp_int__151__Vfuncout = 0U;
        if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__151__value)) {
            vlSelfRef.__Vfunc_clamp_int__151__Vfuncout = 0U;
            goto __Vlabel13;
        }
        if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__151__value)) {
            vlSelfRef.__Vfunc_clamp_int__151__Vfuncout = 0x0000000fU;
            goto __Vlabel13;
        }
        vlSelfRef.__Vfunc_clamp_int__151__Vfuncout 
            = __Vfunc_clamp_int__151__value;
        __Vlabel13: ;
    }
    __Vfunc_mag_from_int__150__clamped_value = vlSelfRef.__Vfunc_clamp_int__151__Vfuncout;
    __Vfunc_mag_from_int__150__result = (0x0000000fU 
                                         & __Vfunc_mag_from_int__150__clamped_value);
    __Vfunc_mag_from_int__150__Vfuncout = __Vfunc_mag_from_int__150__result;
    __Vfunc_msg_from_signed__149____VlefCall_0__mag_from_int 
        = __Vfunc_mag_from_int__150__Vfuncout;
    __Vfunc_msg_pack__152__mag = __Vfunc_msg_from_signed__149____VlefCall_0__mag_from_int;
    __Vfunc_msg_pack__152__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__149__value);
    __Vfunc_msg_pack__152__Vfuncout = (((IData)(__Vfunc_msg_pack__152__sign) 
                                        << 4U) | (IData)(__Vfunc_msg_pack__152__mag));
    __Vfunc_msg_from_signed__149__msg = __Vfunc_msg_pack__152__Vfuncout;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_3__msg_from_signed 
        = __Vfunc_msg_from_signed__149__msg;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____Vlvbound_h02a35ea2__0 
        = tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_3__msg_from_signed;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__vnu_u_next[1U] 
        = tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____Vlvbound_h02a35ea2__0;
    __Vfunc_alpha_scale__148__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__signed_c2v[2U];
    {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_2__alpha_scale = 0U;
        vlSelfRef.__Vfunc_alpha_scale__148__abs_value = 0U;
        vlSelfRef.__Vfunc_alpha_scale__148__scaled_abs = 0U;
        vlSelfRef.__Vfunc_alpha_scale__148__abs_value 
            = (VL_GTS_III(32, 0U, __Vfunc_alpha_scale__148__value)
                ? (- __Vfunc_alpha_scale__148__value)
                : __Vfunc_alpha_scale__148__value);
        vlSelfRef.__Vfunc_alpha_scale__148__scaled_abs 
            = VL_SHIFTRS_III(32,32,32, ((IData)(0x00000010U) 
                                        + VL_MULS_III(32, (IData)(3U), vlSelfRef.__Vfunc_alpha_scale__148__abs_value)), 5U);
        if (VL_GTS_III(32, 0U, __Vfunc_alpha_scale__148__value)) {
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_2__alpha_scale 
                = (- vlSelfRef.__Vfunc_alpha_scale__148__scaled_abs);
            goto __Vlabel14;
        }
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_2__alpha_scale 
            = vlSelfRef.__Vfunc_alpha_scale__148__scaled_abs;
        __Vlabel14: ;
    }
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__u_value 
        = (tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__app_value 
           - vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_2__alpha_scale);
    __Vfunc_msg_from_signed__149__value = tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT__u_value;
    __Vfunc_msg_from_signed__149__abs_value = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__149__value)
                                                ? (- __Vfunc_msg_from_signed__149__value)
                                                : __Vfunc_msg_from_signed__149__value);
    __Vfunc_mag_from_int__150__value = __Vfunc_msg_from_signed__149__abs_value;
    __Vfunc_clamp_int__151__value = __Vfunc_mag_from_int__150__value;
    {
        vlSelfRef.__Vfunc_clamp_int__151__Vfuncout = 0U;
        if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__151__value)) {
            vlSelfRef.__Vfunc_clamp_int__151__Vfuncout = 0U;
            goto __Vlabel15;
        }
        if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__151__value)) {
            vlSelfRef.__Vfunc_clamp_int__151__Vfuncout = 0x0000000fU;
            goto __Vlabel15;
        }
        vlSelfRef.__Vfunc_clamp_int__151__Vfuncout 
            = __Vfunc_clamp_int__151__value;
        __Vlabel15: ;
    }
    __Vfunc_mag_from_int__150__clamped_value = vlSelfRef.__Vfunc_clamp_int__151__Vfuncout;
    __Vfunc_mag_from_int__150__result = (0x0000000fU 
                                         & __Vfunc_mag_from_int__150__clamped_value);
    __Vfunc_mag_from_int__150__Vfuncout = __Vfunc_mag_from_int__150__result;
    __Vfunc_msg_from_signed__149____VlefCall_0__mag_from_int 
        = __Vfunc_mag_from_int__150__Vfuncout;
    __Vfunc_msg_pack__152__mag = __Vfunc_msg_from_signed__149____VlefCall_0__mag_from_int;
    __Vfunc_msg_pack__152__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__149__value);
    __Vfunc_msg_pack__152__Vfuncout = (((IData)(__Vfunc_msg_pack__152__sign) 
                                        << 4U) | (IData)(__Vfunc_msg_pack__152__mag));
    __Vfunc_msg_from_signed__149__msg = __Vfunc_msg_pack__152__Vfuncout;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_3__msg_from_signed 
        = __Vfunc_msg_from_signed__149__msg;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____Vlvbound_h02a35ea2__0 
        = tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____VlemCall_3__msg_from_signed;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__vnu_u_next[2U] 
        = tb_mdpc_decoder_demo__DOT__dut__DOT__u_vnu__DOT____Vlvbound_h02a35ea2__0;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__advance_var 
        = ((3U & ((IData)(1U) + (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__scan_slot))) 
           >= ((vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_count[0U] 
                >= vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_count[1U])
                ? vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_count[0U]
                : vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_count[1U]));
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_local_value = 0U;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_global_value = 0U;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__edge_slot_value = 0U;
    if ((0U < vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_count[0U])) {
        vlSelfRef.__Vfunc_i_entry_row_local__48__i_entry 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_entries[0U][0U];
        vlSelfRef.__Vfunc_i_entry_row_local__48__Vfuncout 
            = (7U & (IData)(vlSelfRef.__Vfunc_i_entry_row_local__48__i_entry));
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_local_value 
            = vlSelfRef.__Vfunc_i_entry_row_local__48__Vfuncout;
        vlSelfRef.__Vfunc_row_global_from_lane_local__49__row_local 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_local_value;
        vlSelfRef.__Vfunc_row_global_from_lane_local__49__row_value 
            = vlSelfRef.__Vfunc_row_global_from_lane_local__49__row_local;
        vlSelfRef.__Vfunc_row_global_from_lane_local__49__Vfuncout 
            = (7U & vlSelfRef.__Vfunc_row_global_from_lane_local__49__row_value);
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_global_value 
            = vlSelfRef.__Vfunc_row_global_from_lane_local__49__Vfuncout;
        vlSelfRef.__Vfunc_i_entry_edge_slot__50__i_entry 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_entries[0U][0U];
        vlSelfRef.__Vfunc_i_entry_edge_slot__50__Vfuncout 
            = (3U & ((IData)(vlSelfRef.__Vfunc_i_entry_edge_slot__50__i_entry) 
                     >> 3U));
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__edge_slot_value 
            = vlSelfRef.__Vfunc_i_entry_edge_slot__50__Vfuncout;
        vlSelfRef.__Vfunc_lane_edge_pack__51__edge_slot 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__edge_slot_value;
        vlSelfRef.__Vfunc_lane_edge_pack__51__var_idx 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx;
        vlSelfRef.__Vfunc_lane_edge_pack__51__row_global 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_global_value;
        vlSelfRef.__Vfunc_lane_edge_pack__51__row_local 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_local_value;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT____VlemCall_0__lane_edge_pack 
            = (1U | ((((IData)(vlSelfRef.__Vfunc_lane_edge_pack__51__edge_slot) 
                       << 0x0000000bU) | ((IData)(vlSelfRef.__Vfunc_lane_edge_pack__51__var_idx) 
                                          << 7U)) | 
                     (((IData)(vlSelfRef.__Vfunc_lane_edge_pack__51__row_global) 
                       << 4U) | ((IData)(vlSelfRef.__Vfunc_lane_edge_pack__51__row_local) 
                                 << 1U))));
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT____Vlvbound_hd03a4323__0 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT____VlemCall_0__lane_edge_pack;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_edges[0U][0U] 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT____Vlvbound_hd03a4323__0;
    } else {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_edges[0U][0U] = 0U;
    }
    if ((1U < vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_count[0U])) {
        vlSelfRef.__Vfunc_i_entry_row_local__48__i_entry 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_entries[0U][1U];
        vlSelfRef.__Vfunc_i_entry_row_local__48__Vfuncout 
            = (7U & (IData)(vlSelfRef.__Vfunc_i_entry_row_local__48__i_entry));
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_local_value 
            = vlSelfRef.__Vfunc_i_entry_row_local__48__Vfuncout;
        vlSelfRef.__Vfunc_row_global_from_lane_local__49__row_local 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_local_value;
        vlSelfRef.__Vfunc_row_global_from_lane_local__49__row_value 
            = vlSelfRef.__Vfunc_row_global_from_lane_local__49__row_local;
        vlSelfRef.__Vfunc_row_global_from_lane_local__49__Vfuncout 
            = (7U & vlSelfRef.__Vfunc_row_global_from_lane_local__49__row_value);
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_global_value 
            = vlSelfRef.__Vfunc_row_global_from_lane_local__49__Vfuncout;
        vlSelfRef.__Vfunc_i_entry_edge_slot__50__i_entry 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_entries[0U][1U];
        vlSelfRef.__Vfunc_i_entry_edge_slot__50__Vfuncout 
            = (3U & ((IData)(vlSelfRef.__Vfunc_i_entry_edge_slot__50__i_entry) 
                     >> 3U));
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__edge_slot_value 
            = vlSelfRef.__Vfunc_i_entry_edge_slot__50__Vfuncout;
        vlSelfRef.__Vfunc_lane_edge_pack__51__edge_slot 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__edge_slot_value;
        vlSelfRef.__Vfunc_lane_edge_pack__51__var_idx 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx;
        vlSelfRef.__Vfunc_lane_edge_pack__51__row_global 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_global_value;
        vlSelfRef.__Vfunc_lane_edge_pack__51__row_local 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_local_value;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT____VlemCall_0__lane_edge_pack 
            = (1U | ((((IData)(vlSelfRef.__Vfunc_lane_edge_pack__51__edge_slot) 
                       << 0x0000000bU) | ((IData)(vlSelfRef.__Vfunc_lane_edge_pack__51__var_idx) 
                                          << 7U)) | 
                     (((IData)(vlSelfRef.__Vfunc_lane_edge_pack__51__row_global) 
                       << 4U) | ((IData)(vlSelfRef.__Vfunc_lane_edge_pack__51__row_local) 
                                 << 1U))));
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT____Vlvbound_hd03a4323__0 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT____VlemCall_0__lane_edge_pack;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_edges[0U][1U] 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT____Vlvbound_hd03a4323__0;
    } else {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_edges[0U][1U] = 0U;
    }
    if ((2U < vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_count[0U])) {
        vlSelfRef.__Vfunc_i_entry_row_local__48__i_entry 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_entries[0U][2U];
        vlSelfRef.__Vfunc_i_entry_row_local__48__Vfuncout 
            = (7U & (IData)(vlSelfRef.__Vfunc_i_entry_row_local__48__i_entry));
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_local_value 
            = vlSelfRef.__Vfunc_i_entry_row_local__48__Vfuncout;
        vlSelfRef.__Vfunc_row_global_from_lane_local__49__row_local 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_local_value;
        vlSelfRef.__Vfunc_row_global_from_lane_local__49__row_value 
            = vlSelfRef.__Vfunc_row_global_from_lane_local__49__row_local;
        vlSelfRef.__Vfunc_row_global_from_lane_local__49__Vfuncout 
            = (7U & vlSelfRef.__Vfunc_row_global_from_lane_local__49__row_value);
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_global_value 
            = vlSelfRef.__Vfunc_row_global_from_lane_local__49__Vfuncout;
        vlSelfRef.__Vfunc_i_entry_edge_slot__50__i_entry 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_entries[0U][2U];
        vlSelfRef.__Vfunc_i_entry_edge_slot__50__Vfuncout 
            = (3U & ((IData)(vlSelfRef.__Vfunc_i_entry_edge_slot__50__i_entry) 
                     >> 3U));
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__edge_slot_value 
            = vlSelfRef.__Vfunc_i_entry_edge_slot__50__Vfuncout;
        vlSelfRef.__Vfunc_lane_edge_pack__51__edge_slot 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__edge_slot_value;
        vlSelfRef.__Vfunc_lane_edge_pack__51__var_idx 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx;
        vlSelfRef.__Vfunc_lane_edge_pack__51__row_global 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_global_value;
        vlSelfRef.__Vfunc_lane_edge_pack__51__row_local 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_local_value;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT____VlemCall_0__lane_edge_pack 
            = (1U | ((((IData)(vlSelfRef.__Vfunc_lane_edge_pack__51__edge_slot) 
                       << 0x0000000bU) | ((IData)(vlSelfRef.__Vfunc_lane_edge_pack__51__var_idx) 
                                          << 7U)) | 
                     (((IData)(vlSelfRef.__Vfunc_lane_edge_pack__51__row_global) 
                       << 4U) | ((IData)(vlSelfRef.__Vfunc_lane_edge_pack__51__row_local) 
                                 << 1U))));
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT____Vlvbound_hd03a4323__0 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT____VlemCall_0__lane_edge_pack;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_edges[0U][2U] 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT____Vlvbound_hd03a4323__0;
    } else {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_edges[0U][2U] = 0U;
    }
    if ((0U < vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_count[1U])) {
        vlSelfRef.__Vfunc_i_entry_row_local__48__i_entry 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_entries[1U][0U];
        vlSelfRef.__Vfunc_i_entry_row_local__48__Vfuncout 
            = (7U & (IData)(vlSelfRef.__Vfunc_i_entry_row_local__48__i_entry));
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_local_value 
            = vlSelfRef.__Vfunc_i_entry_row_local__48__Vfuncout;
        vlSelfRef.__Vfunc_row_global_from_lane_local__49__row_local 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_local_value;
        vlSelfRef.__Vfunc_row_global_from_lane_local__49__row_value 
            = ((IData)(4U) + (IData)(vlSelfRef.__Vfunc_row_global_from_lane_local__49__row_local));
        vlSelfRef.__Vfunc_row_global_from_lane_local__49__Vfuncout 
            = (7U & vlSelfRef.__Vfunc_row_global_from_lane_local__49__row_value);
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_global_value 
            = vlSelfRef.__Vfunc_row_global_from_lane_local__49__Vfuncout;
        vlSelfRef.__Vfunc_i_entry_edge_slot__50__i_entry 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_entries[1U][0U];
        vlSelfRef.__Vfunc_i_entry_edge_slot__50__Vfuncout 
            = (3U & ((IData)(vlSelfRef.__Vfunc_i_entry_edge_slot__50__i_entry) 
                     >> 3U));
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__edge_slot_value 
            = vlSelfRef.__Vfunc_i_entry_edge_slot__50__Vfuncout;
        vlSelfRef.__Vfunc_lane_edge_pack__51__edge_slot 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__edge_slot_value;
        vlSelfRef.__Vfunc_lane_edge_pack__51__var_idx 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx;
        vlSelfRef.__Vfunc_lane_edge_pack__51__row_global 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_global_value;
        vlSelfRef.__Vfunc_lane_edge_pack__51__row_local 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_local_value;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT____VlemCall_0__lane_edge_pack 
            = (1U | ((((IData)(vlSelfRef.__Vfunc_lane_edge_pack__51__edge_slot) 
                       << 0x0000000bU) | ((IData)(vlSelfRef.__Vfunc_lane_edge_pack__51__var_idx) 
                                          << 7U)) | 
                     (((IData)(vlSelfRef.__Vfunc_lane_edge_pack__51__row_global) 
                       << 4U) | ((IData)(vlSelfRef.__Vfunc_lane_edge_pack__51__row_local) 
                                 << 1U))));
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT____Vlvbound_hd03a4323__0 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT____VlemCall_0__lane_edge_pack;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_edges[1U][0U] 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT____Vlvbound_hd03a4323__0;
    } else {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_edges[1U][0U] = 0U;
    }
    if ((1U < vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_count[1U])) {
        vlSelfRef.__Vfunc_i_entry_row_local__48__i_entry 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_entries[1U][1U];
        vlSelfRef.__Vfunc_i_entry_row_local__48__Vfuncout 
            = (7U & (IData)(vlSelfRef.__Vfunc_i_entry_row_local__48__i_entry));
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_local_value 
            = vlSelfRef.__Vfunc_i_entry_row_local__48__Vfuncout;
        vlSelfRef.__Vfunc_row_global_from_lane_local__49__row_local 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_local_value;
        vlSelfRef.__Vfunc_row_global_from_lane_local__49__row_value 
            = ((IData)(4U) + (IData)(vlSelfRef.__Vfunc_row_global_from_lane_local__49__row_local));
        vlSelfRef.__Vfunc_row_global_from_lane_local__49__Vfuncout 
            = (7U & vlSelfRef.__Vfunc_row_global_from_lane_local__49__row_value);
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_global_value 
            = vlSelfRef.__Vfunc_row_global_from_lane_local__49__Vfuncout;
        vlSelfRef.__Vfunc_i_entry_edge_slot__50__i_entry 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_entries[1U][1U];
        vlSelfRef.__Vfunc_i_entry_edge_slot__50__Vfuncout 
            = (3U & ((IData)(vlSelfRef.__Vfunc_i_entry_edge_slot__50__i_entry) 
                     >> 3U));
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__edge_slot_value 
            = vlSelfRef.__Vfunc_i_entry_edge_slot__50__Vfuncout;
        vlSelfRef.__Vfunc_lane_edge_pack__51__edge_slot 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__edge_slot_value;
        vlSelfRef.__Vfunc_lane_edge_pack__51__var_idx 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx;
        vlSelfRef.__Vfunc_lane_edge_pack__51__row_global 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_global_value;
        vlSelfRef.__Vfunc_lane_edge_pack__51__row_local 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_local_value;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT____VlemCall_0__lane_edge_pack 
            = (1U | ((((IData)(vlSelfRef.__Vfunc_lane_edge_pack__51__edge_slot) 
                       << 0x0000000bU) | ((IData)(vlSelfRef.__Vfunc_lane_edge_pack__51__var_idx) 
                                          << 7U)) | 
                     (((IData)(vlSelfRef.__Vfunc_lane_edge_pack__51__row_global) 
                       << 4U) | ((IData)(vlSelfRef.__Vfunc_lane_edge_pack__51__row_local) 
                                 << 1U))));
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT____Vlvbound_hd03a4323__0 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT____VlemCall_0__lane_edge_pack;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_edges[1U][1U] 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT____Vlvbound_hd03a4323__0;
    } else {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_edges[1U][1U] = 0U;
    }
    if ((2U < vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_count[1U])) {
        vlSelfRef.__Vfunc_i_entry_row_local__48__i_entry 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_entries[1U][2U];
        vlSelfRef.__Vfunc_i_entry_row_local__48__Vfuncout 
            = (7U & (IData)(vlSelfRef.__Vfunc_i_entry_row_local__48__i_entry));
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_local_value 
            = vlSelfRef.__Vfunc_i_entry_row_local__48__Vfuncout;
        vlSelfRef.__Vfunc_row_global_from_lane_local__49__row_local 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_local_value;
        vlSelfRef.__Vfunc_row_global_from_lane_local__49__row_value 
            = ((IData)(4U) + (IData)(vlSelfRef.__Vfunc_row_global_from_lane_local__49__row_local));
        vlSelfRef.__Vfunc_row_global_from_lane_local__49__Vfuncout 
            = (7U & vlSelfRef.__Vfunc_row_global_from_lane_local__49__row_value);
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_global_value 
            = vlSelfRef.__Vfunc_row_global_from_lane_local__49__Vfuncout;
        vlSelfRef.__Vfunc_i_entry_edge_slot__50__i_entry 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_entries[1U][2U];
        vlSelfRef.__Vfunc_i_entry_edge_slot__50__Vfuncout 
            = (3U & ((IData)(vlSelfRef.__Vfunc_i_entry_edge_slot__50__i_entry) 
                     >> 3U));
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__edge_slot_value 
            = vlSelfRef.__Vfunc_i_entry_edge_slot__50__Vfuncout;
        vlSelfRef.__Vfunc_lane_edge_pack__51__edge_slot 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__edge_slot_value;
        vlSelfRef.__Vfunc_lane_edge_pack__51__var_idx 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx;
        vlSelfRef.__Vfunc_lane_edge_pack__51__row_global 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_global_value;
        vlSelfRef.__Vfunc_lane_edge_pack__51__row_local 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT__unnamedblk1__DOT__row_local_value;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT____VlemCall_0__lane_edge_pack 
            = (1U | ((((IData)(vlSelfRef.__Vfunc_lane_edge_pack__51__edge_slot) 
                       << 0x0000000bU) | ((IData)(vlSelfRef.__Vfunc_lane_edge_pack__51__var_idx) 
                                          << 7U)) | 
                     (((IData)(vlSelfRef.__Vfunc_lane_edge_pack__51__row_global) 
                       << 4U) | ((IData)(vlSelfRef.__Vfunc_lane_edge_pack__51__row_local) 
                                 << 1U))));
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT____Vlvbound_hd03a4323__0 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT____VlemCall_0__lane_edge_pack;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_edges[1U][2U] 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_h_shift__DOT____Vlvbound_hd03a4323__0;
    } else {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_edges[1U][2U] = 0U;
    }
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_clear_en 
        = ((1U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state)) 
           | (IData)(tb_mdpc_decoder_demo__DOT__dut__DOT__continue_decode));
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__i_shift_en 
        = (((2U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state)) 
            | (3U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state))) 
           & (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__advance_var));
    if ((2U >= (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__scan_slot))) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge0 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_edges[0U]
            [vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__scan_slot];
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge1 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__current_lane_edges[1U]
            [vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__scan_slot];
    } else {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge0 = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge1 = 0U;
    }
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_wr_en0 
        = ((2U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state)) 
           & (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge0));
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_row_state_a0 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem
        [(7U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge0) 
                >> 4U))];
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_msg0 = (
                                                   (2U 
                                                    >= 
                                                    (3U 
                                                     & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge0) 
                                                        >> 0x0000000bU)))
                                                    ? vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem
                                                   [vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx]
                                                   [
                                                   (3U 
                                                    & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge0) 
                                                       >> 0x0000000bU))]
                                                    : 0U);
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_wr_en1 
        = ((2U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state)) 
           & (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge1));
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_row_state_a1 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem
        [(7U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge1) 
                >> 4U))];
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_msg1 = (
                                                   (2U 
                                                    >= 
                                                    (3U 
                                                     & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge1) 
                                                        >> 0x0000000bU)))
                                                    ? vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem
                                                   [vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx]
                                                   [
                                                   (3U 
                                                    & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge1) 
                                                       >> 0x0000000bU))]
                                                    : 0U);
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__next_state 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_row_state_a0;
    __Vfunc_msg_sign__81__msg = tb_mdpc_decoder_demo__DOT__dut__DOT__u_msg0;
    __Vfunc_msg_sign__81__Vfuncout = (1U & ((IData)(__Vfunc_msg_sign__81__msg) 
                                            >> 4U));
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__cnu_a_sign0 
        = __Vfunc_msg_sign__81__Vfuncout;
    __Vfunc_msg_mag__82__msg = tb_mdpc_decoder_demo__DOT__dut__DOT__u_msg0;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_0__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__82__msg));
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__abs_mag 
        = tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_0__msg_mag;
    __Vfunc_row_state_valid_count__83__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_row_state_a0;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_1__row_state_valid_count 
        = (3U & ((IData)(__Vfunc_row_state_valid_count__83__state) 
                 >> 0x0dU));
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__next_count 
        = tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_1__row_state_valid_count;
    __Vfunc_row_state_valid_count__84__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_row_state_a0;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_2__row_state_valid_count 
        = (3U & ((IData)(__Vfunc_row_state_valid_count__84__state) 
                 >> 0x0dU));
    if ((0U == (IData)(tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_2__row_state_valid_count))) {
        vlSelfRef.__Vfunc_mag_from_int__85__value = tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__abs_mag;
        vlSelfRef.__Vfunc_clamp_int__86__hi = 0x0000000fU;
        vlSelfRef.__Vfunc_clamp_int__86__lo = 0U;
        vlSelfRef.__Vfunc_clamp_int__86__value = vlSelfRef.__Vfunc_mag_from_int__85__value;
        {
            vlSelfRef.__Vfunc_clamp_int__86__Vfuncout = 0U;
            if (VL_LTS_III(32, vlSelfRef.__Vfunc_clamp_int__86__value, vlSelfRef.__Vfunc_clamp_int__86__lo)) {
                vlSelfRef.__Vfunc_clamp_int__86__Vfuncout 
                    = vlSelfRef.__Vfunc_clamp_int__86__lo;
                goto __Vlabel16;
            }
            if (VL_GTS_III(32, vlSelfRef.__Vfunc_clamp_int__86__value, vlSelfRef.__Vfunc_clamp_int__86__hi)) {
                vlSelfRef.__Vfunc_clamp_int__86__Vfuncout 
                    = vlSelfRef.__Vfunc_clamp_int__86__hi;
                goto __Vlabel16;
            }
            vlSelfRef.__Vfunc_clamp_int__86__Vfuncout 
                = vlSelfRef.__Vfunc_clamp_int__86__value;
            __Vlabel16: ;
        }
        vlSelfRef.__Vfunc_mag_from_int__85__clamped_value 
            = vlSelfRef.__Vfunc_clamp_int__86__Vfuncout;
        vlSelfRef.__Vfunc_mag_from_int__85__result 
            = (0x0000000fU & vlSelfRef.__Vfunc_mag_from_int__85__clamped_value);
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_3__mag_from_int 
            = vlSelfRef.__Vfunc_mag_from_int__85__result;
        vlSelfRef.__Vfunc_clamp_int__88__hi = 0x0000000fU;
        vlSelfRef.__Vfunc_clamp_int__88__lo = 0U;
        vlSelfRef.__Vfunc_clamp_int__88__value = 0x0000000fU;
        {
            vlSelfRef.__Vfunc_clamp_int__88__Vfuncout = 0U;
            if (VL_LTS_III(32, vlSelfRef.__Vfunc_clamp_int__88__value, vlSelfRef.__Vfunc_clamp_int__88__lo)) {
                vlSelfRef.__Vfunc_clamp_int__88__Vfuncout 
                    = vlSelfRef.__Vfunc_clamp_int__88__lo;
                goto __Vlabel17;
            }
            if (VL_GTS_III(32, vlSelfRef.__Vfunc_clamp_int__88__value, vlSelfRef.__Vfunc_clamp_int__88__hi)) {
                vlSelfRef.__Vfunc_clamp_int__88__Vfuncout 
                    = vlSelfRef.__Vfunc_clamp_int__88__hi;
                goto __Vlabel17;
            }
            vlSelfRef.__Vfunc_clamp_int__88__Vfuncout 
                = vlSelfRef.__Vfunc_clamp_int__88__value;
            __Vlabel17: ;
        }
        vlSelfRef.__Vfunc_mag_from_int__87__clamped_value 
            = vlSelfRef.__Vfunc_clamp_int__88__Vfuncout;
        vlSelfRef.__Vfunc_mag_from_int__87__result 
            = (0x0000000fU & vlSelfRef.__Vfunc_mag_from_int__87__clamped_value);
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_4__mag_from_int 
            = vlSelfRef.__Vfunc_mag_from_int__87__result;
        vlSelfRef.__Vfunc_msg_sign__89__msg = tb_mdpc_decoder_demo__DOT__dut__DOT__u_msg0;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_5__msg_sign 
            = (1U & ((IData)(vlSelfRef.__Vfunc_msg_sign__89__msg) 
                     >> 4U));
        vlSelfRef.__Vfunc_row_state_pack__90__sign_xor 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_5__msg_sign;
        vlSelfRef.__Vfunc_row_state_pack__90__min_id 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx;
        vlSelfRef.__Vfunc_row_state_pack__90__min2 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_4__mag_from_int;
        vlSelfRef.__Vfunc_row_state_pack__90__min1 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_3__mag_from_int;
        vlSelfRef.__Vfunc_row_state_pack__90__Vfuncout 
            = (0x00002000U | ((((IData)(vlSelfRef.__Vfunc_row_state_pack__90__sign_xor) 
                                << 0x0000000cU) | ((IData)(vlSelfRef.__Vfunc_row_state_pack__90__min_id) 
                                                   << 8U)) 
                              | (((IData)(vlSelfRef.__Vfunc_row_state_pack__90__min2) 
                                  << 4U) | (IData)(vlSelfRef.__Vfunc_row_state_pack__90__min1))));
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__next_state 
            = vlSelfRef.__Vfunc_row_state_pack__90__Vfuncout;
    } else {
        vlSelfRef.__Vfunc_row_state_valid_count__91__state 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_row_state_a0;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_6__row_state_valid_count 
            = (3U & ((IData)(vlSelfRef.__Vfunc_row_state_valid_count__91__state) 
                     >> 0x0dU));
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__next_count 
            = ((IData)(1U) + (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_6__row_state_valid_count));
        if (VL_LTS_III(32, 3U, tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__next_count)) {
            tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__next_count = 3U;
        }
        vlSelfRef.__Vfunc_row_state_sign_xor__92__state 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_row_state_a0;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_7__row_state_sign_xor 
            = (1U & ((IData)(vlSelfRef.__Vfunc_row_state_sign_xor__92__state) 
                     >> 0x0cU));
        vlSelfRef.__Vfunc_msg_sign__93__msg = tb_mdpc_decoder_demo__DOT__dut__DOT__u_msg0;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_8__msg_sign 
            = (1U & ((IData)(vlSelfRef.__Vfunc_msg_sign__93__msg) 
                     >> 4U));
        vlSelfRef.__Vfunc_row_state_set_sign_xor__94__sign_xor 
            = ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_7__row_state_sign_xor) 
               ^ (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_8__msg_sign));
        vlSelfRef.__Vfunc_row_state_set_sign_xor__94__state 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__next_state;
        vlSelfRef.__Vfunc_row_state_set_sign_xor__94__next_state 
            = vlSelfRef.__Vfunc_row_state_set_sign_xor__94__state;
        vlSelfRef.__Vfunc_row_state_set_sign_xor__94__next_state 
            = ((0x6fffU & (IData)(vlSelfRef.__Vfunc_row_state_set_sign_xor__94__next_state)) 
               | ((IData)(vlSelfRef.__Vfunc_row_state_set_sign_xor__94__sign_xor) 
                  << 0x0000000cU));
        vlSelfRef.__Vfunc_row_state_set_sign_xor__94__Vfuncout 
            = vlSelfRef.__Vfunc_row_state_set_sign_xor__94__next_state;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__next_state 
            = vlSelfRef.__Vfunc_row_state_set_sign_xor__94__Vfuncout;
        vlSelfRef.__Vfunc_row_state_set_valid_count__95__valid_count 
            = (3U & tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__next_count);
        vlSelfRef.__Vfunc_row_state_set_valid_count__95__state 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__next_state;
        vlSelfRef.__Vfunc_row_state_set_valid_count__95__next_state 
            = vlSelfRef.__Vfunc_row_state_set_valid_count__95__state;
        vlSelfRef.__Vfunc_row_state_set_valid_count__95__next_state 
            = ((0x1fffU & (IData)(vlSelfRef.__Vfunc_row_state_set_valid_count__95__next_state)) 
               | ((IData)(vlSelfRef.__Vfunc_row_state_set_valid_count__95__valid_count) 
                  << 0x0000000dU));
        vlSelfRef.__Vfunc_row_state_set_valid_count__95__Vfuncout 
            = vlSelfRef.__Vfunc_row_state_set_valid_count__95__next_state;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__next_state 
            = vlSelfRef.__Vfunc_row_state_set_valid_count__95__Vfuncout;
        vlSelfRef.__Vfunc_row_state_min1__96__state 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_row_state_a0;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_9__row_state_min1 
            = (0x0000000fU & (IData)(vlSelfRef.__Vfunc_row_state_min1__96__state));
        if (VL_LTS_III(32, tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__abs_mag, (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_9__row_state_min1))) {
            vlSelfRef.__Vfunc_row_state_min1__97__state 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_row_state_a0;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_10__row_state_min1 
                = (0x0000000fU & (IData)(vlSelfRef.__Vfunc_row_state_min1__97__state));
            vlSelfRef.__Vfunc_row_state_set_min2__98__min2 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_10__row_state_min1;
            vlSelfRef.__Vfunc_row_state_set_min2__98__state 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__next_state;
            vlSelfRef.__Vfunc_row_state_set_min2__98__next_state 
                = vlSelfRef.__Vfunc_row_state_set_min2__98__state;
            vlSelfRef.__Vfunc_row_state_set_min2__98__next_state 
                = ((0x7f0fU & (IData)(vlSelfRef.__Vfunc_row_state_set_min2__98__next_state)) 
                   | ((IData)(vlSelfRef.__Vfunc_row_state_set_min2__98__min2) 
                      << 4U));
            vlSelfRef.__Vfunc_row_state_set_min2__98__Vfuncout 
                = vlSelfRef.__Vfunc_row_state_set_min2__98__next_state;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__next_state 
                = vlSelfRef.__Vfunc_row_state_set_min2__98__Vfuncout;
            vlSelfRef.__Vfunc_mag_from_int__99__value 
                = tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__abs_mag;
            vlSelfRef.__Vfunc_clamp_int__100__hi = 0x0000000fU;
            vlSelfRef.__Vfunc_clamp_int__100__lo = 0U;
            vlSelfRef.__Vfunc_clamp_int__100__value 
                = vlSelfRef.__Vfunc_mag_from_int__99__value;
            {
                vlSelfRef.__Vfunc_clamp_int__100__Vfuncout = 0U;
                if (VL_LTS_III(32, vlSelfRef.__Vfunc_clamp_int__100__value, vlSelfRef.__Vfunc_clamp_int__100__lo)) {
                    vlSelfRef.__Vfunc_clamp_int__100__Vfuncout 
                        = vlSelfRef.__Vfunc_clamp_int__100__lo;
                    goto __Vlabel18;
                }
                if (VL_GTS_III(32, vlSelfRef.__Vfunc_clamp_int__100__value, vlSelfRef.__Vfunc_clamp_int__100__hi)) {
                    vlSelfRef.__Vfunc_clamp_int__100__Vfuncout 
                        = vlSelfRef.__Vfunc_clamp_int__100__hi;
                    goto __Vlabel18;
                }
                vlSelfRef.__Vfunc_clamp_int__100__Vfuncout 
                    = vlSelfRef.__Vfunc_clamp_int__100__value;
                __Vlabel18: ;
            }
            vlSelfRef.__Vfunc_mag_from_int__99__clamped_value 
                = vlSelfRef.__Vfunc_clamp_int__100__Vfuncout;
            vlSelfRef.__Vfunc_mag_from_int__99__result 
                = (0x0000000fU & vlSelfRef.__Vfunc_mag_from_int__99__clamped_value);
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_11__mag_from_int 
                = vlSelfRef.__Vfunc_mag_from_int__99__result;
            vlSelfRef.__Vfunc_row_state_set_min1__101__min1 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_11__mag_from_int;
            vlSelfRef.__Vfunc_row_state_set_min1__101__state 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__next_state;
            vlSelfRef.__Vfunc_row_state_set_min1__101__next_state 
                = vlSelfRef.__Vfunc_row_state_set_min1__101__state;
            vlSelfRef.__Vfunc_row_state_set_min1__101__next_state 
                = ((0x7ff0U & (IData)(vlSelfRef.__Vfunc_row_state_set_min1__101__next_state)) 
                   | (IData)(vlSelfRef.__Vfunc_row_state_set_min1__101__min1));
            vlSelfRef.__Vfunc_row_state_set_min1__101__Vfuncout 
                = vlSelfRef.__Vfunc_row_state_set_min1__101__next_state;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__next_state 
                = vlSelfRef.__Vfunc_row_state_set_min1__101__Vfuncout;
            vlSelfRef.__Vfunc_row_state_set_min_id__102__min_id 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx;
            vlSelfRef.__Vfunc_row_state_set_min_id__102__state 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__next_state;
            vlSelfRef.__Vfunc_row_state_set_min_id__102__next_state 
                = vlSelfRef.__Vfunc_row_state_set_min_id__102__state;
            vlSelfRef.__Vfunc_row_state_set_min_id__102__next_state 
                = ((0x70ffU & (IData)(vlSelfRef.__Vfunc_row_state_set_min_id__102__next_state)) 
                   | ((IData)(vlSelfRef.__Vfunc_row_state_set_min_id__102__min_id) 
                      << 8U));
            vlSelfRef.__Vfunc_row_state_set_min_id__102__Vfuncout 
                = vlSelfRef.__Vfunc_row_state_set_min_id__102__next_state;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__next_state 
                = vlSelfRef.__Vfunc_row_state_set_min_id__102__Vfuncout;
        } else {
            vlSelfRef.__Vfunc_row_state_min2__103__state 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_row_state_a0;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_12__row_state_min2 
                = (0x0000000fU & ((IData)(vlSelfRef.__Vfunc_row_state_min2__103__state) 
                                  >> 4U));
            if (VL_LTS_III(32, tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__abs_mag, (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_12__row_state_min2))) {
                vlSelfRef.__Vfunc_mag_from_int__104__value 
                    = tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__abs_mag;
                vlSelfRef.__Vfunc_clamp_int__105__hi = 0x0000000fU;
                vlSelfRef.__Vfunc_clamp_int__105__lo = 0U;
                vlSelfRef.__Vfunc_clamp_int__105__value 
                    = vlSelfRef.__Vfunc_mag_from_int__104__value;
                {
                    vlSelfRef.__Vfunc_clamp_int__105__Vfuncout = 0U;
                    if (VL_LTS_III(32, vlSelfRef.__Vfunc_clamp_int__105__value, vlSelfRef.__Vfunc_clamp_int__105__lo)) {
                        vlSelfRef.__Vfunc_clamp_int__105__Vfuncout 
                            = vlSelfRef.__Vfunc_clamp_int__105__lo;
                        goto __Vlabel19;
                    }
                    if (VL_GTS_III(32, vlSelfRef.__Vfunc_clamp_int__105__value, vlSelfRef.__Vfunc_clamp_int__105__hi)) {
                        vlSelfRef.__Vfunc_clamp_int__105__Vfuncout 
                            = vlSelfRef.__Vfunc_clamp_int__105__hi;
                        goto __Vlabel19;
                    }
                    vlSelfRef.__Vfunc_clamp_int__105__Vfuncout 
                        = vlSelfRef.__Vfunc_clamp_int__105__value;
                    __Vlabel19: ;
                }
                vlSelfRef.__Vfunc_mag_from_int__104__clamped_value 
                    = vlSelfRef.__Vfunc_clamp_int__105__Vfuncout;
                vlSelfRef.__Vfunc_mag_from_int__104__result 
                    = (0x0000000fU & vlSelfRef.__Vfunc_mag_from_int__104__clamped_value);
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_13__mag_from_int 
                    = vlSelfRef.__Vfunc_mag_from_int__104__result;
                vlSelfRef.__Vfunc_row_state_set_min2__106__min2 
                    = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT____VlemCall_13__mag_from_int;
                vlSelfRef.__Vfunc_row_state_set_min2__106__state 
                    = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__next_state;
                vlSelfRef.__Vfunc_row_state_set_min2__106__next_state 
                    = vlSelfRef.__Vfunc_row_state_set_min2__106__state;
                vlSelfRef.__Vfunc_row_state_set_min2__106__next_state 
                    = ((0x7f0fU & (IData)(vlSelfRef.__Vfunc_row_state_set_min2__106__next_state)) 
                       | ((IData)(vlSelfRef.__Vfunc_row_state_set_min2__106__min2) 
                          << 4U));
                vlSelfRef.__Vfunc_row_state_set_min2__106__Vfuncout 
                    = vlSelfRef.__Vfunc_row_state_set_min2__106__next_state;
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__next_state 
                    = vlSelfRef.__Vfunc_row_state_set_min2__106__Vfuncout;
            }
        }
    }
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__next_state 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_row_state_a1;
    __Vfunc_msg_sign__107__msg = tb_mdpc_decoder_demo__DOT__dut__DOT__u_msg1;
    __Vfunc_msg_sign__107__Vfuncout = (1U & ((IData)(__Vfunc_msg_sign__107__msg) 
                                             >> 4U));
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__cnu_a_sign1 
        = __Vfunc_msg_sign__107__Vfuncout;
    __Vfunc_msg_mag__108__msg = tb_mdpc_decoder_demo__DOT__dut__DOT__u_msg1;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_0__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__108__msg));
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__abs_mag 
        = tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_0__msg_mag;
    __Vfunc_row_state_valid_count__109__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_row_state_a1;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_1__row_state_valid_count 
        = (3U & ((IData)(__Vfunc_row_state_valid_count__109__state) 
                 >> 0x0dU));
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__next_count 
        = tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_1__row_state_valid_count;
    __Vfunc_row_state_valid_count__110__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_row_state_a1;
    tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_2__row_state_valid_count 
        = (3U & ((IData)(__Vfunc_row_state_valid_count__110__state) 
                 >> 0x0dU));
    if ((0U == (IData)(tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_2__row_state_valid_count))) {
        vlSelfRef.__Vfunc_mag_from_int__111__value 
            = tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__abs_mag;
        vlSelfRef.__Vfunc_clamp_int__112__hi = 0x0000000fU;
        vlSelfRef.__Vfunc_clamp_int__112__lo = 0U;
        vlSelfRef.__Vfunc_clamp_int__112__value = vlSelfRef.__Vfunc_mag_from_int__111__value;
        {
            vlSelfRef.__Vfunc_clamp_int__112__Vfuncout = 0U;
            if (VL_LTS_III(32, vlSelfRef.__Vfunc_clamp_int__112__value, vlSelfRef.__Vfunc_clamp_int__112__lo)) {
                vlSelfRef.__Vfunc_clamp_int__112__Vfuncout 
                    = vlSelfRef.__Vfunc_clamp_int__112__lo;
                goto __Vlabel20;
            }
            if (VL_GTS_III(32, vlSelfRef.__Vfunc_clamp_int__112__value, vlSelfRef.__Vfunc_clamp_int__112__hi)) {
                vlSelfRef.__Vfunc_clamp_int__112__Vfuncout 
                    = vlSelfRef.__Vfunc_clamp_int__112__hi;
                goto __Vlabel20;
            }
            vlSelfRef.__Vfunc_clamp_int__112__Vfuncout 
                = vlSelfRef.__Vfunc_clamp_int__112__value;
            __Vlabel20: ;
        }
        vlSelfRef.__Vfunc_mag_from_int__111__clamped_value 
            = vlSelfRef.__Vfunc_clamp_int__112__Vfuncout;
        vlSelfRef.__Vfunc_mag_from_int__111__result 
            = (0x0000000fU & vlSelfRef.__Vfunc_mag_from_int__111__clamped_value);
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_3__mag_from_int 
            = vlSelfRef.__Vfunc_mag_from_int__111__result;
        vlSelfRef.__Vfunc_clamp_int__114__hi = 0x0000000fU;
        vlSelfRef.__Vfunc_clamp_int__114__lo = 0U;
        vlSelfRef.__Vfunc_clamp_int__114__value = 0x0000000fU;
        {
            vlSelfRef.__Vfunc_clamp_int__114__Vfuncout = 0U;
            if (VL_LTS_III(32, vlSelfRef.__Vfunc_clamp_int__114__value, vlSelfRef.__Vfunc_clamp_int__114__lo)) {
                vlSelfRef.__Vfunc_clamp_int__114__Vfuncout 
                    = vlSelfRef.__Vfunc_clamp_int__114__lo;
                goto __Vlabel21;
            }
            if (VL_GTS_III(32, vlSelfRef.__Vfunc_clamp_int__114__value, vlSelfRef.__Vfunc_clamp_int__114__hi)) {
                vlSelfRef.__Vfunc_clamp_int__114__Vfuncout 
                    = vlSelfRef.__Vfunc_clamp_int__114__hi;
                goto __Vlabel21;
            }
            vlSelfRef.__Vfunc_clamp_int__114__Vfuncout 
                = vlSelfRef.__Vfunc_clamp_int__114__value;
            __Vlabel21: ;
        }
        vlSelfRef.__Vfunc_mag_from_int__113__clamped_value 
            = vlSelfRef.__Vfunc_clamp_int__114__Vfuncout;
        vlSelfRef.__Vfunc_mag_from_int__113__result 
            = (0x0000000fU & vlSelfRef.__Vfunc_mag_from_int__113__clamped_value);
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_4__mag_from_int 
            = vlSelfRef.__Vfunc_mag_from_int__113__result;
        vlSelfRef.__Vfunc_msg_sign__115__msg = tb_mdpc_decoder_demo__DOT__dut__DOT__u_msg1;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_5__msg_sign 
            = (1U & ((IData)(vlSelfRef.__Vfunc_msg_sign__115__msg) 
                     >> 4U));
        vlSelfRef.__Vfunc_row_state_pack__116__sign_xor 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_5__msg_sign;
        vlSelfRef.__Vfunc_row_state_pack__116__min_id 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx;
        vlSelfRef.__Vfunc_row_state_pack__116__min2 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_4__mag_from_int;
        vlSelfRef.__Vfunc_row_state_pack__116__min1 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_3__mag_from_int;
        vlSelfRef.__Vfunc_row_state_pack__116__Vfuncout 
            = (0x00002000U | ((((IData)(vlSelfRef.__Vfunc_row_state_pack__116__sign_xor) 
                                << 0x0000000cU) | ((IData)(vlSelfRef.__Vfunc_row_state_pack__116__min_id) 
                                                   << 8U)) 
                              | (((IData)(vlSelfRef.__Vfunc_row_state_pack__116__min2) 
                                  << 4U) | (IData)(vlSelfRef.__Vfunc_row_state_pack__116__min1))));
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__next_state 
            = vlSelfRef.__Vfunc_row_state_pack__116__Vfuncout;
    } else {
        vlSelfRef.__Vfunc_row_state_valid_count__117__state 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_row_state_a1;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_6__row_state_valid_count 
            = (3U & ((IData)(vlSelfRef.__Vfunc_row_state_valid_count__117__state) 
                     >> 0x0dU));
        tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__next_count 
            = ((IData)(1U) + (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_6__row_state_valid_count));
        if (VL_LTS_III(32, 3U, tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__next_count)) {
            tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__next_count = 3U;
        }
        vlSelfRef.__Vfunc_row_state_sign_xor__118__state 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_row_state_a1;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_7__row_state_sign_xor 
            = (1U & ((IData)(vlSelfRef.__Vfunc_row_state_sign_xor__118__state) 
                     >> 0x0cU));
        vlSelfRef.__Vfunc_msg_sign__119__msg = tb_mdpc_decoder_demo__DOT__dut__DOT__u_msg1;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_8__msg_sign 
            = (1U & ((IData)(vlSelfRef.__Vfunc_msg_sign__119__msg) 
                     >> 4U));
        vlSelfRef.__Vfunc_row_state_set_sign_xor__120__sign_xor 
            = ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_7__row_state_sign_xor) 
               ^ (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_8__msg_sign));
        vlSelfRef.__Vfunc_row_state_set_sign_xor__120__state 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__next_state;
        vlSelfRef.__Vfunc_row_state_set_sign_xor__120__next_state 
            = vlSelfRef.__Vfunc_row_state_set_sign_xor__120__state;
        vlSelfRef.__Vfunc_row_state_set_sign_xor__120__next_state 
            = ((0x6fffU & (IData)(vlSelfRef.__Vfunc_row_state_set_sign_xor__120__next_state)) 
               | ((IData)(vlSelfRef.__Vfunc_row_state_set_sign_xor__120__sign_xor) 
                  << 0x0000000cU));
        vlSelfRef.__Vfunc_row_state_set_sign_xor__120__Vfuncout 
            = vlSelfRef.__Vfunc_row_state_set_sign_xor__120__next_state;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__next_state 
            = vlSelfRef.__Vfunc_row_state_set_sign_xor__120__Vfuncout;
        vlSelfRef.__Vfunc_row_state_set_valid_count__121__valid_count 
            = (3U & tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__next_count);
        vlSelfRef.__Vfunc_row_state_set_valid_count__121__state 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__next_state;
        vlSelfRef.__Vfunc_row_state_set_valid_count__121__next_state 
            = vlSelfRef.__Vfunc_row_state_set_valid_count__121__state;
        vlSelfRef.__Vfunc_row_state_set_valid_count__121__next_state 
            = ((0x1fffU & (IData)(vlSelfRef.__Vfunc_row_state_set_valid_count__121__next_state)) 
               | ((IData)(vlSelfRef.__Vfunc_row_state_set_valid_count__121__valid_count) 
                  << 0x0000000dU));
        vlSelfRef.__Vfunc_row_state_set_valid_count__121__Vfuncout 
            = vlSelfRef.__Vfunc_row_state_set_valid_count__121__next_state;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__next_state 
            = vlSelfRef.__Vfunc_row_state_set_valid_count__121__Vfuncout;
        vlSelfRef.__Vfunc_row_state_min1__122__state 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_row_state_a1;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_9__row_state_min1 
            = (0x0000000fU & (IData)(vlSelfRef.__Vfunc_row_state_min1__122__state));
        if (VL_LTS_III(32, tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__abs_mag, (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_9__row_state_min1))) {
            vlSelfRef.__Vfunc_row_state_min1__123__state 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_row_state_a1;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_10__row_state_min1 
                = (0x0000000fU & (IData)(vlSelfRef.__Vfunc_row_state_min1__123__state));
            vlSelfRef.__Vfunc_row_state_set_min2__124__min2 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_10__row_state_min1;
            vlSelfRef.__Vfunc_row_state_set_min2__124__state 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__next_state;
            vlSelfRef.__Vfunc_row_state_set_min2__124__next_state 
                = vlSelfRef.__Vfunc_row_state_set_min2__124__state;
            vlSelfRef.__Vfunc_row_state_set_min2__124__next_state 
                = ((0x7f0fU & (IData)(vlSelfRef.__Vfunc_row_state_set_min2__124__next_state)) 
                   | ((IData)(vlSelfRef.__Vfunc_row_state_set_min2__124__min2) 
                      << 4U));
            vlSelfRef.__Vfunc_row_state_set_min2__124__Vfuncout 
                = vlSelfRef.__Vfunc_row_state_set_min2__124__next_state;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__next_state 
                = vlSelfRef.__Vfunc_row_state_set_min2__124__Vfuncout;
            vlSelfRef.__Vfunc_mag_from_int__125__value 
                = tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__abs_mag;
            vlSelfRef.__Vfunc_clamp_int__126__hi = 0x0000000fU;
            vlSelfRef.__Vfunc_clamp_int__126__lo = 0U;
            vlSelfRef.__Vfunc_clamp_int__126__value 
                = vlSelfRef.__Vfunc_mag_from_int__125__value;
            {
                vlSelfRef.__Vfunc_clamp_int__126__Vfuncout = 0U;
                if (VL_LTS_III(32, vlSelfRef.__Vfunc_clamp_int__126__value, vlSelfRef.__Vfunc_clamp_int__126__lo)) {
                    vlSelfRef.__Vfunc_clamp_int__126__Vfuncout 
                        = vlSelfRef.__Vfunc_clamp_int__126__lo;
                    goto __Vlabel22;
                }
                if (VL_GTS_III(32, vlSelfRef.__Vfunc_clamp_int__126__value, vlSelfRef.__Vfunc_clamp_int__126__hi)) {
                    vlSelfRef.__Vfunc_clamp_int__126__Vfuncout 
                        = vlSelfRef.__Vfunc_clamp_int__126__hi;
                    goto __Vlabel22;
                }
                vlSelfRef.__Vfunc_clamp_int__126__Vfuncout 
                    = vlSelfRef.__Vfunc_clamp_int__126__value;
                __Vlabel22: ;
            }
            vlSelfRef.__Vfunc_mag_from_int__125__clamped_value 
                = vlSelfRef.__Vfunc_clamp_int__126__Vfuncout;
            vlSelfRef.__Vfunc_mag_from_int__125__result 
                = (0x0000000fU & vlSelfRef.__Vfunc_mag_from_int__125__clamped_value);
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_11__mag_from_int 
                = vlSelfRef.__Vfunc_mag_from_int__125__result;
            vlSelfRef.__Vfunc_row_state_set_min1__127__min1 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_11__mag_from_int;
            vlSelfRef.__Vfunc_row_state_set_min1__127__state 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__next_state;
            vlSelfRef.__Vfunc_row_state_set_min1__127__next_state 
                = vlSelfRef.__Vfunc_row_state_set_min1__127__state;
            vlSelfRef.__Vfunc_row_state_set_min1__127__next_state 
                = ((0x7ff0U & (IData)(vlSelfRef.__Vfunc_row_state_set_min1__127__next_state)) 
                   | (IData)(vlSelfRef.__Vfunc_row_state_set_min1__127__min1));
            vlSelfRef.__Vfunc_row_state_set_min1__127__Vfuncout 
                = vlSelfRef.__Vfunc_row_state_set_min1__127__next_state;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__next_state 
                = vlSelfRef.__Vfunc_row_state_set_min1__127__Vfuncout;
            vlSelfRef.__Vfunc_row_state_set_min_id__128__min_id 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx;
            vlSelfRef.__Vfunc_row_state_set_min_id__128__state 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__next_state;
            vlSelfRef.__Vfunc_row_state_set_min_id__128__next_state 
                = vlSelfRef.__Vfunc_row_state_set_min_id__128__state;
            vlSelfRef.__Vfunc_row_state_set_min_id__128__next_state 
                = ((0x70ffU & (IData)(vlSelfRef.__Vfunc_row_state_set_min_id__128__next_state)) 
                   | ((IData)(vlSelfRef.__Vfunc_row_state_set_min_id__128__min_id) 
                      << 8U));
            vlSelfRef.__Vfunc_row_state_set_min_id__128__Vfuncout 
                = vlSelfRef.__Vfunc_row_state_set_min_id__128__next_state;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__next_state 
                = vlSelfRef.__Vfunc_row_state_set_min_id__128__Vfuncout;
        } else {
            vlSelfRef.__Vfunc_row_state_min2__129__state 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_row_state_a1;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_12__row_state_min2 
                = (0x0000000fU & ((IData)(vlSelfRef.__Vfunc_row_state_min2__129__state) 
                                  >> 4U));
            if (VL_LTS_III(32, tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__abs_mag, (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_12__row_state_min2))) {
                vlSelfRef.__Vfunc_mag_from_int__130__value 
                    = tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__abs_mag;
                vlSelfRef.__Vfunc_clamp_int__131__hi = 0x0000000fU;
                vlSelfRef.__Vfunc_clamp_int__131__lo = 0U;
                vlSelfRef.__Vfunc_clamp_int__131__value 
                    = vlSelfRef.__Vfunc_mag_from_int__130__value;
                {
                    vlSelfRef.__Vfunc_clamp_int__131__Vfuncout = 0U;
                    if (VL_LTS_III(32, vlSelfRef.__Vfunc_clamp_int__131__value, vlSelfRef.__Vfunc_clamp_int__131__lo)) {
                        vlSelfRef.__Vfunc_clamp_int__131__Vfuncout 
                            = vlSelfRef.__Vfunc_clamp_int__131__lo;
                        goto __Vlabel23;
                    }
                    if (VL_GTS_III(32, vlSelfRef.__Vfunc_clamp_int__131__value, vlSelfRef.__Vfunc_clamp_int__131__hi)) {
                        vlSelfRef.__Vfunc_clamp_int__131__Vfuncout 
                            = vlSelfRef.__Vfunc_clamp_int__131__hi;
                        goto __Vlabel23;
                    }
                    vlSelfRef.__Vfunc_clamp_int__131__Vfuncout 
                        = vlSelfRef.__Vfunc_clamp_int__131__value;
                    __Vlabel23: ;
                }
                vlSelfRef.__Vfunc_mag_from_int__130__clamped_value 
                    = vlSelfRef.__Vfunc_clamp_int__131__Vfuncout;
                vlSelfRef.__Vfunc_mag_from_int__130__result 
                    = (0x0000000fU & vlSelfRef.__Vfunc_mag_from_int__130__clamped_value);
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_13__mag_from_int 
                    = vlSelfRef.__Vfunc_mag_from_int__130__result;
                vlSelfRef.__Vfunc_row_state_set_min2__132__min2 
                    = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT____VlemCall_13__mag_from_int;
                vlSelfRef.__Vfunc_row_state_set_min2__132__state 
                    = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__next_state;
                vlSelfRef.__Vfunc_row_state_set_min2__132__next_state 
                    = vlSelfRef.__Vfunc_row_state_set_min2__132__state;
                vlSelfRef.__Vfunc_row_state_set_min2__132__next_state 
                    = ((0x7f0fU & (IData)(vlSelfRef.__Vfunc_row_state_set_min2__132__next_state)) 
                       | ((IData)(vlSelfRef.__Vfunc_row_state_set_min2__132__min2) 
                          << 4U));
                vlSelfRef.__Vfunc_row_state_set_min2__132__Vfuncout 
                    = vlSelfRef.__Vfunc_row_state_set_min2__132__next_state;
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__next_state 
                    = vlSelfRef.__Vfunc_row_state_set_min2__132__Vfuncout;
            }
        }
    }
}

void Vtb_mdpc_decoder_demo___024root___nba_sequent__TOP__0(Vtb_mdpc_decoder_demo___024root* vlSelf);

void Vtb_mdpc_decoder_demo___024root___eval_nba(Vtb_mdpc_decoder_demo___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_decoder_demo___024root___eval_nba\n"); );
    Vtb_mdpc_decoder_demo__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((3ULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vtb_mdpc_decoder_demo___024root___nba_sequent__TOP__0(vlSelf);
        Vtb_mdpc_decoder_demo___024root___nba_sequent__TOP__1(vlSelf);
    }
}

void Vtb_mdpc_decoder_demo___024root___timing_ready(Vtb_mdpc_decoder_demo___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_decoder_demo___024root___timing_ready\n"); );
    Vtb_mdpc_decoder_demo__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_h5ea129b9__0.ready("@(posedge tb_mdpc_decoder_demo.clk)");
    }
    if ((4ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_h0d62a7d4__0.ready("@( tb_mdpc_decoder_demo.done)");
    }
    if ((8ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_h10b28a8e__0.ready("@( (((3'h3 == tb_mdpc_decoder_demo.dut.state) & (4'h0 == tb_mdpc_decoder_demo.dut.active_var_idx)) & (2'h0 == tb_mdpc_decoder_demo.dut.scan_slot)))");
    }
    if ((0x0000000000000020ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_hd708b578__0.ready("@( ((3'h4 == tb_mdpc_decoder_demo.dut.state) & (4'h0 == tb_mdpc_decoder_demo.dut.active_var_idx)))");
    }
    if ((0x0000000000000040ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_hdfc022cc__0.ready("@( ((3'h5 == tb_mdpc_decoder_demo.dut.state) & (3'h0 == tb_mdpc_decoder_demo.iter_count)))");
    }
}

void Vtb_mdpc_decoder_demo___024root___timing_resume(Vtb_mdpc_decoder_demo___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_decoder_demo___024root___timing_resume\n"); );
    Vtb_mdpc_decoder_demo__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VtrigSched_h5ea129b9__0.moveToResumeQueue(
                                                          "@(posedge tb_mdpc_decoder_demo.clk)");
    vlSelfRef.__VtrigSched_h0d62a7d4__0.moveToResumeQueue(
                                                          "@( tb_mdpc_decoder_demo.done)");
    vlSelfRef.__VtrigSched_h10b28a8e__0.moveToResumeQueue(
                                                          "@( (((3'h3 == tb_mdpc_decoder_demo.dut.state) & (4'h0 == tb_mdpc_decoder_demo.dut.active_var_idx)) & (2'h0 == tb_mdpc_decoder_demo.dut.scan_slot)))");
    vlSelfRef.__VtrigSched_hd708b578__0.moveToResumeQueue(
                                                          "@( ((3'h4 == tb_mdpc_decoder_demo.dut.state) & (4'h0 == tb_mdpc_decoder_demo.dut.active_var_idx)))");
    vlSelfRef.__VtrigSched_hdfc022cc__0.moveToResumeQueue(
                                                          "@( ((3'h5 == tb_mdpc_decoder_demo.dut.state) & (3'h0 == tb_mdpc_decoder_demo.iter_count)))");
    vlSelfRef.__VtrigSched_h5ea129b9__0.resume("@(posedge tb_mdpc_decoder_demo.clk)");
    vlSelfRef.__VtrigSched_h0d62a7d4__0.resume("@( tb_mdpc_decoder_demo.done)");
    vlSelfRef.__VtrigSched_h10b28a8e__0.resume("@( (((3'h3 == tb_mdpc_decoder_demo.dut.state) & (4'h0 == tb_mdpc_decoder_demo.dut.active_var_idx)) & (2'h0 == tb_mdpc_decoder_demo.dut.scan_slot)))");
    vlSelfRef.__VtrigSched_hd708b578__0.resume("@( ((3'h4 == tb_mdpc_decoder_demo.dut.state) & (4'h0 == tb_mdpc_decoder_demo.dut.active_var_idx)))");
    vlSelfRef.__VtrigSched_hdfc022cc__0.resume("@( ((3'h5 == tb_mdpc_decoder_demo.dut.state) & (3'h0 == tb_mdpc_decoder_demo.iter_count)))");
    if ((0x0000000000000010ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VdlySched.resume();
    }
}

void Vtb_mdpc_decoder_demo___024root___trigger_orInto__act_vec_vec(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_decoder_demo___024root___trigger_orInto__act_vec_vec\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = (out[n] | in[n]);
        n = ((IData)(1U) + n);
    } while ((0U >= n));
}

void Vtb_mdpc_decoder_demo___024root___eval_triggers_vec__act(Vtb_mdpc_decoder_demo___024root* vlSelf);
#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_mdpc_decoder_demo___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG
bool Vtb_mdpc_decoder_demo___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);

bool Vtb_mdpc_decoder_demo___024root___eval_phase__act(Vtb_mdpc_decoder_demo___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_decoder_demo___024root___eval_phase__act\n"); );
    Vtb_mdpc_decoder_demo__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VactExecute;
    // Body
    Vtb_mdpc_decoder_demo___024root___eval_triggers_vec__act(vlSelf);
    Vtb_mdpc_decoder_demo___024root___timing_ready(vlSelf);
    Vtb_mdpc_decoder_demo___024root___trigger_orInto__act_vec_vec(vlSelfRef.__VactTriggered, vlSelfRef.__VactTriggeredAcc);
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_mdpc_decoder_demo___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
    }
#endif
    Vtb_mdpc_decoder_demo___024root___trigger_orInto__act_vec_vec(vlSelfRef.__VnbaTriggered, vlSelfRef.__VactTriggered);
    __VactExecute = Vtb_mdpc_decoder_demo___024root___trigger_anySet__act(vlSelfRef.__VactTriggered);
    if (__VactExecute) {
        vlSelfRef.__VactTriggeredAcc.fill(0ULL);
        Vtb_mdpc_decoder_demo___024root___timing_resume(vlSelf);
    }
    return (__VactExecute);
}

bool Vtb_mdpc_decoder_demo___024root___eval_phase__inact(Vtb_mdpc_decoder_demo___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_decoder_demo___024root___eval_phase__inact\n"); );
    Vtb_mdpc_decoder_demo__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VinactExecute;
    // Body
    __VinactExecute = vlSelfRef.__VdlySched.awaitingZeroDelay();
    if (__VinactExecute) {
        VL_FATAL_MT("tb/tb_mdpc_decoder_demo.sv", 5, "", "ZERODLY: Design Verilated with '--no-sched-zero-delay', but #0 delay executed at runtime");
    }
    return (__VinactExecute);
}

void Vtb_mdpc_decoder_demo___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_decoder_demo___024root___trigger_clear__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = 0ULL;
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

bool Vtb_mdpc_decoder_demo___024root___eval_phase__nba(Vtb_mdpc_decoder_demo___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_decoder_demo___024root___eval_phase__nba\n"); );
    Vtb_mdpc_decoder_demo__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = Vtb_mdpc_decoder_demo___024root___trigger_anySet__act(vlSelfRef.__VnbaTriggered);
    if (__VnbaExecute) {
        Vtb_mdpc_decoder_demo___024root___eval_nba(vlSelf);
        Vtb_mdpc_decoder_demo___024root___trigger_clear__act(vlSelfRef.__VnbaTriggered);
    }
    return (__VnbaExecute);
}

void Vtb_mdpc_decoder_demo___024root___eval(Vtb_mdpc_decoder_demo___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_decoder_demo___024root___eval\n"); );
    Vtb_mdpc_decoder_demo__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VnbaIterCount;
    // Body
    __VnbaIterCount = 0U;
    do {
        if (VL_UNLIKELY(((0x00002710U < __VnbaIterCount)))) {
#ifdef VL_DEBUG
            Vtb_mdpc_decoder_demo___024root___dump_triggers__act(vlSelfRef.__VnbaTriggered, "nba"s);
#endif
            VL_FATAL_MT("tb/tb_mdpc_decoder_demo.sv", 5, "", "DIDNOTCONVERGE: NBA region did not converge after '--converge-limit' of 10000 tries");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        vlSelfRef.__VinactIterCount = 0U;
        do {
            if (VL_UNLIKELY(((0x00002710U < vlSelfRef.__VinactIterCount)))) {
                VL_FATAL_MT("tb/tb_mdpc_decoder_demo.sv", 5, "", "DIDNOTCONVERGE: Inactive region did not converge after '--converge-limit' of 10000 tries");
            }
            vlSelfRef.__VinactIterCount = ((IData)(1U) 
                                           + vlSelfRef.__VinactIterCount);
            vlSelfRef.__VactIterCount = 0U;
            do {
                if (VL_UNLIKELY(((0x00002710U < vlSelfRef.__VactIterCount)))) {
#ifdef VL_DEBUG
                    Vtb_mdpc_decoder_demo___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
#endif
                    VL_FATAL_MT("tb/tb_mdpc_decoder_demo.sv", 5, "", "DIDNOTCONVERGE: Active region did not converge after '--converge-limit' of 10000 tries");
                }
                vlSelfRef.__VactIterCount = ((IData)(1U) 
                                             + vlSelfRef.__VactIterCount);
                vlSelfRef.__VactPhaseResult = Vtb_mdpc_decoder_demo___024root___eval_phase__act(vlSelf);
            } while (vlSelfRef.__VactPhaseResult);
            vlSelfRef.__VinactPhaseResult = Vtb_mdpc_decoder_demo___024root___eval_phase__inact(vlSelf);
        } while (vlSelfRef.__VinactPhaseResult);
        vlSelfRef.__VnbaPhaseResult = Vtb_mdpc_decoder_demo___024root___eval_phase__nba(vlSelf);
    } while (vlSelfRef.__VnbaPhaseResult);
}

void Vtb_mdpc_decoder_demo___024root____VbeforeTrig_h5ea129b9__0(Vtb_mdpc_decoder_demo___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_decoder_demo___024root____VbeforeTrig_h5ea129b9__0\n"); );
    Vtb_mdpc_decoder_demo__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    // Body
    __VTmp[0U] = (QData)((IData)(((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__clk) 
                                  & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_mdpc_decoder_demo__DOT__clk__0)))));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_mdpc_decoder_demo__DOT__clk__0 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__clk;
    if ((1ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h5ea129b9__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h5ea129b9__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h5ea129b9__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h5ea129b9__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h5ea129b9__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h5ea129b9__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h5ea129b9__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h5ea129b9__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

void Vtb_mdpc_decoder_demo___024root____VbeforeTrig_h0d62a7d4__0(Vtb_mdpc_decoder_demo___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_decoder_demo___024root____VbeforeTrig_h0d62a7d4__0\n"); );
    Vtb_mdpc_decoder_demo__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    // Body
    __VTmp[0U] = (QData)((IData)((((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__done) 
                                   != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_mdpc_decoder_demo__DOT__done__0)) 
                                  << 2U)));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_mdpc_decoder_demo__DOT__done__0 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__done;
    if ((4ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h0d62a7d4__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h0d62a7d4__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

void Vtb_mdpc_decoder_demo___024root____VbeforeTrig_h10b28a8e__0(Vtb_mdpc_decoder_demo___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_decoder_demo___024root____VbeforeTrig_h10b28a8e__0\n"); );
    Vtb_mdpc_decoder_demo__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    CData/*0:0*/ __Vtrigprevexpr_h95049e09__0;
    __Vtrigprevexpr_h95049e09__0 = 0;
    // Body
    __Vtrigprevexpr_h95049e09__0 = (((3U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state)) 
                                     & (0U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx))) 
                                    & (0U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__scan_slot)));
    __VTmp[0U] = (QData)((IData)((((IData)(__Vtrigprevexpr_h95049e09__0) 
                                   != (IData)(vlSelfRef.__Vtrigprevexpr_h95049e09__1)) 
                                  << 3U)));
    vlSelfRef.__Vtrigprevexpr_h95049e09__1 = __Vtrigprevexpr_h95049e09__0;
    if ((8ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h10b28a8e__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

void Vtb_mdpc_decoder_demo___024root____VbeforeTrig_hd708b578__0(Vtb_mdpc_decoder_demo___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_decoder_demo___024root____VbeforeTrig_hd708b578__0\n"); );
    Vtb_mdpc_decoder_demo__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    CData/*0:0*/ __Vtrigprevexpr_h4f3ec4ef__0;
    __Vtrigprevexpr_h4f3ec4ef__0 = 0;
    // Body
    __Vtrigprevexpr_h4f3ec4ef__0 = ((4U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state)) 
                                    & (0U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx)));
    __VTmp[0U] = (QData)((IData)((((IData)(__Vtrigprevexpr_h4f3ec4ef__0) 
                                   != (IData)(vlSelfRef.__Vtrigprevexpr_h4f3ec4ef__1)) 
                                  << 5U)));
    vlSelfRef.__Vtrigprevexpr_h4f3ec4ef__1 = __Vtrigprevexpr_h4f3ec4ef__0;
    if ((0x0000000000000020ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_hd708b578__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

void Vtb_mdpc_decoder_demo___024root____VbeforeTrig_hdfc022cc__0(Vtb_mdpc_decoder_demo___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_decoder_demo___024root____VbeforeTrig_hdfc022cc__0\n"); );
    Vtb_mdpc_decoder_demo__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    CData/*0:0*/ __Vtrigprevexpr_h87f7365b__0;
    __Vtrigprevexpr_h87f7365b__0 = 0;
    // Body
    __Vtrigprevexpr_h87f7365b__0 = ((5U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state)) 
                                    & (0U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__iter_count)));
    __VTmp[0U] = (QData)((IData)((((IData)(__Vtrigprevexpr_h87f7365b__0) 
                                   != (IData)(vlSelfRef.__Vtrigprevexpr_h87f7365b__1)) 
                                  << 6U)));
    vlSelfRef.__Vtrigprevexpr_h87f7365b__1 = __Vtrigprevexpr_h87f7365b__0;
    if ((0x0000000000000040ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_hdfc022cc__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

#ifdef VL_DEBUG
void Vtb_mdpc_decoder_demo___024root___eval_debug_assertions(Vtb_mdpc_decoder_demo___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_decoder_demo___024root___eval_debug_assertions\n"); );
    Vtb_mdpc_decoder_demo__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}
#endif  // VL_DEBUG
