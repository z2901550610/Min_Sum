// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_mdpc_cnu_b.h for the primary calling header

#include "Vtb_mdpc_cnu_b__pch.h"

VlCoroutine Vtb_mdpc_cnu_b___024root___eval_initial__TOP__Vtiming__0(Vtb_mdpc_cnu_b___024root* vlSelf);

void Vtb_mdpc_cnu_b___024root___eval_initial(Vtb_mdpc_cnu_b___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_b___024root___eval_initial\n"); );
    Vtb_mdpc_cnu_b__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vtb_mdpc_cnu_b___024root___eval_initial__TOP__Vtiming__0(vlSelf);
}

VlCoroutine Vtb_mdpc_cnu_b___024root___eval_initial__TOP__Vtiming__0(Vtb_mdpc_cnu_b___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_b___024root___eval_initial__TOP__Vtiming__0\n"); );
    Vtb_mdpc_cnu_b__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ tb_mdpc_cnu_b__DOT____VlemCall_8__msg_sign;
    CData/*3:0*/ tb_mdpc_cnu_b__DOT____VlemCall_6__msg_mag;
    CData/*0:0*/ tb_mdpc_cnu_b__DOT____VlemCall_4__msg_sign;
    CData/*3:0*/ tb_mdpc_cnu_b__DOT____VlemCall_2__msg_mag;
    CData/*3:0*/ tb_mdpc_cnu_b__DOT____VlemCall_1__mag_from_int;
    CData/*3:0*/ tb_mdpc_cnu_b__DOT____VlemCall_0__mag_from_int;
    IData/*31:0*/ __Vfunc_mag_from_int__0__clamped_value;
    __Vfunc_mag_from_int__0__clamped_value = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__0__result;
    __Vfunc_mag_from_int__0__result = 0;
    IData/*31:0*/ __Vfunc_clamp_int__1__Vfuncout;
    __Vfunc_clamp_int__1__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_clamp_int__1__value;
    __Vfunc_clamp_int__1__value = 0;
    IData/*31:0*/ __Vfunc_clamp_int__1__lo;
    __Vfunc_clamp_int__1__lo = 0;
    IData/*31:0*/ __Vfunc_clamp_int__1__hi;
    __Vfunc_clamp_int__1__hi = 0;
    IData/*31:0*/ __Vfunc_mag_from_int__2__clamped_value;
    __Vfunc_mag_from_int__2__clamped_value = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__2__result;
    __Vfunc_mag_from_int__2__result = 0;
    IData/*31:0*/ __Vfunc_clamp_int__3__Vfuncout;
    __Vfunc_clamp_int__3__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_clamp_int__3__value;
    __Vfunc_clamp_int__3__value = 0;
    IData/*31:0*/ __Vfunc_clamp_int__3__lo;
    __Vfunc_clamp_int__3__lo = 0;
    IData/*31:0*/ __Vfunc_clamp_int__3__hi;
    __Vfunc_clamp_int__3__hi = 0;
    SData/*14:0*/ __Vfunc_row_state_pack__4__Vfuncout;
    __Vfunc_row_state_pack__4__Vfuncout = 0;
    CData/*3:0*/ __Vfunc_row_state_pack__4__min1;
    __Vfunc_row_state_pack__4__min1 = 0;
    CData/*3:0*/ __Vfunc_row_state_pack__4__min2;
    __Vfunc_row_state_pack__4__min2 = 0;
    CData/*4:0*/ __Vfunc_msg_mag__5__msg;
    __Vfunc_msg_mag__5__msg = 0;
    CData/*4:0*/ __Vfunc_msg_mag__6__msg;
    __Vfunc_msg_mag__6__msg = 0;
    CData/*4:0*/ __Vfunc_msg_sign__7__msg;
    __Vfunc_msg_sign__7__msg = 0;
    CData/*4:0*/ __Vfunc_msg_sign__8__msg;
    __Vfunc_msg_sign__8__msg = 0;
    CData/*4:0*/ __Vfunc_msg_mag__9__msg;
    __Vfunc_msg_mag__9__msg = 0;
    CData/*4:0*/ __Vfunc_msg_mag__10__msg;
    __Vfunc_msg_mag__10__msg = 0;
    CData/*4:0*/ __Vfunc_msg_sign__11__msg;
    __Vfunc_msg_sign__11__msg = 0;
    CData/*4:0*/ __Vfunc_msg_sign__12__msg;
    __Vfunc_msg_sign__12__msg = 0;
    // Body
    __Vfunc_clamp_int__1__hi = 0x0000000fU;
    __Vfunc_clamp_int__1__lo = 0U;
    __Vfunc_clamp_int__1__value = 2U;
    {
        __Vfunc_clamp_int__1__Vfuncout = 0U;
        if (VL_LTS_III(32, __Vfunc_clamp_int__1__value, __Vfunc_clamp_int__1__lo)) {
            __Vfunc_clamp_int__1__Vfuncout = __Vfunc_clamp_int__1__lo;
            goto __Vlabel0;
        }
        if (VL_GTS_III(32, __Vfunc_clamp_int__1__value, __Vfunc_clamp_int__1__hi)) {
            __Vfunc_clamp_int__1__Vfuncout = __Vfunc_clamp_int__1__hi;
            goto __Vlabel0;
        }
        __Vfunc_clamp_int__1__Vfuncout = __Vfunc_clamp_int__1__value;
        __Vlabel0: ;
    }
    __Vfunc_mag_from_int__0__clamped_value = __Vfunc_clamp_int__1__Vfuncout;
    __Vfunc_mag_from_int__0__result = (0x0000000fU 
                                       & __Vfunc_mag_from_int__0__clamped_value);
    tb_mdpc_cnu_b__DOT____VlemCall_0__mag_from_int 
        = __Vfunc_mag_from_int__0__result;
    __Vfunc_clamp_int__3__hi = 0x0000000fU;
    __Vfunc_clamp_int__3__lo = 0U;
    __Vfunc_clamp_int__3__value = 5U;
    {
        __Vfunc_clamp_int__3__Vfuncout = 0U;
        if (VL_LTS_III(32, __Vfunc_clamp_int__3__value, __Vfunc_clamp_int__3__lo)) {
            __Vfunc_clamp_int__3__Vfuncout = __Vfunc_clamp_int__3__lo;
            goto __Vlabel1;
        }
        if (VL_GTS_III(32, __Vfunc_clamp_int__3__value, __Vfunc_clamp_int__3__hi)) {
            __Vfunc_clamp_int__3__Vfuncout = __Vfunc_clamp_int__3__hi;
            goto __Vlabel1;
        }
        __Vfunc_clamp_int__3__Vfuncout = __Vfunc_clamp_int__3__value;
        __Vlabel1: ;
    }
    __Vfunc_mag_from_int__2__clamped_value = __Vfunc_clamp_int__3__Vfuncout;
    __Vfunc_mag_from_int__2__result = (0x0000000fU 
                                       & __Vfunc_mag_from_int__2__clamped_value);
    tb_mdpc_cnu_b__DOT____VlemCall_1__mag_from_int 
        = __Vfunc_mag_from_int__2__result;
    __Vfunc_row_state_pack__4__min2 = tb_mdpc_cnu_b__DOT____VlemCall_1__mag_from_int;
    __Vfunc_row_state_pack__4__min1 = tb_mdpc_cnu_b__DOT____VlemCall_0__mag_from_int;
    __Vfunc_row_state_pack__4__Vfuncout = (0x00007400U 
                                           | (((IData)(__Vfunc_row_state_pack__4__min2) 
                                               << 4U) 
                                              | (IData)(__Vfunc_row_state_pack__4__min1)));
    vlSelfRef.tb_mdpc_cnu_b__DOT__row_state_in = __Vfunc_row_state_pack__4__Vfuncout;
    vlSelfRef.tb_mdpc_cnu_b__DOT__u_sign_in = 1U;
    vlSelfRef.tb_mdpc_cnu_b__DOT__var_idx = 4U;
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "tb/tb_mdpc_cnu_b.sv", 
                                         23);
    __Vfunc_msg_mag__5__msg = vlSelfRef.tb_mdpc_cnu_b__DOT__dut__DOT__next_msg;
    tb_mdpc_cnu_b__DOT____VlemCall_2__msg_mag = 0;
    tb_mdpc_cnu_b__DOT____VlemCall_2__msg_mag = (0x0000000fU 
                                                 & (IData)(__Vfunc_msg_mag__5__msg));
    if (VL_UNLIKELY(((5U != (IData)(tb_mdpc_cnu_b__DOT____VlemCall_2__msg_mag))))) {
        __Vfunc_msg_mag__6__msg = vlSelfRef.tb_mdpc_cnu_b__DOT__dut__DOT__next_msg;
        vlSelf->tb_mdpc_cnu_b__DOT____VlemCall_3__msg_mag = 0;
        vlSelfRef.tb_mdpc_cnu_b__DOT____VlemCall_3__msg_mag 
            = (0x0000000fU & (IData)(__Vfunc_msg_mag__6__msg));
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_cnu_b.sv:24: Assertion failed in %m: expected min2 path mag=5, got %0d\n",4, 'M',vlSymsp->name(),"tb_mdpc_cnu_b", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',4,(IData)(vlSelfRef.tb_mdpc_cnu_b__DOT____VlemCall_3__msg_mag));
        VL_STOP_MT("tb/tb_mdpc_cnu_b.sv", 24, "", false);
    }
    __Vfunc_msg_sign__7__msg = vlSelfRef.tb_mdpc_cnu_b__DOT__dut__DOT__next_msg;
    tb_mdpc_cnu_b__DOT____VlemCall_4__msg_sign = 0;
    tb_mdpc_cnu_b__DOT____VlemCall_4__msg_sign = (1U 
                                                  & ((IData)(__Vfunc_msg_sign__7__msg) 
                                                     >> 4U));
    if (VL_UNLIKELY((tb_mdpc_cnu_b__DOT____VlemCall_4__msg_sign))) {
        __Vfunc_msg_sign__8__msg = vlSelfRef.tb_mdpc_cnu_b__DOT__dut__DOT__next_msg;
        vlSelf->tb_mdpc_cnu_b__DOT____VlemCall_5__msg_sign = 0;
        vlSelfRef.tb_mdpc_cnu_b__DOT____VlemCall_5__msg_sign 
            = (1U & ((IData)(__Vfunc_msg_sign__8__msg) 
                     >> 4U));
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_cnu_b.sv:25: Assertion failed in %m: expected sign xor result 0, got %0d\n",4, 'M',vlSymsp->name(),"tb_mdpc_cnu_b", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',1,(IData)(vlSelfRef.tb_mdpc_cnu_b__DOT____VlemCall_5__msg_sign));
        VL_STOP_MT("tb/tb_mdpc_cnu_b.sv", 25, "", false);
    }
    vlSelfRef.tb_mdpc_cnu_b__DOT__u_sign_in = 0U;
    vlSelfRef.tb_mdpc_cnu_b__DOT__var_idx = 6U;
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "tb/tb_mdpc_cnu_b.sv", 
                                         29);
    __Vfunc_msg_mag__9__msg = vlSelfRef.tb_mdpc_cnu_b__DOT__dut__DOT__next_msg;
    tb_mdpc_cnu_b__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_cnu_b__DOT____VlemCall_6__msg_mag = (0x0000000fU 
                                                 & (IData)(__Vfunc_msg_mag__9__msg));
    if (VL_UNLIKELY(((2U != (IData)(tb_mdpc_cnu_b__DOT____VlemCall_6__msg_mag))))) {
        __Vfunc_msg_mag__10__msg = vlSelfRef.tb_mdpc_cnu_b__DOT__dut__DOT__next_msg;
        vlSelf->tb_mdpc_cnu_b__DOT____VlemCall_7__msg_mag = 0;
        vlSelfRef.tb_mdpc_cnu_b__DOT____VlemCall_7__msg_mag 
            = (0x0000000fU & (IData)(__Vfunc_msg_mag__10__msg));
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_cnu_b.sv:30: Assertion failed in %m: expected min1 path mag=2, got %0d\n",4, 'M',vlSymsp->name(),"tb_mdpc_cnu_b", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',4,(IData)(vlSelfRef.tb_mdpc_cnu_b__DOT____VlemCall_7__msg_mag));
        VL_STOP_MT("tb/tb_mdpc_cnu_b.sv", 30, "", false);
    }
    __Vfunc_msg_sign__11__msg = vlSelfRef.tb_mdpc_cnu_b__DOT__dut__DOT__next_msg;
    tb_mdpc_cnu_b__DOT____VlemCall_8__msg_sign = 0;
    tb_mdpc_cnu_b__DOT____VlemCall_8__msg_sign = (1U 
                                                  & ((IData)(__Vfunc_msg_sign__11__msg) 
                                                     >> 4U));
    if (VL_UNLIKELY(((1U & (~ (IData)(tb_mdpc_cnu_b__DOT____VlemCall_8__msg_sign)))))) {
        __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_cnu_b__DOT__dut__DOT__next_msg;
        vlSelf->tb_mdpc_cnu_b__DOT____VlemCall_9__msg_sign = 0;
        vlSelfRef.tb_mdpc_cnu_b__DOT____VlemCall_9__msg_sign 
            = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                     >> 4U));
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_cnu_b.sv:31: Assertion failed in %m: expected sign xor result 1, got %0d\n",4, 'M',vlSymsp->name(),"tb_mdpc_cnu_b", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',1,(IData)(vlSelfRef.tb_mdpc_cnu_b__DOT____VlemCall_9__msg_sign));
        VL_STOP_MT("tb/tb_mdpc_cnu_b.sv", 31, "", false);
    }
    VL_WRITEF_NX("tb_mdpc_cnu_b PASS\n",0);
    VL_FINISH_MT("tb/tb_mdpc_cnu_b.sv", 34, "");
    co_return;
}

