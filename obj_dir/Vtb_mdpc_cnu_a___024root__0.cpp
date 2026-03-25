// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_mdpc_cnu_a.h for the primary calling header

#include "Vtb_mdpc_cnu_a__pch.h"

VlCoroutine Vtb_mdpc_cnu_a___024root___eval_initial__TOP__Vtiming__0(Vtb_mdpc_cnu_a___024root* vlSelf);

void Vtb_mdpc_cnu_a___024root___eval_initial(Vtb_mdpc_cnu_a___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_a___024root___eval_initial\n"); );
    Vtb_mdpc_cnu_a__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vtb_mdpc_cnu_a___024root___eval_initial__TOP__Vtiming__0(vlSelf);
}

VlCoroutine Vtb_mdpc_cnu_a___024root___eval_initial__TOP__Vtiming__0(Vtb_mdpc_cnu_a___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_a___024root___eval_initial__TOP__Vtiming__0\n"); );
    Vtb_mdpc_cnu_a__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    SData/*14:0*/ __Vfunc_row_state_init__0__Vfuncout;
    __Vfunc_row_state_init__0__Vfuncout = 0;
    CData/*3:0*/ __Vfunc_row_state_init__0____VlefCall_1__mag_from_int;
    __Vfunc_row_state_init__0____VlefCall_1__mag_from_int = 0;
    CData/*3:0*/ __Vfunc_row_state_init__0____VlefCall_0__mag_from_int;
    __Vfunc_row_state_init__0____VlefCall_0__mag_from_int = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__1__Vfuncout;
    __Vfunc_mag_from_int__1__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_mag_from_int__1__clamped_value;
    __Vfunc_mag_from_int__1__clamped_value = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__1__result;
    __Vfunc_mag_from_int__1__result = 0;
    IData/*31:0*/ __Vfunc_clamp_int__2__Vfuncout;
    __Vfunc_clamp_int__2__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_clamp_int__2__value;
    __Vfunc_clamp_int__2__value = 0;
    IData/*31:0*/ __Vfunc_clamp_int__2__lo;
    __Vfunc_clamp_int__2__lo = 0;
    IData/*31:0*/ __Vfunc_clamp_int__2__hi;
    __Vfunc_clamp_int__2__hi = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__3__Vfuncout;
    __Vfunc_mag_from_int__3__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_mag_from_int__3__clamped_value;
    __Vfunc_mag_from_int__3__clamped_value = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__3__result;
    __Vfunc_mag_from_int__3__result = 0;
    IData/*31:0*/ __Vfunc_clamp_int__4__Vfuncout;
    __Vfunc_clamp_int__4__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_clamp_int__4__value;
    __Vfunc_clamp_int__4__value = 0;
    IData/*31:0*/ __Vfunc_clamp_int__4__lo;
    __Vfunc_clamp_int__4__lo = 0;
    IData/*31:0*/ __Vfunc_clamp_int__4__hi;
    __Vfunc_clamp_int__4__hi = 0;
    SData/*14:0*/ __Vfunc_row_state_pack__5__Vfuncout;
    __Vfunc_row_state_pack__5__Vfuncout = 0;
    CData/*3:0*/ __Vfunc_row_state_pack__5__min1;
    __Vfunc_row_state_pack__5__min1 = 0;
    CData/*3:0*/ __Vfunc_row_state_pack__5__min2;
    __Vfunc_row_state_pack__5__min2 = 0;
    CData/*4:0*/ __Vfunc_msg_from_signed__6__Vfuncout;
    __Vfunc_msg_from_signed__6__Vfuncout = 0;
    CData/*3:0*/ __Vfunc_msg_from_signed__6____VlefCall_0__mag_from_int;
    __Vfunc_msg_from_signed__6____VlefCall_0__mag_from_int = 0;
    CData/*4:0*/ __Vfunc_msg_from_signed__6__msg;
    __Vfunc_msg_from_signed__6__msg = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__7__Vfuncout;
    __Vfunc_mag_from_int__7__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_mag_from_int__7__clamped_value;
    __Vfunc_mag_from_int__7__clamped_value = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__7__result;
    __Vfunc_mag_from_int__7__result = 0;
    IData/*31:0*/ __Vfunc_clamp_int__8__Vfuncout;
    __Vfunc_clamp_int__8__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_clamp_int__8__value;
    __Vfunc_clamp_int__8__value = 0;
    IData/*31:0*/ __Vfunc_clamp_int__8__lo;
    __Vfunc_clamp_int__8__lo = 0;
    IData/*31:0*/ __Vfunc_clamp_int__8__hi;
    __Vfunc_clamp_int__8__hi = 0;
    CData/*4:0*/ __Vfunc_msg_pack__9__Vfuncout;
    __Vfunc_msg_pack__9__Vfuncout = 0;
    CData/*3:0*/ __Vfunc_msg_pack__9__mag;
    __Vfunc_msg_pack__9__mag = 0;
    IData/*31:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_min1;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_min1 = 0;
    IData/*31:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_min2;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_min2 = 0;
    IData/*31:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_min_id;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_min_id = 0;
    IData/*31:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_sign_xor;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_sign_xor = 0;
    IData/*31:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_valid_count;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_valid_count = 0;
    IData/*31:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_sign_bit;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_sign_bit = 0;
    CData/*1:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_9__row_state_valid_count;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_9__row_state_valid_count = 0;
    CData/*1:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_8__row_state_valid_count;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_8__row_state_valid_count = 0;
    CData/*0:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_7__row_state_sign_xor;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_7__row_state_sign_xor = 0;
    CData/*0:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_6__row_state_sign_xor;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_6__row_state_sign_xor = 0;
    CData/*3:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_5__row_state_min_id;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_5__row_state_min_id = 0;
    CData/*3:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_4__row_state_min_id;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_4__row_state_min_id = 0;
    CData/*3:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_3__row_state_min2;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_3__row_state_min2 = 0;
    CData/*3:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_2__row_state_min2;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_2__row_state_min2 = 0;
    CData/*3:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_1__row_state_min1;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_1__row_state_min1 = 0;
    CData/*3:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_0__row_state_min1;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_0__row_state_min1 = 0;
    CData/*3:0*/ __Vfunc_row_state_min1__11__Vfuncout;
    __Vfunc_row_state_min1__11__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_min1__11__state;
    __Vfunc_row_state_min1__11__state = 0;
    CData/*3:0*/ __Vfunc_row_state_min1__12__Vfuncout;
    __Vfunc_row_state_min1__12__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_min1__12__state;
    __Vfunc_row_state_min1__12__state = 0;
    CData/*3:0*/ __Vfunc_row_state_min2__13__Vfuncout;
    __Vfunc_row_state_min2__13__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_min2__13__state;
    __Vfunc_row_state_min2__13__state = 0;
    CData/*3:0*/ __Vfunc_row_state_min2__14__Vfuncout;
    __Vfunc_row_state_min2__14__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_min2__14__state;
    __Vfunc_row_state_min2__14__state = 0;
    CData/*3:0*/ __Vfunc_row_state_min_id__15__Vfuncout;
    __Vfunc_row_state_min_id__15__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_min_id__15__state;
    __Vfunc_row_state_min_id__15__state = 0;
    CData/*3:0*/ __Vfunc_row_state_min_id__16__Vfuncout;
    __Vfunc_row_state_min_id__16__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_min_id__16__state;
    __Vfunc_row_state_min_id__16__state = 0;
    CData/*0:0*/ __Vfunc_row_state_sign_xor__17__Vfuncout;
    __Vfunc_row_state_sign_xor__17__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_sign_xor__17__state;
    __Vfunc_row_state_sign_xor__17__state = 0;
    CData/*0:0*/ __Vfunc_row_state_sign_xor__18__Vfuncout;
    __Vfunc_row_state_sign_xor__18__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_sign_xor__18__state;
    __Vfunc_row_state_sign_xor__18__state = 0;
    CData/*1:0*/ __Vfunc_row_state_valid_count__19__Vfuncout;
    __Vfunc_row_state_valid_count__19__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_valid_count__19__state;
    __Vfunc_row_state_valid_count__19__state = 0;
    CData/*1:0*/ __Vfunc_row_state_valid_count__20__Vfuncout;
    __Vfunc_row_state_valid_count__20__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_valid_count__20__state;
    __Vfunc_row_state_valid_count__20__state = 0;
    CData/*4:0*/ __Vfunc_msg_from_signed__21__Vfuncout;
    __Vfunc_msg_from_signed__21__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_msg_from_signed__21__value;
    __Vfunc_msg_from_signed__21__value = 0;
    CData/*3:0*/ __Vfunc_msg_from_signed__21____VlefCall_0__mag_from_int;
    __Vfunc_msg_from_signed__21____VlefCall_0__mag_from_int = 0;
    CData/*4:0*/ __Vfunc_msg_from_signed__21__msg;
    __Vfunc_msg_from_signed__21__msg = 0;
    IData/*31:0*/ __Vfunc_msg_from_signed__21__abs_value;
    __Vfunc_msg_from_signed__21__abs_value = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__22__Vfuncout;
    __Vfunc_mag_from_int__22__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_mag_from_int__22__value;
    __Vfunc_mag_from_int__22__value = 0;
    IData/*31:0*/ __Vfunc_mag_from_int__22__clamped_value;
    __Vfunc_mag_from_int__22__clamped_value = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__22__result;
    __Vfunc_mag_from_int__22__result = 0;
    IData/*31:0*/ __Vfunc_clamp_int__23__Vfuncout;
    __Vfunc_clamp_int__23__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_clamp_int__23__value;
    __Vfunc_clamp_int__23__value = 0;
    IData/*31:0*/ __Vfunc_clamp_int__23__lo;
    __Vfunc_clamp_int__23__lo = 0;
    IData/*31:0*/ __Vfunc_clamp_int__23__hi;
    __Vfunc_clamp_int__23__hi = 0;
    CData/*4:0*/ __Vfunc_msg_pack__24__Vfuncout;
    __Vfunc_msg_pack__24__Vfuncout = 0;
    CData/*0:0*/ __Vfunc_msg_pack__24__sign;
    __Vfunc_msg_pack__24__sign = 0;
    CData/*3:0*/ __Vfunc_msg_pack__24__mag;
    __Vfunc_msg_pack__24__mag = 0;
    IData/*31:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_min1;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_min1 = 0;
    IData/*31:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_min2;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_min2 = 0;
    IData/*31:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_min_id;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_min_id = 0;
    IData/*31:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_sign_xor;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_sign_xor = 0;
    IData/*31:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_valid_count;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_valid_count = 0;
    IData/*31:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_sign_bit;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_sign_bit = 0;
    CData/*1:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_9__row_state_valid_count;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_9__row_state_valid_count = 0;
    CData/*1:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_8__row_state_valid_count;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_8__row_state_valid_count = 0;
    CData/*0:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_7__row_state_sign_xor;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_7__row_state_sign_xor = 0;
    CData/*0:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_6__row_state_sign_xor;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_6__row_state_sign_xor = 0;
    CData/*3:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_5__row_state_min_id;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_5__row_state_min_id = 0;
    CData/*3:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_4__row_state_min_id;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_4__row_state_min_id = 0;
    CData/*3:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_3__row_state_min2;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_3__row_state_min2 = 0;
    CData/*3:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_2__row_state_min2;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_2__row_state_min2 = 0;
    CData/*3:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_1__row_state_min1;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_1__row_state_min1 = 0;
    CData/*3:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_0__row_state_min1;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_0__row_state_min1 = 0;
    CData/*3:0*/ __Vfunc_row_state_min1__26__Vfuncout;
    __Vfunc_row_state_min1__26__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_min1__26__state;
    __Vfunc_row_state_min1__26__state = 0;
    CData/*3:0*/ __Vfunc_row_state_min1__27__Vfuncout;
    __Vfunc_row_state_min1__27__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_min1__27__state;
    __Vfunc_row_state_min1__27__state = 0;
    CData/*3:0*/ __Vfunc_row_state_min2__28__Vfuncout;
    __Vfunc_row_state_min2__28__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_min2__28__state;
    __Vfunc_row_state_min2__28__state = 0;
    CData/*3:0*/ __Vfunc_row_state_min2__29__Vfuncout;
    __Vfunc_row_state_min2__29__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_min2__29__state;
    __Vfunc_row_state_min2__29__state = 0;
    CData/*3:0*/ __Vfunc_row_state_min_id__30__Vfuncout;
    __Vfunc_row_state_min_id__30__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_min_id__30__state;
    __Vfunc_row_state_min_id__30__state = 0;
    CData/*3:0*/ __Vfunc_row_state_min_id__31__Vfuncout;
    __Vfunc_row_state_min_id__31__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_min_id__31__state;
    __Vfunc_row_state_min_id__31__state = 0;
    CData/*0:0*/ __Vfunc_row_state_sign_xor__32__Vfuncout;
    __Vfunc_row_state_sign_xor__32__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_sign_xor__32__state;
    __Vfunc_row_state_sign_xor__32__state = 0;
    CData/*0:0*/ __Vfunc_row_state_sign_xor__33__Vfuncout;
    __Vfunc_row_state_sign_xor__33__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_sign_xor__33__state;
    __Vfunc_row_state_sign_xor__33__state = 0;
    CData/*1:0*/ __Vfunc_row_state_valid_count__34__Vfuncout;
    __Vfunc_row_state_valid_count__34__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_valid_count__34__state;
    __Vfunc_row_state_valid_count__34__state = 0;
    CData/*1:0*/ __Vfunc_row_state_valid_count__35__Vfuncout;
    __Vfunc_row_state_valid_count__35__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_valid_count__35__state;
    __Vfunc_row_state_valid_count__35__state = 0;
    CData/*4:0*/ __Vfunc_msg_from_signed__36__Vfuncout;
    __Vfunc_msg_from_signed__36__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_msg_from_signed__36__value;
    __Vfunc_msg_from_signed__36__value = 0;
    CData/*3:0*/ __Vfunc_msg_from_signed__36____VlefCall_0__mag_from_int;
    __Vfunc_msg_from_signed__36____VlefCall_0__mag_from_int = 0;
    CData/*4:0*/ __Vfunc_msg_from_signed__36__msg;
    __Vfunc_msg_from_signed__36__msg = 0;
    IData/*31:0*/ __Vfunc_msg_from_signed__36__abs_value;
    __Vfunc_msg_from_signed__36__abs_value = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__37__Vfuncout;
    __Vfunc_mag_from_int__37__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_mag_from_int__37__value;
    __Vfunc_mag_from_int__37__value = 0;
    IData/*31:0*/ __Vfunc_mag_from_int__37__clamped_value;
    __Vfunc_mag_from_int__37__clamped_value = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__37__result;
    __Vfunc_mag_from_int__37__result = 0;
    IData/*31:0*/ __Vfunc_clamp_int__38__Vfuncout;
    __Vfunc_clamp_int__38__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_clamp_int__38__value;
    __Vfunc_clamp_int__38__value = 0;
    IData/*31:0*/ __Vfunc_clamp_int__38__lo;
    __Vfunc_clamp_int__38__lo = 0;
    IData/*31:0*/ __Vfunc_clamp_int__38__hi;
    __Vfunc_clamp_int__38__hi = 0;
    CData/*4:0*/ __Vfunc_msg_pack__39__Vfuncout;
    __Vfunc_msg_pack__39__Vfuncout = 0;
    CData/*0:0*/ __Vfunc_msg_pack__39__sign;
    __Vfunc_msg_pack__39__sign = 0;
    CData/*3:0*/ __Vfunc_msg_pack__39__mag;
    __Vfunc_msg_pack__39__mag = 0;
    IData/*31:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_min1;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_min1 = 0;
    IData/*31:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_min2;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_min2 = 0;
    IData/*31:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_min_id;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_min_id = 0;
    IData/*31:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_sign_xor;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_sign_xor = 0;
    IData/*31:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_valid_count;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_valid_count = 0;
    IData/*31:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_sign_bit;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_sign_bit = 0;
    CData/*1:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_9__row_state_valid_count;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_9__row_state_valid_count = 0;
    CData/*1:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_8__row_state_valid_count;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_8__row_state_valid_count = 0;
    CData/*0:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_7__row_state_sign_xor;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_7__row_state_sign_xor = 0;
    CData/*0:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_6__row_state_sign_xor;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_6__row_state_sign_xor = 0;
    CData/*3:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_5__row_state_min_id;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_5__row_state_min_id = 0;
    CData/*3:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_4__row_state_min_id;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_4__row_state_min_id = 0;
    CData/*3:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_3__row_state_min2;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_3__row_state_min2 = 0;
    CData/*3:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_2__row_state_min2;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_2__row_state_min2 = 0;
    CData/*3:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_1__row_state_min1;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_1__row_state_min1 = 0;
    CData/*3:0*/ __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_0__row_state_min1;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_0__row_state_min1 = 0;
    CData/*3:0*/ __Vfunc_row_state_min1__41__Vfuncout;
    __Vfunc_row_state_min1__41__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_min1__41__state;
    __Vfunc_row_state_min1__41__state = 0;
    CData/*3:0*/ __Vfunc_row_state_min1__42__Vfuncout;
    __Vfunc_row_state_min1__42__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_min1__42__state;
    __Vfunc_row_state_min1__42__state = 0;
    CData/*3:0*/ __Vfunc_row_state_min2__43__Vfuncout;
    __Vfunc_row_state_min2__43__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_min2__43__state;
    __Vfunc_row_state_min2__43__state = 0;
    CData/*3:0*/ __Vfunc_row_state_min2__44__Vfuncout;
    __Vfunc_row_state_min2__44__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_min2__44__state;
    __Vfunc_row_state_min2__44__state = 0;
    CData/*3:0*/ __Vfunc_row_state_min_id__45__Vfuncout;
    __Vfunc_row_state_min_id__45__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_min_id__45__state;
    __Vfunc_row_state_min_id__45__state = 0;
    CData/*3:0*/ __Vfunc_row_state_min_id__46__Vfuncout;
    __Vfunc_row_state_min_id__46__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_min_id__46__state;
    __Vfunc_row_state_min_id__46__state = 0;
    CData/*0:0*/ __Vfunc_row_state_sign_xor__47__Vfuncout;
    __Vfunc_row_state_sign_xor__47__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_sign_xor__47__state;
    __Vfunc_row_state_sign_xor__47__state = 0;
    CData/*0:0*/ __Vfunc_row_state_sign_xor__48__Vfuncout;
    __Vfunc_row_state_sign_xor__48__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_sign_xor__48__state;
    __Vfunc_row_state_sign_xor__48__state = 0;
    CData/*1:0*/ __Vfunc_row_state_valid_count__49__Vfuncout;
    __Vfunc_row_state_valid_count__49__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_valid_count__49__state;
    __Vfunc_row_state_valid_count__49__state = 0;
    CData/*1:0*/ __Vfunc_row_state_valid_count__50__Vfuncout;
    __Vfunc_row_state_valid_count__50__Vfuncout = 0;
    SData/*14:0*/ __Vfunc_row_state_valid_count__50__state;
    __Vfunc_row_state_valid_count__50__state = 0;
    // Body
    __Vfunc_clamp_int__2__hi = 0x0000000fU;
    __Vfunc_clamp_int__2__lo = 0U;
    __Vfunc_clamp_int__2__value = 0x0000000fU;
    {
        __Vfunc_clamp_int__2__Vfuncout = 0U;
        if (VL_LTS_III(32, __Vfunc_clamp_int__2__value, __Vfunc_clamp_int__2__lo)) {
            __Vfunc_clamp_int__2__Vfuncout = __Vfunc_clamp_int__2__lo;
            goto __Vlabel0;
        }
        if (VL_GTS_III(32, __Vfunc_clamp_int__2__value, __Vfunc_clamp_int__2__hi)) {
            __Vfunc_clamp_int__2__Vfuncout = __Vfunc_clamp_int__2__hi;
            goto __Vlabel0;
        }
        __Vfunc_clamp_int__2__Vfuncout = __Vfunc_clamp_int__2__value;
        __Vlabel0: ;
    }
    __Vfunc_mag_from_int__1__clamped_value = __Vfunc_clamp_int__2__Vfuncout;
    __Vfunc_mag_from_int__1__result = (0x0000000fU 
                                       & __Vfunc_mag_from_int__1__clamped_value);
    __Vfunc_mag_from_int__1__Vfuncout = __Vfunc_mag_from_int__1__result;
    __Vfunc_row_state_init__0____VlefCall_0__mag_from_int 
        = __Vfunc_mag_from_int__1__Vfuncout;
    __Vfunc_clamp_int__4__hi = 0x0000000fU;
    __Vfunc_clamp_int__4__lo = 0U;
    __Vfunc_clamp_int__4__value = 0x0000000fU;
    {
        __Vfunc_clamp_int__4__Vfuncout = 0U;
        if (VL_LTS_III(32, __Vfunc_clamp_int__4__value, __Vfunc_clamp_int__4__lo)) {
            __Vfunc_clamp_int__4__Vfuncout = __Vfunc_clamp_int__4__lo;
            goto __Vlabel1;
        }
        if (VL_GTS_III(32, __Vfunc_clamp_int__4__value, __Vfunc_clamp_int__4__hi)) {
            __Vfunc_clamp_int__4__Vfuncout = __Vfunc_clamp_int__4__hi;
            goto __Vlabel1;
        }
        __Vfunc_clamp_int__4__Vfuncout = __Vfunc_clamp_int__4__value;
        __Vlabel1: ;
    }
    __Vfunc_mag_from_int__3__clamped_value = __Vfunc_clamp_int__4__Vfuncout;
    __Vfunc_mag_from_int__3__result = (0x0000000fU 
                                       & __Vfunc_mag_from_int__3__clamped_value);
    __Vfunc_mag_from_int__3__Vfuncout = __Vfunc_mag_from_int__3__result;
    __Vfunc_row_state_init__0____VlefCall_1__mag_from_int 
        = __Vfunc_mag_from_int__3__Vfuncout;
    __Vfunc_row_state_pack__5__min2 = __Vfunc_row_state_init__0____VlefCall_1__mag_from_int;
    __Vfunc_row_state_pack__5__min1 = __Vfunc_row_state_init__0____VlefCall_0__mag_from_int;
    __Vfunc_row_state_pack__5__Vfuncout = (((IData)(__Vfunc_row_state_pack__5__min2) 
                                            << 4U) 
                                           | (IData)(__Vfunc_row_state_pack__5__min1));
    __Vfunc_row_state_init__0__Vfuncout = __Vfunc_row_state_pack__5__Vfuncout;
    vlSelfRef.tb_mdpc_cnu_a__DOT__row_state_in = __Vfunc_row_state_init__0__Vfuncout;
    __Vfunc_clamp_int__8__hi = 0x0000000fU;
    __Vfunc_clamp_int__8__lo = 0U;
    __Vfunc_clamp_int__8__value = 5U;
    {
        __Vfunc_clamp_int__8__Vfuncout = 0U;
        if (VL_LTS_III(32, __Vfunc_clamp_int__8__value, __Vfunc_clamp_int__8__lo)) {
            __Vfunc_clamp_int__8__Vfuncout = __Vfunc_clamp_int__8__lo;
            goto __Vlabel2;
        }
        if (VL_GTS_III(32, __Vfunc_clamp_int__8__value, __Vfunc_clamp_int__8__hi)) {
            __Vfunc_clamp_int__8__Vfuncout = __Vfunc_clamp_int__8__hi;
            goto __Vlabel2;
        }
        __Vfunc_clamp_int__8__Vfuncout = __Vfunc_clamp_int__8__value;
        __Vlabel2: ;
    }
    __Vfunc_mag_from_int__7__clamped_value = __Vfunc_clamp_int__8__Vfuncout;
    __Vfunc_mag_from_int__7__result = (0x0000000fU 
                                       & __Vfunc_mag_from_int__7__clamped_value);
    __Vfunc_mag_from_int__7__Vfuncout = __Vfunc_mag_from_int__7__result;
    __Vfunc_msg_from_signed__6____VlefCall_0__mag_from_int 
        = __Vfunc_mag_from_int__7__Vfuncout;
    __Vfunc_msg_pack__9__mag = __Vfunc_msg_from_signed__6____VlefCall_0__mag_from_int;
    __Vfunc_msg_pack__9__Vfuncout = __Vfunc_msg_pack__9__mag;
    __Vfunc_msg_from_signed__6__msg = __Vfunc_msg_pack__9__Vfuncout;
    __Vfunc_msg_from_signed__6__Vfuncout = __Vfunc_msg_from_signed__6__msg;
    vlSelfRef.tb_mdpc_cnu_a__DOT__u_in = __Vfunc_msg_from_signed__6__Vfuncout;
    vlSelfRef.tb_mdpc_cnu_a__DOT__var_idx = 4U;
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "tb/tb_mdpc_cnu_a.sv", 
                                         40);
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_sign_bit = 0U;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_valid_count = 1U;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_sign_xor = 0U;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_min_id = 4U;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_min2 = 0x0000000fU;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_min1 = 5U;
    __Vfunc_row_state_min1__11__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
    __Vfunc_row_state_min1__11__Vfuncout = 0;
    __Vfunc_row_state_min1__11__Vfuncout = (0x0000000fU 
                                            & (IData)(__Vfunc_row_state_min1__11__state));
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_0__row_state_min1 
        = __Vfunc_row_state_min1__11__Vfuncout;
    if (VL_UNLIKELY((((IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_0__row_state_min1) 
                      != __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_min1)))) {
        __Vfunc_row_state_min1__12__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
        __Vfunc_row_state_min1__12__Vfuncout = 0;
        __Vfunc_row_state_min1__12__Vfuncout = (0x0000000fU 
                                                & (IData)(__Vfunc_row_state_min1__12__state));
        __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_1__row_state_min1 
            = __Vfunc_row_state_min1__12__Vfuncout;
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_cnu_a.sv:28: Assertion failed in %m: min1 mismatch: got %0d exp %0d\n",5, 'M',vlSymsp->name(),"tb_mdpc_cnu_a.expect_state", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',4,(IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_1__row_state_min1)
                     , '~',32,__Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_min1);
        VL_STOP_MT("tb/tb_mdpc_cnu_a.sv", 28, "", false);
    }
    __Vfunc_row_state_min2__13__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
    __Vfunc_row_state_min2__13__Vfuncout = 0;
    __Vfunc_row_state_min2__13__Vfuncout = (0x0000000fU 
                                            & ((IData)(__Vfunc_row_state_min2__13__state) 
                                               >> 4U));
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_2__row_state_min2 
        = __Vfunc_row_state_min2__13__Vfuncout;
    if (VL_UNLIKELY((((IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_2__row_state_min2) 
                      != __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_min2)))) {
        __Vfunc_row_state_min2__14__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
        __Vfunc_row_state_min2__14__Vfuncout = 0;
        __Vfunc_row_state_min2__14__Vfuncout = (0x0000000fU 
                                                & ((IData)(__Vfunc_row_state_min2__14__state) 
                                                   >> 4U));
        __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_3__row_state_min2 
            = __Vfunc_row_state_min2__14__Vfuncout;
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_cnu_a.sv:29: Assertion failed in %m: min2 mismatch: got %0d exp %0d\n",5, 'M',vlSymsp->name(),"tb_mdpc_cnu_a.expect_state", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',4,(IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_3__row_state_min2)
                     , '~',32,__Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_min2);
        VL_STOP_MT("tb/tb_mdpc_cnu_a.sv", 29, "", false);
    }
    __Vfunc_row_state_min_id__15__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
    __Vfunc_row_state_min_id__15__Vfuncout = 0;
    __Vfunc_row_state_min_id__15__Vfuncout = (0x0000000fU 
                                              & ((IData)(__Vfunc_row_state_min_id__15__state) 
                                                 >> 8U));
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_4__row_state_min_id 
        = __Vfunc_row_state_min_id__15__Vfuncout;
    if (VL_UNLIKELY((((IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_4__row_state_min_id) 
                      != __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_min_id)))) {
        __Vfunc_row_state_min_id__16__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
        __Vfunc_row_state_min_id__16__Vfuncout = 0;
        __Vfunc_row_state_min_id__16__Vfuncout = (0x0000000fU 
                                                  & ((IData)(__Vfunc_row_state_min_id__16__state) 
                                                     >> 8U));
        __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_5__row_state_min_id 
            = __Vfunc_row_state_min_id__16__Vfuncout;
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_cnu_a.sv:30: Assertion failed in %m: min_id mismatch: got %0d exp %0d\n",5, 'M',vlSymsp->name(),"tb_mdpc_cnu_a.expect_state", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',4,(IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_5__row_state_min_id)
                     , '~',32,__Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_min_id);
        VL_STOP_MT("tb/tb_mdpc_cnu_a.sv", 30, "", false);
    }
    __Vfunc_row_state_sign_xor__17__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
    __Vfunc_row_state_sign_xor__17__Vfuncout = 0;
    __Vfunc_row_state_sign_xor__17__Vfuncout = (1U 
                                                & ((IData)(__Vfunc_row_state_sign_xor__17__state) 
                                                   >> 0x0cU));
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_6__row_state_sign_xor 
        = __Vfunc_row_state_sign_xor__17__Vfuncout;
    if (VL_UNLIKELY((((IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_6__row_state_sign_xor) 
                      != __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_sign_xor)))) {
        __Vfunc_row_state_sign_xor__18__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
        __Vfunc_row_state_sign_xor__18__Vfuncout = 0;
        __Vfunc_row_state_sign_xor__18__Vfuncout = 
            (1U & ((IData)(__Vfunc_row_state_sign_xor__18__state) 
                   >> 0x0cU));
        __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_7__row_state_sign_xor 
            = __Vfunc_row_state_sign_xor__18__Vfuncout;
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_cnu_a.sv:31: Assertion failed in %m: sign_xor mismatch: got %0d exp %0d\n",5, 'M',vlSymsp->name(),"tb_mdpc_cnu_a.expect_state", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',1,(IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_7__row_state_sign_xor)
                     , '~',32,__Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_sign_xor);
        VL_STOP_MT("tb/tb_mdpc_cnu_a.sv", 31, "", false);
    }
    __Vfunc_row_state_valid_count__19__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
    __Vfunc_row_state_valid_count__19__Vfuncout = 0;
    __Vfunc_row_state_valid_count__19__Vfuncout = (3U 
                                                   & ((IData)(__Vfunc_row_state_valid_count__19__state) 
                                                      >> 0x0dU));
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_8__row_state_valid_count 
        = __Vfunc_row_state_valid_count__19__Vfuncout;
    if (VL_UNLIKELY((((IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_8__row_state_valid_count) 
                      != __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_valid_count)))) {
        __Vfunc_row_state_valid_count__20__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
        __Vfunc_row_state_valid_count__20__Vfuncout = 0;
        __Vfunc_row_state_valid_count__20__Vfuncout 
            = (3U & ((IData)(__Vfunc_row_state_valid_count__20__state) 
                     >> 0x0dU));
        __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_9__row_state_valid_count 
            = __Vfunc_row_state_valid_count__20__Vfuncout;
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_cnu_a.sv:32: Assertion failed in %m: valid_count mismatch: got %0d exp %0d\n",5, 'M',vlSymsp->name(),"tb_mdpc_cnu_a.expect_state", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',2,(IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__10____VlefCall_9__row_state_valid_count)
                     , '~',32,__Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_valid_count);
        VL_STOP_MT("tb/tb_mdpc_cnu_a.sv", 32, "", false);
    }
    if (VL_UNLIKELY((((IData)(vlSelfRef.tb_mdpc_cnu_a__DOT__sign_bit_out) 
                      != __Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_sign_bit)))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_cnu_a.sv:33: Assertion failed in %m: sign_bit mismatch: got %0d exp %0d\n",5, 'M',vlSymsp->name(),"tb_mdpc_cnu_a.expect_state", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',1,(IData)(vlSelfRef.tb_mdpc_cnu_a__DOT__sign_bit_out)
                     , '~',32,__Vtask_tb_mdpc_cnu_a__DOT__expect_state__10__exp_sign_bit);
        VL_STOP_MT("tb/tb_mdpc_cnu_a.sv", 33, "", false);
    }
    vlSelfRef.tb_mdpc_cnu_a__DOT__row_state_in = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
    __Vfunc_msg_from_signed__21__value = 0xfffffffeU;
    __Vfunc_msg_from_signed__21__Vfuncout = 0;
    __Vfunc_msg_from_signed__21__msg = 0;
    __Vfunc_msg_from_signed__21__abs_value = 0U;
    __Vfunc_msg_from_signed__21__abs_value = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__21__value)
                                               ? (- __Vfunc_msg_from_signed__21__value)
                                               : __Vfunc_msg_from_signed__21__value);
    __Vfunc_mag_from_int__22__value = __Vfunc_msg_from_signed__21__abs_value;
    __Vfunc_mag_from_int__22__Vfuncout = 0;
    __Vfunc_mag_from_int__22__clamped_value = 0U;
    __Vfunc_mag_from_int__22__result = 0;
    __Vfunc_clamp_int__23__hi = 0x0000000fU;
    __Vfunc_clamp_int__23__lo = 0U;
    __Vfunc_clamp_int__23__value = __Vfunc_mag_from_int__22__value;
    {
        __Vfunc_clamp_int__23__Vfuncout = 0U;
        if (VL_LTS_III(32, __Vfunc_clamp_int__23__value, __Vfunc_clamp_int__23__lo)) {
            __Vfunc_clamp_int__23__Vfuncout = __Vfunc_clamp_int__23__lo;
            goto __Vlabel3;
        }
        if (VL_GTS_III(32, __Vfunc_clamp_int__23__value, __Vfunc_clamp_int__23__hi)) {
            __Vfunc_clamp_int__23__Vfuncout = __Vfunc_clamp_int__23__hi;
            goto __Vlabel3;
        }
        __Vfunc_clamp_int__23__Vfuncout = __Vfunc_clamp_int__23__value;
        __Vlabel3: ;
    }
    __Vfunc_mag_from_int__22__clamped_value = __Vfunc_clamp_int__23__Vfuncout;
    __Vfunc_mag_from_int__22__result = (0x0000000fU 
                                        & __Vfunc_mag_from_int__22__clamped_value);
    __Vfunc_mag_from_int__22__Vfuncout = __Vfunc_mag_from_int__22__result;
    __Vfunc_msg_from_signed__21____VlefCall_0__mag_from_int 
        = __Vfunc_mag_from_int__22__Vfuncout;
    __Vfunc_msg_pack__24__mag = __Vfunc_msg_from_signed__21____VlefCall_0__mag_from_int;
    __Vfunc_msg_pack__24__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__21__value);
    __Vfunc_msg_pack__24__Vfuncout = 0;
    __Vfunc_msg_pack__24__Vfuncout = (((IData)(__Vfunc_msg_pack__24__sign) 
                                       << 4U) | (IData)(__Vfunc_msg_pack__24__mag));
    __Vfunc_msg_from_signed__21__msg = __Vfunc_msg_pack__24__Vfuncout;
    __Vfunc_msg_from_signed__21__Vfuncout = __Vfunc_msg_from_signed__21__msg;
    vlSelfRef.tb_mdpc_cnu_a__DOT__u_in = __Vfunc_msg_from_signed__21__Vfuncout;
    vlSelfRef.tb_mdpc_cnu_a__DOT__var_idx = 3U;
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "tb/tb_mdpc_cnu_a.sv", 
                                         46);
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_sign_bit = 1U;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_valid_count = 2U;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_sign_xor = 1U;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_min_id = 3U;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_min2 = 5U;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_min1 = 2U;
    __Vfunc_row_state_min1__26__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
    __Vfunc_row_state_min1__26__Vfuncout = 0;
    __Vfunc_row_state_min1__26__Vfuncout = (0x0000000fU 
                                            & (IData)(__Vfunc_row_state_min1__26__state));
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_0__row_state_min1 
        = __Vfunc_row_state_min1__26__Vfuncout;
    if (VL_UNLIKELY((((IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_0__row_state_min1) 
                      != __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_min1)))) {
        __Vfunc_row_state_min1__27__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
        __Vfunc_row_state_min1__27__Vfuncout = 0;
        __Vfunc_row_state_min1__27__Vfuncout = (0x0000000fU 
                                                & (IData)(__Vfunc_row_state_min1__27__state));
        __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_1__row_state_min1 
            = __Vfunc_row_state_min1__27__Vfuncout;
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_cnu_a.sv:28: Assertion failed in %m: min1 mismatch: got %0d exp %0d\n",5, 'M',vlSymsp->name(),"tb_mdpc_cnu_a.expect_state", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',4,(IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_1__row_state_min1)
                     , '~',32,__Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_min1);
        VL_STOP_MT("tb/tb_mdpc_cnu_a.sv", 28, "", false);
    }
    __Vfunc_row_state_min2__28__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
    __Vfunc_row_state_min2__28__Vfuncout = 0;
    __Vfunc_row_state_min2__28__Vfuncout = (0x0000000fU 
                                            & ((IData)(__Vfunc_row_state_min2__28__state) 
                                               >> 4U));
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_2__row_state_min2 
        = __Vfunc_row_state_min2__28__Vfuncout;
    if (VL_UNLIKELY((((IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_2__row_state_min2) 
                      != __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_min2)))) {
        __Vfunc_row_state_min2__29__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
        __Vfunc_row_state_min2__29__Vfuncout = 0;
        __Vfunc_row_state_min2__29__Vfuncout = (0x0000000fU 
                                                & ((IData)(__Vfunc_row_state_min2__29__state) 
                                                   >> 4U));
        __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_3__row_state_min2 
            = __Vfunc_row_state_min2__29__Vfuncout;
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_cnu_a.sv:29: Assertion failed in %m: min2 mismatch: got %0d exp %0d\n",5, 'M',vlSymsp->name(),"tb_mdpc_cnu_a.expect_state", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',4,(IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_3__row_state_min2)
                     , '~',32,__Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_min2);
        VL_STOP_MT("tb/tb_mdpc_cnu_a.sv", 29, "", false);
    }
    __Vfunc_row_state_min_id__30__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
    __Vfunc_row_state_min_id__30__Vfuncout = 0;
    __Vfunc_row_state_min_id__30__Vfuncout = (0x0000000fU 
                                              & ((IData)(__Vfunc_row_state_min_id__30__state) 
                                                 >> 8U));
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_4__row_state_min_id 
        = __Vfunc_row_state_min_id__30__Vfuncout;
    if (VL_UNLIKELY((((IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_4__row_state_min_id) 
                      != __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_min_id)))) {
        __Vfunc_row_state_min_id__31__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
        __Vfunc_row_state_min_id__31__Vfuncout = 0;
        __Vfunc_row_state_min_id__31__Vfuncout = (0x0000000fU 
                                                  & ((IData)(__Vfunc_row_state_min_id__31__state) 
                                                     >> 8U));
        __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_5__row_state_min_id 
            = __Vfunc_row_state_min_id__31__Vfuncout;
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_cnu_a.sv:30: Assertion failed in %m: min_id mismatch: got %0d exp %0d\n",5, 'M',vlSymsp->name(),"tb_mdpc_cnu_a.expect_state", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',4,(IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_5__row_state_min_id)
                     , '~',32,__Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_min_id);
        VL_STOP_MT("tb/tb_mdpc_cnu_a.sv", 30, "", false);
    }
    __Vfunc_row_state_sign_xor__32__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
    __Vfunc_row_state_sign_xor__32__Vfuncout = 0;
    __Vfunc_row_state_sign_xor__32__Vfuncout = (1U 
                                                & ((IData)(__Vfunc_row_state_sign_xor__32__state) 
                                                   >> 0x0cU));
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_6__row_state_sign_xor 
        = __Vfunc_row_state_sign_xor__32__Vfuncout;
    if (VL_UNLIKELY((((IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_6__row_state_sign_xor) 
                      != __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_sign_xor)))) {
        __Vfunc_row_state_sign_xor__33__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
        __Vfunc_row_state_sign_xor__33__Vfuncout = 0;
        __Vfunc_row_state_sign_xor__33__Vfuncout = 
            (1U & ((IData)(__Vfunc_row_state_sign_xor__33__state) 
                   >> 0x0cU));
        __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_7__row_state_sign_xor 
            = __Vfunc_row_state_sign_xor__33__Vfuncout;
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_cnu_a.sv:31: Assertion failed in %m: sign_xor mismatch: got %0d exp %0d\n",5, 'M',vlSymsp->name(),"tb_mdpc_cnu_a.expect_state", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',1,(IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_7__row_state_sign_xor)
                     , '~',32,__Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_sign_xor);
        VL_STOP_MT("tb/tb_mdpc_cnu_a.sv", 31, "", false);
    }
    __Vfunc_row_state_valid_count__34__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
    __Vfunc_row_state_valid_count__34__Vfuncout = 0;
    __Vfunc_row_state_valid_count__34__Vfuncout = (3U 
                                                   & ((IData)(__Vfunc_row_state_valid_count__34__state) 
                                                      >> 0x0dU));
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_8__row_state_valid_count 
        = __Vfunc_row_state_valid_count__34__Vfuncout;
    if (VL_UNLIKELY((((IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_8__row_state_valid_count) 
                      != __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_valid_count)))) {
        __Vfunc_row_state_valid_count__35__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
        __Vfunc_row_state_valid_count__35__Vfuncout = 0;
        __Vfunc_row_state_valid_count__35__Vfuncout 
            = (3U & ((IData)(__Vfunc_row_state_valid_count__35__state) 
                     >> 0x0dU));
        __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_9__row_state_valid_count 
            = __Vfunc_row_state_valid_count__35__Vfuncout;
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_cnu_a.sv:32: Assertion failed in %m: valid_count mismatch: got %0d exp %0d\n",5, 'M',vlSymsp->name(),"tb_mdpc_cnu_a.expect_state", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',2,(IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__25____VlefCall_9__row_state_valid_count)
                     , '~',32,__Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_valid_count);
        VL_STOP_MT("tb/tb_mdpc_cnu_a.sv", 32, "", false);
    }
    if (VL_UNLIKELY((((IData)(vlSelfRef.tb_mdpc_cnu_a__DOT__sign_bit_out) 
                      != __Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_sign_bit)))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_cnu_a.sv:33: Assertion failed in %m: sign_bit mismatch: got %0d exp %0d\n",5, 'M',vlSymsp->name(),"tb_mdpc_cnu_a.expect_state", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',1,(IData)(vlSelfRef.tb_mdpc_cnu_a__DOT__sign_bit_out)
                     , '~',32,__Vtask_tb_mdpc_cnu_a__DOT__expect_state__25__exp_sign_bit);
        VL_STOP_MT("tb/tb_mdpc_cnu_a.sv", 33, "", false);
    }
    vlSelfRef.tb_mdpc_cnu_a__DOT__row_state_in = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
    __Vfunc_msg_from_signed__36__value = 2U;
    __Vfunc_msg_from_signed__36__Vfuncout = 0;
    __Vfunc_msg_from_signed__36__msg = 0;
    __Vfunc_msg_from_signed__36__abs_value = 0U;
    __Vfunc_msg_from_signed__36__abs_value = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__36__value)
                                               ? (- __Vfunc_msg_from_signed__36__value)
                                               : __Vfunc_msg_from_signed__36__value);
    __Vfunc_mag_from_int__37__value = __Vfunc_msg_from_signed__36__abs_value;
    __Vfunc_mag_from_int__37__Vfuncout = 0;
    __Vfunc_mag_from_int__37__clamped_value = 0U;
    __Vfunc_mag_from_int__37__result = 0;
    __Vfunc_clamp_int__38__hi = 0x0000000fU;
    __Vfunc_clamp_int__38__lo = 0U;
    __Vfunc_clamp_int__38__value = __Vfunc_mag_from_int__37__value;
    {
        __Vfunc_clamp_int__38__Vfuncout = 0U;
        if (VL_LTS_III(32, __Vfunc_clamp_int__38__value, __Vfunc_clamp_int__38__lo)) {
            __Vfunc_clamp_int__38__Vfuncout = __Vfunc_clamp_int__38__lo;
            goto __Vlabel4;
        }
        if (VL_GTS_III(32, __Vfunc_clamp_int__38__value, __Vfunc_clamp_int__38__hi)) {
            __Vfunc_clamp_int__38__Vfuncout = __Vfunc_clamp_int__38__hi;
            goto __Vlabel4;
        }
        __Vfunc_clamp_int__38__Vfuncout = __Vfunc_clamp_int__38__value;
        __Vlabel4: ;
    }
    __Vfunc_mag_from_int__37__clamped_value = __Vfunc_clamp_int__38__Vfuncout;
    __Vfunc_mag_from_int__37__result = (0x0000000fU 
                                        & __Vfunc_mag_from_int__37__clamped_value);
    __Vfunc_mag_from_int__37__Vfuncout = __Vfunc_mag_from_int__37__result;
    __Vfunc_msg_from_signed__36____VlefCall_0__mag_from_int 
        = __Vfunc_mag_from_int__37__Vfuncout;
    __Vfunc_msg_pack__39__mag = __Vfunc_msg_from_signed__36____VlefCall_0__mag_from_int;
    __Vfunc_msg_pack__39__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__36__value);
    __Vfunc_msg_pack__39__Vfuncout = 0;
    __Vfunc_msg_pack__39__Vfuncout = (((IData)(__Vfunc_msg_pack__39__sign) 
                                       << 4U) | (IData)(__Vfunc_msg_pack__39__mag));
    __Vfunc_msg_from_signed__36__msg = __Vfunc_msg_pack__39__Vfuncout;
    __Vfunc_msg_from_signed__36__Vfuncout = __Vfunc_msg_from_signed__36__msg;
    vlSelfRef.tb_mdpc_cnu_a__DOT__u_in = __Vfunc_msg_from_signed__36__Vfuncout;
    vlSelfRef.tb_mdpc_cnu_a__DOT__var_idx = 7U;
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "tb/tb_mdpc_cnu_a.sv", 
                                         52);
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_sign_bit = 0U;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_valid_count = 3U;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_sign_xor = 1U;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_min_id = 3U;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_min2 = 2U;
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_min1 = 2U;
    __Vfunc_row_state_min1__41__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
    __Vfunc_row_state_min1__41__Vfuncout = 0;
    __Vfunc_row_state_min1__41__Vfuncout = (0x0000000fU 
                                            & (IData)(__Vfunc_row_state_min1__41__state));
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_0__row_state_min1 
        = __Vfunc_row_state_min1__41__Vfuncout;
    if (VL_UNLIKELY((((IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_0__row_state_min1) 
                      != __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_min1)))) {
        __Vfunc_row_state_min1__42__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
        __Vfunc_row_state_min1__42__Vfuncout = 0;
        __Vfunc_row_state_min1__42__Vfuncout = (0x0000000fU 
                                                & (IData)(__Vfunc_row_state_min1__42__state));
        __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_1__row_state_min1 
            = __Vfunc_row_state_min1__42__Vfuncout;
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_cnu_a.sv:28: Assertion failed in %m: min1 mismatch: got %0d exp %0d\n",5, 'M',vlSymsp->name(),"tb_mdpc_cnu_a.expect_state", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',4,(IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_1__row_state_min1)
                     , '~',32,__Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_min1);
        VL_STOP_MT("tb/tb_mdpc_cnu_a.sv", 28, "", false);
    }
    __Vfunc_row_state_min2__43__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
    __Vfunc_row_state_min2__43__Vfuncout = 0;
    __Vfunc_row_state_min2__43__Vfuncout = (0x0000000fU 
                                            & ((IData)(__Vfunc_row_state_min2__43__state) 
                                               >> 4U));
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_2__row_state_min2 
        = __Vfunc_row_state_min2__43__Vfuncout;
    if (VL_UNLIKELY((((IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_2__row_state_min2) 
                      != __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_min2)))) {
        __Vfunc_row_state_min2__44__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
        __Vfunc_row_state_min2__44__Vfuncout = 0;
        __Vfunc_row_state_min2__44__Vfuncout = (0x0000000fU 
                                                & ((IData)(__Vfunc_row_state_min2__44__state) 
                                                   >> 4U));
        __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_3__row_state_min2 
            = __Vfunc_row_state_min2__44__Vfuncout;
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_cnu_a.sv:29: Assertion failed in %m: min2 mismatch: got %0d exp %0d\n",5, 'M',vlSymsp->name(),"tb_mdpc_cnu_a.expect_state", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',4,(IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_3__row_state_min2)
                     , '~',32,__Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_min2);
        VL_STOP_MT("tb/tb_mdpc_cnu_a.sv", 29, "", false);
    }
    __Vfunc_row_state_min_id__45__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
    __Vfunc_row_state_min_id__45__Vfuncout = 0;
    __Vfunc_row_state_min_id__45__Vfuncout = (0x0000000fU 
                                              & ((IData)(__Vfunc_row_state_min_id__45__state) 
                                                 >> 8U));
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_4__row_state_min_id 
        = __Vfunc_row_state_min_id__45__Vfuncout;
    if (VL_UNLIKELY((((IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_4__row_state_min_id) 
                      != __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_min_id)))) {
        __Vfunc_row_state_min_id__46__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
        __Vfunc_row_state_min_id__46__Vfuncout = 0;
        __Vfunc_row_state_min_id__46__Vfuncout = (0x0000000fU 
                                                  & ((IData)(__Vfunc_row_state_min_id__46__state) 
                                                     >> 8U));
        __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_5__row_state_min_id 
            = __Vfunc_row_state_min_id__46__Vfuncout;
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_cnu_a.sv:30: Assertion failed in %m: min_id mismatch: got %0d exp %0d\n",5, 'M',vlSymsp->name(),"tb_mdpc_cnu_a.expect_state", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',4,(IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_5__row_state_min_id)
                     , '~',32,__Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_min_id);
        VL_STOP_MT("tb/tb_mdpc_cnu_a.sv", 30, "", false);
    }
    __Vfunc_row_state_sign_xor__47__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
    __Vfunc_row_state_sign_xor__47__Vfuncout = 0;
    __Vfunc_row_state_sign_xor__47__Vfuncout = (1U 
                                                & ((IData)(__Vfunc_row_state_sign_xor__47__state) 
                                                   >> 0x0cU));
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_6__row_state_sign_xor 
        = __Vfunc_row_state_sign_xor__47__Vfuncout;
    if (VL_UNLIKELY((((IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_6__row_state_sign_xor) 
                      != __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_sign_xor)))) {
        __Vfunc_row_state_sign_xor__48__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
        __Vfunc_row_state_sign_xor__48__Vfuncout = 0;
        __Vfunc_row_state_sign_xor__48__Vfuncout = 
            (1U & ((IData)(__Vfunc_row_state_sign_xor__48__state) 
                   >> 0x0cU));
        __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_7__row_state_sign_xor 
            = __Vfunc_row_state_sign_xor__48__Vfuncout;
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_cnu_a.sv:31: Assertion failed in %m: sign_xor mismatch: got %0d exp %0d\n",5, 'M',vlSymsp->name(),"tb_mdpc_cnu_a.expect_state", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',1,(IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_7__row_state_sign_xor)
                     , '~',32,__Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_sign_xor);
        VL_STOP_MT("tb/tb_mdpc_cnu_a.sv", 31, "", false);
    }
    __Vfunc_row_state_valid_count__49__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
    __Vfunc_row_state_valid_count__49__Vfuncout = 0;
    __Vfunc_row_state_valid_count__49__Vfuncout = (3U 
                                                   & ((IData)(__Vfunc_row_state_valid_count__49__state) 
                                                      >> 0x0dU));
    __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_8__row_state_valid_count 
        = __Vfunc_row_state_valid_count__49__Vfuncout;
    if (VL_UNLIKELY((((IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_8__row_state_valid_count) 
                      != __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_valid_count)))) {
        __Vfunc_row_state_valid_count__50__state = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
        __Vfunc_row_state_valid_count__50__Vfuncout = 0;
        __Vfunc_row_state_valid_count__50__Vfuncout 
            = (3U & ((IData)(__Vfunc_row_state_valid_count__50__state) 
                     >> 0x0dU));
        __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_9__row_state_valid_count 
            = __Vfunc_row_state_valid_count__50__Vfuncout;
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_cnu_a.sv:32: Assertion failed in %m: valid_count mismatch: got %0d exp %0d\n",5, 'M',vlSymsp->name(),"tb_mdpc_cnu_a.expect_state", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',2,(IData)(__Vtask_tb_mdpc_cnu_a__DOT__expect_state__40____VlefCall_9__row_state_valid_count)
                     , '~',32,__Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_valid_count);
        VL_STOP_MT("tb/tb_mdpc_cnu_a.sv", 32, "", false);
    }
    if (VL_UNLIKELY((((IData)(vlSelfRef.tb_mdpc_cnu_a__DOT__sign_bit_out) 
                      != __Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_sign_bit)))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_cnu_a.sv:33: Assertion failed in %m: sign_bit mismatch: got %0d exp %0d\n",5, 'M',vlSymsp->name(),"tb_mdpc_cnu_a.expect_state", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',1,(IData)(vlSelfRef.tb_mdpc_cnu_a__DOT__sign_bit_out)
                     , '~',32,__Vtask_tb_mdpc_cnu_a__DOT__expect_state__40__exp_sign_bit);
        VL_STOP_MT("tb/tb_mdpc_cnu_a.sv", 33, "", false);
    }
    VL_WRITEF_NX("tb_mdpc_cnu_a PASS\n",0);
    VL_FINISH_MT("tb/tb_mdpc_cnu_a.sv", 56, "");
    co_return;
}

