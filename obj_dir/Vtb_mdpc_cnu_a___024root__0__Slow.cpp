// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_mdpc_cnu_a.h for the primary calling header

#include "Vtb_mdpc_cnu_a__pch.h"

VL_ATTR_COLD void Vtb_mdpc_cnu_a___024root___eval_static(Vtb_mdpc_cnu_a___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_a___024root___eval_static\n"); );
    Vtb_mdpc_cnu_a__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    do {
        vlSelfRef.__VactTriggeredAcc[vlSelfRef.__Vi] 
            = vlSelfRef.__VactTriggered[vlSelfRef.__Vi];
        vlSelfRef.__Vi = ((IData)(1U) + vlSelfRef.__Vi);
    } while ((0U >= vlSelfRef.__Vi));
}

VL_ATTR_COLD void Vtb_mdpc_cnu_a___024root___eval_final(Vtb_mdpc_cnu_a___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_a___024root___eval_final\n"); );
    Vtb_mdpc_cnu_a__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_mdpc_cnu_a___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vtb_mdpc_cnu_a___024root___eval_phase__stl(Vtb_mdpc_cnu_a___024root* vlSelf);

VL_ATTR_COLD void Vtb_mdpc_cnu_a___024root___eval_settle(Vtb_mdpc_cnu_a___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_a___024root___eval_settle\n"); );
    Vtb_mdpc_cnu_a__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VstlIterCount;
    // Body
    __VstlIterCount = 0U;
    vlSelfRef.__VstlFirstIteration = 1U;
    do {
        if (VL_UNLIKELY(((0x00002710U < __VstlIterCount)))) {
#ifdef VL_DEBUG
            Vtb_mdpc_cnu_a___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
#endif
            VL_FATAL_MT("tb/tb_mdpc_cnu_a.sv", 5, "", "DIDNOTCONVERGE: Settle region did not converge after '--converge-limit' of 10000 tries");
        }
        __VstlIterCount = ((IData)(1U) + __VstlIterCount);
        vlSelfRef.__VstlPhaseResult = Vtb_mdpc_cnu_a___024root___eval_phase__stl(vlSelf);
        vlSelfRef.__VstlFirstIteration = 0U;
    } while (vlSelfRef.__VstlPhaseResult);
}

VL_ATTR_COLD void Vtb_mdpc_cnu_a___024root___eval_triggers_vec__stl(Vtb_mdpc_cnu_a___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_a___024root___eval_triggers_vec__stl\n"); );
    Vtb_mdpc_cnu_a__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VstlTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VstlTriggered[0U]) 
                                     | (IData)((IData)(vlSelfRef.__VstlFirstIteration)));
}

VL_ATTR_COLD bool Vtb_mdpc_cnu_a___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_mdpc_cnu_a___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_a___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_mdpc_cnu_a___024root___trigger_anySet__stl(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD bool Vtb_mdpc_cnu_a___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_a___024root___trigger_anySet__stl\n"); );
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

VL_ATTR_COLD void Vtb_mdpc_cnu_a___024root___stl_sequent__TOP__0(Vtb_mdpc_cnu_a___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_a___024root___stl_sequent__TOP__0\n"); );
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

VL_ATTR_COLD void Vtb_mdpc_cnu_a___024root___eval_stl(Vtb_mdpc_cnu_a___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_a___024root___eval_stl\n"); );
    Vtb_mdpc_cnu_a__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VstlTriggered[0U])) {
        Vtb_mdpc_cnu_a___024root___stl_sequent__TOP__0(vlSelf);
    }
}

VL_ATTR_COLD bool Vtb_mdpc_cnu_a___024root___eval_phase__stl(Vtb_mdpc_cnu_a___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_a___024root___eval_phase__stl\n"); );
    Vtb_mdpc_cnu_a__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VstlExecute;
    // Body
    Vtb_mdpc_cnu_a___024root___eval_triggers_vec__stl(vlSelf);
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_mdpc_cnu_a___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
    }
#endif
    __VstlExecute = Vtb_mdpc_cnu_a___024root___trigger_anySet__stl(vlSelfRef.__VstlTriggered);
    if (__VstlExecute) {
        Vtb_mdpc_cnu_a___024root___eval_stl(vlSelf);
    }
    return (__VstlExecute);
}

