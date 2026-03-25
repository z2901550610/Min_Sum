// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_mdpc_vnu.h for the primary calling header

#include "Vtb_mdpc_vnu__pch.h"

VL_ATTR_COLD void Vtb_mdpc_vnu___024root___eval_static(Vtb_mdpc_vnu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_vnu___024root___eval_static\n"); );
    Vtb_mdpc_vnu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    do {
        vlSelfRef.__VactTriggeredAcc[vlSelfRef.__Vi] 
            = vlSelfRef.__VactTriggered[vlSelfRef.__Vi];
        vlSelfRef.__Vi = ((IData)(1U) + vlSelfRef.__Vi);
    } while ((0U >= vlSelfRef.__Vi));
}

VL_ATTR_COLD void Vtb_mdpc_vnu___024root___eval_final(Vtb_mdpc_vnu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_vnu___024root___eval_final\n"); );
    Vtb_mdpc_vnu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_mdpc_vnu___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vtb_mdpc_vnu___024root___eval_phase__stl(Vtb_mdpc_vnu___024root* vlSelf);

VL_ATTR_COLD void Vtb_mdpc_vnu___024root___eval_settle(Vtb_mdpc_vnu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_vnu___024root___eval_settle\n"); );
    Vtb_mdpc_vnu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VstlIterCount;
    // Body
    __VstlIterCount = 0U;
    vlSelfRef.__VstlFirstIteration = 1U;
    do {
        if (VL_UNLIKELY(((0x00002710U < __VstlIterCount)))) {
#ifdef VL_DEBUG
            Vtb_mdpc_vnu___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
#endif
            VL_FATAL_MT("tb/tb_mdpc_vnu.sv", 5, "", "DIDNOTCONVERGE: Settle region did not converge after '--converge-limit' of 10000 tries");
        }
        __VstlIterCount = ((IData)(1U) + __VstlIterCount);
        vlSelfRef.__VstlPhaseResult = Vtb_mdpc_vnu___024root___eval_phase__stl(vlSelf);
        vlSelfRef.__VstlFirstIteration = 0U;
    } while (vlSelfRef.__VstlPhaseResult);
}

VL_ATTR_COLD void Vtb_mdpc_vnu___024root___eval_triggers_vec__stl(Vtb_mdpc_vnu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_vnu___024root___eval_triggers_vec__stl\n"); );
    Vtb_mdpc_vnu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VstlTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VstlTriggered[0U]) 
                                     | (IData)((IData)(vlSelfRef.__VstlFirstIteration)));
}

VL_ATTR_COLD bool Vtb_mdpc_vnu___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_mdpc_vnu___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_vnu___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_mdpc_vnu___024root___trigger_anySet__stl(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD bool Vtb_mdpc_vnu___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_vnu___024root___trigger_anySet__stl\n"); );
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

VL_ATTR_COLD void Vtb_mdpc_vnu___024root___stl_sequent__TOP__0(Vtb_mdpc_vnu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_vnu___024root___stl_sequent__TOP__0\n"); );
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

VL_ATTR_COLD void Vtb_mdpc_vnu___024root___eval_stl(Vtb_mdpc_vnu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_vnu___024root___eval_stl\n"); );
    Vtb_mdpc_vnu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VstlTriggered[0U])) {
        Vtb_mdpc_vnu___024root___stl_sequent__TOP__0(vlSelf);
    }
}

VL_ATTR_COLD bool Vtb_mdpc_vnu___024root___eval_phase__stl(Vtb_mdpc_vnu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_vnu___024root___eval_phase__stl\n"); );
    Vtb_mdpc_vnu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VstlExecute;
    // Body
    Vtb_mdpc_vnu___024root___eval_triggers_vec__stl(vlSelf);
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_mdpc_vnu___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
    }
#endif
    __VstlExecute = Vtb_mdpc_vnu___024root___trigger_anySet__stl(vlSelfRef.__VstlTriggered);
    if (__VstlExecute) {
        Vtb_mdpc_vnu___024root___eval_stl(vlSelf);
    }
    return (__VstlExecute);
}

bool Vtb_mdpc_vnu___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_mdpc_vnu___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_vnu___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_mdpc_vnu___024root___trigger_anySet__act(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_mdpc_vnu___024root___ctor_var_reset(Vtb_mdpc_vnu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_vnu___024root___ctor_var_reset\n"); );
    Vtb_mdpc_vnu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const uint64_t __VscopeHash = VL_MURMUR64_HASH(vlSelf->vlNamep);
    vlSelf->tb_mdpc_vnu__DOT__gamma_in = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 10158184602110188395ull);
    for (int __Vi0 = 0; __Vi0 < 3; ++__Vi0) {
        vlSelf->tb_mdpc_vnu__DOT__c2v_in[__Vi0] = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 9560424571743190900ull);
    }
    vlSelf->tb_mdpc_vnu__DOT__app_out = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 3466845481818337724ull);
    vlSelf->tb_mdpc_vnu__DOT__x_out = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2021735327644995008ull);
    for (int __Vi0 = 0; __Vi0 < 3; ++__Vi0) {
        vlSelf->tb_mdpc_vnu__DOT__u_next_out[__Vi0] = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 5578861536687462354ull);
    }
    for (int __Vi0 = 0; __Vi0 < 3; ++__Vi0) {
        vlSelf->tb_mdpc_vnu__DOT__dut__DOT__signed_c2v[__Vi0] = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 15916815960438070495ull);
    }
    vlSelf->__Vfunc_msg_to_signed__60____VlefCall_1__msg_sign = 0;
    vlSelf->__Vfunc_msg_to_signed__60____VlefCall_0__msg_mag = 0;
    vlSelf->__Vfunc_msg_to_signed__60__mag_value = 0;
    vlSelf->__Vfunc_msg_mag__61__Vfuncout = 0;
    vlSelf->__Vfunc_msg_mag__61__msg = 0;
    vlSelf->__Vfunc_msg_sign__62__Vfuncout = 0;
    vlSelf->__Vfunc_msg_sign__62__msg = 0;
    vlSelf->__Vfunc_alpha_scale__63__abs_value = 0;
    vlSelf->__Vfunc_alpha_scale__63__scaled_abs = 0;
    vlSelf->__Vfunc_alpha_scale__65__abs_value = 0;
    vlSelf->__Vfunc_alpha_scale__65__scaled_abs = 0;
    vlSelf->__Vfunc_clamp_int__68__Vfuncout = 0;
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