void Vtb_mdpc_cnu_a___024root___eval_triggers_vec__act(Vtb_mdpc_cnu_a___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_a___024root___eval_triggers_vec__act\n"); );
    Vtb_mdpc_cnu_a__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VactTriggered[0U] = (QData)((IData)(vlSelfRef.__VdlySched.awaitingCurrentTime()));
}

bool Vtb_mdpc_cnu_a___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_a___024root___trigger_anySet__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        if (in[n]) {
            return (1U);
        }
        n = ((IData)(1U) + n);
    } while ((1U > n));
    return (0U);
}

void Vtb_mdpc_cnu_a___024root___act_sequent__TOP__0(Vtb_mdpc_cnu_a___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_a___024root___act_sequent__TOP__0\n"); );
    Vtb_mdpc_cnu_a__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*1:0*/ tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_2__row_state_valid_count;
    CData/*1:0*/ tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_1__row_state_valid_count;
    CData/*3:0*/ tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_0__msg_mag;
    IData/*31:0*/ tb_mdpc_cnu_a__DOT__dut__DOT__abs_mag;
    tb_mdpc_cnu_a__DOT__dut__DOT__abs_mag = 0;
    IData/*31:0*/ tb_mdpc_cnu_a__DOT__dut__DOT__next_count;
    tb_mdpc_cnu_a__DOT__dut__DOT__next_count = 0;
    CData/*0:0*/ __Vfunc_msg_sign__51__Vfuncout;
    __Vfunc_msg_sign__51__Vfuncout = 0;
    CData/*4:0*/ __Vfunc_msg_sign__51__msg;
    __Vfunc_msg_sign__51__msg = 0;
    CData/*4:0*/ __Vfunc_msg_mag__52__msg;
    __Vfunc_msg_mag__52__msg = 0;
    SData/*14:0*/ __Vfunc_row_state_valid_count__53__state;
    __Vfunc_row_state_valid_count__53__state = 0;
    SData/*14:0*/ __Vfunc_row_state_valid_count__54__state;
    __Vfunc_row_state_valid_count__54__state = 0;
    // Body
    vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state 
        = vlSelfRef.tb_mdpc_cnu_a__DOT__row_state_in;
    __Vfunc_msg_sign__51__msg = vlSelfRef.tb_mdpc_cnu_a__DOT__u_in;
    __Vfunc_msg_sign__51__Vfuncout = (1U & ((IData)(__Vfunc_msg_sign__51__msg) 
                                            >> 4U));
    vlSelfRef.tb_mdpc_cnu_a__DOT__sign_bit_out = __Vfunc_msg_sign__51__Vfuncout;
    __Vfunc_msg_mag__52__msg = vlSelfRef.tb_mdpc_cnu_a__DOT__u_in;
    tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_0__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__52__msg));
    tb_mdpc_cnu_a__DOT__dut__DOT__abs_mag = tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_0__msg_mag;
    __Vfunc_row_state_valid_count__53__state = vlSelfRef.tb_mdpc_cnu_a__DOT__row_state_in;
    tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_1__row_state_valid_count 
        = (3U & ((IData)(__Vfunc_row_state_valid_count__53__state) 
                 >> 0x0dU));
    tb_mdpc_cnu_a__DOT__dut__DOT__next_count = tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_1__row_state_valid_count;
    __Vfunc_row_state_valid_count__54__state = vlSelfRef.tb_mdpc_cnu_a__DOT__row_state_in;
    tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_2__row_state_valid_count 
        = (3U & ((IData)(__Vfunc_row_state_valid_count__54__state) 
                 >> 0x0dU));
    if ((0U == (IData)(tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_2__row_state_valid_count))) {
        vlSelfRef.__Vfunc_mag_from_int__55__value = tb_mdpc_cnu_a__DOT__dut__DOT__abs_mag;
        vlSelfRef.__Vfunc_clamp_int__56__hi = 0x0000000fU;
        vlSelfRef.__Vfunc_clamp_int__56__lo = 0U;
        vlSelfRef.__Vfunc_clamp_int__56__value = vlSelfRef.__Vfunc_mag_from_int__55__value;
        {
            vlSelfRef.__Vfunc_clamp_int__56__Vfuncout = 0U;
            if (VL_LTS_III(32, vlSelfRef.__Vfunc_clamp_int__56__value, vlSelfRef.__Vfunc_clamp_int__56__lo)) {
                vlSelfRef.__Vfunc_clamp_int__56__Vfuncout 
                    = vlSelfRef.__Vfunc_clamp_int__56__lo;
                goto __Vlabel0;
            }
            if (VL_GTS_III(32, vlSelfRef.__Vfunc_clamp_int__56__value, vlSelfRef.__Vfunc_clamp_int__56__hi)) {
                vlSelfRef.__Vfunc_clamp_int__56__Vfuncout 
                    = vlSelfRef.__Vfunc_clamp_int__56__hi;
                goto __Vlabel0;
            }
            vlSelfRef.__Vfunc_clamp_int__56__Vfuncout 
                = vlSelfRef.__Vfunc_clamp_int__56__value;
            __Vlabel0: ;
        }
        vlSelfRef.__Vfunc_mag_from_int__55__clamped_value 
            = vlSelfRef.__Vfunc_clamp_int__56__Vfuncout;
        vlSelfRef.__Vfunc_mag_from_int__55__result 
            = (0x0000000fU & vlSelfRef.__Vfunc_mag_from_int__55__clamped_value);
        vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_3__mag_from_int 
            = vlSelfRef.__Vfunc_mag_from_int__55__result;
        vlSelfRef.__Vfunc_clamp_int__58__hi = 0x0000000fU;
        vlSelfRef.__Vfunc_clamp_int__58__lo = 0U;
        vlSelfRef.__Vfunc_clamp_int__58__value = 0x0000000fU;
        {
            vlSelfRef.__Vfunc_clamp_int__58__Vfuncout = 0U;
            if (VL_LTS_III(32, vlSelfRef.__Vfunc_clamp_int__58__value, vlSelfRef.__Vfunc_clamp_int__58__lo)) {
                vlSelfRef.__Vfunc_clamp_int__58__Vfuncout 
                    = vlSelfRef.__Vfunc_clamp_int__58__lo;
                goto __Vlabel1;
            }
            if (VL_GTS_III(32, vlSelfRef.__Vfunc_clamp_int__58__value, vlSelfRef.__Vfunc_clamp_int__58__hi)) {
                vlSelfRef.__Vfunc_clamp_int__58__Vfuncout 
                    = vlSelfRef.__Vfunc_clamp_int__58__hi;
                goto __Vlabel1;
            }
            vlSelfRef.__Vfunc_clamp_int__58__Vfuncout 
                = vlSelfRef.__Vfunc_clamp_int__58__value;
            __Vlabel1: ;
        }
        vlSelfRef.__Vfunc_mag_from_int__57__clamped_value 
            = vlSelfRef.__Vfunc_clamp_int__58__Vfuncout;
        vlSelfRef.__Vfunc_mag_from_int__57__result 
            = (0x0000000fU & vlSelfRef.__Vfunc_mag_from_int__57__clamped_value);
        vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_4__mag_from_int 
            = vlSelfRef.__Vfunc_mag_from_int__57__result;
        vlSelfRef.__Vfunc_msg_sign__59__msg = vlSelfRef.tb_mdpc_cnu_a__DOT__u_in;
        vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_5__msg_sign 
            = (1U & ((IData)(vlSelfRef.__Vfunc_msg_sign__59__msg) 
                     >> 4U));
        vlSelfRef.__Vfunc_row_state_pack__60__sign_xor 
            = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_5__msg_sign;
        vlSelfRef.__Vfunc_row_state_pack__60__min_id 
            = vlSelfRef.tb_mdpc_cnu_a__DOT__var_idx;
        vlSelfRef.__Vfunc_row_state_pack__60__min2 
            = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_4__mag_from_int;
        vlSelfRef.__Vfunc_row_state_pack__60__min1 
            = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_3__mag_from_int;
        vlSelfRef.__Vfunc_row_state_pack__60__Vfuncout 
            = (0x00002000U | ((((IData)(vlSelfRef.__Vfunc_row_state_pack__60__sign_xor) 
                                << 0x0000000cU) | ((IData)(vlSelfRef.__Vfunc_row_state_pack__60__min_id) 
                                                   << 8U)) 
                              | (((IData)(vlSelfRef.__Vfunc_row_state_pack__60__min2) 
                                  << 4U) | (IData)(vlSelfRef.__Vfunc_row_state_pack__60__min1))));
        vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state 
            = vlSelfRef.__Vfunc_row_state_pack__60__Vfuncout;
    } else {
        vlSelfRef.__Vfunc_row_state_valid_count__61__state 
            = vlSelfRef.tb_mdpc_cnu_a__DOT__row_state_in;
        vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_6__row_state_valid_count 
            = (3U & ((IData)(vlSelfRef.__Vfunc_row_state_valid_count__61__state) 
                     >> 0x0dU));
        tb_mdpc_cnu_a__DOT__dut__DOT__next_count = 
            ((IData)(1U) + (IData)(vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_6__row_state_valid_count));
        if (VL_LTS_III(32, 3U, tb_mdpc_cnu_a__DOT__dut__DOT__next_count)) {
            tb_mdpc_cnu_a__DOT__dut__DOT__next_count = 3U;
        }
        vlSelfRef.__Vfunc_row_state_sign_xor__62__state 
            = vlSelfRef.tb_mdpc_cnu_a__DOT__row_state_in;
        vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_7__row_state_sign_xor 
            = (1U & ((IData)(vlSelfRef.__Vfunc_row_state_sign_xor__62__state) 
                     >> 0x0cU));
        vlSelfRef.__Vfunc_msg_sign__63__msg = vlSelfRef.tb_mdpc_cnu_a__DOT__u_in;
        vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_8__msg_sign 
            = (1U & ((IData)(vlSelfRef.__Vfunc_msg_sign__63__msg) 
                     >> 4U));
        vlSelfRef.__Vfunc_row_state_set_sign_xor__64__sign_xor 
            = ((IData)(vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_7__row_state_sign_xor) 
               ^ (IData)(vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_8__msg_sign));
        vlSelfRef.__Vfunc_row_state_set_sign_xor__64__state 
            = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
        vlSelfRef.__Vfunc_row_state_set_sign_xor__64__next_state 
            = vlSelfRef.__Vfunc_row_state_set_sign_xor__64__state;
        vlSelfRef.__Vfunc_row_state_set_sign_xor__64__next_state 
            = ((0x6fffU & (IData)(vlSelfRef.__Vfunc_row_state_set_sign_xor__64__next_state)) 
               | ((IData)(vlSelfRef.__Vfunc_row_state_set_sign_xor__64__sign_xor) 
                  << 0x0000000cU));
        vlSelfRef.__Vfunc_row_state_set_sign_xor__64__Vfuncout 
            = vlSelfRef.__Vfunc_row_state_set_sign_xor__64__next_state;
        vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state 
            = vlSelfRef.__Vfunc_row_state_set_sign_xor__64__Vfuncout;
        vlSelfRef.__Vfunc_row_state_set_valid_count__65__valid_count 
            = (3U & tb_mdpc_cnu_a__DOT__dut__DOT__next_count);
        vlSelfRef.__Vfunc_row_state_set_valid_count__65__state 
            = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
        vlSelfRef.__Vfunc_row_state_set_valid_count__65__next_state 
            = vlSelfRef.__Vfunc_row_state_set_valid_count__65__state;
        vlSelfRef.__Vfunc_row_state_set_valid_count__65__next_state 
            = ((0x1fffU & (IData)(vlSelfRef.__Vfunc_row_state_set_valid_count__65__next_state)) 
               | ((IData)(vlSelfRef.__Vfunc_row_state_set_valid_count__65__valid_count) 
                  << 0x0000000dU));
        vlSelfRef.__Vfunc_row_state_set_valid_count__65__Vfuncout 
            = vlSelfRef.__Vfunc_row_state_set_valid_count__65__next_state;
        vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state 
            = vlSelfRef.__Vfunc_row_state_set_valid_count__65__Vfuncout;
        vlSelfRef.__Vfunc_row_state_min1__66__state 
            = vlSelfRef.tb_mdpc_cnu_a__DOT__row_state_in;
        vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_9__row_state_min1 
            = (0x0000000fU & (IData)(vlSelfRef.__Vfunc_row_state_min1__66__state));
        if (VL_LTS_III(32, tb_mdpc_cnu_a__DOT__dut__DOT__abs_mag, (IData)(vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_9__row_state_min1))) {
            vlSelfRef.__Vfunc_row_state_min1__67__state 
                = vlSelfRef.tb_mdpc_cnu_a__DOT__row_state_in;
            vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_10__row_state_min1 
                = (0x0000000fU & (IData)(vlSelfRef.__Vfunc_row_state_min1__67__state));
            vlSelfRef.__Vfunc_row_state_set_min2__68__min2 
                = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_10__row_state_min1;
            vlSelfRef.__Vfunc_row_state_set_min2__68__state 
                = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
            vlSelfRef.__Vfunc_row_state_set_min2__68__next_state 
                = vlSelfRef.__Vfunc_row_state_set_min2__68__state;
            vlSelfRef.__Vfunc_row_state_set_min2__68__next_state 
                = ((0x7f0fU & (IData)(vlSelfRef.__Vfunc_row_state_set_min2__68__next_state)) 
                   | ((IData)(vlSelfRef.__Vfunc_row_state_set_min2__68__min2) 
                      << 4U));
            vlSelfRef.__Vfunc_row_state_set_min2__68__Vfuncout 
                = vlSelfRef.__Vfunc_row_state_set_min2__68__next_state;
            vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state 
                = vlSelfRef.__Vfunc_row_state_set_min2__68__Vfuncout;
            vlSelfRef.__Vfunc_mag_from_int__69__value 
                = tb_mdpc_cnu_a__DOT__dut__DOT__abs_mag;
            vlSelfRef.__Vfunc_clamp_int__70__hi = 0x0000000fU;
            vlSelfRef.__Vfunc_clamp_int__70__lo = 0U;
            vlSelfRef.__Vfunc_clamp_int__70__value 
                = vlSelfRef.__Vfunc_mag_from_int__69__value;
            {
                vlSelfRef.__Vfunc_clamp_int__70__Vfuncout = 0U;
                if (VL_LTS_III(32, vlSelfRef.__Vfunc_clamp_int__70__value, vlSelfRef.__Vfunc_clamp_int__70__lo)) {
                    vlSelfRef.__Vfunc_clamp_int__70__Vfuncout 
                        = vlSelfRef.__Vfunc_clamp_int__70__lo;
                    goto __Vlabel2;
                }
                if (VL_GTS_III(32, vlSelfRef.__Vfunc_clamp_int__70__value, vlSelfRef.__Vfunc_clamp_int__70__hi)) {
                    vlSelfRef.__Vfunc_clamp_int__70__Vfuncout 
                        = vlSelfRef.__Vfunc_clamp_int__70__hi;
                    goto __Vlabel2;
                }
                vlSelfRef.__Vfunc_clamp_int__70__Vfuncout 
                    = vlSelfRef.__Vfunc_clamp_int__70__value;
                __Vlabel2: ;
            }
            vlSelfRef.__Vfunc_mag_from_int__69__clamped_value 
                = vlSelfRef.__Vfunc_clamp_int__70__Vfuncout;
            vlSelfRef.__Vfunc_mag_from_int__69__result 
                = (0x0000000fU & vlSelfRef.__Vfunc_mag_from_int__69__clamped_value);
            vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_11__mag_from_int 
                = vlSelfRef.__Vfunc_mag_from_int__69__result;
            vlSelfRef.__Vfunc_row_state_set_min1__71__min1 
                = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_11__mag_from_int;
            vlSelfRef.__Vfunc_row_state_set_min1__71__state 
                = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
            vlSelfRef.__Vfunc_row_state_set_min1__71__next_state 
                = vlSelfRef.__Vfunc_row_state_set_min1__71__state;
            vlSelfRef.__Vfunc_row_state_set_min1__71__next_state 
                = ((0x7ff0U & (IData)(vlSelfRef.__Vfunc_row_state_set_min1__71__next_state)) 
                   | (IData)(vlSelfRef.__Vfunc_row_state_set_min1__71__min1));
            vlSelfRef.__Vfunc_row_state_set_min1__71__Vfuncout 
                = vlSelfRef.__Vfunc_row_state_set_min1__71__next_state;
            vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state 
                = vlSelfRef.__Vfunc_row_state_set_min1__71__Vfuncout;
            vlSelfRef.__Vfunc_row_state_set_min_id__72__min_id 
                = vlSelfRef.tb_mdpc_cnu_a__DOT__var_idx;
            vlSelfRef.__Vfunc_row_state_set_min_id__72__state 
                = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
            vlSelfRef.__Vfunc_row_state_set_min_id__72__next_state 
                = vlSelfRef.__Vfunc_row_state_set_min_id__72__state;
            vlSelfRef.__Vfunc_row_state_set_min_id__72__next_state 
                = ((0x70ffU & (IData)(vlSelfRef.__Vfunc_row_state_set_min_id__72__next_state)) 
                   | ((IData)(vlSelfRef.__Vfunc_row_state_set_min_id__72__min_id) 
                      << 8U));
            vlSelfRef.__Vfunc_row_state_set_min_id__72__Vfuncout 
                = vlSelfRef.__Vfunc_row_state_set_min_id__72__next_state;
            vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state 
                = vlSelfRef.__Vfunc_row_state_set_min_id__72__Vfuncout;
        } else {
            vlSelfRef.__Vfunc_row_state_min2__73__state 
                = vlSelfRef.tb_mdpc_cnu_a__DOT__row_state_in;
            vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_12__row_state_min2 
                = (0x0000000fU & ((IData)(vlSelfRef.__Vfunc_row_state_min2__73__state) 
                                  >> 4U));
            if (VL_LTS_III(32, tb_mdpc_cnu_a__DOT__dut__DOT__abs_mag, (IData)(vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_12__row_state_min2))) {
                vlSelfRef.__Vfunc_mag_from_int__74__value 
                    = tb_mdpc_cnu_a__DOT__dut__DOT__abs_mag;
                vlSelfRef.__Vfunc_clamp_int__75__hi = 0x0000000fU;
                vlSelfRef.__Vfunc_clamp_int__75__lo = 0U;
                vlSelfRef.__Vfunc_clamp_int__75__value 
                    = vlSelfRef.__Vfunc_mag_from_int__74__value;
                {
                    vlSelfRef.__Vfunc_clamp_int__75__Vfuncout = 0U;
                    if (VL_LTS_III(32, vlSelfRef.__Vfunc_clamp_int__75__value, vlSelfRef.__Vfunc_clamp_int__75__lo)) {
                        vlSelfRef.__Vfunc_clamp_int__75__Vfuncout 
                            = vlSelfRef.__Vfunc_clamp_int__75__lo;
                        goto __Vlabel3;
                    }
                    if (VL_GTS_III(32, vlSelfRef.__Vfunc_clamp_int__75__value, vlSelfRef.__Vfunc_clamp_int__75__hi)) {
                        vlSelfRef.__Vfunc_clamp_int__75__Vfuncout 
                            = vlSelfRef.__Vfunc_clamp_int__75__hi;
                        goto __Vlabel3;
                    }
                    vlSelfRef.__Vfunc_clamp_int__75__Vfuncout 
                        = vlSelfRef.__Vfunc_clamp_int__75__value;
                    __Vlabel3: ;
                }
                vlSelfRef.__Vfunc_mag_from_int__74__clamped_value 
                    = vlSelfRef.__Vfunc_clamp_int__75__Vfuncout;
                vlSelfRef.__Vfunc_mag_from_int__74__result 
                    = (0x0000000fU & vlSelfRef.__Vfunc_mag_from_int__74__clamped_value);
                vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_13__mag_from_int 
                    = vlSelfRef.__Vfunc_mag_from_int__74__result;
                vlSelfRef.__Vfunc_row_state_set_min2__76__min2 
                    = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_13__mag_from_int;
                vlSelfRef.__Vfunc_row_state_set_min2__76__state 
                    = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
                vlSelfRef.__Vfunc_row_state_set_min2__76__next_state 
                    = vlSelfRef.__Vfunc_row_state_set_min2__76__state;
                vlSelfRef.__Vfunc_row_state_set_min2__76__next_state 
                    = ((0x7f0fU & (IData)(vlSelfRef.__Vfunc_row_state_set_min2__76__next_state)) 
                       | ((IData)(vlSelfRef.__Vfunc_row_state_set_min2__76__min2) 
                          << 4U));
                vlSelfRef.__Vfunc_row_state_set_min2__76__Vfuncout 
                    = vlSelfRef.__Vfunc_row_state_set_min2__76__next_state;
                vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state 
                    = vlSelfRef.__Vfunc_row_state_set_min2__76__Vfuncout;
            }
        }
    }
}