void Vtb_mdpc_cnu_b___024root___eval_triggers_vec__act(Vtb_mdpc_cnu_b___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_b___024root___eval_triggers_vec__act\n"); );
    Vtb_mdpc_cnu_b__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VactTriggered[0U] = (QData)((IData)(vlSelfRef.__VdlySched.awaitingCurrentTime()));
}

bool Vtb_mdpc_cnu_b___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_b___024root___trigger_anySet__act\n"); );
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

void Vtb_mdpc_cnu_b___024root___act_sequent__TOP__0(Vtb_mdpc_cnu_b___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_b___024root___act_sequent__TOP__0\n"); );
    Vtb_mdpc_cnu_b__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.tb_mdpc_cnu_b__DOT__dut__DOT__next_msg 
        = ((0x00000010U & ((0x00fffff0U & ((IData)(vlSelfRef.tb_mdpc_cnu_b__DOT__row_state_in) 
                                           >> 8U)) 
                           ^ ((IData)(vlSelfRef.tb_mdpc_cnu_b__DOT__u_sign_in) 
                              << 4U))) | (0x0000000fU 
                                          & (((IData)(vlSelfRef.tb_mdpc_cnu_b__DOT__var_idx) 
                                              == (0x0000000fU 
                                                  & ((IData)(vlSelfRef.tb_mdpc_cnu_b__DOT__row_state_in) 
                                                     >> 8U)))
                                              ? ((IData)(vlSelfRef.tb_mdpc_cnu_b__DOT__row_state_in) 
                                                 >> 4U)
                                              : (IData)(vlSelfRef.tb_mdpc_cnu_b__DOT__row_state_in))));
}

