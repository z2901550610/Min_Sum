// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_mdpc_cnu_b.h for the primary calling header

#include "Vtb_mdpc_cnu_b__pch.h"

VL_ATTR_COLD void Vtb_mdpc_cnu_b___024root___eval_static(Vtb_mdpc_cnu_b___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_b___024root___eval_static\n"); );
    Vtb_mdpc_cnu_b__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    do {
        vlSelfRef.__VactTriggeredAcc[vlSelfRef.__Vi] 
            = vlSelfRef.__VactTriggered[vlSelfRef.__Vi];
        vlSelfRef.__Vi = ((IData)(1U) + vlSelfRef.__Vi);
    } while ((0U >= vlSelfRef.__Vi));
}

VL_ATTR_COLD void Vtb_mdpc_cnu_b___024root___eval_final(Vtb_mdpc_cnu_b___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_b___024root___eval_final\n"); );
    Vtb_mdpc_cnu_b__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_mdpc_cnu_b___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vtb_mdpc_cnu_b___024root___eval_phase__stl(Vtb_mdpc_cnu_b___024root* vlSelf);

VL_ATTR_COLD void Vtb_mdpc_cnu_b___024root___eval_settle(Vtb_mdpc_cnu_b___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_b___024root___eval_settle\n"); );
    Vtb_mdpc_cnu_b__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VstlIterCount;
    // Body
    __VstlIterCount = 0U;
    vlSelfRef.__VstlFirstIteration = 1U;
    do {
        if (VL_UNLIKELY(((0x00002710U < __VstlIterCount)))) {
#ifdef VL_DEBUG
            Vtb_mdpc_cnu_b___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
#endif
            VL_FATAL_MT("tb/tb_mdpc_cnu_b.sv", 5, "", "DIDNOTCONVERGE: Settle region did not converge after '--converge-limit' of 10000 tries");
        }
        __VstlIterCount = ((IData)(1U) + __VstlIterCount);
        vlSelfRef.__VstlPhaseResult = Vtb_mdpc_cnu_b___024root___eval_phase__stl(vlSelf);
        vlSelfRef.__VstlFirstIteration = 0U;
    } while (vlSelfRef.__VstlPhaseResult);
}

VL_ATTR_COLD void Vtb_mdpc_cnu_b___024root___eval_triggers_vec__stl(Vtb_mdpc_cnu_b___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_b___024root___eval_triggers_vec__stl\n"); );
    Vtb_mdpc_cnu_b__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VstlTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VstlTriggered[0U]) 
                                     | (IData)((IData)(vlSelfRef.__VstlFirstIteration)));
}

VL_ATTR_COLD bool Vtb_mdpc_cnu_b___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_mdpc_cnu_b___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_b___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_mdpc_cnu_b___024root___trigger_anySet__stl(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD bool Vtb_mdpc_cnu_b___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_b___024root___trigger_anySet__stl\n"); );
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

VL_ATTR_COLD void Vtb_mdpc_cnu_b___024root___eval_stl(Vtb_mdpc_cnu_b___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_b___024root___eval_stl\n"); );
    Vtb_mdpc_cnu_b__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VstlTriggered[0U])) {
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

VL_ATTR_COLD bool Vtb_mdpc_cnu_b___024root___eval_phase__stl(Vtb_mdpc_cnu_b___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_b___024root___eval_phase__stl\n"); );
    Vtb_mdpc_cnu_b__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VstlExecute;
    // Body
    Vtb_mdpc_cnu_b___024root___eval_triggers_vec__stl(vlSelf);
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_mdpc_cnu_b___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
    }
#endif
    __VstlExecute = Vtb_mdpc_cnu_b___024root___trigger_anySet__stl(vlSelfRef.__VstlTriggered);
    if (__VstlExecute) {
        Vtb_mdpc_cnu_b___024root___eval_stl(vlSelf);
    }
    return (__VstlExecute);
}

bool Vtb_mdpc_cnu_b___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_mdpc_cnu_b___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_b___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_mdpc_cnu_b___024root___trigger_anySet__act(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_mdpc_cnu_b___024root___ctor_var_reset(Vtb_mdpc_cnu_b___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_cnu_b___024root___ctor_var_reset\n"); );
    Vtb_mdpc_cnu_b__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const uint64_t __VscopeHash = VL_MURMUR64_HASH(vlSelf->vlNamep);
    vlSelf->tb_mdpc_cnu_b__DOT__row_state_in = VL_SCOPED_RAND_RESET_I(15, __VscopeHash, 15353278497997406285ull);
    vlSelf->tb_mdpc_cnu_b__DOT__u_sign_in = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 15755719808574485955ull);
    vlSelf->tb_mdpc_cnu_b__DOT__var_idx = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 16769062452722689423ull);
    vlSelf->tb_mdpc_cnu_b__DOT__dut__DOT__next_msg = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 2127884240782068028ull);
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