void Vtb_mdpc_cnu_a___024root___eval_act(Vtb_mdpc_cnu_a___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_a___024root___eval_act\n"); );
    Vtb_mdpc_cnu_a__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VactTriggered[0U])) {
        Vtb_mdpc_cnu_a___024root___act_sequent__TOP__0(vlSelf);
    }
}

void Vtb_mdpc_cnu_a___024root___nba_sequent__TOP__0(Vtb_mdpc_cnu_a___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_a___024root___nba_sequent__TOP__0\n"); );
    Vtb_mdpc_cnu_a__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*1:0*/ tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_2__row_state_valid_count;
    CData/*1:0*/ tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_1__row_state_valid_count;
    CData/*3:0*/ tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_0__msg_mag;
    IData/*31:0*/ tb_mdpc_cnu_a__DOT__dut__DOT__abs_mag;
    tb_mdpc_cnu_a__DOT__dut__DOT__abs_mag = 0;
    IData/*31:0*/ tb_mdpc_cnu_a__DOT__dut__DOT__next_count;
    tb_mdpc_cnu_a__DOT__dut__DOT__next_count = 0;
    CData/*0:0*/ __Vfunc_msg_sign__51__Vfuncout;
    __Vfunc_msg_sign__51__Vfuncout = 0;
    CData/*4:0*/ __Vfunc_msg_sign__51__msg;
    __Vfunc_msg_sign__51__msg = 0;
    CData/*4:0*/ __Vfunc_msg_mag__52__msg;
    __Vfunc_msg_mag__52__msg = 0;
    SData/*14:0*/ __Vfunc_row_state_valid_count__53__state;
    __Vfunc_row_state_valid_count__53__state = 0;
    SData/*14:0*/ __Vfunc_row_state_valid_count__54__state;
    __Vfunc_row_state_valid_count__54__state = 0;
    // Body
    vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state 
        = vlSelfRef.tb_mdpc_cnu_a__DOT__row_state_in;
    __Vfunc_msg_sign__51__msg = vlSelfRef.tb_mdpc_cnu_a__DOT__u_in;
    __Vfunc_msg_sign__51__Vfuncout = (1U & ((IData)(__Vfunc_msg_sign__51__msg) 
                                            >> 4U));
    vlSelfRef.tb_mdpc_cnu_a__DOT__sign_bit_out = __Vfunc_msg_sign__51__Vfuncout;
    __Vfunc_msg_mag__52__msg = vlSelfRef.tb_mdpc_cnu_a__DOT__u_in;
    tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_0__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__52__msg));
    tb_mdpc_cnu_a__DOT__dut__DOT__abs_mag = tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_0__msg_mag;
    __Vfunc_row_state_valid_count__53__state = vlSelfRef.tb_mdpc_cnu_a__DOT__row_state_in;
    tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_1__row_state_valid_count 
        = (3U & ((IData)(__Vfunc_row_state_valid_count__53__state) 
                 >> 0x0dU));
    tb_mdpc_cnu_a__DOT__dut__DOT__next_count = tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_1__row_state_valid_count;
    __Vfunc_row_state_valid_count__54__state = vlSelfRef.tb_mdpc_cnu_a__DOT__row_state_in;
    tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_2__row_state_valid_count 
        = (3U & ((IData)(__Vfunc_row_state_valid_count__54__state) 
                 >> 0x0dU));
    if ((0U == (IData)(tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_2__row_state_valid_count))) {
        vlSelfRef.__Vfunc_mag_from_int__55__value = tb_mdpc_cnu_a__DOT__dut__DOT__abs_mag;
        vlSelfRef.__Vfunc_clamp_int__56__hi = 0x0000000fU;
        vlSelfRef.__Vfunc_clamp_int__56__lo = 0U;
        vlSelfRef.__Vfunc_clamp_int__56__value = vlSelfRef.__Vfunc_mag_from_int__55__value;
        {
            vlSelfRef.__Vfunc_clamp_int__56__Vfuncout = 0U;
            if (VL_LTS_III(32, vlSelfRef.__Vfunc_clamp_int__56__value, vlSelfRef.__Vfunc_clamp_int__56__lo)) {
                vlSelfRef.__Vfunc_clamp_int__56__Vfuncout 
                    = vlSelfRef.__Vfunc_clamp_int__56__lo;
                goto __Vlabel0;
            }
            if (VL_GTS_III(32, vlSelfRef.__Vfunc_clamp_int__56__value, vlSelfRef.__Vfunc_clamp_int__56__hi)) {
                vlSelfRef.__Vfunc_clamp_int__56__Vfuncout 
                    = vlSelfRef.__Vfunc_clamp_int__56__hi;
                goto __Vlabel0;
            }
            vlSelfRef.__Vfunc_clamp_int__56__Vfuncout 
                = vlSelfRef.__Vfunc_clamp_int__56__value;
            __Vlabel0: ;
        }
        vlSelfRef.__Vfunc_mag_from_int__55__clamped_value 
            = vlSelfRef.__Vfunc_clamp_int__56__Vfuncout;
        vlSelfRef.__Vfunc_mag_from_int__55__result 
            = (0x0000000fU & vlSelfRef.__Vfunc_mag_from_int__55__clamped_value);
        vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_3__mag_from_int 
            = vlSelfRef.__Vfunc_mag_from_int__55__result;
        vlSelfRef.__Vfunc_clamp_int__58__hi = 0x0000000fU;
        vlSelfRef.__Vfunc_clamp_int__58__lo = 0U;
        vlSelfRef.__Vfunc_clamp_int__58__value = 0x0000000fU;
        {
            vlSelfRef.__Vfunc_clamp_int__58__Vfuncout = 0U;
            if (VL_LTS_III(32, vlSelfRef.__Vfunc_clamp_int__58__value, vlSelfRef.__Vfunc_clamp_int__58__lo)) {
                vlSelfRef.__Vfunc_clamp_int__58__Vfuncout 
                    = vlSelfRef.__Vfunc_clamp_int__58__lo;
                goto __Vlabel1;
            }
            if (VL_GTS_III(32, vlSelfRef.__Vfunc_clamp_int__58__value, vlSelfRef.__Vfunc_clamp_int__58__hi)) {
                vlSelfRef.__Vfunc_clamp_int__58__Vfuncout 
                    = vlSelfRef.__Vfunc_clamp_int__58__hi;
                goto __Vlabel1;
            }
            vlSelfRef.__Vfunc_clamp_int__58__Vfuncout 
                = vlSelfRef.__Vfunc_clamp_int__58__value;
            __Vlabel1: ;
        }
        vlSelfRef.__Vfunc_mag_from_int__57__clamped_value 
            = vlSelfRef.__Vfunc_clamp_int__58__Vfuncout;
        vlSelfRef.__Vfunc_mag_from_int__57__result 
            = (0x0000000fU & vlSelfRef.__Vfunc_mag_from_int__57__clamped_value);
        vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_4__mag_from_int 
            = vlSelfRef.__Vfunc_mag_from_int__57__result;
        vlSelfRef.__Vfunc_msg_sign__59__msg = vlSelfRef.tb_mdpc_cnu_a__DOT__u_in;
        vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_5__msg_sign 
            = (1U & ((IData)(vlSelfRef.__Vfunc_msg_sign__59__msg) 
                     >> 4U));
        vlSelfRef.__Vfunc_row_state_pack__60__sign_xor 
            = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_5__msg_sign;
        vlSelfRef.__Vfunc_row_state_pack__60__min_id 
            = vlSelfRef.tb_mdpc_cnu_a__DOT__var_idx;
        vlSelfRef.__Vfunc_row_state_pack__60__min2 
            = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_4__mag_from_int;
        vlSelfRef.__Vfunc_row_state_pack__60__min1 
            = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_3__mag_from_int;
        vlSelfRef.__Vfunc_row_state_pack__60__Vfuncout 
            = (0x00002000U | ((((IData)(vlSelfRef.__Vfunc_row_state_pack__60__sign_xor) 
                                << 0x0000000cU) | ((IData)(vlSelfRef.__Vfunc_row_state_pack__60__min_id) 
                                                   << 8U)) 
                              | (((IData)(vlSelfRef.__Vfunc_row_state_pack__60__min2) 
                                  << 4U) | (IData)(vlSelfRef.__Vfunc_row_state_pack__60__min1))));
        vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state 
            = vlSelfRef.__Vfunc_row_state_pack__60__Vfuncout;
    } else {
        vlSelfRef.__Vfunc_row_state_valid_count__61__state 
            = vlSelfRef.tb_mdpc_cnu_a__DOT__row_state_in;
        vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_6__row_state_valid_count 
            = (3U & ((IData)(vlSelfRef.__Vfunc_row_state_valid_count__61__state) 
                     >> 0x0dU));
        tb_mdpc_cnu_a__DOT__dut__DOT__next_count = 
            ((IData)(1U) + (IData)(vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_6__row_state_valid_count));
        if (VL_LTS_III(32, 3U, tb_mdpc_cnu_a__DOT__dut__DOT__next_count)) {
            tb_mdpc_cnu_a__DOT__dut__DOT__next_count = 3U;
        }
        vlSelfRef.__Vfunc_row_state_sign_xor__62__state 
            = vlSelfRef.tb_mdpc_cnu_a__DOT__row_state_in;
        vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_7__row_state_sign_xor 
            = (1U & ((IData)(vlSelfRef.__Vfunc_row_state_sign_xor__62__state) 
                     >> 0x0cU));
        vlSelfRef.__Vfunc_msg_sign__63__msg = vlSelfRef.tb_mdpc_cnu_a__DOT__u_in;
        vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_8__msg_sign 
            = (1U & ((IData)(vlSelfRef.__Vfunc_msg_sign__63__msg) 
                     >> 4U));
        vlSelfRef.__Vfunc_row_state_set_sign_xor__64__sign_xor 
            = ((IData)(vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_7__row_state_sign_xor) 
               ^ (IData)(vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_8__msg_sign));
        vlSelfRef.__Vfunc_row_state_set_sign_xor__64__state 
            = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
        vlSelfRef.__Vfunc_row_state_set_sign_xor__64__next_state 
            = vlSelfRef.__Vfunc_row_state_set_sign_xor__64__state;
        vlSelfRef.__Vfunc_row_state_set_sign_xor__64__next_state 
            = ((0x6fffU & (IData)(vlSelfRef.__Vfunc_row_state_set_sign_xor__64__next_state)) 
               | ((IData)(vlSelfRef.__Vfunc_row_state_set_sign_xor__64__sign_xor) 
                  << 0x0000000cU));
        vlSelfRef.__Vfunc_row_state_set_sign_xor__64__Vfuncout 
            = vlSelfRef.__Vfunc_row_state_set_sign_xor__64__next_state;
        vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state 
            = vlSelfRef.__Vfunc_row_state_set_sign_xor__64__Vfuncout;
        vlSelfRef.__Vfunc_row_state_set_valid_count__65__valid_count 
            = (3U & tb_mdpc_cnu_a__DOT__dut__DOT__next_count);
        vlSelfRef.__Vfunc_row_state_set_valid_count__65__state 
            = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
        vlSelfRef.__Vfunc_row_state_set_valid_count__65__next_state 
            = vlSelfRef.__Vfunc_row_state_set_valid_count__65__state;
        vlSelfRef.__Vfunc_row_state_set_valid_count__65__next_state 
            = ((0x1fffU & (IData)(vlSelfRef.__Vfunc_row_state_set_valid_count__65__next_state)) 
               | ((IData)(vlSelfRef.__Vfunc_row_state_set_valid_count__65__valid_count) 
                  << 0x0000000dU));
        vlSelfRef.__Vfunc_row_state_set_valid_count__65__Vfuncout 
            = vlSelfRef.__Vfunc_row_state_set_valid_count__65__next_state;
        vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state 
            = vlSelfRef.__Vfunc_row_state_set_valid_count__65__Vfuncout;
        vlSelfRef.__Vfunc_row_state_min1__66__state 
            = vlSelfRef.tb_mdpc_cnu_a__DOT__row_state_in;
        vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_9__row_state_min1 
            = (0x0000000fU & (IData)(vlSelfRef.__Vfunc_row_state_min1__66__state));
        if (VL_LTS_III(32, tb_mdpc_cnu_a__DOT__dut__DOT__abs_mag, (IData)(vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_9__row_state_min1))) {
            vlSelfRef.__Vfunc_row_state_min1__67__state 
                = vlSelfRef.tb_mdpc_cnu_a__DOT__row_state_in;
            vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_10__row_state_min1 
                = (0x0000000fU & (IData)(vlSelfRef.__Vfunc_row_state_min1__67__state));
            vlSelfRef.__Vfunc_row_state_set_min2__68__min2 
                = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_10__row_state_min1;
            vlSelfRef.__Vfunc_row_state_set_min2__68__state 
                = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
            vlSelfRef.__Vfunc_row_state_set_min2__68__next_state 
                = vlSelfRef.__Vfunc_row_state_set_min2__68__state;
            vlSelfRef.__Vfunc_row_state_set_min2__68__next_state 
                = ((0x7f0fU & (IData)(vlSelfRef.__Vfunc_row_state_set_min2__68__next_state)) 
                   | ((IData)(vlSelfRef.__Vfunc_row_state_set_min2__68__min2) 
                      << 4U));
            vlSelfRef.__Vfunc_row_state_set_min2__68__Vfuncout 
                = vlSelfRef.__Vfunc_row_state_set_min2__68__next_state;
            vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state 
                = vlSelfRef.__Vfunc_row_state_set_min2__68__Vfuncout;
            vlSelfRef.__Vfunc_mag_from_int__69__value 
                = tb_mdpc_cnu_a__DOT__dut__DOT__abs_mag;
            vlSelfRef.__Vfunc_clamp_int__70__hi = 0x0000000fU;
            vlSelfRef.__Vfunc_clamp_int__70__lo = 0U;
            vlSelfRef.__Vfunc_clamp_int__70__value 
                = vlSelfRef.__Vfunc_mag_from_int__69__value;
            {
                vlSelfRef.__Vfunc_clamp_int__70__Vfuncout = 0U;
                if (VL_LTS_III(32, vlSelfRef.__Vfunc_clamp_int__70__value, vlSelfRef.__Vfunc_clamp_int__70__lo)) {
                    vlSelfRef.__Vfunc_clamp_int__70__Vfuncout 
                        = vlSelfRef.__Vfunc_clamp_int__70__lo;
                    goto __Vlabel2;
                }
                if (VL_GTS_III(32, vlSelfRef.__Vfunc_clamp_int__70__value, vlSelfRef.__Vfunc_clamp_int__70__hi)) {
                    vlSelfRef.__Vfunc_clamp_int__70__Vfuncout 
                        = vlSelfRef.__Vfunc_clamp_int__70__hi;
                    goto __Vlabel2;
                }
                vlSelfRef.__Vfunc_clamp_int__70__Vfuncout 
                    = vlSelfRef.__Vfunc_clamp_int__70__value;
                __Vlabel2: ;
            }
            vlSelfRef.__Vfunc_mag_from_int__69__clamped_value 
                = vlSelfRef.__Vfunc_clamp_int__70__Vfuncout;
            vlSelfRef.__Vfunc_mag_from_int__69__result 
                = (0x0000000fU & vlSelfRef.__Vfunc_mag_from_int__69__clamped_value);
            vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_11__mag_from_int 
                = vlSelfRef.__Vfunc_mag_from_int__69__result;
            vlSelfRef.__Vfunc_row_state_set_min1__71__min1 
                = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_11__mag_from_int;
            vlSelfRef.__Vfunc_row_state_set_min1__71__state 
                = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
            vlSelfRef.__Vfunc_row_state_set_min1__71__next_state 
                = vlSelfRef.__Vfunc_row_state_set_min1__71__state;
            vlSelfRef.__Vfunc_row_state_set_min1__71__next_state 
                = ((0x7ff0U & (IData)(vlSelfRef.__Vfunc_row_state_set_min1__71__next_state)) 
                   | (IData)(vlSelfRef.__Vfunc_row_state_set_min1__71__min1));
            vlSelfRef.__Vfunc_row_state_set_min1__71__Vfuncout 
                = vlSelfRef.__Vfunc_row_state_set_min1__71__next_state;
            vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state 
                = vlSelfRef.__Vfunc_row_state_set_min1__71__Vfuncout;
            vlSelfRef.__Vfunc_row_state_set_min_id__72__min_id 
                = vlSelfRef.tb_mdpc_cnu_a__DOT__var_idx;
            vlSelfRef.__Vfunc_row_state_set_min_id__72__state 
                = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
            vlSelfRef.__Vfunc_row_state_set_min_id__72__next_state 
                = vlSelfRef.__Vfunc_row_state_set_min_id__72__state;
            vlSelfRef.__Vfunc_row_state_set_min_id__72__next_state 
                = ((0x70ffU & (IData)(vlSelfRef.__Vfunc_row_state_set_min_id__72__next_state)) 
                   | ((IData)(vlSelfRef.__Vfunc_row_state_set_min_id__72__min_id) 
                      << 8U));
            vlSelfRef.__Vfunc_row_state_set_min_id__72__Vfuncout 
                = vlSelfRef.__Vfunc_row_state_set_min_id__72__next_state;
            vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state 
                = vlSelfRef.__Vfunc_row_state_set_min_id__72__Vfuncout;
        } else {
            vlSelfRef.__Vfunc_row_state_min2__73__state 
                = vlSelfRef.tb_mdpc_cnu_a__DOT__row_state_in;
            vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_12__row_state_min2 
                = (0x0000000fU & ((IData)(vlSelfRef.__Vfunc_row_state_min2__73__state) 
                                  >> 4U));
            if (VL_LTS_III(32, tb_mdpc_cnu_a__DOT__dut__DOT__abs_mag, (IData)(vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_12__row_state_min2))) {
                vlSelfRef.__Vfunc_mag_from_int__74__value 
                    = tb_mdpc_cnu_a__DOT__dut__DOT__abs_mag;
                vlSelfRef.__Vfunc_clamp_int__75__hi = 0x0000000fU;
                vlSelfRef.__Vfunc_clamp_int__75__lo = 0U;
                vlSelfRef.__Vfunc_clamp_int__75__value 
                    = vlSelfRef.__Vfunc_mag_from_int__74__value;
                {
                    vlSelfRef.__Vfunc_clamp_int__75__Vfuncout = 0U;
                    if (VL_LTS_III(32, vlSelfRef.__Vfunc_clamp_int__75__value, vlSelfRef.__Vfunc_clamp_int__75__lo)) {
                        vlSelfRef.__Vfunc_clamp_int__75__Vfuncout 
                            = vlSelfRef.__Vfunc_clamp_int__75__lo;
                        goto __Vlabel3;
                    }
                    if (VL_GTS_III(32, vlSelfRef.__Vfunc_clamp_int__75__value, vlSelfRef.__Vfunc_clamp_int__75__hi)) {
                        vlSelfRef.__Vfunc_clamp_int__75__Vfuncout 
                            = vlSelfRef.__Vfunc_clamp_int__75__hi;
                        goto __Vlabel3;
                    }
                    vlSelfRef.__Vfunc_clamp_int__75__Vfuncout 
                        = vlSelfRef.__Vfunc_clamp_int__75__value;
                    __Vlabel3: ;
                }
                vlSelfRef.__Vfunc_mag_from_int__74__clamped_value 
                    = vlSelfRef.__Vfunc_clamp_int__75__Vfuncout;
                vlSelfRef.__Vfunc_mag_from_int__74__result 
                    = (0x0000000fU & vlSelfRef.__Vfunc_mag_from_int__74__clamped_value);
                vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_13__mag_from_int 
                    = vlSelfRef.__Vfunc_mag_from_int__74__result;
                vlSelfRef.__Vfunc_row_state_set_min2__76__min2 
                    = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_13__mag_from_int;
                vlSelfRef.__Vfunc_row_state_set_min2__76__state 
                    = vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
                vlSelfRef.__Vfunc_row_state_set_min2__76__next_state 
                    = vlSelfRef.__Vfunc_row_state_set_min2__76__state;
                vlSelfRef.__Vfunc_row_state_set_min2__76__next_state 
                    = ((0x7f0fU & (IData)(vlSelfRef.__Vfunc_row_state_set_min2__76__next_state)) 
                       | ((IData)(vlSelfRef.__Vfunc_row_state_set_min2__76__min2) 
                          << 4U));
                vlSelfRef.__Vfunc_row_state_set_min2__76__Vfuncout 
                    = vlSelfRef.__Vfunc_row_state_set_min2__76__next_state;
                vlSelfRef.tb_mdpc_cnu_a__DOT__dut__DOT__next_state 
                    = vlSelfRef.__Vfunc_row_state_set_min2__76__Vfuncout;
            }
        }
    }
}