void Vtb_mdpc_cnu_b___024root___eval_act(Vtb_mdpc_cnu_b___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_b___024root___eval_act\n"); );
    Vtb_mdpc_cnu_b__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.tb_mdpc_cnu_b__DOT__dut__DOT__next_msg 
            = ((0x00000010U & ((0x00fffff0U & ((IData)(vlSelfRef.tb_mdpc_cnu_b__DOT__row_state_in) 
                                               >> 8U)) 
                               ^ ((IData)(vlSelfRef.tb_mdpc_cnu_b__DOT__u_sign_in) 
                                  << 4U))) | (0x0000000fU 
                                              & (((IData)(vlSelfRef.tb_mdpc_cnu_b__DOT__var_idx) 
                                                  == 
                                                  (0x0000000fU 
                                                   & ((IData)(vlSelfRef.tb_mdpc_cnu_b__DOT__row_state_in) 
                                                      >> 8U)))
                                                  ? 
                                                 ((IData)(vlSelfRef.tb_mdpc_cnu_b__DOT__row_state_in) 
                                                  >> 4U)
                                                  : (IData)(vlSelfRef.tb_mdpc_cnu_b__DOT__row_state_in))));
    }
}

void Vtb_mdpc_cnu_b___024root___eval_nba(Vtb_mdpc_cnu_b___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_b___024root___eval_nba\n"); );
    Vtb_mdpc_cnu_b__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VnbaTriggered[0U])) {
        vlSelfRef.tb_mdpc_cnu_b__DOT__dut__DOT__next_msg 
            = ((0x00000010U & ((0x00fffff0U & ((IData)(vlSelfRef.tb_mdpc_cnu_b__DOT__row_state_in) 
                                               >> 8U)) 
                               ^ ((IData)(vlSelfRef.tb_mdpc_cnu_b__DOT__u_sign_in) 
                                  << 4U))) | (0x0000000fU 
                                              & (((IData)(vlSelfRef.tb_mdpc_cnu_b__DOT__var_idx) 
                                                  == 
                                                  (0x0000000fU 
                                                   & ((IData)(vlSelfRef.tb_mdpc_cnu_b__DOT__row_state_in) 
                                                      >> 8U)))
                                                  ? 
                                                 ((IData)(vlSelfRef.tb_mdpc_cnu_b__DOT__row_state_in) 
                                                  >> 4U)
                                                  : (IData)(vlSelfRef.tb_mdpc_cnu_b__DOT__row_state_in))));
    }
}

