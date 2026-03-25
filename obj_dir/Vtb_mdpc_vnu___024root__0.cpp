// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_mdpc_vnu.h for the primary calling header

#include "Vtb_mdpc_vnu__pch.h"

VlCoroutine Vtb_mdpc_vnu___024root___eval_initial__TOP__Vtiming__0(Vtb_mdpc_vnu___024root* vlSelf);

void Vtb_mdpc_vnu___024root___eval_initial(Vtb_mdpc_vnu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_vnu___024root___eval_initial\n"); );
    Vtb_mdpc_vnu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vtb_mdpc_vnu___024root___eval_initial__TOP__Vtiming__0(vlSelf);
}

VlCoroutine Vtb_mdpc_vnu___024root___eval_initial__TOP__Vtiming__0(Vtb_mdpc_vnu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_vnu___024root___eval_initial__TOP__Vtiming__0\n"); );
    Vtb_mdpc_vnu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*4:0*/ tb_mdpc_vnu__DOT____VlemCall_11__msg_from_signed;
    CData/*4:0*/ tb_mdpc_vnu__DOT____VlemCall_10__msg_from_signed;
    CData/*4:0*/ tb_mdpc_vnu__DOT____VlemCall_9__msg_from_signed;
    CData/*4:0*/ tb_mdpc_vnu__DOT____VlemCall_2__msg_from_signed;
    CData/*4:0*/ tb_mdpc_vnu__DOT____VlemCall_1__msg_from_signed;
    CData/*4:0*/ tb_mdpc_vnu__DOT____VlemCall_0__msg_from_signed;
    CData/*3:0*/ __Vfunc_msg_from_signed__0____VlefCall_0__mag_from_int;
    __Vfunc_msg_from_signed__0____VlefCall_0__mag_from_int = 0;
    CData/*4:0*/ __Vfunc_msg_from_signed__0__msg;
    __Vfunc_msg_from_signed__0__msg = 0;
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
    CData/*4:0*/ __Vfunc_msg_pack__3__Vfuncout;
    __Vfunc_msg_pack__3__Vfuncout = 0;
    CData/*3:0*/ __Vfunc_msg_pack__3__mag;
    __Vfunc_msg_pack__3__mag = 0;
    CData/*3:0*/ __Vfunc_msg_from_signed__4____VlefCall_0__mag_from_int;
    __Vfunc_msg_from_signed__4____VlefCall_0__mag_from_int = 0;
    CData/*4:0*/ __Vfunc_msg_from_signed__4__msg;
    __Vfunc_msg_from_signed__4__msg = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__5__Vfuncout;
    __Vfunc_mag_from_int__5__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_mag_from_int__5__clamped_value;
    __Vfunc_mag_from_int__5__clamped_value = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__5__result;
    __Vfunc_mag_from_int__5__result = 0;
    IData/*31:0*/ __Vfunc_clamp_int__6__Vfuncout;
    __Vfunc_clamp_int__6__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_clamp_int__6__value;
    __Vfunc_clamp_int__6__value = 0;
    IData/*31:0*/ __Vfunc_clamp_int__6__lo;
    __Vfunc_clamp_int__6__lo = 0;
    IData/*31:0*/ __Vfunc_clamp_int__6__hi;
    __Vfunc_clamp_int__6__hi = 0;
    CData/*4:0*/ __Vfunc_msg_pack__7__Vfuncout;
    __Vfunc_msg_pack__7__Vfuncout = 0;
    CData/*3:0*/ __Vfunc_msg_pack__7__mag;
    __Vfunc_msg_pack__7__mag = 0;
    CData/*3:0*/ __Vfunc_msg_from_signed__8____VlefCall_0__mag_from_int;
    __Vfunc_msg_from_signed__8____VlefCall_0__mag_from_int = 0;
    CData/*4:0*/ __Vfunc_msg_from_signed__8__msg;
    __Vfunc_msg_from_signed__8__msg = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__9__Vfuncout;
    __Vfunc_mag_from_int__9__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_mag_from_int__9__clamped_value;
    __Vfunc_mag_from_int__9__clamped_value = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__9__result;
    __Vfunc_mag_from_int__9__result = 0;
    IData/*31:0*/ __Vfunc_clamp_int__10__Vfuncout;
    __Vfunc_clamp_int__10__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_clamp_int__10__value;
    __Vfunc_clamp_int__10__value = 0;
    IData/*31:0*/ __Vfunc_clamp_int__10__lo;
    __Vfunc_clamp_int__10__lo = 0;
    IData/*31:0*/ __Vfunc_clamp_int__10__hi;
    __Vfunc_clamp_int__10__hi = 0;
    CData/*4:0*/ __Vfunc_msg_pack__11__Vfuncout;
    __Vfunc_msg_pack__11__Vfuncout = 0;
    CData/*3:0*/ __Vfunc_msg_pack__11__mag;
    __Vfunc_msg_pack__11__mag = 0;
    CData/*4:0*/ __Vfunc_msg_to_signed__12__msg;
    __Vfunc_msg_to_signed__12__msg = 0;
    CData/*0:0*/ __Vfunc_msg_to_signed__12____VlefCall_1__msg_sign;
    __Vfunc_msg_to_signed__12____VlefCall_1__msg_sign = 0;
    CData/*3:0*/ __Vfunc_msg_to_signed__12____VlefCall_0__msg_mag;
    __Vfunc_msg_to_signed__12____VlefCall_0__msg_mag = 0;
    IData/*31:0*/ __Vfunc_msg_to_signed__12__mag_value;
    __Vfunc_msg_to_signed__12__mag_value = 0;
    CData/*3:0*/ __Vfunc_msg_mag__13__Vfuncout;
    __Vfunc_msg_mag__13__Vfuncout = 0;
    CData/*4:0*/ __Vfunc_msg_mag__13__msg;
    __Vfunc_msg_mag__13__msg = 0;
    CData/*0:0*/ __Vfunc_msg_sign__14__Vfuncout;
    __Vfunc_msg_sign__14__Vfuncout = 0;
    CData/*4:0*/ __Vfunc_msg_sign__14__msg;
    __Vfunc_msg_sign__14__msg = 0;
    CData/*4:0*/ __Vfunc_msg_to_signed__15__msg;
    __Vfunc_msg_to_signed__15__msg = 0;
    CData/*0:0*/ __Vfunc_msg_to_signed__15____VlefCall_1__msg_sign;
    __Vfunc_msg_to_signed__15____VlefCall_1__msg_sign = 0;
    CData/*3:0*/ __Vfunc_msg_to_signed__15____VlefCall_0__msg_mag;
    __Vfunc_msg_to_signed__15____VlefCall_0__msg_mag = 0;
    IData/*31:0*/ __Vfunc_msg_to_signed__15__mag_value;
    __Vfunc_msg_to_signed__15__mag_value = 0;
    CData/*3:0*/ __Vfunc_msg_mag__16__Vfuncout;
    __Vfunc_msg_mag__16__Vfuncout = 0;
    CData/*4:0*/ __Vfunc_msg_mag__16__msg;
    __Vfunc_msg_mag__16__msg = 0;
    CData/*0:0*/ __Vfunc_msg_sign__17__Vfuncout;
    __Vfunc_msg_sign__17__Vfuncout = 0;
    CData/*4:0*/ __Vfunc_msg_sign__17__msg;
    __Vfunc_msg_sign__17__msg = 0;
    CData/*4:0*/ __Vfunc_msg_to_signed__18__msg;
    __Vfunc_msg_to_signed__18__msg = 0;
    CData/*0:0*/ __Vfunc_msg_to_signed__18____VlefCall_1__msg_sign;
    __Vfunc_msg_to_signed__18____VlefCall_1__msg_sign = 0;
    CData/*3:0*/ __Vfunc_msg_to_signed__18____VlefCall_0__msg_mag;
    __Vfunc_msg_to_signed__18____VlefCall_0__msg_mag = 0;
    IData/*31:0*/ __Vfunc_msg_to_signed__18__mag_value;
    __Vfunc_msg_to_signed__18__mag_value = 0;
    CData/*3:0*/ __Vfunc_msg_mag__19__Vfuncout;
    __Vfunc_msg_mag__19__Vfuncout = 0;
    CData/*4:0*/ __Vfunc_msg_mag__19__msg;
    __Vfunc_msg_mag__19__msg = 0;
    CData/*0:0*/ __Vfunc_msg_sign__20__Vfuncout;
    __Vfunc_msg_sign__20__Vfuncout = 0;
    CData/*4:0*/ __Vfunc_msg_sign__20__msg;
    __Vfunc_msg_sign__20__msg = 0;
    CData/*4:0*/ __Vfunc_msg_to_signed__21__msg;
    __Vfunc_msg_to_signed__21__msg = 0;
    CData/*0:0*/ __Vfunc_msg_to_signed__21____VlefCall_1__msg_sign;
    __Vfunc_msg_to_signed__21____VlefCall_1__msg_sign = 0;
    CData/*3:0*/ __Vfunc_msg_to_signed__21____VlefCall_0__msg_mag;
    __Vfunc_msg_to_signed__21____VlefCall_0__msg_mag = 0;
    IData/*31:0*/ __Vfunc_msg_to_signed__21__mag_value;
    __Vfunc_msg_to_signed__21__mag_value = 0;
    CData/*3:0*/ __Vfunc_msg_mag__22__Vfuncout;
    __Vfunc_msg_mag__22__Vfuncout = 0;
    CData/*4:0*/ __Vfunc_msg_mag__22__msg;
    __Vfunc_msg_mag__22__msg = 0;
    CData/*0:0*/ __Vfunc_msg_sign__23__Vfuncout;
    __Vfunc_msg_sign__23__Vfuncout = 0;
    CData/*4:0*/ __Vfunc_msg_sign__23__msg;
    __Vfunc_msg_sign__23__msg = 0;
    CData/*4:0*/ __Vfunc_msg_to_signed__24__msg;
    __Vfunc_msg_to_signed__24__msg = 0;
    CData/*0:0*/ __Vfunc_msg_to_signed__24____VlefCall_1__msg_sign;
    __Vfunc_msg_to_signed__24____VlefCall_1__msg_sign = 0;
    CData/*3:0*/ __Vfunc_msg_to_signed__24____VlefCall_0__msg_mag;
    __Vfunc_msg_to_signed__24____VlefCall_0__msg_mag = 0;
    IData/*31:0*/ __Vfunc_msg_to_signed__24__mag_value;
    __Vfunc_msg_to_signed__24__mag_value = 0;
    CData/*3:0*/ __Vfunc_msg_mag__25__Vfuncout;
    __Vfunc_msg_mag__25__Vfuncout = 0;
    CData/*4:0*/ __Vfunc_msg_mag__25__msg;
    __Vfunc_msg_mag__25__msg = 0;
    CData/*0:0*/ __Vfunc_msg_sign__26__Vfuncout;
    __Vfunc_msg_sign__26__Vfuncout = 0;
    CData/*4:0*/ __Vfunc_msg_sign__26__msg;
    __Vfunc_msg_sign__26__msg = 0;
    CData/*4:0*/ __Vfunc_msg_to_signed__27__msg;
    __Vfunc_msg_to_signed__27__msg = 0;
    CData/*0:0*/ __Vfunc_msg_to_signed__27____VlefCall_1__msg_sign;
    __Vfunc_msg_to_signed__27____VlefCall_1__msg_sign = 0;
    CData/*3:0*/ __Vfunc_msg_to_signed__27____VlefCall_0__msg_mag;
    __Vfunc_msg_to_signed__27____VlefCall_0__msg_mag = 0;
    IData/*31:0*/ __Vfunc_msg_to_signed__27__mag_value;
    __Vfunc_msg_to_signed__27__mag_value = 0;
    CData/*3:0*/ __Vfunc_msg_mag__28__Vfuncout;
    __Vfunc_msg_mag__28__Vfuncout = 0;
    CData/*4:0*/ __Vfunc_msg_mag__28__msg;
    __Vfunc_msg_mag__28__msg = 0;
    CData/*0:0*/ __Vfunc_msg_sign__29__Vfuncout;
    __Vfunc_msg_sign__29__Vfuncout = 0;
    CData/*4:0*/ __Vfunc_msg_sign__29__msg;
    __Vfunc_msg_sign__29__msg = 0;
    IData/*31:0*/ __Vfunc_msg_from_signed__30__value;
    __Vfunc_msg_from_signed__30__value = 0;
    CData/*3:0*/ __Vfunc_msg_from_signed__30____VlefCall_0__mag_from_int;
    __Vfunc_msg_from_signed__30____VlefCall_0__mag_from_int = 0;
    CData/*4:0*/ __Vfunc_msg_from_signed__30__msg;
    __Vfunc_msg_from_signed__30__msg = 0;
    IData/*31:0*/ __Vfunc_msg_from_signed__30__abs_value;
    __Vfunc_msg_from_signed__30__abs_value = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__31__Vfuncout;
    __Vfunc_mag_from_int__31__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_mag_from_int__31__value;
    __Vfunc_mag_from_int__31__value = 0;
    IData/*31:0*/ __Vfunc_mag_from_int__31__clamped_value;
    __Vfunc_mag_from_int__31__clamped_value = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__31__result;
    __Vfunc_mag_from_int__31__result = 0;
    IData/*31:0*/ __Vfunc_clamp_int__32__Vfuncout;
    __Vfunc_clamp_int__32__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_clamp_int__32__value;
    __Vfunc_clamp_int__32__value = 0;
    IData/*31:0*/ __Vfunc_clamp_int__32__lo;
    __Vfunc_clamp_int__32__lo = 0;
    IData/*31:0*/ __Vfunc_clamp_int__32__hi;
    __Vfunc_clamp_int__32__hi = 0;
    CData/*4:0*/ __Vfunc_msg_pack__33__Vfuncout;
    __Vfunc_msg_pack__33__Vfuncout = 0;
    CData/*0:0*/ __Vfunc_msg_pack__33__sign;
    __Vfunc_msg_pack__33__sign = 0;
    CData/*3:0*/ __Vfunc_msg_pack__33__mag;
    __Vfunc_msg_pack__33__mag = 0;
    IData/*31:0*/ __Vfunc_msg_from_signed__34__value;
    __Vfunc_msg_from_signed__34__value = 0;
    CData/*3:0*/ __Vfunc_msg_from_signed__34____VlefCall_0__mag_from_int;
    __Vfunc_msg_from_signed__34____VlefCall_0__mag_from_int = 0;
    CData/*4:0*/ __Vfunc_msg_from_signed__34__msg;
    __Vfunc_msg_from_signed__34__msg = 0;
    IData/*31:0*/ __Vfunc_msg_from_signed__34__abs_value;
    __Vfunc_msg_from_signed__34__abs_value = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__35__Vfuncout;
    __Vfunc_mag_from_int__35__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_mag_from_int__35__value;
    __Vfunc_mag_from_int__35__value = 0;
    IData/*31:0*/ __Vfunc_mag_from_int__35__clamped_value;
    __Vfunc_mag_from_int__35__clamped_value = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__35__result;
    __Vfunc_mag_from_int__35__result = 0;
    IData/*31:0*/ __Vfunc_clamp_int__36__Vfuncout;
    __Vfunc_clamp_int__36__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_clamp_int__36__value;
    __Vfunc_clamp_int__36__value = 0;
    IData/*31:0*/ __Vfunc_clamp_int__36__lo;
    __Vfunc_clamp_int__36__lo = 0;
    IData/*31:0*/ __Vfunc_clamp_int__36__hi;
    __Vfunc_clamp_int__36__hi = 0;
    CData/*4:0*/ __Vfunc_msg_pack__37__Vfuncout;
    __Vfunc_msg_pack__37__Vfuncout = 0;
    CData/*0:0*/ __Vfunc_msg_pack__37__sign;
    __Vfunc_msg_pack__37__sign = 0;
    CData/*3:0*/ __Vfunc_msg_pack__37__mag;
    __Vfunc_msg_pack__37__mag = 0;
    IData/*31:0*/ __Vfunc_msg_from_signed__38__value;
    __Vfunc_msg_from_signed__38__value = 0;
    CData/*3:0*/ __Vfunc_msg_from_signed__38____VlefCall_0__mag_from_int;
    __Vfunc_msg_from_signed__38____VlefCall_0__mag_from_int = 0;
    CData/*4:0*/ __Vfunc_msg_from_signed__38__msg;
    __Vfunc_msg_from_signed__38__msg = 0;
    IData/*31:0*/ __Vfunc_msg_from_signed__38__abs_value;
    __Vfunc_msg_from_signed__38__abs_value = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__39__Vfuncout;
    __Vfunc_mag_from_int__39__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_mag_from_int__39__value;
    __Vfunc_mag_from_int__39__value = 0;
    IData/*31:0*/ __Vfunc_mag_from_int__39__clamped_value;
    __Vfunc_mag_from_int__39__clamped_value = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__39__result;
    __Vfunc_mag_from_int__39__result = 0;
    IData/*31:0*/ __Vfunc_clamp_int__40__Vfuncout;
    __Vfunc_clamp_int__40__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_clamp_int__40__value;
    __Vfunc_clamp_int__40__value = 0;
    IData/*31:0*/ __Vfunc_clamp_int__40__lo;
    __Vfunc_clamp_int__40__lo = 0;
    IData/*31:0*/ __Vfunc_clamp_int__40__hi;
    __Vfunc_clamp_int__40__hi = 0;
    CData/*4:0*/ __Vfunc_msg_pack__41__Vfuncout;
    __Vfunc_msg_pack__41__Vfuncout = 0;
    CData/*0:0*/ __Vfunc_msg_pack__41__sign;
    __Vfunc_msg_pack__41__sign = 0;
    CData/*3:0*/ __Vfunc_msg_pack__41__mag;
    __Vfunc_msg_pack__41__mag = 0;
    CData/*4:0*/ __Vfunc_msg_to_signed__42__msg;
    __Vfunc_msg_to_signed__42__msg = 0;
    CData/*0:0*/ __Vfunc_msg_to_signed__42____VlefCall_1__msg_sign;
    __Vfunc_msg_to_signed__42____VlefCall_1__msg_sign = 0;
    CData/*3:0*/ __Vfunc_msg_to_signed__42____VlefCall_0__msg_mag;
    __Vfunc_msg_to_signed__42____VlefCall_0__msg_mag = 0;
    IData/*31:0*/ __Vfunc_msg_to_signed__42__mag_value;
    __Vfunc_msg_to_signed__42__mag_value = 0;
    CData/*3:0*/ __Vfunc_msg_mag__43__Vfuncout;
    __Vfunc_msg_mag__43__Vfuncout = 0;
    CData/*4:0*/ __Vfunc_msg_mag__43__msg;
    __Vfunc_msg_mag__43__msg = 0;
    CData/*0:0*/ __Vfunc_msg_sign__44__Vfuncout;
    __Vfunc_msg_sign__44__Vfuncout = 0;
    CData/*4:0*/ __Vfunc_msg_sign__44__msg;
    __Vfunc_msg_sign__44__msg = 0;
    CData/*4:0*/ __Vfunc_msg_to_signed__45__msg;
    __Vfunc_msg_to_signed__45__msg = 0;
    CData/*0:0*/ __Vfunc_msg_to_signed__45____VlefCall_1__msg_sign;
    __Vfunc_msg_to_signed__45____VlefCall_1__msg_sign = 0;
    CData/*3:0*/ __Vfunc_msg_to_signed__45____VlefCall_0__msg_mag;
    __Vfunc_msg_to_signed__45____VlefCall_0__msg_mag = 0;
    IData/*31:0*/ __Vfunc_msg_to_signed__45__mag_value;
    __Vfunc_msg_to_signed__45__mag_value = 0;
    CData/*3:0*/ __Vfunc_msg_mag__46__Vfuncout;
    __Vfunc_msg_mag__46__Vfuncout = 0;
    CData/*4:0*/ __Vfunc_msg_mag__46__msg;
    __Vfunc_msg_mag__46__msg = 0;
    CData/*0:0*/ __Vfunc_msg_sign__47__Vfuncout;
    __Vfunc_msg_sign__47__Vfuncout = 0;
    CData/*4:0*/ __Vfunc_msg_sign__47__msg;
    __Vfunc_msg_sign__47__msg = 0;
    CData/*4:0*/ __Vfunc_msg_to_signed__48__msg;
    __Vfunc_msg_to_signed__48__msg = 0;
    CData/*0:0*/ __Vfunc_msg_to_signed__48____VlefCall_1__msg_sign;
    __Vfunc_msg_to_signed__48____VlefCall_1__msg_sign = 0;
    CData/*3:0*/ __Vfunc_msg_to_signed__48____VlefCall_0__msg_mag;
    __Vfunc_msg_to_signed__48____VlefCall_0__msg_mag = 0;
    IData/*31:0*/ __Vfunc_msg_to_signed__48__mag_value;
    __Vfunc_msg_to_signed__48__mag_value = 0;
    CData/*3:0*/ __Vfunc_msg_mag__49__Vfuncout;
    __Vfunc_msg_mag__49__Vfuncout = 0;
    CData/*4:0*/ __Vfunc_msg_mag__49__msg;
    __Vfunc_msg_mag__49__msg = 0;
    CData/*0:0*/ __Vfunc_msg_sign__50__Vfuncout;
    __Vfunc_msg_sign__50__Vfuncout = 0;
    CData/*4:0*/ __Vfunc_msg_sign__50__msg;
    __Vfunc_msg_sign__50__msg = 0;
    CData/*4:0*/ __Vfunc_msg_to_signed__51__msg;
    __Vfunc_msg_to_signed__51__msg = 0;
    CData/*0:0*/ __Vfunc_msg_to_signed__51____VlefCall_1__msg_sign;
    __Vfunc_msg_to_signed__51____VlefCall_1__msg_sign = 0;
    CData/*3:0*/ __Vfunc_msg_to_signed__51____VlefCall_0__msg_mag;
    __Vfunc_msg_to_signed__51____VlefCall_0__msg_mag = 0;
    IData/*31:0*/ __Vfunc_msg_to_signed__51__mag_value;
    __Vfunc_msg_to_signed__51__mag_value = 0;
    CData/*3:0*/ __Vfunc_msg_mag__52__Vfuncout;
    __Vfunc_msg_mag__52__Vfuncout = 0;
    CData/*4:0*/ __Vfunc_msg_mag__52__msg;
    __Vfunc_msg_mag__52__msg = 0;
    CData/*0:0*/ __Vfunc_msg_sign__53__Vfuncout;
    __Vfunc_msg_sign__53__Vfuncout = 0;
    CData/*4:0*/ __Vfunc_msg_sign__53__msg;
    __Vfunc_msg_sign__53__msg = 0;
    CData/*4:0*/ __Vfunc_msg_to_signed__54__msg;
    __Vfunc_msg_to_signed__54__msg = 0;
    CData/*0:0*/ __Vfunc_msg_to_signed__54____VlefCall_1__msg_sign;
    __Vfunc_msg_to_signed__54____VlefCall_1__msg_sign = 0;
    CData/*3:0*/ __Vfunc_msg_to_signed__54____VlefCall_0__msg_mag;
    __Vfunc_msg_to_signed__54____VlefCall_0__msg_mag = 0;
    IData/*31:0*/ __Vfunc_msg_to_signed__54__mag_value;
    __Vfunc_msg_to_signed__54__mag_value = 0;
    CData/*3:0*/ __Vfunc_msg_mag__55__Vfuncout;
    __Vfunc_msg_mag__55__Vfuncout = 0;
    CData/*4:0*/ __Vfunc_msg_mag__55__msg;
    __Vfunc_msg_mag__55__msg = 0;
    CData/*0:0*/ __Vfunc_msg_sign__56__Vfuncout;
    __Vfunc_msg_sign__56__Vfuncout = 0;
    CData/*4:0*/ __Vfunc_msg_sign__56__msg;
    __Vfunc_msg_sign__56__msg = 0;
    CData/*4:0*/ __Vfunc_msg_to_signed__57__msg;
    __Vfunc_msg_to_signed__57__msg = 0;
    CData/*0:0*/ __Vfunc_msg_to_signed__57____VlefCall_1__msg_sign;
    __Vfunc_msg_to_signed__57____VlefCall_1__msg_sign = 0;
    CData/*3:0*/ __Vfunc_msg_to_signed__57____VlefCall_0__msg_mag;
    __Vfunc_msg_to_signed__57____VlefCall_0__msg_mag = 0;
    IData/*31:0*/ __Vfunc_msg_to_signed__57__mag_value;
    __Vfunc_msg_to_signed__57__mag_value = 0;
    CData/*3:0*/ __Vfunc_msg_mag__58__Vfuncout;
    __Vfunc_msg_mag__58__Vfuncout = 0;
    CData/*4:0*/ __Vfunc_msg_mag__58__msg;
    __Vfunc_msg_mag__58__msg = 0;
    CData/*0:0*/ __Vfunc_msg_sign__59__Vfuncout;
    __Vfunc_msg_sign__59__Vfuncout = 0;
    CData/*4:0*/ __Vfunc_msg_sign__59__msg;
    __Vfunc_msg_sign__59__msg = 0;
    // Body
    vlSelfRef.tb_mdpc_vnu__DOT__gamma_in = 9U;
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
    __Vfunc_msg_from_signed__0____VlefCall_0__mag_from_int 
        = __Vfunc_mag_from_int__1__Vfuncout;
    __Vfunc_msg_pack__3__mag = __Vfunc_msg_from_signed__0____VlefCall_0__mag_from_int;
    __Vfunc_msg_pack__3__Vfuncout = __Vfunc_msg_pack__3__mag;
    __Vfunc_msg_from_signed__0__msg = __Vfunc_msg_pack__3__Vfuncout;
    tb_mdpc_vnu__DOT____VlemCall_0__msg_from_signed 
        = __Vfunc_msg_from_signed__0__msg;
    vlSelfRef.tb_mdpc_vnu__DOT__c2v_in[0U] = tb_mdpc_vnu__DOT____VlemCall_0__msg_from_signed;
    __Vfunc_clamp_int__6__hi = 0x0000000fU;
    __Vfunc_clamp_int__6__lo = 0U;
    __Vfunc_clamp_int__6__value = 0x0000000fU;
    {
        __Vfunc_clamp_int__6__Vfuncout = 0U;
        if (VL_LTS_III(32, __Vfunc_clamp_int__6__value, __Vfunc_clamp_int__6__lo)) {
            __Vfunc_clamp_int__6__Vfuncout = __Vfunc_clamp_int__6__lo;
            goto __Vlabel1;
        }
        if (VL_GTS_III(32, __Vfunc_clamp_int__6__value, __Vfunc_clamp_int__6__hi)) {
            __Vfunc_clamp_int__6__Vfuncout = __Vfunc_clamp_int__6__hi;
            goto __Vlabel1;
        }
        __Vfunc_clamp_int__6__Vfuncout = __Vfunc_clamp_int__6__value;
        __Vlabel1: ;
    }
    __Vfunc_mag_from_int__5__clamped_value = __Vfunc_clamp_int__6__Vfuncout;
    __Vfunc_mag_from_int__5__result = (0x0000000fU 
                                       & __Vfunc_mag_from_int__5__clamped_value);
    __Vfunc_mag_from_int__5__Vfuncout = __Vfunc_mag_from_int__5__result;
    __Vfunc_msg_from_signed__4____VlefCall_0__mag_from_int 
        = __Vfunc_mag_from_int__5__Vfuncout;
    __Vfunc_msg_pack__7__mag = __Vfunc_msg_from_signed__4____VlefCall_0__mag_from_int;
    __Vfunc_msg_pack__7__Vfuncout = __Vfunc_msg_pack__7__mag;
    __Vfunc_msg_from_signed__4__msg = __Vfunc_msg_pack__7__Vfuncout;
    tb_mdpc_vnu__DOT____VlemCall_1__msg_from_signed 
        = __Vfunc_msg_from_signed__4__msg;
    vlSelfRef.tb_mdpc_vnu__DOT__c2v_in[1U] = tb_mdpc_vnu__DOT____VlemCall_1__msg_from_signed;
    __Vfunc_clamp_int__10__hi = 0x0000000fU;
    __Vfunc_clamp_int__10__lo = 0U;
    __Vfunc_clamp_int__10__value = 9U;
    {
        __Vfunc_clamp_int__10__Vfuncout = 0U;
        if (VL_LTS_III(32, __Vfunc_clamp_int__10__value, __Vfunc_clamp_int__10__lo)) {
            __Vfunc_clamp_int__10__Vfuncout = __Vfunc_clamp_int__10__lo;
            goto __Vlabel2;
        }
        if (VL_GTS_III(32, __Vfunc_clamp_int__10__value, __Vfunc_clamp_int__10__hi)) {
            __Vfunc_clamp_int__10__Vfuncout = __Vfunc_clamp_int__10__hi;
            goto __Vlabel2;
        }
        __Vfunc_clamp_int__10__Vfuncout = __Vfunc_clamp_int__10__value;
        __Vlabel2: ;
    }
    __Vfunc_mag_from_int__9__clamped_value = __Vfunc_clamp_int__10__Vfuncout;
    __Vfunc_mag_from_int__9__result = (0x0000000fU 
                                       & __Vfunc_mag_from_int__9__clamped_value);
    __Vfunc_mag_from_int__9__Vfuncout = __Vfunc_mag_from_int__9__result;
    __Vfunc_msg_from_signed__8____VlefCall_0__mag_from_int 
        = __Vfunc_mag_from_int__9__Vfuncout;
    __Vfunc_msg_pack__11__mag = __Vfunc_msg_from_signed__8____VlefCall_0__mag_from_int;
    __Vfunc_msg_pack__11__Vfuncout = (0x00000010U | (IData)(__Vfunc_msg_pack__11__mag));
    __Vfunc_msg_from_signed__8__msg = __Vfunc_msg_pack__11__Vfuncout;
    tb_mdpc_vnu__DOT____VlemCall_2__msg_from_signed 
        = __Vfunc_msg_from_signed__8__msg;
    vlSelfRef.tb_mdpc_vnu__DOT__c2v_in[2U] = tb_mdpc_vnu__DOT____VlemCall_2__msg_from_signed;
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "tb/tb_mdpc_vnu.sv", 
                                         25);
    if (VL_UNLIKELY(((0x0000000bU != VL_EXTENDS_II(32,8, (IData)(vlSelfRef.tb_mdpc_vnu__DOT__app_out)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_vnu.sv:26: Assertion failed in %m: app_out mismatch: got %0d exp 11\n",4, 'M',vlSymsp->name(),"tb_mdpc_vnu", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '~',8,(IData)(vlSelfRef.tb_mdpc_vnu__DOT__app_out));
        VL_STOP_MT("tb/tb_mdpc_vnu.sv", 26, "", false);
    }
    __Vfunc_msg_to_signed__12__msg = vlSelfRef.tb_mdpc_vnu__DOT__u_next_out[0U];
    if (VL_UNLIKELY((vlSelfRef.tb_mdpc_vnu__DOT__x_out))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_vnu.sv:27: Assertion failed in %m: x_out mismatch: got %0d exp 0\n",4, 'M',vlSymsp->name(),"tb_mdpc_vnu", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',1,(IData)(vlSelfRef.tb_mdpc_vnu__DOT__x_out));
        VL_STOP_MT("tb/tb_mdpc_vnu.sv", 27, "", false);
    }
    {
        vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_3__msg_to_signed = 0U;
        __Vfunc_msg_to_signed__12__mag_value = 0U;
        __Vfunc_msg_mag__13__msg = __Vfunc_msg_to_signed__12__msg;
        __Vfunc_msg_mag__13__Vfuncout = 0;
        __Vfunc_msg_mag__13__Vfuncout = (0x0000000fU 
                                         & (IData)(__Vfunc_msg_mag__13__msg));
        __Vfunc_msg_to_signed__12____VlefCall_0__msg_mag 
            = __Vfunc_msg_mag__13__Vfuncout;
        __Vfunc_msg_to_signed__12__mag_value = __Vfunc_msg_to_signed__12____VlefCall_0__msg_mag;
        __Vfunc_msg_sign__14__msg = __Vfunc_msg_to_signed__12__msg;
        __Vfunc_msg_sign__14__Vfuncout = 0;
        __Vfunc_msg_sign__14__Vfuncout = (1U & ((IData)(__Vfunc_msg_sign__14__msg) 
                                                >> 4U));
        __Vfunc_msg_to_signed__12____VlefCall_1__msg_sign 
            = __Vfunc_msg_sign__14__Vfuncout;
        if (__Vfunc_msg_to_signed__12____VlefCall_1__msg_sign) {
            vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_3__msg_to_signed 
                = (- __Vfunc_msg_to_signed__12__mag_value);
            goto __Vlabel3;
        }
        vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_3__msg_to_signed 
            = __Vfunc_msg_to_signed__12__mag_value;
        __Vlabel3: ;
    }
    if (VL_UNLIKELY(((0x0000000aU != vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_3__msg_to_signed)))) {
        __Vfunc_msg_to_signed__15__msg = vlSelfRef.tb_mdpc_vnu__DOT__u_next_out[0U];
        {
            vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_4__msg_to_signed = 0U;
            __Vfunc_msg_to_signed__15__mag_value = 0U;
            __Vfunc_msg_mag__16__msg = __Vfunc_msg_to_signed__15__msg;
            __Vfunc_msg_mag__16__Vfuncout = 0;
            __Vfunc_msg_mag__16__Vfuncout = (0x0000000fU 
                                             & (IData)(__Vfunc_msg_mag__16__msg));
            __Vfunc_msg_to_signed__15____VlefCall_0__msg_mag 
                = __Vfunc_msg_mag__16__Vfuncout;
            __Vfunc_msg_to_signed__15__mag_value = __Vfunc_msg_to_signed__15____VlefCall_0__msg_mag;
            __Vfunc_msg_sign__17__msg = __Vfunc_msg_to_signed__15__msg;
            __Vfunc_msg_sign__17__Vfuncout = 0;
            __Vfunc_msg_sign__17__Vfuncout = (1U & 
                                              ((IData)(__Vfunc_msg_sign__17__msg) 
                                               >> 4U));
            __Vfunc_msg_to_signed__15____VlefCall_1__msg_sign 
                = __Vfunc_msg_sign__17__Vfuncout;
            if (__Vfunc_msg_to_signed__15____VlefCall_1__msg_sign) {
                vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_4__msg_to_signed 
                    = (- __Vfunc_msg_to_signed__15__mag_value);
                goto __Vlabel4;
            }
            vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_4__msg_to_signed 
                = __Vfunc_msg_to_signed__15__mag_value;
            __Vlabel4: ;
        }
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_vnu.sv:28: Assertion failed in %m: u_next[0] mismatch: got %0d exp 10\n",4, 'M',vlSymsp->name(),"tb_mdpc_vnu", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '~',32,vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_4__msg_to_signed);
        VL_STOP_MT("tb/tb_mdpc_vnu.sv", 28, "", false);
    }
    __Vfunc_msg_to_signed__18__msg = vlSelfRef.tb_mdpc_vnu__DOT__u_next_out[1U];
    {
        vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_5__msg_to_signed = 0U;
        __Vfunc_msg_to_signed__18__mag_value = 0U;
        __Vfunc_msg_mag__19__msg = __Vfunc_msg_to_signed__18__msg;
        __Vfunc_msg_mag__19__Vfuncout = 0;
        __Vfunc_msg_mag__19__Vfuncout = (0x0000000fU 
                                         & (IData)(__Vfunc_msg_mag__19__msg));
        __Vfunc_msg_to_signed__18____VlefCall_0__msg_mag 
            = __Vfunc_msg_mag__19__Vfuncout;
        __Vfunc_msg_to_signed__18__mag_value = __Vfunc_msg_to_signed__18____VlefCall_0__msg_mag;
        __Vfunc_msg_sign__20__msg = __Vfunc_msg_to_signed__18__msg;
        __Vfunc_msg_sign__20__Vfuncout = 0;
        __Vfunc_msg_sign__20__Vfuncout = (1U & ((IData)(__Vfunc_msg_sign__20__msg) 
                                                >> 4U));
        __Vfunc_msg_to_signed__18____VlefCall_1__msg_sign 
            = __Vfunc_msg_sign__20__Vfuncout;
        if (__Vfunc_msg_to_signed__18____VlefCall_1__msg_sign) {
            vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_5__msg_to_signed 
                = (- __Vfunc_msg_to_signed__18__mag_value);
            goto __Vlabel5;
        }
        vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_5__msg_to_signed 
            = __Vfunc_msg_to_signed__18__mag_value;
        __Vlabel5: ;
    }
    if (VL_UNLIKELY(((0x0000000aU != vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_5__msg_to_signed)))) {
        __Vfunc_msg_to_signed__21__msg = vlSelfRef.tb_mdpc_vnu__DOT__u_next_out[1U];
        {
            vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_6__msg_to_signed = 0U;
            __Vfunc_msg_to_signed__21__mag_value = 0U;
            __Vfunc_msg_mag__22__msg = __Vfunc_msg_to_signed__21__msg;
            __Vfunc_msg_mag__22__Vfuncout = 0;
            __Vfunc_msg_mag__22__Vfuncout = (0x0000000fU 
                                             & (IData)(__Vfunc_msg_mag__22__msg));
            __Vfunc_msg_to_signed__21____VlefCall_0__msg_mag 
                = __Vfunc_msg_mag__22__Vfuncout;
            __Vfunc_msg_to_signed__21__mag_value = __Vfunc_msg_to_signed__21____VlefCall_0__msg_mag;
            __Vfunc_msg_sign__23__msg = __Vfunc_msg_to_signed__21__msg;
            __Vfunc_msg_sign__23__Vfuncout = 0;
            __Vfunc_msg_sign__23__Vfuncout = (1U & 
                                              ((IData)(__Vfunc_msg_sign__23__msg) 
                                               >> 4U));
            __Vfunc_msg_to_signed__21____VlefCall_1__msg_sign 
                = __Vfunc_msg_sign__23__Vfuncout;
            if (__Vfunc_msg_to_signed__21____VlefCall_1__msg_sign) {
                vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_6__msg_to_signed 
                    = (- __Vfunc_msg_to_signed__21__mag_value);
                goto __Vlabel6;
            }
            vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_6__msg_to_signed 
                = __Vfunc_msg_to_signed__21__mag_value;
            __Vlabel6: ;
        }
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_vnu.sv:29: Assertion failed in %m: u_next[1] mismatch: got %0d exp 10\n",4, 'M',vlSymsp->name(),"tb_mdpc_vnu", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '~',32,vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_6__msg_to_signed);
        VL_STOP_MT("tb/tb_mdpc_vnu.sv", 29, "", false);
    }
    __Vfunc_msg_to_signed__24__msg = vlSelfRef.tb_mdpc_vnu__DOT__u_next_out[2U];
    {
        vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_7__msg_to_signed = 0U;
        __Vfunc_msg_to_signed__24__mag_value = 0U;
        __Vfunc_msg_mag__25__msg = __Vfunc_msg_to_signed__24__msg;
        __Vfunc_msg_mag__25__Vfuncout = 0;
        __Vfunc_msg_mag__25__Vfuncout = (0x0000000fU 
                                         & (IData)(__Vfunc_msg_mag__25__msg));
        __Vfunc_msg_to_signed__24____VlefCall_0__msg_mag 
            = __Vfunc_msg_mag__25__Vfuncout;
        __Vfunc_msg_to_signed__24__mag_value = __Vfunc_msg_to_signed__24____VlefCall_0__msg_mag;
        __Vfunc_msg_sign__26__msg = __Vfunc_msg_to_signed__24__msg;
        __Vfunc_msg_sign__26__Vfuncout = 0;
        __Vfunc_msg_sign__26__Vfuncout = (1U & ((IData)(__Vfunc_msg_sign__26__msg) 
                                                >> 4U));
        __Vfunc_msg_to_signed__24____VlefCall_1__msg_sign 
            = __Vfunc_msg_sign__26__Vfuncout;
        if (__Vfunc_msg_to_signed__24____VlefCall_1__msg_sign) {
            vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_7__msg_to_signed 
                = (- __Vfunc_msg_to_signed__24__mag_value);
            goto __Vlabel7;
        }
        vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_7__msg_to_signed 
            = __Vfunc_msg_to_signed__24__mag_value;
        __Vlabel7: ;
    }
    if (VL_UNLIKELY(((0x0000000cU != vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_7__msg_to_signed)))) {
        __Vfunc_msg_to_signed__27__msg = vlSelfRef.tb_mdpc_vnu__DOT__u_next_out[2U];
        {
            vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_8__msg_to_signed = 0U;
            __Vfunc_msg_to_signed__27__mag_value = 0U;
            __Vfunc_msg_mag__28__msg = __Vfunc_msg_to_signed__27__msg;
            __Vfunc_msg_mag__28__Vfuncout = 0;
            __Vfunc_msg_mag__28__Vfuncout = (0x0000000fU 
                                             & (IData)(__Vfunc_msg_mag__28__msg));
            __Vfunc_msg_to_signed__27____VlefCall_0__msg_mag 
                = __Vfunc_msg_mag__28__Vfuncout;
            __Vfunc_msg_to_signed__27__mag_value = __Vfunc_msg_to_signed__27____VlefCall_0__msg_mag;
            __Vfunc_msg_sign__29__msg = __Vfunc_msg_to_signed__27__msg;
            __Vfunc_msg_sign__29__Vfuncout = 0;
            __Vfunc_msg_sign__29__Vfuncout = (1U & 
                                              ((IData)(__Vfunc_msg_sign__29__msg) 
                                               >> 4U));
            __Vfunc_msg_to_signed__27____VlefCall_1__msg_sign 
                = __Vfunc_msg_sign__29__Vfuncout;
            if (__Vfunc_msg_to_signed__27____VlefCall_1__msg_sign) {
                vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_8__msg_to_signed 
                    = (- __Vfunc_msg_to_signed__27__mag_value);
                goto __Vlabel8;
            }
            vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_8__msg_to_signed 
                = __Vfunc_msg_to_signed__27__mag_value;
            __Vlabel8: ;
        }
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_vnu.sv:30: Assertion failed in %m: u_next[2] mismatch: got %0d exp 12\n",4, 'M',vlSymsp->name(),"tb_mdpc_vnu", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '~',32,vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_8__msg_to_signed);
        VL_STOP_MT("tb/tb_mdpc_vnu.sv", 30, "", false);
    }
    vlSelfRef.tb_mdpc_vnu__DOT__gamma_in = 0x1fU;
    __Vfunc_msg_from_signed__30__value = 0xfffffff1U;
    tb_mdpc_vnu__DOT____VlemCall_9__msg_from_signed = 0;
    __Vfunc_msg_from_signed__30__msg = 0;
    __Vfunc_msg_from_signed__30__abs_value = 0U;
    __Vfunc_msg_from_signed__30__abs_value = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__30__value)
                                               ? (- __Vfunc_msg_from_signed__30__value)
                                               : __Vfunc_msg_from_signed__30__value);
    __Vfunc_mag_from_int__31__value = __Vfunc_msg_from_signed__30__abs_value;
    __Vfunc_mag_from_int__31__Vfuncout = 0;
    __Vfunc_mag_from_int__31__clamped_value = 0U;
    __Vfunc_mag_from_int__31__result = 0;
    __Vfunc_clamp_int__32__hi = 0x0000000fU;
    __Vfunc_clamp_int__32__lo = 0U;
    __Vfunc_clamp_int__32__value = __Vfunc_mag_from_int__31__value;
    {
        __Vfunc_clamp_int__32__Vfuncout = 0U;
        if (VL_LTS_III(32, __Vfunc_clamp_int__32__value, __Vfunc_clamp_int__32__lo)) {
            __Vfunc_clamp_int__32__Vfuncout = __Vfunc_clamp_int__32__lo;
            goto __Vlabel9;
        }
        if (VL_GTS_III(32, __Vfunc_clamp_int__32__value, __Vfunc_clamp_int__32__hi)) {
            __Vfunc_clamp_int__32__Vfuncout = __Vfunc_clamp_int__32__hi;
            goto __Vlabel9;
        }
        __Vfunc_clamp_int__32__Vfuncout = __Vfunc_clamp_int__32__value;
        __Vlabel9: ;
    }
    __Vfunc_mag_from_int__31__clamped_value = __Vfunc_clamp_int__32__Vfuncout;
    __Vfunc_mag_from_int__31__result = (0x0000000fU 
                                        & __Vfunc_mag_from_int__31__clamped_value);
    __Vfunc_mag_from_int__31__Vfuncout = __Vfunc_mag_from_int__31__result;
    __Vfunc_msg_from_signed__30____VlefCall_0__mag_from_int 
        = __Vfunc_mag_from_int__31__Vfuncout;
    __Vfunc_msg_pack__33__mag = __Vfunc_msg_from_signed__30____VlefCall_0__mag_from_int;
    __Vfunc_msg_pack__33__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__30__value);
    __Vfunc_msg_pack__33__Vfuncout = 0;
    __Vfunc_msg_pack__33__Vfuncout = (((IData)(__Vfunc_msg_pack__33__sign) 
                                       << 4U) | (IData)(__Vfunc_msg_pack__33__mag));
    __Vfunc_msg_from_signed__30__msg = __Vfunc_msg_pack__33__Vfuncout;
    tb_mdpc_vnu__DOT____VlemCall_9__msg_from_signed 
        = __Vfunc_msg_from_signed__30__msg;
    vlSelfRef.tb_mdpc_vnu__DOT__c2v_in[0U] = tb_mdpc_vnu__DOT____VlemCall_9__msg_from_signed;
    __Vfunc_msg_from_signed__34__value = 0xfffffff1U;
    tb_mdpc_vnu__DOT____VlemCall_10__msg_from_signed = 0;
    __Vfunc_msg_from_signed__34__msg = 0;
    __Vfunc_msg_from_signed__34__abs_value = 0U;
    __Vfunc_msg_from_signed__34__abs_value = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__34__value)
                                               ? (- __Vfunc_msg_from_signed__34__value)
                                               : __Vfunc_msg_from_signed__34__value);
    __Vfunc_mag_from_int__35__value = __Vfunc_msg_from_signed__34__abs_value;
    __Vfunc_mag_from_int__35__Vfuncout = 0;
    __Vfunc_mag_from_int__35__clamped_value = 0U;
    __Vfunc_mag_from_int__35__result = 0;
    __Vfunc_clamp_int__36__hi = 0x0000000fU;
    __Vfunc_clamp_int__36__lo = 0U;
    __Vfunc_clamp_int__36__value = __Vfunc_mag_from_int__35__value;
    {
        __Vfunc_clamp_int__36__Vfuncout = 0U;
        if (VL_LTS_III(32, __Vfunc_clamp_int__36__value, __Vfunc_clamp_int__36__lo)) {
            __Vfunc_clamp_int__36__Vfuncout = __Vfunc_clamp_int__36__lo;
            goto __Vlabel10;
        }
        if (VL_GTS_III(32, __Vfunc_clamp_int__36__value, __Vfunc_clamp_int__36__hi)) {
            __Vfunc_clamp_int__36__Vfuncout = __Vfunc_clamp_int__36__hi;
            goto __Vlabel10;
        }
        __Vfunc_clamp_int__36__Vfuncout = __Vfunc_clamp_int__36__value;
        __Vlabel10: ;
    }
    __Vfunc_mag_from_int__35__clamped_value = __Vfunc_clamp_int__36__Vfuncout;
    __Vfunc_mag_from_int__35__result = (0x0000000fU 
                                        & __Vfunc_mag_from_int__35__clamped_value);
    __Vfunc_mag_from_int__35__Vfuncout = __Vfunc_mag_from_int__35__result;
    __Vfunc_msg_from_signed__34____VlefCall_0__mag_from_int 
        = __Vfunc_mag_from_int__35__Vfuncout;
    __Vfunc_msg_pack__37__mag = __Vfunc_msg_from_signed__34____VlefCall_0__mag_from_int;
    __Vfunc_msg_pack__37__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__34__value);
    __Vfunc_msg_pack__37__Vfuncout = 0;
    __Vfunc_msg_pack__37__Vfuncout = (((IData)(__Vfunc_msg_pack__37__sign) 
                                       << 4U) | (IData)(__Vfunc_msg_pack__37__mag));
    __Vfunc_msg_from_signed__34__msg = __Vfunc_msg_pack__37__Vfuncout;
    tb_mdpc_vnu__DOT____VlemCall_10__msg_from_signed 
        = __Vfunc_msg_from_signed__34__msg;
    vlSelfRef.tb_mdpc_vnu__DOT__c2v_in[1U] = tb_mdpc_vnu__DOT____VlemCall_10__msg_from_signed;
    __Vfunc_msg_from_signed__38__value = 0xfffffff1U;
    tb_mdpc_vnu__DOT____VlemCall_11__msg_from_signed = 0;
    __Vfunc_msg_from_signed__38__msg = 0;
    __Vfunc_msg_from_signed__38__abs_value = 0U;
    __Vfunc_msg_from_signed__38__abs_value = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__38__value)
                                               ? (- __Vfunc_msg_from_signed__38__value)
                                               : __Vfunc_msg_from_signed__38__value);
    __Vfunc_mag_from_int__39__value = __Vfunc_msg_from_signed__38__abs_value;
    __Vfunc_mag_from_int__39__Vfuncout = 0;
    __Vfunc_mag_from_int__39__clamped_value = 0U;
    __Vfunc_mag_from_int__39__result = 0;
    __Vfunc_clamp_int__40__hi = 0x0000000fU;
    __Vfunc_clamp_int__40__lo = 0U;
    __Vfunc_clamp_int__40__value = __Vfunc_mag_from_int__39__value;
    {
        __Vfunc_clamp_int__40__Vfuncout = 0U;
        if (VL_LTS_III(32, __Vfunc_clamp_int__40__value, __Vfunc_clamp_int__40__lo)) {
            __Vfunc_clamp_int__40__Vfuncout = __Vfunc_clamp_int__40__lo;
            goto __Vlabel11;
        }
        if (VL_GTS_III(32, __Vfunc_clamp_int__40__value, __Vfunc_clamp_int__40__hi)) {
            __Vfunc_clamp_int__40__Vfuncout = __Vfunc_clamp_int__40__hi;
            goto __Vlabel11;
        }
        __Vfunc_clamp_int__40__Vfuncout = __Vfunc_clamp_int__40__value;
        __Vlabel11: ;
    }
    __Vfunc_mag_from_int__39__clamped_value = __Vfunc_clamp_int__40__Vfuncout;
    __Vfunc_mag_from_int__39__result = (0x0000000fU 
                                        & __Vfunc_mag_from_int__39__clamped_value);
    __Vfunc_mag_from_int__39__Vfuncout = __Vfunc_mag_from_int__39__result;
    __Vfunc_msg_from_signed__38____VlefCall_0__mag_from_int 
        = __Vfunc_mag_from_int__39__Vfuncout;
    __Vfunc_msg_pack__41__mag = __Vfunc_msg_from_signed__38____VlefCall_0__mag_from_int;
    __Vfunc_msg_pack__41__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__38__value);
    __Vfunc_msg_pack__41__Vfuncout = 0;
    __Vfunc_msg_pack__41__Vfuncout = (((IData)(__Vfunc_msg_pack__41__sign) 
                                       << 4U) | (IData)(__Vfunc_msg_pack__41__mag));
    __Vfunc_msg_from_signed__38__msg = __Vfunc_msg_pack__41__Vfuncout;
    tb_mdpc_vnu__DOT____VlemCall_11__msg_from_signed 
        = __Vfunc_msg_from_signed__38__msg;
    vlSelfRef.tb_mdpc_vnu__DOT__c2v_in[2U] = tb_mdpc_vnu__DOT____VlemCall_11__msg_from_signed;
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "tb/tb_mdpc_vnu.sv", 
                                         36);
    if (VL_UNLIKELY(((0x0000001bU != VL_EXTENDS_II(32,8, (IData)(vlSelfRef.tb_mdpc_vnu__DOT__app_out)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_vnu.sv:37: Assertion failed in %m: saturation case app_out mismatch: got %0d exp 27\n",4, 'M',vlSymsp->name(),"tb_mdpc_vnu", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '~',8,(IData)(vlSelfRef.tb_mdpc_vnu__DOT__app_out));
        VL_STOP_MT("tb/tb_mdpc_vnu.sv", 37, "", false);
    }
    if (VL_UNLIKELY((vlSelfRef.tb_mdpc_vnu__DOT__x_out))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_vnu.sv:38: Assertion failed in %m: saturation case x_out mismatch: got %0d exp 0\n",4, 'M',vlSymsp->name(),"tb_mdpc_vnu", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',1,(IData)(vlSelfRef.tb_mdpc_vnu__DOT__x_out));
        VL_STOP_MT("tb/tb_mdpc_vnu.sv", 38, "", false);
    }
    __Vfunc_msg_to_signed__42__msg = vlSelfRef.tb_mdpc_vnu__DOT__u_next_out[0U];
    {
        vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_12__msg_to_signed = 0U;
        __Vfunc_msg_to_signed__42__mag_value = 0U;
        __Vfunc_msg_mag__43__msg = __Vfunc_msg_to_signed__42__msg;
        __Vfunc_msg_mag__43__Vfuncout = 0;
        __Vfunc_msg_mag__43__Vfuncout = (0x0000000fU 
                                         & (IData)(__Vfunc_msg_mag__43__msg));
        __Vfunc_msg_to_signed__42____VlefCall_0__msg_mag 
            = __Vfunc_msg_mag__43__Vfuncout;
        __Vfunc_msg_to_signed__42__mag_value = __Vfunc_msg_to_signed__42____VlefCall_0__msg_mag;
        __Vfunc_msg_sign__44__msg = __Vfunc_msg_to_signed__42__msg;
        __Vfunc_msg_sign__44__Vfuncout = 0;
        __Vfunc_msg_sign__44__Vfuncout = (1U & ((IData)(__Vfunc_msg_sign__44__msg) 
                                                >> 4U));
        __Vfunc_msg_to_signed__42____VlefCall_1__msg_sign 
            = __Vfunc_msg_sign__44__Vfuncout;
        if (__Vfunc_msg_to_signed__42____VlefCall_1__msg_sign) {
            vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_12__msg_to_signed 
                = (- __Vfunc_msg_to_signed__42__mag_value);
            goto __Vlabel12;
        }
        vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_12__msg_to_signed 
            = __Vfunc_msg_to_signed__42__mag_value;
        __Vlabel12: ;
    }
    if (VL_UNLIKELY(((0x0000000fU != vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_12__msg_to_signed)))) {
        __Vfunc_msg_to_signed__45__msg = vlSelfRef.tb_mdpc_vnu__DOT__u_next_out[0U];
        {
            vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_13__msg_to_signed = 0U;
            __Vfunc_msg_to_signed__45__mag_value = 0U;
            __Vfunc_msg_mag__46__msg = __Vfunc_msg_to_signed__45__msg;
            __Vfunc_msg_mag__46__Vfuncout = 0;
            __Vfunc_msg_mag__46__Vfuncout = (0x0000000fU 
                                             & (IData)(__Vfunc_msg_mag__46__msg));
            __Vfunc_msg_to_signed__45____VlefCall_0__msg_mag 
                = __Vfunc_msg_mag__46__Vfuncout;
            __Vfunc_msg_to_signed__45__mag_value = __Vfunc_msg_to_signed__45____VlefCall_0__msg_mag;
            __Vfunc_msg_sign__47__msg = __Vfunc_msg_to_signed__45__msg;
            __Vfunc_msg_sign__47__Vfuncout = 0;
            __Vfunc_msg_sign__47__Vfuncout = (1U & 
                                              ((IData)(__Vfunc_msg_sign__47__msg) 
                                               >> 4U));
            __Vfunc_msg_to_signed__45____VlefCall_1__msg_sign 
                = __Vfunc_msg_sign__47__Vfuncout;
            if (__Vfunc_msg_to_signed__45____VlefCall_1__msg_sign) {
                vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_13__msg_to_signed 
                    = (- __Vfunc_msg_to_signed__45__mag_value);
                goto __Vlabel13;
            }
            vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_13__msg_to_signed 
                = __Vfunc_msg_to_signed__45__mag_value;
            __Vlabel13: ;
        }
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_vnu.sv:39: Assertion failed in %m: u_next[0] saturation mismatch: got %0d exp 15\n",4, 'M',vlSymsp->name(),"tb_mdpc_vnu", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '~',32,vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_13__msg_to_signed);
        VL_STOP_MT("tb/tb_mdpc_vnu.sv", 39, "", false);
    }
    __Vfunc_msg_to_signed__48__msg = vlSelfRef.tb_mdpc_vnu__DOT__u_next_out[1U];
    {
        vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_14__msg_to_signed = 0U;
        __Vfunc_msg_to_signed__48__mag_value = 0U;
        __Vfunc_msg_mag__49__msg = __Vfunc_msg_to_signed__48__msg;
        __Vfunc_msg_mag__49__Vfuncout = 0;
        __Vfunc_msg_mag__49__Vfuncout = (0x0000000fU 
                                         & (IData)(__Vfunc_msg_mag__49__msg));
        __Vfunc_msg_to_signed__48____VlefCall_0__msg_mag 
            = __Vfunc_msg_mag__49__Vfuncout;
        __Vfunc_msg_to_signed__48__mag_value = __Vfunc_msg_to_signed__48____VlefCall_0__msg_mag;
        __Vfunc_msg_sign__50__msg = __Vfunc_msg_to_signed__48__msg;
        __Vfunc_msg_sign__50__Vfuncout = 0;
        __Vfunc_msg_sign__50__Vfuncout = (1U & ((IData)(__Vfunc_msg_sign__50__msg) 
                                                >> 4U));
        __Vfunc_msg_to_signed__48____VlefCall_1__msg_sign 
            = __Vfunc_msg_sign__50__Vfuncout;
        if (__Vfunc_msg_to_signed__48____VlefCall_1__msg_sign) {
            vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_14__msg_to_signed 
                = (- __Vfunc_msg_to_signed__48__mag_value);
            goto __Vlabel14;
        }
        vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_14__msg_to_signed 
            = __Vfunc_msg_to_signed__48__mag_value;
        __Vlabel14: ;
    }
    if (VL_UNLIKELY(((0x0000000fU != vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_14__msg_to_signed)))) {
        __Vfunc_msg_to_signed__51__msg = vlSelfRef.tb_mdpc_vnu__DOT__u_next_out[1U];
        {
            vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_15__msg_to_signed = 0U;
            __Vfunc_msg_to_signed__51__mag_value = 0U;
            __Vfunc_msg_mag__52__msg = __Vfunc_msg_to_signed__51__msg;
            __Vfunc_msg_mag__52__Vfuncout = 0;
            __Vfunc_msg_mag__52__Vfuncout = (0x0000000fU 
                                             & (IData)(__Vfunc_msg_mag__52__msg));
            __Vfunc_msg_to_signed__51____VlefCall_0__msg_mag 
                = __Vfunc_msg_mag__52__Vfuncout;
            __Vfunc_msg_to_signed__51__mag_value = __Vfunc_msg_to_signed__51____VlefCall_0__msg_mag;
            __Vfunc_msg_sign__53__msg = __Vfunc_msg_to_signed__51__msg;
            __Vfunc_msg_sign__53__Vfuncout = 0;
            __Vfunc_msg_sign__53__Vfuncout = (1U & 
                                              ((IData)(__Vfunc_msg_sign__53__msg) 
                                               >> 4U));
            __Vfunc_msg_to_signed__51____VlefCall_1__msg_sign 
                = __Vfunc_msg_sign__53__Vfuncout;
            if (__Vfunc_msg_to_signed__51____VlefCall_1__msg_sign) {
                vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_15__msg_to_signed 
                    = (- __Vfunc_msg_to_signed__51__mag_value);
                goto __Vlabel15;
            }
            vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_15__msg_to_signed 
                = __Vfunc_msg_to_signed__51__mag_value;
            __Vlabel15: ;
        }
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_vnu.sv:40: Assertion failed in %m: u_next[1] saturation mismatch: got %0d exp 15\n",4, 'M',vlSymsp->name(),"tb_mdpc_vnu", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '~',32,vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_15__msg_to_signed);
        VL_STOP_MT("tb/tb_mdpc_vnu.sv", 40, "", false);
    }
    __Vfunc_msg_to_signed__54__msg = vlSelfRef.tb_mdpc_vnu__DOT__u_next_out[2U];
    {
        vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_16__msg_to_signed = 0U;
        __Vfunc_msg_to_signed__54__mag_value = 0U;
        __Vfunc_msg_mag__55__msg = __Vfunc_msg_to_signed__54__msg;
        __Vfunc_msg_mag__55__Vfuncout = 0;
        __Vfunc_msg_mag__55__Vfuncout = (0x0000000fU 
                                         & (IData)(__Vfunc_msg_mag__55__msg));
        __Vfunc_msg_to_signed__54____VlefCall_0__msg_mag 
            = __Vfunc_msg_mag__55__Vfuncout;
        __Vfunc_msg_to_signed__54__mag_value = __Vfunc_msg_to_signed__54____VlefCall_0__msg_mag;
        __Vfunc_msg_sign__56__msg = __Vfunc_msg_to_signed__54__msg;
        __Vfunc_msg_sign__56__Vfuncout = 0;
        __Vfunc_msg_sign__56__Vfuncout = (1U & ((IData)(__Vfunc_msg_sign__56__msg) 
                                                >> 4U));
        __Vfunc_msg_to_signed__54____VlefCall_1__msg_sign 
            = __Vfunc_msg_sign__56__Vfuncout;
        if (__Vfunc_msg_to_signed__54____VlefCall_1__msg_sign) {
            vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_16__msg_to_signed 
                = (- __Vfunc_msg_to_signed__54__mag_value);
            goto __Vlabel16;
        }
        vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_16__msg_to_signed 
            = __Vfunc_msg_to_signed__54__mag_value;
        __Vlabel16: ;
    }
    if (VL_UNLIKELY(((0x0000000fU != vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_16__msg_to_signed)))) {
        __Vfunc_msg_to_signed__57__msg = vlSelfRef.tb_mdpc_vnu__DOT__u_next_out[2U];
        {
            vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_17__msg_to_signed = 0U;
            __Vfunc_msg_to_signed__57__mag_value = 0U;
            __Vfunc_msg_mag__58__msg = __Vfunc_msg_to_signed__57__msg;
            __Vfunc_msg_mag__58__Vfuncout = 0;
            __Vfunc_msg_mag__58__Vfuncout = (0x0000000fU 
                                             & (IData)(__Vfunc_msg_mag__58__msg));
            __Vfunc_msg_to_signed__57____VlefCall_0__msg_mag 
                = __Vfunc_msg_mag__58__Vfuncout;
            __Vfunc_msg_to_signed__57__mag_value = __Vfunc_msg_to_signed__57____VlefCall_0__msg_mag;
            __Vfunc_msg_sign__59__msg = __Vfunc_msg_to_signed__57__msg;
            __Vfunc_msg_sign__59__Vfuncout = 0;
            __Vfunc_msg_sign__59__Vfuncout = (1U & 
                                              ((IData)(__Vfunc_msg_sign__59__msg) 
                                               >> 4U));
            __Vfunc_msg_to_signed__57____VlefCall_1__msg_sign 
                = __Vfunc_msg_sign__59__Vfuncout;
            if (__Vfunc_msg_to_signed__57____VlefCall_1__msg_sign) {
                vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_17__msg_to_signed 
                    = (- __Vfunc_msg_to_signed__57__mag_value);
                goto __Vlabel17;
            }
            vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_17__msg_to_signed 
                = __Vfunc_msg_to_signed__57__mag_value;
            __Vlabel17: ;
        }
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_vnu.sv:41: Assertion failed in %m: u_next[2] saturation mismatch: got %0d exp 15\n",4, 'M',vlSymsp->name(),"tb_mdpc_vnu", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '~',32,vlSelfRef.tb_mdpc_vnu__DOT____VlemCall_17__msg_to_signed);
        VL_STOP_MT("tb/tb_mdpc_vnu.sv", 41, "", false);
    }
    VL_WRITEF_NX("tb_mdpc_vnu PASS\n",0);
    VL_FINISH_MT("tb/tb_mdpc_vnu.sv", 44, "");
    co_return;
}

void Vtb_mdpc_vnu___024root___eval_triggers_vec__act(Vtb_mdpc_vnu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_vnu___024root___eval_triggers_vec__act\n"); );
    Vtb_mdpc_vnu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VactTriggered[0U] = (QData)((IData)(vlSelfRef.__VdlySched.awaitingCurrentTime()));
}

bool Vtb_mdpc_vnu___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_vnu___024root___trigger_anySet__act\n"); );
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

void Vtb_mdpc_vnu___024root___act_sequent__TOP__0(Vtb_mdpc_vnu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_vnu___024root___act_sequent__TOP__0\n"); );
    Vtb_mdpc_vnu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*4:0*/ tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h02a35ea2__0;
    tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h02a35ea2__0 = 0;
    IData/*31:0*/ tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h619e30fe__0;
    tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h619e30fe__0 = 0;
    CData/*4:0*/ tb_mdpc_vnu__DOT__dut__DOT____VlemCall_3__msg_from_signed;
    IData/*31:0*/ tb_mdpc_vnu__DOT__dut__DOT__sum_c2v;
    tb_mdpc_vnu__DOT__dut__DOT__sum_c2v = 0;
    IData/*31:0*/ tb_mdpc_vnu__DOT__dut__DOT__gamma_value;
    tb_mdpc_vnu__DOT__dut__DOT__gamma_value = 0;
    IData/*31:0*/ tb_mdpc_vnu__DOT__dut__DOT__app_value;
    tb_mdpc_vnu__DOT__dut__DOT__app_value = 0;
    IData/*31:0*/ tb_mdpc_vnu__DOT__dut__DOT__u_value;
    tb_mdpc_vnu__DOT__dut__DOT__u_value = 0;
    CData/*4:0*/ __Vfunc_msg_to_signed__60__msg;
    __Vfunc_msg_to_signed__60__msg = 0;
    IData/*31:0*/ __Vfunc_alpha_scale__63__value;
    __Vfunc_alpha_scale__63__value = 0;
    CData/*7:0*/ __Vfunc_app_from_int__64__Vfuncout;
    __Vfunc_app_from_int__64__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_app_from_int__64__value;
    __Vfunc_app_from_int__64__value = 0;
    IData/*31:0*/ __Vfunc_app_from_int__64__app_value_int;
    __Vfunc_app_from_int__64__app_value_int = 0;
    CData/*7:0*/ __Vfunc_app_from_int__64__result;
    __Vfunc_app_from_int__64__result = 0;
    IData/*31:0*/ __Vfunc_alpha_scale__65__value;
    __Vfunc_alpha_scale__65__value = 0;
    IData/*31:0*/ __Vfunc_msg_from_signed__66__value;
    __Vfunc_msg_from_signed__66__value = 0;
    CData/*3:0*/ __Vfunc_msg_from_signed__66____VlefCall_0__mag_from_int;
    __Vfunc_msg_from_signed__66____VlefCall_0__mag_from_int = 0;
    CData/*4:0*/ __Vfunc_msg_from_signed__66__msg;
    __Vfunc_msg_from_signed__66__msg = 0;
    IData/*31:0*/ __Vfunc_msg_from_signed__66__abs_value;
    __Vfunc_msg_from_signed__66__abs_value = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__67__Vfuncout;
    __Vfunc_mag_from_int__67__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_mag_from_int__67__value;
    __Vfunc_mag_from_int__67__value = 0;
    IData/*31:0*/ __Vfunc_mag_from_int__67__clamped_value;
    __Vfunc_mag_from_int__67__clamped_value = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__67__result;
    __Vfunc_mag_from_int__67__result = 0;
    IData/*31:0*/ __Vfunc_clamp_int__68__value;
    __Vfunc_clamp_int__68__value = 0;
    CData/*4:0*/ __Vfunc_msg_pack__69__Vfuncout;
    __Vfunc_msg_pack__69__Vfuncout = 0;
    CData/*0:0*/ __Vfunc_msg_pack__69__sign;
    __Vfunc_msg_pack__69__sign = 0;
    CData/*3:0*/ __Vfunc_msg_pack__69__mag;
    __Vfunc_msg_pack__69__mag = 0;
    // Body
    tb_mdpc_vnu__DOT__dut__DOT__gamma_value = VL_EXTENDS_II(32,8, (IData)(vlSelfRef.tb_mdpc_vnu__DOT__gamma_in));
    __Vfunc_msg_to_signed__60__msg = vlSelfRef.tb_mdpc_vnu__DOT__c2v_in[0U];
    {
        vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_0__msg_to_signed = 0U;
        vlSelfRef.__Vfunc_msg_to_signed__60__mag_value = 0U;
        vlSelfRef.__Vfunc_msg_mag__61__msg = __Vfunc_msg_to_signed__60__msg;
        vlSelf->__Vfunc_msg_mag__61__Vfuncout = 0;
        vlSelfRef.__Vfunc_msg_mag__61__Vfuncout = (0x0000000fU 
                                                   & (IData)(vlSelfRef.__Vfunc_msg_mag__61__msg));
        vlSelfRef.__Vfunc_msg_to_signed__60____VlefCall_0__msg_mag 
            = vlSelfRef.__Vfunc_msg_mag__61__Vfuncout;
        vlSelfRef.__Vfunc_msg_to_signed__60__mag_value 
            = vlSelfRef.__Vfunc_msg_to_signed__60____VlefCall_0__msg_mag;
        vlSelfRef.__Vfunc_msg_sign__62__msg = __Vfunc_msg_to_signed__60__msg;
        vlSelf->__Vfunc_msg_sign__62__Vfuncout = 0;
        vlSelfRef.__Vfunc_msg_sign__62__Vfuncout = 
            (1U & ((IData)(vlSelfRef.__Vfunc_msg_sign__62__msg) 
                   >> 4U));
        vlSelfRef.__Vfunc_msg_to_signed__60____VlefCall_1__msg_sign 
            = vlSelfRef.__Vfunc_msg_sign__62__Vfuncout;
        if (vlSelfRef.__Vfunc_msg_to_signed__60____VlefCall_1__msg_sign) {
            vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_0__msg_to_signed 
                = (- vlSelfRef.__Vfunc_msg_to_signed__60__mag_value);
            goto __Vlabel0;
        }
        vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_0__msg_to_signed 
            = vlSelfRef.__Vfunc_msg_to_signed__60__mag_value;
        __Vlabel0: ;
    }
    tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h619e30fe__0 
        = vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_0__msg_to_signed;
    vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT__signed_c2v[0U] 
        = tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h619e30fe__0;
    tb_mdpc_vnu__DOT__dut__DOT__sum_c2v = vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT__signed_c2v[0U];
    __Vfunc_msg_to_signed__60__msg = vlSelfRef.tb_mdpc_vnu__DOT__c2v_in[1U];
    {
        vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_0__msg_to_signed = 0U;
        vlSelfRef.__Vfunc_msg_to_signed__60__mag_value = 0U;
        vlSelfRef.__Vfunc_msg_mag__61__msg = __Vfunc_msg_to_signed__60__msg;
        vlSelf->__Vfunc_msg_mag__61__Vfuncout = 0;
        vlSelfRef.__Vfunc_msg_mag__61__Vfuncout = (0x0000000fU 
                                                   & (IData)(vlSelfRef.__Vfunc_msg_mag__61__msg));
        vlSelfRef.__Vfunc_msg_to_signed__60____VlefCall_0__msg_mag 
            = vlSelfRef.__Vfunc_msg_mag__61__Vfuncout;
        vlSelfRef.__Vfunc_msg_to_signed__60__mag_value 
            = vlSelfRef.__Vfunc_msg_to_signed__60____VlefCall_0__msg_mag;
        vlSelfRef.__Vfunc_msg_sign__62__msg = __Vfunc_msg_to_signed__60__msg;
        vlSelf->__Vfunc_msg_sign__62__Vfuncout = 0;
        vlSelfRef.__Vfunc_msg_sign__62__Vfuncout = 
            (1U & ((IData)(vlSelfRef.__Vfunc_msg_sign__62__msg) 
                   >> 4U));
        vlSelfRef.__Vfunc_msg_to_signed__60____VlefCall_1__msg_sign 
            = vlSelfRef.__Vfunc_msg_sign__62__Vfuncout;
        if (vlSelfRef.__Vfunc_msg_to_signed__60____VlefCall_1__msg_sign) {
            vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_0__msg_to_signed 
                = (- vlSelfRef.__Vfunc_msg_to_signed__60__mag_value);
            goto __Vlabel1;
        }
        vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_0__msg_to_signed 
            = vlSelfRef.__Vfunc_msg_to_signed__60__mag_value;
        __Vlabel1: ;
    }
    tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h619e30fe__0 
        = vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_0__msg_to_signed;
    vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT__signed_c2v[1U] 
        = tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h619e30fe__0;
    tb_mdpc_vnu__DOT__dut__DOT__sum_c2v = (tb_mdpc_vnu__DOT__dut__DOT__sum_c2v 
                                           + vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT__signed_c2v[1U]);
    __Vfunc_msg_to_signed__60__msg = vlSelfRef.tb_mdpc_vnu__DOT__c2v_in[2U];
    {
        vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_0__msg_to_signed = 0U;
        vlSelfRef.__Vfunc_msg_to_signed__60__mag_value = 0U;
        vlSelfRef.__Vfunc_msg_mag__61__msg = __Vfunc_msg_to_signed__60__msg;
        vlSelf->__Vfunc_msg_mag__61__Vfuncout = 0;
        vlSelfRef.__Vfunc_msg_mag__61__Vfuncout = (0x0000000fU 
                                                   & (IData)(vlSelfRef.__Vfunc_msg_mag__61__msg));
        vlSelfRef.__Vfunc_msg_to_signed__60____VlefCall_0__msg_mag 
            = vlSelfRef.__Vfunc_msg_mag__61__Vfuncout;
        vlSelfRef.__Vfunc_msg_to_signed__60__mag_value 
            = vlSelfRef.__Vfunc_msg_to_signed__60____VlefCall_0__msg_mag;
        vlSelfRef.__Vfunc_msg_sign__62__msg = __Vfunc_msg_to_signed__60__msg;
        vlSelf->__Vfunc_msg_sign__62__Vfuncout = 0;
        vlSelfRef.__Vfunc_msg_sign__62__Vfuncout = 
            (1U & ((IData)(vlSelfRef.__Vfunc_msg_sign__62__msg) 
                   >> 4U));
        vlSelfRef.__Vfunc_msg_to_signed__60____VlefCall_1__msg_sign 
            = vlSelfRef.__Vfunc_msg_sign__62__Vfuncout;
        if (vlSelfRef.__Vfunc_msg_to_signed__60____VlefCall_1__msg_sign) {
            vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_0__msg_to_signed 
                = (- vlSelfRef.__Vfunc_msg_to_signed__60__mag_value);
            goto __Vlabel2;
        }
        vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_0__msg_to_signed 
            = vlSelfRef.__Vfunc_msg_to_signed__60__mag_value;
        __Vlabel2: ;
    }
    tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h619e30fe__0 
        = vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_0__msg_to_signed;
    vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT__signed_c2v[2U] 
        = tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h619e30fe__0;
    tb_mdpc_vnu__DOT__dut__DOT__sum_c2v = (tb_mdpc_vnu__DOT__dut__DOT__sum_c2v 
                                           + vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT__signed_c2v[2U]);
    __Vfunc_alpha_scale__63__value = tb_mdpc_vnu__DOT__dut__DOT__sum_c2v;
    {
        vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_1__alpha_scale = 0U;
        vlSelfRef.__Vfunc_alpha_scale__63__abs_value = 0U;
        vlSelfRef.__Vfunc_alpha_scale__63__scaled_abs = 0U;
        vlSelfRef.__Vfunc_alpha_scale__63__abs_value 
            = (VL_GTS_III(32, 0U, __Vfunc_alpha_scale__63__value)
                ? (- __Vfunc_alpha_scale__63__value)
                : __Vfunc_alpha_scale__63__value);
        vlSelfRef.__Vfunc_alpha_scale__63__scaled_abs 
            = VL_SHIFTRS_III(32,32,32, ((IData)(0x00000010U) 
                                        + VL_MULS_III(32, (IData)(3U), vlSelfRef.__Vfunc_alpha_scale__63__abs_value)), 5U);
        if (VL_GTS_III(32, 0U, __Vfunc_alpha_scale__63__value)) {
            vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_1__alpha_scale 
                = (- vlSelfRef.__Vfunc_alpha_scale__63__scaled_abs);
            goto __Vlabel3;
        }
        vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_1__alpha_scale 
            = vlSelfRef.__Vfunc_alpha_scale__63__scaled_abs;
        __Vlabel3: ;
    }
    tb_mdpc_vnu__DOT__dut__DOT__app_value = (tb_mdpc_vnu__DOT__dut__DOT__gamma_value 
                                             + vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_1__alpha_scale);
    __Vfunc_app_from_int__64__value = tb_mdpc_vnu__DOT__dut__DOT__app_value;
    __Vfunc_app_from_int__64__app_value_int = __Vfunc_app_from_int__64__value;
    __Vfunc_app_from_int__64__result = (0x000000ffU 
                                        & __Vfunc_app_from_int__64__app_value_int);
    __Vfunc_app_from_int__64__Vfuncout = __Vfunc_app_from_int__64__result;
    vlSelfRef.tb_mdpc_vnu__DOT__app_out = __Vfunc_app_from_int__64__Vfuncout;
    vlSelfRef.tb_mdpc_vnu__DOT__x_out = VL_GTS_III(32, 0U, tb_mdpc_vnu__DOT__dut__DOT__app_value);
    __Vfunc_alpha_scale__65__value = vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT__signed_c2v[0U];
    {
        vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_2__alpha_scale = 0U;
        vlSelfRef.__Vfunc_alpha_scale__65__abs_value = 0U;
        vlSelfRef.__Vfunc_alpha_scale__65__scaled_abs = 0U;
        vlSelfRef.__Vfunc_alpha_scale__65__abs_value 
            = (VL_GTS_III(32, 0U, __Vfunc_alpha_scale__65__value)
                ? (- __Vfunc_alpha_scale__65__value)
                : __Vfunc_alpha_scale__65__value);
        vlSelfRef.__Vfunc_alpha_scale__65__scaled_abs 
            = VL_SHIFTRS_III(32,32,32, ((IData)(0x00000010U) 
                                        + VL_MULS_III(32, (IData)(3U), vlSelfRef.__Vfunc_alpha_scale__65__abs_value)), 5U);
        if (VL_GTS_III(32, 0U, __Vfunc_alpha_scale__65__value)) {
            vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_2__alpha_scale 
                = (- vlSelfRef.__Vfunc_alpha_scale__65__scaled_abs);
            goto __Vlabel4;
        }
        vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_2__alpha_scale 
            = vlSelfRef.__Vfunc_alpha_scale__65__scaled_abs;
        __Vlabel4: ;
    }
    tb_mdpc_vnu__DOT__dut__DOT__u_value = (tb_mdpc_vnu__DOT__dut__DOT__app_value 
                                           - vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_2__alpha_scale);
    __Vfunc_msg_from_signed__66__value = tb_mdpc_vnu__DOT__dut__DOT__u_value;
    __Vfunc_msg_from_signed__66__abs_value = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__66__value)
                                               ? (- __Vfunc_msg_from_signed__66__value)
                                               : __Vfunc_msg_from_signed__66__value);
    __Vfunc_mag_from_int__67__value = __Vfunc_msg_from_signed__66__abs_value;
    __Vfunc_clamp_int__68__value = __Vfunc_mag_from_int__67__value;
    {
        vlSelfRef.__Vfunc_clamp_int__68__Vfuncout = 0U;
        if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__68__value)) {
            vlSelfRef.__Vfunc_clamp_int__68__Vfuncout = 0U;
            goto __Vlabel5;
        }
        if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__68__value)) {
            vlSelfRef.__Vfunc_clamp_int__68__Vfuncout = 0x0000000fU;
            goto __Vlabel5;
        }
        vlSelfRef.__Vfunc_clamp_int__68__Vfuncout = __Vfunc_clamp_int__68__value;
        __Vlabel5: ;
    }
    __Vfunc_mag_from_int__67__clamped_value = vlSelfRef.__Vfunc_clamp_int__68__Vfuncout;
    __Vfunc_mag_from_int__67__result = (0x0000000fU 
                                        & __Vfunc_mag_from_int__67__clamped_value);
    __Vfunc_mag_from_int__67__Vfuncout = __Vfunc_mag_from_int__67__result;
    __Vfunc_msg_from_signed__66____VlefCall_0__mag_from_int 
        = __Vfunc_mag_from_int__67__Vfuncout;
    __Vfunc_msg_pack__69__mag = __Vfunc_msg_from_signed__66____VlefCall_0__mag_from_int;
    __Vfunc_msg_pack__69__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__66__value);
    __Vfunc_msg_pack__69__Vfuncout = (((IData)(__Vfunc_msg_pack__69__sign) 
                                       << 4U) | (IData)(__Vfunc_msg_pack__69__mag));
    __Vfunc_msg_from_signed__66__msg = __Vfunc_msg_pack__69__Vfuncout;
    tb_mdpc_vnu__DOT__dut__DOT____VlemCall_3__msg_from_signed 
        = __Vfunc_msg_from_signed__66__msg;
    tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h02a35ea2__0 
        = tb_mdpc_vnu__DOT__dut__DOT____VlemCall_3__msg_from_signed;
    vlSelfRef.tb_mdpc_vnu__DOT__u_next_out[0U] = tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h02a35ea2__0;
    __Vfunc_alpha_scale__65__value = vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT__signed_c2v[1U];
    {
        vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_2__alpha_scale = 0U;
        vlSelfRef.__Vfunc_alpha_scale__65__abs_value = 0U;
        vlSelfRef.__Vfunc_alpha_scale__65__scaled_abs = 0U;
        vlSelfRef.__Vfunc_alpha_scale__65__abs_value 
            = (VL_GTS_III(32, 0U, __Vfunc_alpha_scale__65__value)
                ? (- __Vfunc_alpha_scale__65__value)
                : __Vfunc_alpha_scale__65__value);
        vlSelfRef.__Vfunc_alpha_scale__65__scaled_abs 
            = VL_SHIFTRS_III(32,32,32, ((IData)(0x00000010U) 
                                        + VL_MULS_III(32, (IData)(3U), vlSelfRef.__Vfunc_alpha_scale__65__abs_value)), 5U);
        if (VL_GTS_III(32, 0U, __Vfunc_alpha_scale__65__value)) {
            vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_2__alpha_scale 
                = (- vlSelfRef.__Vfunc_alpha_scale__65__scaled_abs);
            goto __Vlabel6;
        }
        vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_2__alpha_scale 
            = vlSelfRef.__Vfunc_alpha_scale__65__scaled_abs;
        __Vlabel6: ;
    }
    tb_mdpc_vnu__DOT__dut__DOT__u_value = (tb_mdpc_vnu__DOT__dut__DOT__app_value 
                                           - vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_2__alpha_scale);
    __Vfunc_msg_from_signed__66__value = tb_mdpc_vnu__DOT__dut__DOT__u_value;
    __Vfunc_msg_from_signed__66__abs_value = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__66__value)
                                               ? (- __Vfunc_msg_from_signed__66__value)
                                               : __Vfunc_msg_from_signed__66__value);
    __Vfunc_mag_from_int__67__value = __Vfunc_msg_from_signed__66__abs_value;
    __Vfunc_clamp_int__68__value = __Vfunc_mag_from_int__67__value;
    {
        vlSelfRef.__Vfunc_clamp_int__68__Vfuncout = 0U;
        if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__68__value)) {
            vlSelfRef.__Vfunc_clamp_int__68__Vfuncout = 0U;
            goto __Vlabel7;
        }
        if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__68__value)) {
            vlSelfRef.__Vfunc_clamp_int__68__Vfuncout = 0x0000000fU;
            goto __Vlabel7;
        }
        vlSelfRef.__Vfunc_clamp_int__68__Vfuncout = __Vfunc_clamp_int__68__value;
        __Vlabel7: ;
    }
    __Vfunc_mag_from_int__67__clamped_value = vlSelfRef.__Vfunc_clamp_int__68__Vfuncout;
    __Vfunc_mag_from_int__67__result = (0x0000000fU 
                                        & __Vfunc_mag_from_int__67__clamped_value);
    __Vfunc_mag_from_int__67__Vfuncout = __Vfunc_mag_from_int__67__result;
    __Vfunc_msg_from_signed__66____VlefCall_0__mag_from_int 
        = __Vfunc_mag_from_int__67__Vfuncout;
    __Vfunc_msg_pack__69__mag = __Vfunc_msg_from_signed__66____VlefCall_0__mag_from_int;
    __Vfunc_msg_pack__69__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__66__value);
    __Vfunc_msg_pack__69__Vfuncout = (((IData)(__Vfunc_msg_pack__69__sign) 
                                       << 4U) | (IData)(__Vfunc_msg_pack__69__mag));
    __Vfunc_msg_from_signed__66__msg = __Vfunc_msg_pack__69__Vfuncout;
    tb_mdpc_vnu__DOT__dut__DOT____VlemCall_3__msg_from_signed 
        = __Vfunc_msg_from_signed__66__msg;
    tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h02a35ea2__0 
        = tb_mdpc_vnu__DOT__dut__DOT____VlemCall_3__msg_from_signed;
    vlSelfRef.tb_mdpc_vnu__DOT__u_next_out[1U] = tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h02a35ea2__0;
    __Vfunc_alpha_scale__65__value = vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT__signed_c2v[2U];
    {
        vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_2__alpha_scale = 0U;
        vlSelfRef.__Vfunc_alpha_scale__65__abs_value = 0U;
        vlSelfRef.__Vfunc_alpha_scale__65__scaled_abs = 0U;
        vlSelfRef.__Vfunc_alpha_scale__65__abs_value 
            = (VL_GTS_III(32, 0U, __Vfunc_alpha_scale__65__value)
                ? (- __Vfunc_alpha_scale__65__value)
                : __Vfunc_alpha_scale__65__value);
        vlSelfRef.__Vfunc_alpha_scale__65__scaled_abs 
            = VL_SHIFTRS_III(32,32,32, ((IData)(0x00000010U) 
                                        + VL_MULS_III(32, (IData)(3U), vlSelfRef.__Vfunc_alpha_scale__65__abs_value)), 5U);
        if (VL_GTS_III(32, 0U, __Vfunc_alpha_scale__65__value)) {
            vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_2__alpha_scale 
                = (- vlSelfRef.__Vfunc_alpha_scale__65__scaled_abs);
            goto __Vlabel8;
        }
        vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_2__alpha_scale 
            = vlSelfRef.__Vfunc_alpha_scale__65__scaled_abs;
        __Vlabel8: ;
    }
    tb_mdpc_vnu__DOT__dut__DOT__u_value = (tb_mdpc_vnu__DOT__dut__DOT__app_value 
                                           - vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_2__alpha_scale);
    __Vfunc_msg_from_signed__66__value = tb_mdpc_vnu__DOT__dut__DOT__u_value;
    __Vfunc_msg_from_signed__66__abs_value = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__66__value)
                                               ? (- __Vfunc_msg_from_signed__66__value)
                                               : __Vfunc_msg_from_signed__66__value);
    __Vfunc_mag_from_int__67__value = __Vfunc_msg_from_signed__66__abs_value;
    __Vfunc_clamp_int__68__value = __Vfunc_mag_from_int__67__value;
    {
        vlSelfRef.__Vfunc_clamp_int__68__Vfuncout = 0U;
        if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__68__value)) {
            vlSelfRef.__Vfunc_clamp_int__68__Vfuncout = 0U;
            goto __Vlabel9;
        }
        if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__68__value)) {
            vlSelfRef.__Vfunc_clamp_int__68__Vfuncout = 0x0000000fU;
            goto __Vlabel9;
        }
        vlSelfRef.__Vfunc_clamp_int__68__Vfuncout = __Vfunc_clamp_int__68__value;
        __Vlabel9: ;
    }
    __Vfunc_mag_from_int__67__clamped_value = vlSelfRef.__Vfunc_clamp_int__68__Vfuncout;
    __Vfunc_mag_from_int__67__result = (0x0000000fU 
                                        & __Vfunc_mag_from_int__67__clamped_value);
    __Vfunc_mag_from_int__67__Vfuncout = __Vfunc_mag_from_int__67__result;
    __Vfunc_msg_from_signed__66____VlefCall_0__mag_from_int 
        = __Vfunc_mag_from_int__67__Vfuncout;
    __Vfunc_msg_pack__69__mag = __Vfunc_msg_from_signed__66____VlefCall_0__mag_from_int;
    __Vfunc_msg_pack__69__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__66__value);
    __Vfunc_msg_pack__69__Vfuncout = (((IData)(__Vfunc_msg_pack__69__sign) 
                                       << 4U) | (IData)(__Vfunc_msg_pack__69__mag));
    __Vfunc_msg_from_signed__66__msg = __Vfunc_msg_pack__69__Vfuncout;
    tb_mdpc_vnu__DOT__dut__DOT____VlemCall_3__msg_from_signed 
        = __Vfunc_msg_from_signed__66__msg;
    tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h02a35ea2__0 
        = tb_mdpc_vnu__DOT__dut__DOT____VlemCall_3__msg_from_signed;
    vlSelfRef.tb_mdpc_vnu__DOT__u_next_out[2U] = tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h02a35ea2__0;
}