void Vtb_mdpc_cnu_a___024root___eval_nba(Vtb_mdpc_cnu_a___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_a___024root___eval_nba\n"); );
    Vtb_mdpc_cnu_a__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vtb_mdpc_cnu_a___024root___nba_sequent__TOP__0(vlSelf);
    }
}

void Vtb_mdpc_cnu_a___024root___timing_resume(Vtb_mdpc_cnu_a___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_a___024root___timing_resume\n"); );
    Vtb_mdpc_cnu_a__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VdlySched.resume();
    }
}

void Vtb_mdpc_cnu_a___024root___trigger_orInto__act_vec_vec(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_a___024root___trigger_orInto__act_vec_vec\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = (out[n] | in[n]);
        n = ((IData)(1U) + n);
    } while ((0U >= n));
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_mdpc_cnu_a___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

bool Vtb_mdpc_cnu_a___024root___eval_phase__act(Vtb_mdpc_cnu_a___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_a___024root___eval_phase__act\n"); );
    Vtb_mdpc_cnu_a__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VactExecute;
    // Body
    Vtb_mdpc_cnu_a___024root___eval_triggers_vec__act(vlSelf);
    Vtb_mdpc_cnu_a___024root___trigger_orInto__act_vec_vec(vlSelfRef.__VactTriggered, vlSelfRef.__VactTriggeredAcc);
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_mdpc_cnu_a___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
    }