void Vtb_mdpc_cnu_b___024root___timing_resume(Vtb_mdpc_cnu_b___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_b___024root___timing_resume\n"); );
    Vtb_mdpc_cnu_b__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VdlySched.resume();
    }
}

void Vtb_mdpc_cnu_b___024root___trigger_orInto__act_vec_vec(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_b___024root___trigger_orInto__act_vec_vec\n"); );
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
VL_ATTR_COLD void Vtb_mdpc_cnu_b___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

bool Vtb_mdpc_cnu_b___024root___eval_phase__act(Vtb_mdpc_cnu_b___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_b___024root___eval_phase__act\n"); );
    Vtb_mdpc_cnu_b__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VactExecute;
    // Body
    Vtb_mdpc_cnu_b___024root___eval_triggers_vec__act(vlSelf);
    Vtb_mdpc_cnu_b___024root___trigger_orInto__act_vec_vec(vlSelfRef.__VactTriggered, vlSelfRef.__VactTriggeredAcc);
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_mdpc_cnu_b___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
    }
#endif
    Vtb_mdpc_cnu_b___024root___trigger_orInto__act_vec_vec(vlSelfRef.__VnbaTriggered, vlSelfRef.__VactTriggered);
    __VactExecute = Vtb_mdpc_cnu_b___024root___trigger_anySet__act(vlSelfRef.__VactTriggered);
    if (__VactExecute) {
        vlSelfRef.__VactTriggeredAcc.fill(0ULL);
        Vtb_mdpc_cnu_b___024root___timing_resume(vlSelf);
        Vtb_mdpc_cnu_b___024root___eval_act(vlSelf);
    }
    return (__VactExecute);
}