bool Vtb_mdpc_cnu_a___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_mdpc_cnu_a___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_a___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_mdpc_cnu_a___024root___trigger_anySet__act(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_mdpc_cnu_a___024root___ctor_var_reset(Vtb_mdpc_cnu_a___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_a___024root___ctor_var_reset\n"); );
    Vtb_mdpc_cnu_a__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const uint64_t __VscopeHash = VL_MURMUR64_HASH(vlSelf->vlNamep);
    vlSelf->tb_mdpc_cnu_a__DOT__u_in = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 5999843495749965419ull);
    vlSelf->tb_mdpc_cnu_a__DOT__var_idx = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 16928137261194565027ull);
    vlSelf->tb_mdpc_cnu_a__DOT__row_state_in = VL_SCOPED_RAND_RESET_I(15, __VscopeHash, 8847509690584604774ull);
    vlSelf->tb_mdpc_cnu_a__DOT__sign_bit_out = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1656885834522656751ull);
    vlSelf->tb_mdpc_cnu_a__DOT__dut__DOT__next_state = VL_SCOPED_RAND_RESET_I(15, __VscopeHash, 17928498935138055712ull);
    vlSelf->__Vfunc_mag_from_int__55__value = 0;
    vlSelf->__Vfunc_mag_from_int__55__clamped_value = 0;
    vlSelf->__Vfunc_mag_from_int__55__result = 0;
    vlSelf->__Vfunc_clamp_int__56__Vfuncout = 0;
    vlSelf->__Vfunc_clamp_int__56__value = 0;
    vlSelf->__Vfunc_clamp_int__56__lo = 0;
    vlSelf->__Vfunc_clamp_int__56__hi = 0;
    vlSelf->__Vfunc_mag_from_int__57__clamped_value = 0;
    vlSelf->__Vfunc_mag_from_int__57__result = 0;
    vlSelf->__Vfunc_clamp_int__58__Vfuncout = 0;
    vlSelf->__Vfunc_clamp_int__58__value = 0;
    vlSelf->__Vfunc_clamp_int__58__lo = 0;
    vlSelf->__Vfunc_clamp_int__58__hi = 0;
    vlSelf->__Vfunc_msg_sign__59__msg = 0;
    vlSelf->__Vfunc_row_state_pack__60__Vfuncout = 0;
    vlSelf->__Vfunc_row_state_pack__60__min1 = 0;
    vlSelf->__Vfunc_row_state_pack__60__min2 = 0;
    vlSelf->__Vfunc_row_state_pack__60__min_id = 0;
    vlSelf->__Vfunc_row_state_pack__60__sign_xor = 0;
    vlSelf->__Vfunc_row_state_valid_count__61__state = 0;
    vlSelf->__Vfunc_row_state_sign_xor__62__state = 0;
    vlSelf->__Vfunc_msg_sign__63__msg = 0;
    vlSelf->__Vfunc_row_state_set_sign_xor__64__Vfuncout = 0;
    vlSelf->__Vfunc_row_state_set_sign_xor__64__state = 0;
    vlSelf->__Vfunc_row_state_set_sign_xor__64__sign_xor = 0;
    vlSelf->__Vfunc_row_state_set_sign_xor__64__next_state = 0;
    vlSelf->__Vfunc_row_state_set_valid_count__65__Vfuncout = 0;
    vlSelf->__Vfunc_row_state_set_valid_count__65__state = 0;
    vlSelf->__Vfunc_row_state_set_valid_count__65__valid_count = 0;
    vlSelf->__Vfunc_row_state_set_valid_count__65__next_state = 0;
    vlSelf->__Vfunc_row_state_min1__66__state = 0;
    vlSelf->__Vfunc_row_state_min1__67__state = 0;
    vlSelf->__Vfunc_row_state_set_min2__68__Vfuncout = 0;
    vlSelf->__Vfunc_row_state_set_min2__68__state = 0;
    vlSelf->__Vfunc_row_state_set_min2__68__min2 = 0;
    vlSelf->__Vfunc_row_state_set_min2__68__next_state = 0;
    vlSelf->__Vfunc_mag_from_int__69__value = 0;
    vlSelf->__Vfunc_mag_from_int__69__clamped_value = 0;
    vlSelf->__Vfunc_mag_from_int__69__result = 0;
    vlSelf->__Vfunc_clamp_int__70__Vfuncout = 0;
    vlSelf->__Vfunc_clamp_int__70__value = 0;
    vlSelf->__Vfunc_clamp_int__70__lo = 0;
    vlSelf->__Vfunc_clamp_int__70__hi = 0;
    vlSelf->__Vfunc_row_state_set_min1__71__Vfuncout = 0;
    vlSelf->__Vfunc_row_state_set_min1__71__state = 0;
    vlSelf->__Vfunc_row_state_set_min1__71__min1 = 0;
    vlSelf->__Vfunc_row_state_set_min1__71__next_state = 0;
    vlSelf->__Vfunc_row_state_set_min_id__72__Vfuncout = 0;
    vlSelf->__Vfunc_row_state_set_min_id__72__state = 0;
    vlSelf->__Vfunc_row_state_set_min_id__72__min_id = 0;
    vlSelf->__Vfunc_row_state_set_min_id__72__next_state = 0;
    vlSelf->__Vfunc_row_state_min2__73__state = 0;
    vlSelf->__Vfunc_mag_from_int__74__value = 0;
    vlSelf->__Vfunc_mag_from_int__74__clamped_value = 0;
    vlSelf->__Vfunc_mag_from_int__74__result = 0;
    vlSelf->__Vfunc_clamp_int__75__Vfuncout = 0;
    vlSelf->__Vfunc_clamp_int__75__value = 0;
    vlSelf->__Vfunc_clamp_int__75__lo = 0;
    vlSelf->__Vfunc_clamp_int__75__hi = 0;
    vlSelf->__Vfunc_row_state_set_min2__76__Vfuncout = 0;
    vlSelf->__Vfunc_row_state_set_min2__76__state = 0;
    vlSelf->__Vfunc_row_state_set_min2__76__min2 = 0;
    vlSelf->__Vfunc_row_state_set_min2__76__next_state = 0;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VstlTriggered[__Vi0] = 0;
    }
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VactTriggered[__Vi0] = 0;
    }
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VactTriggeredAcc[__Vi0] = 0;
    }
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VnbaTriggered[__Vi0] = 0;
    }
    vlSelf->__Vi = 0;
}