#endif
    Vtb_mdpc_cnu_a___024root___trigger_orInto__act_vec_vec(vlSelfRef.__VnbaTriggered, vlSelfRef.__VactTriggered);
    __VactExecute = Vtb_mdpc_cnu_a___024root___trigger_anySet__act(vlSelfRef.__VactTriggered);
    if (__VactExecute) {
        vlSelfRef.__VactTriggeredAcc.fill(0ULL);
        Vtb_mdpc_cnu_a___024root___timing_resume(vlSelf);
        Vtb_mdpc_cnu_a___024root___eval_act(vlSelf);
    }
    return (__VactExecute);
}

bool Vtb_mdpc_cnu_a___024root___eval_phase__inact(Vtb_mdpc_cnu_a___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_a___024root___eval_phase__inact\n"); );
    Vtb_mdpc_cnu_a__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VinactExecute;
    // Body
    __VinactExecute = vlSelfRef.__VdlySched.awaitingZeroDelay();
    if (__VinactExecute) {
        VL_FATAL_MT("tb/tb_mdpc_cnu_a.sv", 5, "", "ZERODLY: Design Verilated with '--no-sched-zero-delay', but #0 delay executed at runtime");
    }
    return (__VinactExecute);
}

void Vtb_mdpc_cnu_a___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_a___024root___trigger_clear__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = 0ULL;
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