bool Vtb_mdpc_cnu_b___024root___eval_phase__inact(Vtb_mdpc_cnu_b___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_b___024root___eval_phase__inact\n"); );
    Vtb_mdpc_cnu_b__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VinactExecute;
    // Body
    __VinactExecute = vlSelfRef.__VdlySched.awaitingZeroDelay();
    if (__VinactExecute) {
        VL_FATAL_MT("tb/tb_mdpc_cnu_b.sv", 5, "", "ZERODLY: Design Verilated with '--no-sched-zero-delay', but #0 delay executed at runtime");
    }
    return (__VinactExecute);
}

void Vtb_mdpc_cnu_b___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_b___024root___trigger_clear__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = 0ULL;
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

bool Vtb_mdpc_cnu_b___024root___eval_phase__nba(Vtb_mdpc_cnu_b___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_b___024root___eval_phase__nba\n"); );
    Vtb_mdpc_cnu_b__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = Vtb_mdpc_cnu_b___024root___trigger_anySet__act(vlSelfRef.__VnbaTriggered);
    if (__VnbaExecute) {
        Vtb_mdpc_cnu_b___024root___eval_nba(vlSelf);
        Vtb_mdpc_cnu_b___024root___trigger_clear__act(vlSelfRef.__VnbaTriggered);
    }
    return (__VnbaExecute);
}