void Vtb_mdpc_vnu___024root___eval_act(Vtb_mdpc_vnu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_vnu___024root___eval_act\n"); );
    Vtb_mdpc_vnu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VactTriggered[0U])) {
        Vtb_mdpc_vnu___024root___act_sequent__TOP__0(vlSelf);
    }
}

void Vtb_mdpc_vnu___024root___nba_sequent__TOP__0(Vtb_mdpc_vnu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_vnu___024root___nba_sequent__TOP__0\n"); );
    Vtb_mdpc_vnu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*4:0*/ tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h02a35ea2__0;
    tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h02a35ea2__0 = 0;
    IData/*31:0*/ tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h619e30fe__0;
    tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h619e30fe__0 = 0;
    CData/*4:0*/ tb_mdpc_vnu__DOT__dut__DOT____VlemCall_3__msg_from_signed;
    IData/*31:0*/ tb_mdpc_vnu__DOT__dut__DOT__sum_c2v;
    tb_mdpc_vnu__DOT__dut__DOT__sum_c2v = 0;
    IData/*31:0*/ tb_mdpc_vnu__DOT__dut__DOT__gamma_value;
    tb_mdpc_vnu__DOT__dut__DOT__gamma_value = 0;
    IData/*31:0*/ tb_mdpc_vnu__DOT__dut__DOT__app_value;
    tb_mdpc_vnu__DOT__dut__DOT__app_value = 0;
    IData/*31:0*/ tb_mdpc_vnu__DOT__dut__DOT__u_value;
    tb_mdpc_vnu__DOT__dut__DOT__u_value = 0;
    CData/*4:0*/ __Vfunc_msg_to_signed__60__msg;
    __Vfunc_msg_to_signed__60__msg = 0;
    IData/*31:0*/ __Vfunc_alpha_scale__63__value;
    __Vfunc_alpha_scale__63__value = 0;
    CData/*7:0*/ __Vfunc_app_from_int__64__Vfuncout;
    __Vfunc_app_from_int__64__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_app_from_int__64__value;
    __Vfunc_app_from_int__64__value = 0;
    IData/*31:0*/ __Vfunc_app_from_int__64__app_value_int;
    __Vfunc_app_from_int__64__app_value_int = 0;
    CData/*7:0*/ __Vfunc_app_from_int__64__result;
    __Vfunc_app_from_int__64__result = 0;
    IData/*31:0*/ __Vfunc_alpha_scale__65__value;
    __Vfunc_alpha_scale__65__value = 0;
    IData/*31:0*/ __Vfunc_msg_from_signed__66__value;
    __Vfunc_msg_from_signed__66__value = 0;
    CData/*3:0*/ __Vfunc_msg_from_signed__66____VlefCall_0__mag_from_int;
    __Vfunc_msg_from_signed__66____VlefCall_0__mag_from_int = 0;
    CData/*4:0*/ __Vfunc_msg_from_signed__66__msg;
    __Vfunc_msg_from_signed__66__msg = 0;
    IData/*31:0*/ __Vfunc_msg_from_signed__66__abs_value;
    __Vfunc_msg_from_signed__66__abs_value = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__67__Vfuncout;
    __Vfunc_mag_from_int__67__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_mag_from_int__67__value;
    __Vfunc_mag_from_int__67__value = 0;
    IData/*31:0*/ __Vfunc_mag_from_int__67__clamped_value;
    __Vfunc_mag_from_int__67__clamped_value = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__67__result;
    __Vfunc_mag_from_int__67__result = 0;
    IData/*31:0*/ __Vfunc_clamp_int__68__value;
    __Vfunc_clamp_int__68__value = 0;
    CData/*4:0*/ __Vfunc_msg_pack__69__Vfuncout;
    __Vfunc_msg_pack__69__Vfuncout = 0;
    CData/*0:0*/ __Vfunc_msg_pack__69__sign;
    __Vfunc_msg_pack__69__sign = 0;
    CData/*3:0*/ __Vfunc_msg_pack__69__mag;
    __Vfunc_msg_pack__69__mag = 0;
    // Body
    tb_mdpc_vnu__DOT__dut__DOT__gamma_value = VL_EXTENDS_II(32,8, (IData)(vlSelfRef.tb_mdpc_vnu__DOT__gamma_in));
    __Vfunc_msg_to_signed__60__msg = vlSelfRef.tb_mdpc_vnu__DOT__c2v_in[0U];
    {
        vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_0__msg_to_signed = 0U;
        vlSelfRef.__Vfunc_msg_to_signed__60__mag_value = 0U;
        vlSelfRef.__Vfunc_msg_mag__61__msg = __Vfunc_msg_to_signed__60__msg;
        vlSelf->__Vfunc_msg_mag__61__Vfuncout = 0;
        vlSelfRef.__Vfunc_msg_mag__61__Vfuncout = (0x0000000fU 
                                                   & (IData)(vlSelfRef.__Vfunc_msg_mag__61__msg));
        vlSelfRef.__Vfunc_msg_to_signed__60____VlefCall_0__msg_mag 
            = vlSelfRef.__Vfunc_msg_mag__61__Vfuncout;
        vlSelfRef.__Vfunc_msg_to_signed__60__mag_value 
            = vlSelfRef.__Vfunc_msg_to_signed__60____VlefCall_0__msg_mag;
        vlSelfRef.__Vfunc_msg_sign__62__msg = __Vfunc_msg_to_signed__60__msg;
        vlSelf->__Vfunc_msg_sign__62__Vfuncout = 0;
        vlSelfRef.__Vfunc_msg_sign__62__Vfuncout = 
            (1U & ((IData)(vlSelfRef.__Vfunc_msg_sign__62__msg) 
                   >> 4U));
        vlSelfRef.__Vfunc_msg_to_signed__60____VlefCall_1__msg_sign 
            = vlSelfRef.__Vfunc_msg_sign__62__Vfuncout;
        if (vlSelfRef.__Vfunc_msg_to_signed__60____VlefCall_1__msg_sign) {
            vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_0__msg_to_signed 
                = (- vlSelfRef.__Vfunc_msg_to_signed__60__mag_value);
            goto __Vlabel0;
        }
        vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_0__msg_to_signed 
            = vlSelfRef.__Vfunc_msg_to_signed__60__mag_value;
        __Vlabel0: ;
    }
    tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h619e30fe__0 
        = vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_0__msg_to_signed;
    vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT__signed_c2v[0U] 
        = tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h619e30fe__0;
    tb_mdpc_vnu__DOT__dut__DOT__sum_c2v = vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT__signed_c2v[0U];
    __Vfunc_msg_to_signed__60__msg = vlSelfRef.tb_mdpc_vnu__DOT__c2v_in[1U];
    {
        vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_0__msg_to_signed = 0U;
        vlSelfRef.__Vfunc_msg_to_signed__60__mag_value = 0U;
        vlSelfRef.__Vfunc_msg_mag__61__msg = __Vfunc_msg_to_signed__60__msg;
        vlSelf->__Vfunc_msg_mag__61__Vfuncout = 0;
        vlSelfRef.__Vfunc_msg_mag__61__Vfuncout = (0x0000000fU 
                                                   & (IData)(vlSelfRef.__Vfunc_msg_mag__61__msg));
        vlSelfRef.__Vfunc_msg_to_signed__60____VlefCall_0__msg_mag 
            = vlSelfRef.__Vfunc_msg_mag__61__Vfuncout;
        vlSelfRef.__Vfunc_msg_to_signed__60__mag_value 
            = vlSelfRef.__Vfunc_msg_to_signed__60____VlefCall_0__msg_mag;
        vlSelfRef.__Vfunc_msg_sign__62__msg = __Vfunc_msg_to_signed__60__msg;
        vlSelf->__Vfunc_msg_sign__62__Vfuncout = 0;
        vlSelfRef.__Vfunc_msg_sign__62__Vfuncout = 
            (1U & ((IData)(vlSelfRef.__Vfunc_msg_sign__62__msg) 
                   >> 4U));
        vlSelfRef.__Vfunc_msg_to_signed__60____VlefCall_1__msg_sign 
            = vlSelfRef.__Vfunc_msg_sign__62__Vfuncout;
        if (vlSelfRef.__Vfunc_msg_to_signed__60____VlefCall_1__msg_sign) {
            vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_0__msg_to_signed 
                = (- vlSelfRef.__Vfunc_msg_to_signed__60__mag_value);
            goto __Vlabel1;
        }
        vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_0__msg_to_signed 
            = vlSelfRef.__Vfunc_msg_to_signed__60__mag_value;
        __Vlabel1: ;
    }
    tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h619e30fe__0 
        = vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_0__msg_to_signed;
    vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT__signed_c2v[1U] 
        = tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h619e30fe__0;
    tb_mdpc_vnu__DOT__dut__DOT__sum_c2v = (tb_mdpc_vnu__DOT__dut__DOT__sum_c2v 
                                           + vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT__signed_c2v[1U]);
    __Vfunc_msg_to_signed__60__msg = vlSelfRef.tb_mdpc_vnu__DOT__c2v_in[2U];
    {
        vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_0__msg_to_signed = 0U;
        vlSelfRef.__Vfunc_msg_to_signed__60__mag_value = 0U;
        vlSelfRef.__Vfunc_msg_mag__61__msg = __Vfunc_msg_to_signed__60__msg;
        vlSelf->__Vfunc_msg_mag__61__Vfuncout = 0;
        vlSelfRef.__Vfunc_msg_mag__61__Vfuncout = (0x0000000fU 
                                                   & (IData)(vlSelfRef.__Vfunc_msg_mag__61__msg));
        vlSelfRef.__Vfunc_msg_to_signed__60____VlefCall_0__msg_mag 
            = vlSelfRef.__Vfunc_msg_mag__61__Vfuncout;
        vlSelfRef.__Vfunc_msg_to_signed__60__mag_value 
            = vlSelfRef.__Vfunc_msg_to_signed__60____VlefCall_0__msg_mag;
        vlSelfRef.__Vfunc_msg_sign__62__msg = __Vfunc_msg_to_signed__60__msg;
        vlSelf->__Vfunc_msg_sign__62__Vfuncout = 0;
        vlSelfRef.__Vfunc_msg_sign__62__Vfuncout = 
            (1U & ((IData)(vlSelfRef.__Vfunc_msg_sign__62__msg) 
                   >> 4U));
        vlSelfRef.__Vfunc_msg_to_signed__60____VlefCall_1__msg_sign 
            = vlSelfRef.__Vfunc_msg_sign__62__Vfuncout;
        if (vlSelfRef.__Vfunc_msg_to_signed__60____VlefCall_1__msg_sign) {
            vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_0__msg_to_signed 
                = (- vlSelfRef.__Vfunc_msg_to_signed__60__mag_value);
            goto __Vlabel2;
        }
        vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_0__msg_to_signed 
            = vlSelfRef.__Vfunc_msg_to_signed__60__mag_value;
        __Vlabel2: ;
    }
    tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h619e30fe__0 
        = vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_0__msg_to_signed;
    vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT__signed_c2v[2U] 
        = tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h619e30fe__0;
    tb_mdpc_vnu__DOT__dut__DOT__sum_c2v = (tb_mdpc_vnu__DOT__dut__DOT__sum_c2v 
                                           + vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT__signed_c2v[2U]);
    __Vfunc_alpha_scale__63__value = tb_mdpc_vnu__DOT__dut__DOT__sum_c2v;
    {
        vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_1__alpha_scale = 0U;
        vlSelfRef.__Vfunc_alpha_scale__63__abs_value = 0U;
        vlSelfRef.__Vfunc_alpha_scale__63__scaled_abs = 0U;
        vlSelfRef.__Vfunc_alpha_scale__63__abs_value 
            = (VL_GTS_III(32, 0U, __Vfunc_alpha_scale__63__value)
                ? (- __Vfunc_alpha_scale__63__value)
                : __Vfunc_alpha_scale__63__value);
        vlSelfRef.__Vfunc_alpha_scale__63__scaled_abs 
            = VL_SHIFTRS_III(32,32,32, ((IData)(0x00000010U) 
                                        + VL_MULS_III(32, (IData)(3U), vlSelfRef.__Vfunc_alpha_scale__63__abs_value)), 5U);
        if (VL_GTS_III(32, 0U, __Vfunc_alpha_scale__63__value)) {
            vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_1__alpha_scale 
                = (- vlSelfRef.__Vfunc_alpha_scale__63__scaled_abs);
            goto __Vlabel3;
        }
        vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_1__alpha_scale 
            = vlSelfRef.__Vfunc_alpha_scale__63__scaled_abs;
        __Vlabel3: ;
    }
    tb_mdpc_vnu__DOT__dut__DOT__app_value = (tb_mdpc_vnu__DOT__dut__DOT__gamma_value 
                                             + vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_1__alpha_scale);
    __Vfunc_app_from_int__64__value = tb_mdpc_vnu__DOT__dut__DOT__app_value;
    __Vfunc_app_from_int__64__app_value_int = __Vfunc_app_from_int__64__value;
    __Vfunc_app_from_int__64__result = (0x000000ffU 
                                        & __Vfunc_app_from_int__64__app_value_int);
    __Vfunc_app_from_int__64__Vfuncout = __Vfunc_app_from_int__64__result;
    vlSelfRef.tb_mdpc_vnu__DOT__app_out = __Vfunc_app_from_int__64__Vfuncout;
    vlSelfRef.tb_mdpc_vnu__DOT__x_out = VL_GTS_III(32, 0U, tb_mdpc_vnu__DOT__dut__DOT__app_value);
    __Vfunc_alpha_scale__65__value = vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT__signed_c2v[0U];
    {
        vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_2__alpha_scale = 0U;
        vlSelfRef.__Vfunc_alpha_scale__65__abs_value = 0U;
        vlSelfRef.__Vfunc_alpha_scale__65__scaled_abs = 0U;
        vlSelfRef.__Vfunc_alpha_scale__65__abs_value 
            = (VL_GTS_III(32, 0U, __Vfunc_alpha_scale__65__value)
                ? (- __Vfunc_alpha_scale__65__value)
                : __Vfunc_alpha_scale__65__value);
        vlSelfRef.__Vfunc_alpha_scale__65__scaled_abs 
            = VL_SHIFTRS_III(32,32,32, ((IData)(0x00000010U) 
                                        + VL_MULS_III(32, (IData)(3U), vlSelfRef.__Vfunc_alpha_scale__65__abs_value)), 5U);
        if (VL_GTS_III(32, 0U, __Vfunc_alpha_scale__65__value)) {
            vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_2__alpha_scale 
                = (- vlSelfRef.__Vfunc_alpha_scale__65__scaled_abs);
            goto __Vlabel4;
        }
        vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_2__alpha_scale 
            = vlSelfRef.__Vfunc_alpha_scale__65__scaled_abs;
        __Vlabel4: ;
    }
    tb_mdpc_vnu__DOT__dut__DOT__u_value = (tb_mdpc_vnu__DOT__dut__DOT__app_value 
                                           - vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_2__alpha_scale);
    __Vfunc_msg_from_signed__66__value = tb_mdpc_vnu__DOT__dut__DOT__u_value;
    __Vfunc_msg_from_signed__66__abs_value = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__66__value)
                                               ? (- __Vfunc_msg_from_signed__66__value)
                                               : __Vfunc_msg_from_signed__66__value);
    __Vfunc_mag_from_int__67__value = __Vfunc_msg_from_signed__66__abs_value;
    __Vfunc_clamp_int__68__value = __Vfunc_mag_from_int__67__value;
    {
        vlSelfRef.__Vfunc_clamp_int__68__Vfuncout = 0U;
        if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__68__value)) {
            vlSelfRef.__Vfunc_clamp_int__68__Vfuncout = 0U;
            goto __Vlabel5;
        }
        if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__68__value)) {
            vlSelfRef.__Vfunc_clamp_int__68__Vfuncout = 0x0000000fU;
            goto __Vlabel5;
        }
        vlSelfRef.__Vfunc_clamp_int__68__Vfuncout = __Vfunc_clamp_int__68__value;
        __Vlabel5: ;
    }
    __Vfunc_mag_from_int__67__clamped_value = vlSelfRef.__Vfunc_clamp_int__68__Vfuncout;
    __Vfunc_mag_from_int__67__result = (0x0000000fU 
                                        & __Vfunc_mag_from_int__67__clamped_value);
    __Vfunc_mag_from_int__67__Vfuncout = __Vfunc_mag_from_int__67__result;
    __Vfunc_msg_from_signed__66____VlefCall_0__mag_from_int 
        = __Vfunc_mag_from_int__67__Vfuncout;
    __Vfunc_msg_pack__69__mag = __Vfunc_msg_from_signed__66____VlefCall_0__mag_from_int;
    __Vfunc_msg_pack__69__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__66__value);
    __Vfunc_msg_pack__69__Vfuncout = (((IData)(__Vfunc_msg_pack__69__sign) 
                                       << 4U) | (IData)(__Vfunc_msg_pack__69__mag));
    __Vfunc_msg_from_signed__66__msg = __Vfunc_msg_pack__69__Vfuncout;
    tb_mdpc_vnu__DOT__dut__DOT____VlemCall_3__msg_from_signed 
        = __Vfunc_msg_from_signed__66__msg;
    tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h02a35ea2__0 
        = tb_mdpc_vnu__DOT__dut__DOT____VlemCall_3__msg_from_signed;
    vlSelfRef.tb_mdpc_vnu__DOT__u_next_out[0U] = tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h02a35ea2__0;
    __Vfunc_alpha_scale__65__value = vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT__signed_c2v[1U];
    {
        vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_2__alpha_scale = 0U;
        vlSelfRef.__Vfunc_alpha_scale__65__abs_value = 0U;
        vlSelfRef.__Vfunc_alpha_scale__65__scaled_abs = 0U;
        vlSelfRef.__Vfunc_alpha_scale__65__abs_value 
            = (VL_GTS_III(32, 0U, __Vfunc_alpha_scale__65__value)
                ? (- __Vfunc_alpha_scale__65__value)
                : __Vfunc_alpha_scale__65__value);
        vlSelfRef.__Vfunc_alpha_scale__65__scaled_abs 
            = VL_SHIFTRS_III(32,32,32, ((IData)(0x00000010U) 
                                        + VL_MULS_III(32, (IData)(3U), vlSelfRef.__Vfunc_alpha_scale__65__abs_value)), 5U);
        if (VL_GTS_III(32, 0U, __Vfunc_alpha_scale__65__value)) {
            vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_2__alpha_scale 
                = (- vlSelfRef.__Vfunc_alpha_scale__65__scaled_abs);
            goto __Vlabel6;
        }
        vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_2__alpha_scale 
            = vlSelfRef.__Vfunc_alpha_scale__65__scaled_abs;
        __Vlabel6: ;
    }
    tb_mdpc_vnu__DOT__dut__DOT__u_value = (tb_mdpc_vnu__DOT__dut__DOT__app_value 
                                           - vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_2__alpha_scale);
    __Vfunc_msg_from_signed__66__value = tb_mdpc_vnu__DOT__dut__DOT__u_value;
    __Vfunc_msg_from_signed__66__abs_value = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__66__value)
                                               ? (- __Vfunc_msg_from_signed__66__value)
                                               : __Vfunc_msg_from_signed__66__value);
    __Vfunc_mag_from_int__67__value = __Vfunc_msg_from_signed__66__abs_value;
    __Vfunc_clamp_int__68__value = __Vfunc_mag_from_int__67__value;
    {
        vlSelfRef.__Vfunc_clamp_int__68__Vfuncout = 0U;
        if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__68__value)) {
            vlSelfRef.__Vfunc_clamp_int__68__Vfuncout = 0U;
            goto __Vlabel7;
        }
        if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__68__value)) {
            vlSelfRef.__Vfunc_clamp_int__68__Vfuncout = 0x0000000fU;
            goto __Vlabel7;
        }
        vlSelfRef.__Vfunc_clamp_int__68__Vfuncout = __Vfunc_clamp_int__68__value;
        __Vlabel7: ;
    }
    __Vfunc_mag_from_int__67__clamped_value = vlSelfRef.__Vfunc_clamp_int__68__Vfuncout;
    __Vfunc_mag_from_int__67__result = (0x0000000fU 
                                        & __Vfunc_mag_from_int__67__clamped_value);
    __Vfunc_mag_from_int__67__Vfuncout = __Vfunc_mag_from_int__67__result;
    __Vfunc_msg_from_signed__66____VlefCall_0__mag_from_int 
        = __Vfunc_mag_from_int__67__Vfuncout;
    __Vfunc_msg_pack__69__mag = __Vfunc_msg_from_signed__66____VlefCall_0__mag_from_int;
    __Vfunc_msg_pack__69__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__66__value);
    __Vfunc_msg_pack__69__Vfuncout = (((IData)(__Vfunc_msg_pack__69__sign) 
                                       << 4U) | (IData)(__Vfunc_msg_pack__69__mag));
    __Vfunc_msg_from_signed__66__msg = __Vfunc_msg_pack__69__Vfuncout;
    tb_mdpc_vnu__DOT__dut__DOT____VlemCall_3__msg_from_signed 
        = __Vfunc_msg_from_signed__66__msg;
    tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h02a35ea2__0 
        = tb_mdpc_vnu__DOT__dut__DOT____VlemCall_3__msg_from_signed;
    vlSelfRef.tb_mdpc_vnu__DOT__u_next_out[1U] = tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h02a35ea2__0;
    __Vfunc_alpha_scale__65__value = vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT__signed_c2v[2U];
    {
        vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_2__alpha_scale = 0U;
        vlSelfRef.__Vfunc_alpha_scale__65__abs_value = 0U;
        vlSelfRef.__Vfunc_alpha_scale__65__scaled_abs = 0U;
        vlSelfRef.__Vfunc_alpha_scale__65__abs_value 
            = (VL_GTS_III(32, 0U, __Vfunc_alpha_scale__65__value)
                ? (- __Vfunc_alpha_scale__65__value)
                : __Vfunc_alpha_scale__65__value);
        vlSelfRef.__Vfunc_alpha_scale__65__scaled_abs 
            = VL_SHIFTRS_III(32,32,32, ((IData)(0x00000010U) 
                                        + VL_MULS_III(32, (IData)(3U), vlSelfRef.__Vfunc_alpha_scale__65__abs_value)), 5U);
        if (VL_GTS_III(32, 0U, __Vfunc_alpha_scale__65__value)) {
            vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_2__alpha_scale 
                = (- vlSelfRef.__Vfunc_alpha_scale__65__scaled_abs);
            goto __Vlabel8;
        }
        vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_2__alpha_scale 
            = vlSelfRef.__Vfunc_alpha_scale__65__scaled_abs;
        __Vlabel8: ;
    }
    tb_mdpc_vnu__DOT__dut__DOT__u_value = (tb_mdpc_vnu__DOT__dut__DOT__app_value 
                                           - vlSelfRef.tb_mdpc_vnu__DOT__dut__DOT____VlemCall_2__alpha_scale);
    __Vfunc_msg_from_signed__66__value = tb_mdpc_vnu__DOT__dut__DOT__u_value;
    __Vfunc_msg_from_signed__66__abs_value = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__66__value)
                                               ? (- __Vfunc_msg_from_signed__66__value)
                                               : __Vfunc_msg_from_signed__66__value);
    __Vfunc_mag_from_int__67__value = __Vfunc_msg_from_signed__66__abs_value;
    __Vfunc_clamp_int__68__value = __Vfunc_mag_from_int__67__value;
    {
        vlSelfRef.__Vfunc_clamp_int__68__Vfuncout = 0U;
        if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__68__value)) {
            vlSelfRef.__Vfunc_clamp_int__68__Vfuncout = 0U;
            goto __Vlabel9;
        }
        if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__68__value)) {
            vlSelfRef.__Vfunc_clamp_int__68__Vfuncout = 0x0000000fU;
            goto __Vlabel9;
        }
        vlSelfRef.__Vfunc_clamp_int__68__Vfuncout = __Vfunc_clamp_int__68__value;
        __Vlabel9: ;
    }
    __Vfunc_mag_from_int__67__clamped_value = vlSelfRef.__Vfunc_clamp_int__68__Vfuncout;
    __Vfunc_mag_from_int__67__result = (0x0000000fU 
                                        & __Vfunc_mag_from_int__67__clamped_value);
    __Vfunc_mag_from_int__67__Vfuncout = __Vfunc_mag_from_int__67__result;
    __Vfunc_msg_from_signed__66____VlefCall_0__mag_from_int 
        = __Vfunc_mag_from_int__67__Vfuncout;
    __Vfunc_msg_pack__69__mag = __Vfunc_msg_from_signed__66____VlefCall_0__mag_from_int;
    __Vfunc_msg_pack__69__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__66__value);
    __Vfunc_msg_pack__69__Vfuncout = (((IData)(__Vfunc_msg_pack__69__sign) 
                                       << 4U) | (IData)(__Vfunc_msg_pack__69__mag));
    __Vfunc_msg_from_signed__66__msg = __Vfunc_msg_pack__69__Vfuncout;
    tb_mdpc_vnu__DOT__dut__DOT____VlemCall_3__msg_from_signed 
        = __Vfunc_msg_from_signed__66__msg;
    tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h02a35ea2__0 
        = tb_mdpc_vnu__DOT__dut__DOT____VlemCall_3__msg_from_signed;
    vlSelfRef.tb_mdpc_vnu__DOT__u_next_out[2U] = tb_mdpc_vnu__DOT__dut__DOT____Vlvbound_h02a35ea2__0;
}