bool Vtb_mdpc_cnu_a___024root___eval_phase__nba(Vtb_mdpc_cnu_a___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_a___024root___eval_phase__nba\n"); );
    Vtb_mdpc_cnu_a__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = Vtb_mdpc_cnu_a___024root___trigger_anySet__act(vlSelfRef.__VnbaTriggered);
    if (__VnbaExecute) {
        Vtb_mdpc_cnu_a___024root___eval_nba(vlSelf);
        Vtb_mdpc_cnu_a___024root___trigger_clear__act(vlSelfRef.__VnbaTriggered);
    }
    return (__VnbaExecute);
}

void Vtb_mdpc_cnu_a___024root___eval(Vtb_mdpc_cnu_a___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_a___024root___eval\n"); );
    Vtb_mdpc_cnu_a__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VnbaIterCount;
    // Body
    __VnbaIterCount = 0U;
    do {
        if (VL_UNLIKELY(((0x00002710U < __VnbaIterCount)))) {
#ifdef VL_DEBUG
            Vtb_mdpc_cnu_a___024root___dump_triggers__act(vlSelfRef.__VnbaTriggered, "nba"s);
#endif
            VL_FATAL_MT("tb/tb_mdpc_cnu_a.sv", 5, "", "DIDNOTCONVERGE: NBA region did not converge after '--converge-limit' of 10000 tries");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        vlSelfRef.__VinactIterCount = 0U;
        do {
            if (VL_UNLIKELY(((0x00002710U < vlSelfRef.__VinactIterCount)))) {
                VL_FATAL_MT("tb/tb_mdpc_cnu_a.sv", 5, "", "DIDNOTCONVERGE: Inactive region did not converge after '--converge-limit' of 10000 tries");
            }
            vlSelfRef.__VinactIterCount = ((IData)(1U) 
                                           + vlSelfRef.__VinactIterCount);
            vlSelfRef.__VactIterCount = 0U;
            do {
                if (VL_UNLIKELY(((0x00002710U < vlSelfRef.__VactIterCount)))) {
#ifdef VL_DEBUG
                    Vtb_mdpc_cnu_a___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
#endif
                    VL_FATAL_MT("tb/tb_mdpc_cnu_a.sv", 5, "", "DIDNOTCONVERGE: Active region did not converge after '--converge-limit' of 10000 tries");
                }
                vlSelfRef.__VactIterCount = ((IData)(1U) 
                                             + vlSelfRef.__VactIterCount);
                vlSelfRef.__VactPhaseResult = Vtb_mdpc_cnu_a___024root___eval_phase__act(vlSelf);
            } while (vlSelfRef.__VactPhaseResult);
            vlSelfRef.__VinactPhaseResult = Vtb_mdpc_cnu_a___024root___eval_phase__inact(vlSelf);
        } while (vlSelfRef.__VinactPhaseResult);
        vlSelfRef.__VnbaPhaseResult = Vtb_mdpc_cnu_a___024root___eval_phase__nba(vlSelf);
    } while (vlSelfRef.__VnbaPhaseResult);
}

#ifdef VL_DEBUG
void Vtb_mdpc_cnu_a___024root___eval_debug_assertions(Vtb_mdpc_cnu_a___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_a___024root___eval_debug_assertions\n"); );
    Vtb_mdpc_cnu_a__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}
#endif  // VL_DEBUG