void Vtb_mdpc_cnu_b___024root___eval(Vtb_mdpc_cnu_b___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_b___024root___eval\n"); );
    Vtb_mdpc_cnu_b__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VnbaIterCount;
    // Body
    __VnbaIterCount = 0U;
    do {
        if (VL_UNLIKELY(((0x00002710U < __VnbaIterCount)))) {
#ifdef VL_DEBUG
            Vtb_mdpc_cnu_b___024root___dump_triggers__act(vlSelfRef.__VnbaTriggered, "nba"s);
#endif
            VL_FATAL_MT("tb/tb_mdpc_cnu_b.sv", 5, "", "DIDNOTCONVERGE: NBA region did not converge after '--converge-limit' of 10000 tries");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        vlSelfRef.__VinactIterCount = 0U;
        do {
            if (VL_UNLIKELY(((0x00002710U < vlSelfRef.__VinactIterCount)))) {
                VL_FATAL_MT("tb/tb_mdpc_cnu_b.sv", 5, "", "DIDNOTCONVERGE: Inactive region did not converge after '--converge-limit' of 10000 tries");
            }
            vlSelfRef.__VinactIterCount = ((IData)(1U) 
                                           + vlSelfRef.__VinactIterCount);
            vlSelfRef.__VactIterCount = 0U;
            do {
                if (VL_UNLIKELY(((0x00002710U < vlSelfRef.__VactIterCount)))) {
#ifdef VL_DEBUG
                    Vtb_mdpc_cnu_b___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
#endif
                    VL_FATAL_MT("tb/tb_mdpc_cnu_b.sv", 5, "", "DIDNOTCONVERGE: Active region did not converge after '--converge-limit' of 10000 tries");
                }
                vlSelfRef.__VactIterCount = ((IData)(1U) 
                                             + vlSelfRef.__VactIterCount);
                vlSelfRef.__VactPhaseResult = Vtb_mdpc_cnu_b___024root___eval_phase__act(vlSelf);
            } while (vlSelfRef.__VactPhaseResult);
            vlSelfRef.__VinactPhaseResult = Vtb_mdpc_cnu_b___024root___eval_phase__inact(vlSelf);
        } while (vlSelfRef.__VinactPhaseResult);
        vlSelfRef.__VnbaPhaseResult = Vtb_mdpc_cnu_b___024root___eval_phase__nba(vlSelf);
    } while (vlSelfRef.__VnbaPhaseResult);
}

#ifdef VL_DEBUG
void Vtb_mdpc_cnu_b___024root___eval_debug_assertions(Vtb_mdpc_cnu_b___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_b___024root___eval_debug_assertions\n"); );
    Vtb_mdpc_cnu_b__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}
#endif  // VL_DEBUG