void Vtb_mdpc_vnu___024root___eval_nba(Vtb_mdpc_vnu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_vnu___024root___eval_nba\n"); );
    Vtb_mdpc_vnu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vtb_mdpc_vnu___024root___nba_sequent__TOP__0(vlSelf);
    }
}

void Vtb_mdpc_vnu___024root___timing_resume(Vtb_mdpc_vnu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_vnu___024root___timing_resume\n"); );
    Vtb_mdpc_vnu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VdlySched.resume();
    }
}

void Vtb_mdpc_vnu___024root___trigger_orInto__act_vec_vec(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_vnu___024root___trigger_orInto__act_vec_vec\n"); );
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
VL_ATTR_COLD void Vtb_mdpc_vnu___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

bool Vtb_mdpc_vnu___024root___eval_phase__act(Vtb_mdpc_vnu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_vnu___024root___eval_phase__act\n"); );
    Vtb_mdpc_vnu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VactExecute;
    // Body
    Vtb_mdpc_vnu___024root___eval_triggers_vec__act(vlSelf);
    Vtb_mdpc_vnu___024root___trigger_orInto__act_vec_vec(vlSelfRef.__VactTriggered, vlSelfRef.__VactTriggeredAcc);
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_mdpc_vnu___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
    }
#endif
    Vtb_mdpc_vnu___024root___trigger_orInto__act_vec_vec(vlSelfRef.__VnbaTriggered, vlSelfRef.__VactTriggered);
    __VactExecute = Vtb_mdpc_vnu___024root___trigger_anySet__act(vlSelfRef.__VactTriggered);
    if (__VactExecute) {
        vlSelfRef.__VactTriggeredAcc.fill(0ULL);
        Vtb_mdpc_vnu___024root___timing_resume(vlSelf);
        Vtb_mdpc_vnu___024root___eval_act(vlSelf);
    }
    return (__VactExecute);
}

bool Vtb_mdpc_vnu___024root___eval_phase__inact(Vtb_mdpc_vnu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_vnu___024root___eval_phase__inact\n"); );
    Vtb_mdpc_vnu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VinactExecute;
    // Body
    __VinactExecute = vlSelfRef.__VdlySched.awaitingZeroDelay();
    if (__VinactExecute) {
        VL_FATAL_MT("tb/tb_mdpc_vnu.sv", 5, "", "ZERODLY: Design Verilated with '--no-sched-zero-delay', but #0 delay executed at runtime");
    }
    return (__VinactExecute);
}

void Vtb_mdpc_vnu___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_vnu___024root___trigger_clear__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = 0ULL;
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

bool Vtb_mdpc_vnu___024root___eval_phase__nba(Vtb_mdpc_vnu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_vnu___024root___eval_phase__nba\n"); );
    Vtb_mdpc_vnu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = Vtb_mdpc_vnu___024root___trigger_anySet__act(vlSelfRef.__VnbaTriggered);
    if (__VnbaExecute) {
        Vtb_mdpc_vnu___024root___eval_nba(vlSelf);
        Vtb_mdpc_vnu___024root___trigger_clear__act(vlSelfRef.__VnbaTriggered);
    }
    return (__VnbaExecute);
}

void Vtb_mdpc_vnu___024root___eval(Vtb_mdpc_vnu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_vnu___024root___eval\n"); );
    Vtb_mdpc_vnu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VnbaIterCount;
    // Body
    __VnbaIterCount = 0U;
    do {
        if (VL_UNLIKELY(((0x00002710U < __VnbaIterCount)))) {
#ifdef VL_DEBUG
            Vtb_mdpc_vnu___024root___dump_triggers__act(vlSelfRef.__VnbaTriggered, "nba"s);
#endif
            VL_FATAL_MT("tb/tb_mdpc_vnu.sv", 5, "", "DIDNOTCONVERGE: NBA region did not converge after '--converge-limit' of 10000 tries");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        vlSelfRef.__VinactIterCount = 0U;
        do {
            if (VL_UNLIKELY(((0x00002710U < vlSelfRef.__VinactIterCount)))) {
                VL_FATAL_MT("tb/tb_mdpc_vnu.sv", 5, "", "DIDNOTCONVERGE: Inactive region did not converge after '--converge-limit' of 10000 tries");
            }
            vlSelfRef.__VinactIterCount = ((IData)(1U) 
                                           + vlSelfRef.__VinactIterCount);
            vlSelfRef.__VactIterCount = 0U;
            do {
                if (VL_UNLIKELY(((0x00002710U < vlSelfRef.__VactIterCount)))) {
#ifdef VL_DEBUG
                    Vtb_mdpc_vnu___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
#endif
                    VL_FATAL_MT("tb/tb_mdpc_vnu.sv", 5, "", "DIDNOTCONVERGE: Active region did not converge after '--converge-limit' of 10000 tries");
                }
                vlSelfRef.__VactIterCount = ((IData)(1U) 
                                             + vlSelfRef.__VactIterCount);
                vlSelfRef.__VactPhaseResult = Vtb_mdpc_vnu___024root___eval_phase__act(vlSelf);
            } while (vlSelfRef.__VactPhaseResult);
            vlSelfRef.__VinactPhaseResult = Vtb_mdpc_vnu___024root___eval_phase__inact(vlSelf);
        } while (vlSelfRef.__VinactPhaseResult);
        vlSelfRef.__VnbaPhaseResult = Vtb_mdpc_vnu___024root___eval_phase__nba(vlSelf);
    } while (vlSelfRef.__VnbaPhaseResult);
}

#ifdef VL_DEBUG
void Vtb_mdpc_vnu___024root___eval_debug_assertions(Vtb_mdpc_vnu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_vnu___024root___eval_debug_assertions\n"); );
    Vtb_mdpc_vnu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}
#endif  // VL_DEBUG
