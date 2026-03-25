// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_mdpc_decoder_demo.h for the primary calling header

#include "Vtb_mdpc_decoder_demo__pch.h"

VlCoroutine Vtb_mdpc_decoder_demo___024root___eval_initial__TOP__Vtiming__0(Vtb_mdpc_decoder_demo___024root* vlSelf);
VlCoroutine Vtb_mdpc_decoder_demo___024root___eval_initial__TOP__Vtiming__1(Vtb_mdpc_decoder_demo___024root* vlSelf);

void Vtb_mdpc_decoder_demo___024root___eval_initial(Vtb_mdpc_decoder_demo___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_decoder_demo___024root___eval_initial\n"); );
    Vtb_mdpc_decoder_demo__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.tb_mdpc_decoder_demo__DOT__clk = 0U;
    Vtb_mdpc_decoder_demo___024root___eval_initial__TOP__Vtiming__0(vlSelf);
    Vtb_mdpc_decoder_demo___024root___eval_initial__TOP__Vtiming__1(vlSelf);
}

void Vtb_mdpc_decoder_demo___024root____VbeforeTrig_h5ea129b9__0(Vtb_mdpc_decoder_demo___024root* vlSelf, const char* __VeventDescription);
void Vtb_mdpc_decoder_demo___024root____VbeforeTrig_h0d62a7d4__0(Vtb_mdpc_decoder_demo___024root* vlSelf, const char* __VeventDescription);
void Vtb_mdpc_decoder_demo___024root____VbeforeTrig_h10b28a8e__0(Vtb_mdpc_decoder_demo___024root* vlSelf, const char* __VeventDescription);
void Vtb_mdpc_decoder_demo___024root____VbeforeTrig_hd708b578__0(Vtb_mdpc_decoder_demo___024root* vlSelf, const char* __VeventDescription);
void Vtb_mdpc_decoder_demo___024root____VbeforeTrig_hdfc022cc__0(Vtb_mdpc_decoder_demo___024root* vlSelf, const char* __VeventDescription);

VlCoroutine Vtb_mdpc_decoder_demo___024root___eval_initial__TOP__Vtiming__0(Vtb_mdpc_decoder_demo___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_decoder_demo___024root___eval_initial__TOP__Vtiming__0\n"); );
    Vtb_mdpc_decoder_demo__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*3:0*/ tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag;
    CData/*0:0*/ tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign;
    CData/*3:0*/ tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag;
    CData/*0:0*/ tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign;
    CData/*1:0*/ tb_mdpc_decoder_demo__DOT____VlemCall_4__row_state_valid_count;
    CData/*0:0*/ tb_mdpc_decoder_demo__DOT____VlemCall_3__row_state_sign_xor;
    CData/*3:0*/ tb_mdpc_decoder_demo__DOT____VlemCall_2__row_state_min_id;
    CData/*3:0*/ tb_mdpc_decoder_demo__DOT____VlemCall_1__row_state_min2;
    CData/*3:0*/ tb_mdpc_decoder_demo__DOT____VlemCall_0__row_state_min1;
    IData/*31:0*/ __Vtask_tb_mdpc_decoder_demo__DOT__apply_reset__0__tb_mdpc_decoder_demo__DOT__unnamedblk1_1__DOT____Vrepeat0;
    __Vtask_tb_mdpc_decoder_demo__DOT__apply_reset__0__tb_mdpc_decoder_demo__DOT__unnamedblk1_1__DOT____Vrepeat0 = 0;
    SData/*15:0*/ __Vtask_tb_mdpc_decoder_demo__DOT__start_case__1__vec;
    __Vtask_tb_mdpc_decoder_demo__DOT__start_case__1__vec = 0;
    VlUnpacked<IData/*31:0*/, 4> __Vtask_tb_mdpc_decoder_demo__DOT__check_hist__2__expected_hist;
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        __Vtask_tb_mdpc_decoder_demo__DOT__check_hist__2__expected_hist[__Vi0] = 0;
    }
    IData/*31:0*/ __Vtask_tb_mdpc_decoder_demo__DOT__apply_reset__3__tb_mdpc_decoder_demo__DOT__unnamedblk1_1__DOT____Vrepeat0;
    __Vtask_tb_mdpc_decoder_demo__DOT__apply_reset__3__tb_mdpc_decoder_demo__DOT__unnamedblk1_1__DOT____Vrepeat0 = 0;
    SData/*15:0*/ __Vtask_tb_mdpc_decoder_demo__DOT__start_case__4__vec;
    __Vtask_tb_mdpc_decoder_demo__DOT__start_case__4__vec = 0;
    SData/*14:0*/ __Vfunc_row_state_min1__5__state;
    __Vfunc_row_state_min1__5__state = 0;
    SData/*14:0*/ __Vfunc_row_state_min2__6__state;
    __Vfunc_row_state_min2__6__state = 0;
    SData/*14:0*/ __Vfunc_row_state_min_id__7__state;
    __Vfunc_row_state_min_id__7__state = 0;
    SData/*14:0*/ __Vfunc_row_state_sign_xor__8__state;
    __Vfunc_row_state_sign_xor__8__state = 0;
    SData/*14:0*/ __Vfunc_row_state_valid_count__9__state;
    __Vfunc_row_state_valid_count__9__state = 0;
    CData/*4:0*/ __Vfunc_msg_sign__10__msg;
    __Vfunc_msg_sign__10__msg = 0;
    CData/*4:0*/ __Vfunc_msg_mag__11__msg;
    __Vfunc_msg_mag__11__msg = 0;
    CData/*4:0*/ __Vfunc_msg_sign__12__msg;
    __Vfunc_msg_sign__12__msg = 0;
    CData/*4:0*/ __Vfunc_msg_mag__13__msg;
    __Vfunc_msg_mag__13__msg = 0;
    VlUnpacked<IData/*31:0*/, 4> __Vtask_tb_mdpc_decoder_demo__DOT__check_hist__14__expected_hist;
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        __Vtask_tb_mdpc_decoder_demo__DOT__check_hist__14__expected_hist[__Vi0] = 0;
    }
    // Body
    vlSelfRef.tb_mdpc_decoder_demo__DOT__unnamedblk1__DOT__case0_hist[0U] = 0U;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__unnamedblk1__DOT__case0_hist[1U] = 0U;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__unnamedblk1__DOT__case0_hist[2U] = 0U;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__unnamedblk1__DOT__case0_hist[3U] = 0U;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__unnamedblk1__DOT__case1_hist[0U] = 0x0000000bU;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__unnamedblk1__DOT__case1_hist[1U] = 0x0000000bU;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__unnamedblk1__DOT__case1_hist[2U] = 0x0000000bU;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__unnamedblk1__DOT__case1_hist[3U] = 0x0000000bU;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__rst_n = 0U;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__start = 0U;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in = 0U;
    __Vtask_tb_mdpc_decoder_demo__DOT__apply_reset__0__tb_mdpc_decoder_demo__DOT__unnamedblk1_1__DOT____Vrepeat0 = 2U;
    while (VL_LTS_III(32, 0U, __Vtask_tb_mdpc_decoder_demo__DOT__apply_reset__0__tb_mdpc_decoder_demo__DOT__unnamedblk1_1__DOT____Vrepeat0)) {
        Vtb_mdpc_decoder_demo___024root____VbeforeTrig_h5ea129b9__0(vlSelf, 
                                                                    "@(posedge tb_mdpc_decoder_demo.clk)");
        co_await vlSelfRef.__VtrigSched_h5ea129b9__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_mdpc_decoder_demo.clk)", 
                                                             "tb/tb_mdpc_decoder_demo.sv", 
                                                             38);
        __Vtask_tb_mdpc_decoder_demo__DOT__apply_reset__0__tb_mdpc_decoder_demo__DOT__unnamedblk1_1__DOT____Vrepeat0 
            = (__Vtask_tb_mdpc_decoder_demo__DOT__apply_reset__0__tb_mdpc_decoder_demo__DOT__unnamedblk1_1__DOT____Vrepeat0 
               - (IData)(1U));
    }
    vlSelfRef.tb_mdpc_decoder_demo__DOT__rst_n = 1U;
    Vtb_mdpc_decoder_demo___024root____VbeforeTrig_h5ea129b9__0(vlSelf, 
                                                                "@(posedge tb_mdpc_decoder_demo.clk)");
    co_await vlSelfRef.__VtrigSched_h5ea129b9__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mdpc_decoder_demo.clk)", 
                                                         "tb/tb_mdpc_decoder_demo.sv", 
                                                         40);
    __Vtask_tb_mdpc_decoder_demo__DOT__start_case__1__vec = 0U;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in = __Vtask_tb_mdpc_decoder_demo__DOT__start_case__1__vec;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__start = 1U;
    Vtb_mdpc_decoder_demo___024root____VbeforeTrig_h5ea129b9__0(vlSelf, 
                                                                "@(posedge tb_mdpc_decoder_demo.clk)");
    co_await vlSelfRef.__VtrigSched_h5ea129b9__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mdpc_decoder_demo.clk)", 
                                                         "tb/tb_mdpc_decoder_demo.sv", 
                                                         48);
    vlSelfRef.tb_mdpc_decoder_demo__DOT__start = 0U;
    while ((1U & (~ (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__done)))) {
        Vtb_mdpc_decoder_demo___024root____VbeforeTrig_h0d62a7d4__0(vlSelf, 
                                                                    "@( tb_mdpc_decoder_demo.done)");
        co_await vlSelfRef.__VtrigSched_h0d62a7d4__0.trigger(1U, 
                                                             nullptr, 
                                                             "@( tb_mdpc_decoder_demo.done)", 
                                                             "tb/tb_mdpc_decoder_demo.sv", 
                                                             72);
    }
    Vtb_mdpc_decoder_demo___024root____VbeforeTrig_h5ea129b9__0(vlSelf, 
                                                                "@(posedge tb_mdpc_decoder_demo.clk)");
    co_await vlSelfRef.__VtrigSched_h5ea129b9__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mdpc_decoder_demo.clk)", 
                                                         "tb/tb_mdpc_decoder_demo.sv", 
                                                         73);
    if (VL_UNLIKELY(((1U & (~ (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__success)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:74: Assertion failed in %m: CASE0 success mismatch: got %0d exp 1\n",4, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',1,(IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__success));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 74, "", false);
    }
    if (VL_UNLIKELY(((1U != (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__iter_count))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:75: Assertion failed in %m: CASE0 iterations mismatch: got %0d exp 1\n",4, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',3,(IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__iter_count));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 75, "", false);
    }
    if (VL_UNLIKELY(((0U != (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_out))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:76: Assertion failed in %m: CASE0 x_out mismatch: got %h exp 0000\n",4, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',16,(IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_out));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 76, "", false);
    }
    __Vtask_tb_mdpc_decoder_demo__DOT__check_hist__2__expected_hist[0U] 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__unnamedblk1__DOT__case0_hist[0U];
    __Vtask_tb_mdpc_decoder_demo__DOT__check_hist__2__expected_hist[1U] 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__unnamedblk1__DOT__case0_hist[1U];
    __Vtask_tb_mdpc_decoder_demo__DOT__check_hist__2__expected_hist[2U] 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__unnamedblk1__DOT__case0_hist[2U];
    __Vtask_tb_mdpc_decoder_demo__DOT__check_hist__2__expected_hist[3U] 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__unnamedblk1__DOT__case0_hist[3U];
    if (VL_UNLIKELY(((vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist[0U] 
                      != __Vtask_tb_mdpc_decoder_demo__DOT__check_hist__2__expected_hist[0U])))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:57: Assertion failed in %m: syndrome_hist[0] mismatch: got %0d exp %0d\n",5, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.check_hist", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',8,vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist[0U]
                     , '~',32,__Vtask_tb_mdpc_decoder_demo__DOT__check_hist__2__expected_hist[0U]);
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 57, "", false);
    }
    if (VL_UNLIKELY(((vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist[1U] 
                      != __Vtask_tb_mdpc_decoder_demo__DOT__check_hist__2__expected_hist[1U])))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:57: Assertion failed in %m: syndrome_hist[1] mismatch: got %0d exp %0d\n",5, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.check_hist", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',8,vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist[1U]
                     , '~',32,__Vtask_tb_mdpc_decoder_demo__DOT__check_hist__2__expected_hist[1U]);
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 57, "", false);
    }
    if (VL_UNLIKELY(((vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist[2U] 
                      != __Vtask_tb_mdpc_decoder_demo__DOT__check_hist__2__expected_hist[2U])))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:57: Assertion failed in %m: syndrome_hist[2] mismatch: got %0d exp %0d\n",5, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.check_hist", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',8,vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist[2U]
                     , '~',32,__Vtask_tb_mdpc_decoder_demo__DOT__check_hist__2__expected_hist[2U]);
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 57, "", false);
    }
    if (VL_UNLIKELY(((vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist[3U] 
                      != __Vtask_tb_mdpc_decoder_demo__DOT__check_hist__2__expected_hist[3U])))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:57: Assertion failed in %m: syndrome_hist[3] mismatch: got %0d exp %0d\n",5, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.check_hist", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',8,vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist[3U]
                     , '~',32,__Vtask_tb_mdpc_decoder_demo__DOT__check_hist__2__expected_hist[3U]);
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 57, "", false);
    }
    __Vtask_tb_mdpc_decoder_demo__DOT__apply_reset__3__tb_mdpc_decoder_demo__DOT__unnamedblk1_1__DOT____Vrepeat0 = 0;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__rst_n = 0U;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__start = 0U;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in = 0U;
    __Vtask_tb_mdpc_decoder_demo__DOT__apply_reset__3__tb_mdpc_decoder_demo__DOT__unnamedblk1_1__DOT____Vrepeat0 = 2U;
    while (VL_LTS_III(32, 0U, __Vtask_tb_mdpc_decoder_demo__DOT__apply_reset__3__tb_mdpc_decoder_demo__DOT__unnamedblk1_1__DOT____Vrepeat0)) {
        Vtb_mdpc_decoder_demo___024root____VbeforeTrig_h5ea129b9__0(vlSelf, 
                                                                    "@(posedge tb_mdpc_decoder_demo.clk)");
        co_await vlSelfRef.__VtrigSched_h5ea129b9__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_mdpc_decoder_demo.clk)", 
                                                             "tb/tb_mdpc_decoder_demo.sv", 
                                                             38);
        __Vtask_tb_mdpc_decoder_demo__DOT__apply_reset__3__tb_mdpc_decoder_demo__DOT__unnamedblk1_1__DOT____Vrepeat0 
            = (__Vtask_tb_mdpc_decoder_demo__DOT__apply_reset__3__tb_mdpc_decoder_demo__DOT__unnamedblk1_1__DOT____Vrepeat0 
               - (IData)(1U));
    }
    vlSelfRef.tb_mdpc_decoder_demo__DOT__rst_n = 1U;
    Vtb_mdpc_decoder_demo___024root____VbeforeTrig_h5ea129b9__0(vlSelf, 
                                                                "@(posedge tb_mdpc_decoder_demo.clk)");
    co_await vlSelfRef.__VtrigSched_h5ea129b9__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mdpc_decoder_demo.clk)", 
                                                         "tb/tb_mdpc_decoder_demo.sv", 
                                                         40);
    __Vtask_tb_mdpc_decoder_demo__DOT__start_case__4__vec = 1U;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in = __Vtask_tb_mdpc_decoder_demo__DOT__start_case__4__vec;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__start = 1U;
    Vtb_mdpc_decoder_demo___024root____VbeforeTrig_h5ea129b9__0(vlSelf, 
                                                                "@(posedge tb_mdpc_decoder_demo.clk)");
    co_await vlSelfRef.__VtrigSched_h5ea129b9__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mdpc_decoder_demo.clk)", 
                                                         "tb/tb_mdpc_decoder_demo.sv", 
                                                         48);
    vlSelfRef.tb_mdpc_decoder_demo__DOT__start = 0U;
    while ((1U & (~ (((3U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state)) 
                      & (0U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx))) 
                     & (0U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__scan_slot)))))) {
        Vtb_mdpc_decoder_demo___024root____VbeforeTrig_h10b28a8e__0(vlSelf, 
                                                                    "@( (((3'h3 == tb_mdpc_decoder_demo.dut.state) & (4'h0 == tb_mdpc_decoder_demo.dut.active_var_idx)) & (2'h0 == tb_mdpc_decoder_demo.dut.scan_slot)))");
        co_await vlSelfRef.__VtrigSched_h10b28a8e__0.trigger(1U, 
                                                             nullptr, 
                                                             "@( (((3'h3 == tb_mdpc_decoder_demo.dut.state) & (4'h0 == tb_mdpc_decoder_demo.dut.active_var_idx)) & (2'h0 == tb_mdpc_decoder_demo.dut.scan_slot)))", 
                                                             "tb/tb_mdpc_decoder_demo.sv", 
                                                             82);
    }
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "tb/tb_mdpc_decoder_demo.sv", 
                                         83);
    __Vfunc_row_state_min1__5__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[0U];
    tb_mdpc_decoder_demo__DOT____VlemCall_0__row_state_min1 = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_0__row_state_min1 
        = (0x0000000fU & (IData)(__Vfunc_row_state_min1__5__state));
    __Vfunc_row_state_min2__6__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[0U];
    tb_mdpc_decoder_demo__DOT____VlemCall_1__row_state_min2 = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_1__row_state_min2 
        = (0x0000000fU & ((IData)(__Vfunc_row_state_min2__6__state) 
                          >> 4U));
    __Vfunc_row_state_min_id__7__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[0U];
    tb_mdpc_decoder_demo__DOT____VlemCall_2__row_state_min_id = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_2__row_state_min_id 
        = (0x0000000fU & ((IData)(__Vfunc_row_state_min_id__7__state) 
                          >> 8U));
    __Vfunc_row_state_sign_xor__8__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[0U];
    tb_mdpc_decoder_demo__DOT____VlemCall_3__row_state_sign_xor = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_3__row_state_sign_xor 
        = (1U & ((IData)(__Vfunc_row_state_sign_xor__8__state) 
                 >> 0x0cU));
    __Vfunc_row_state_valid_count__9__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[0U];
    tb_mdpc_decoder_demo__DOT____VlemCall_4__row_state_valid_count = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_4__row_state_valid_count 
        = (3U & ((IData)(__Vfunc_row_state_valid_count__9__state) 
                 >> 0x0dU));
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_0__row_state_min1))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:85: Assertion failed in %m: CASE1 row min1[0] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 85, "", false);
    }
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_1__row_state_min2))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:86: Assertion failed in %m: CASE1 row min2[0] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 86, "", false);
    }
    if (VL_UNLIKELY(((0U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_2__row_state_min_id))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:87: Assertion failed in %m: CASE1 row min_id[0] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 87, "", false);
    }
    __Vfunc_row_state_min1__5__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[1U];
    tb_mdpc_decoder_demo__DOT____VlemCall_0__row_state_min1 = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_0__row_state_min1 
        = (0x0000000fU & (IData)(__Vfunc_row_state_min1__5__state));
    __Vfunc_row_state_min2__6__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[1U];
    tb_mdpc_decoder_demo__DOT____VlemCall_1__row_state_min2 = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_1__row_state_min2 
        = (0x0000000fU & ((IData)(__Vfunc_row_state_min2__6__state) 
                          >> 4U));
    if (VL_UNLIKELY(((1U & (~ (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_3__row_state_sign_xor)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:88: Assertion failed in %m: CASE1 row sign_xor[0] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 88, "", false);
    }
    __Vfunc_row_state_min_id__7__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[1U];
    tb_mdpc_decoder_demo__DOT____VlemCall_2__row_state_min_id = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_2__row_state_min_id 
        = (0x0000000fU & ((IData)(__Vfunc_row_state_min_id__7__state) 
                          >> 8U));
    __Vfunc_row_state_sign_xor__8__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[1U];
    tb_mdpc_decoder_demo__DOT____VlemCall_3__row_state_sign_xor = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_3__row_state_sign_xor 
        = (1U & ((IData)(__Vfunc_row_state_sign_xor__8__state) 
                 >> 0x0cU));
    if (VL_UNLIKELY(((3U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_4__row_state_valid_count))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:89: Assertion failed in %m: CASE1 row valid_count[0] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 89, "", false);
    }
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_0__row_state_min1))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:85: Assertion failed in %m: CASE1 row min1[1] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 85, "", false);
    }
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_1__row_state_min2))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:86: Assertion failed in %m: CASE1 row min2[1] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 86, "", false);
    }
    if (VL_UNLIKELY(((0U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_2__row_state_min_id))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:87: Assertion failed in %m: CASE1 row min_id[1] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 87, "", false);
    }
    __Vfunc_row_state_valid_count__9__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[1U];
    tb_mdpc_decoder_demo__DOT____VlemCall_4__row_state_valid_count = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_4__row_state_valid_count 
        = (3U & ((IData)(__Vfunc_row_state_valid_count__9__state) 
                 >> 0x0dU));
    __Vfunc_row_state_min1__5__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[2U];
    tb_mdpc_decoder_demo__DOT____VlemCall_0__row_state_min1 = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_0__row_state_min1 
        = (0x0000000fU & (IData)(__Vfunc_row_state_min1__5__state));
    if (VL_UNLIKELY(((1U & (~ (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_3__row_state_sign_xor)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:88: Assertion failed in %m: CASE1 row sign_xor[1] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 88, "", false);
    }
    __Vfunc_row_state_min2__6__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[2U];
    tb_mdpc_decoder_demo__DOT____VlemCall_1__row_state_min2 = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_1__row_state_min2 
        = (0x0000000fU & ((IData)(__Vfunc_row_state_min2__6__state) 
                          >> 4U));
    __Vfunc_row_state_min_id__7__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[2U];
    tb_mdpc_decoder_demo__DOT____VlemCall_2__row_state_min_id = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_2__row_state_min_id 
        = (0x0000000fU & ((IData)(__Vfunc_row_state_min_id__7__state) 
                          >> 8U));
    __Vfunc_row_state_sign_xor__8__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[2U];
    tb_mdpc_decoder_demo__DOT____VlemCall_3__row_state_sign_xor = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_3__row_state_sign_xor 
        = (1U & ((IData)(__Vfunc_row_state_sign_xor__8__state) 
                 >> 0x0cU));
    if (VL_UNLIKELY(((3U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_4__row_state_valid_count))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:89: Assertion failed in %m: CASE1 row valid_count[1] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 89, "", false);
    }
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_0__row_state_min1))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:85: Assertion failed in %m: CASE1 row min1[2] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 85, "", false);
    }
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_1__row_state_min2))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:86: Assertion failed in %m: CASE1 row min2[2] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 86, "", false);
    }
    if (VL_UNLIKELY(((1U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_2__row_state_min_id))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:87: Assertion failed in %m: CASE1 row min_id[2] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 87, "", false);
    }
    __Vfunc_row_state_valid_count__9__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[2U];
    tb_mdpc_decoder_demo__DOT____VlemCall_4__row_state_valid_count = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_4__row_state_valid_count 
        = (3U & ((IData)(__Vfunc_row_state_valid_count__9__state) 
                 >> 0x0dU));
    __Vfunc_row_state_min1__5__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[3U];
    tb_mdpc_decoder_demo__DOT____VlemCall_0__row_state_min1 = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_0__row_state_min1 
        = (0x0000000fU & (IData)(__Vfunc_row_state_min1__5__state));
    __Vfunc_row_state_min2__6__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[3U];
    tb_mdpc_decoder_demo__DOT____VlemCall_1__row_state_min2 = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_1__row_state_min2 
        = (0x0000000fU & ((IData)(__Vfunc_row_state_min2__6__state) 
                          >> 4U));
    __Vfunc_row_state_min_id__7__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[3U];
    tb_mdpc_decoder_demo__DOT____VlemCall_2__row_state_min_id = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_2__row_state_min_id 
        = (0x0000000fU & ((IData)(__Vfunc_row_state_min_id__7__state) 
                          >> 8U));
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_3__row_state_sign_xor))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:88: Assertion failed in %m: CASE1 row sign_xor[2] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 88, "", false);
    }
    if (VL_UNLIKELY(((3U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_4__row_state_valid_count))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:89: Assertion failed in %m: CASE1 row valid_count[2] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 89, "", false);
    }
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_0__row_state_min1))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:85: Assertion failed in %m: CASE1 row min1[3] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 85, "", false);
    }
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_1__row_state_min2))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:86: Assertion failed in %m: CASE1 row min2[3] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 86, "", false);
    }
    if (VL_UNLIKELY(((0U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_2__row_state_min_id))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:87: Assertion failed in %m: CASE1 row min_id[3] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 87, "", false);
    }
    __Vfunc_row_state_sign_xor__8__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[3U];
    tb_mdpc_decoder_demo__DOT____VlemCall_3__row_state_sign_xor = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_3__row_state_sign_xor 
        = (1U & ((IData)(__Vfunc_row_state_sign_xor__8__state) 
                 >> 0x0cU));
    if (VL_UNLIKELY(((1U & (~ (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_3__row_state_sign_xor)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:88: Assertion failed in %m: CASE1 row sign_xor[3] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 88, "", false);
    }
    __Vfunc_row_state_valid_count__9__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[3U];
    tb_mdpc_decoder_demo__DOT____VlemCall_4__row_state_valid_count = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_4__row_state_valid_count 
        = (3U & ((IData)(__Vfunc_row_state_valid_count__9__state) 
                 >> 0x0dU));
    __Vfunc_row_state_min1__5__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[4U];
    tb_mdpc_decoder_demo__DOT____VlemCall_0__row_state_min1 = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_0__row_state_min1 
        = (0x0000000fU & (IData)(__Vfunc_row_state_min1__5__state));
    __Vfunc_row_state_min2__6__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[4U];
    tb_mdpc_decoder_demo__DOT____VlemCall_1__row_state_min2 = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_1__row_state_min2 
        = (0x0000000fU & ((IData)(__Vfunc_row_state_min2__6__state) 
                          >> 4U));
    __Vfunc_row_state_min_id__7__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[4U];
    tb_mdpc_decoder_demo__DOT____VlemCall_2__row_state_min_id = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_2__row_state_min_id 
        = (0x0000000fU & ((IData)(__Vfunc_row_state_min_id__7__state) 
                          >> 8U));
    if (VL_UNLIKELY(((3U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_4__row_state_valid_count))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:89: Assertion failed in %m: CASE1 row valid_count[3] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 89, "", false);
    }
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_0__row_state_min1))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:85: Assertion failed in %m: CASE1 row min1[4] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 85, "", false);
    }
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_1__row_state_min2))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:86: Assertion failed in %m: CASE1 row min2[4] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 86, "", false);
    }
    if (VL_UNLIKELY(((1U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_2__row_state_min_id))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:87: Assertion failed in %m: CASE1 row min_id[4] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 87, "", false);
    }
    __Vfunc_row_state_sign_xor__8__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[4U];
    tb_mdpc_decoder_demo__DOT____VlemCall_3__row_state_sign_xor = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_3__row_state_sign_xor 
        = (1U & ((IData)(__Vfunc_row_state_sign_xor__8__state) 
                 >> 0x0cU));
    __Vfunc_row_state_valid_count__9__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[4U];
    tb_mdpc_decoder_demo__DOT____VlemCall_4__row_state_valid_count = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_4__row_state_valid_count 
        = (3U & ((IData)(__Vfunc_row_state_valid_count__9__state) 
                 >> 0x0dU));
    __Vfunc_row_state_min1__5__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[5U];
    tb_mdpc_decoder_demo__DOT____VlemCall_0__row_state_min1 = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_0__row_state_min1 
        = (0x0000000fU & (IData)(__Vfunc_row_state_min1__5__state));
    __Vfunc_row_state_min2__6__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[5U];
    tb_mdpc_decoder_demo__DOT____VlemCall_1__row_state_min2 = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_1__row_state_min2 
        = (0x0000000fU & ((IData)(__Vfunc_row_state_min2__6__state) 
                          >> 4U));
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_3__row_state_sign_xor))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:88: Assertion failed in %m: CASE1 row sign_xor[4] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 88, "", false);
    }
    __Vfunc_row_state_min_id__7__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[5U];
    tb_mdpc_decoder_demo__DOT____VlemCall_2__row_state_min_id = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_2__row_state_min_id 
        = (0x0000000fU & ((IData)(__Vfunc_row_state_min_id__7__state) 
                          >> 8U));
    if (VL_UNLIKELY(((3U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_4__row_state_valid_count))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:89: Assertion failed in %m: CASE1 row valid_count[4] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 89, "", false);
    }
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_0__row_state_min1))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:85: Assertion failed in %m: CASE1 row min1[5] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 85, "", false);
    }
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_1__row_state_min2))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:86: Assertion failed in %m: CASE1 row min2[5] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 86, "", false);
    }
    if (VL_UNLIKELY(((2U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_2__row_state_min_id))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:87: Assertion failed in %m: CASE1 row min_id[5] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 87, "", false);
    }
    __Vfunc_row_state_sign_xor__8__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[5U];
    tb_mdpc_decoder_demo__DOT____VlemCall_3__row_state_sign_xor = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_3__row_state_sign_xor 
        = (1U & ((IData)(__Vfunc_row_state_sign_xor__8__state) 
                 >> 0x0cU));
    __Vfunc_row_state_valid_count__9__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[5U];
    tb_mdpc_decoder_demo__DOT____VlemCall_4__row_state_valid_count = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_4__row_state_valid_count 
        = (3U & ((IData)(__Vfunc_row_state_valid_count__9__state) 
                 >> 0x0dU));
    __Vfunc_row_state_min1__5__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[6U];
    tb_mdpc_decoder_demo__DOT____VlemCall_0__row_state_min1 = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_0__row_state_min1 
        = (0x0000000fU & (IData)(__Vfunc_row_state_min1__5__state));
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_3__row_state_sign_xor))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:88: Assertion failed in %m: CASE1 row sign_xor[5] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 88, "", false);
    }
    __Vfunc_row_state_min2__6__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[6U];
    tb_mdpc_decoder_demo__DOT____VlemCall_1__row_state_min2 = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_1__row_state_min2 
        = (0x0000000fU & ((IData)(__Vfunc_row_state_min2__6__state) 
                          >> 4U));
    if (VL_UNLIKELY(((3U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_4__row_state_valid_count))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:89: Assertion failed in %m: CASE1 row valid_count[5] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 89, "", false);
    }
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_0__row_state_min1))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:85: Assertion failed in %m: CASE1 row min1[6] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 85, "", false);
    }
    __Vfunc_row_state_min_id__7__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[6U];
    tb_mdpc_decoder_demo__DOT____VlemCall_2__row_state_min_id = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_2__row_state_min_id 
        = (0x0000000fU & ((IData)(__Vfunc_row_state_min_id__7__state) 
                          >> 8U));
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_1__row_state_min2))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:86: Assertion failed in %m: CASE1 row min2[6] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 86, "", false);
    }
    if (VL_UNLIKELY(((3U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_2__row_state_min_id))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:87: Assertion failed in %m: CASE1 row min_id[6] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 87, "", false);
    }
    __Vfunc_row_state_sign_xor__8__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[6U];
    tb_mdpc_decoder_demo__DOT____VlemCall_3__row_state_sign_xor = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_3__row_state_sign_xor 
        = (1U & ((IData)(__Vfunc_row_state_sign_xor__8__state) 
                 >> 0x0cU));
    __Vfunc_row_state_valid_count__9__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[6U];
    tb_mdpc_decoder_demo__DOT____VlemCall_4__row_state_valid_count = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_4__row_state_valid_count 
        = (3U & ((IData)(__Vfunc_row_state_valid_count__9__state) 
                 >> 0x0dU));
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_3__row_state_sign_xor))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:88: Assertion failed in %m: CASE1 row sign_xor[6] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 88, "", false);
    }
    __Vfunc_row_state_min1__5__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[7U];
    tb_mdpc_decoder_demo__DOT____VlemCall_0__row_state_min1 = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_0__row_state_min1 
        = (0x0000000fU & (IData)(__Vfunc_row_state_min1__5__state));
    if (VL_UNLIKELY(((3U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_4__row_state_valid_count))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:89: Assertion failed in %m: CASE1 row valid_count[6] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 89, "", false);
    }
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_0__row_state_min1))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:85: Assertion failed in %m: CASE1 row min1[7] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 85, "", false);
    }
    __Vfunc_row_state_min2__6__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[7U];
    tb_mdpc_decoder_demo__DOT____VlemCall_1__row_state_min2 = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_1__row_state_min2 
        = (0x0000000fU & ((IData)(__Vfunc_row_state_min2__6__state) 
                          >> 4U));
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_1__row_state_min2))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:86: Assertion failed in %m: CASE1 row min2[7] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 86, "", false);
    }
    __Vfunc_row_state_min_id__7__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[7U];
    tb_mdpc_decoder_demo__DOT____VlemCall_2__row_state_min_id = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_2__row_state_min_id 
        = (0x0000000fU & ((IData)(__Vfunc_row_state_min_id__7__state) 
                          >> 8U));
    if (VL_UNLIKELY(((4U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_2__row_state_min_id))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:87: Assertion failed in %m: CASE1 row min_id[7] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 87, "", false);
    }
    __Vfunc_row_state_sign_xor__8__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[7U];
    tb_mdpc_decoder_demo__DOT____VlemCall_3__row_state_sign_xor = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_3__row_state_sign_xor 
        = (1U & ((IData)(__Vfunc_row_state_sign_xor__8__state) 
                 >> 0x0cU));
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_3__row_state_sign_xor))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:88: Assertion failed in %m: CASE1 row sign_xor[7] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 88, "", false);
    }
    __Vfunc_row_state_valid_count__9__state = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[7U];
    tb_mdpc_decoder_demo__DOT____VlemCall_4__row_state_valid_count = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_4__row_state_valid_count 
        = (3U & ((IData)(__Vfunc_row_state_valid_count__9__state) 
                 >> 0x0dU));
    if (VL_UNLIKELY(((3U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_4__row_state_valid_count))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:89: Assertion failed in %m: CASE1 row valid_count[7] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 89, "", false);
    }
    while ((1U & (~ ((4U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state)) 
                     & (0U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx)))))) {
        Vtb_mdpc_decoder_demo___024root____VbeforeTrig_hd708b578__0(vlSelf, 
                                                                    "@( ((3'h4 == tb_mdpc_decoder_demo.dut.state) & (4'h0 == tb_mdpc_decoder_demo.dut.active_var_idx)))");
        co_await vlSelfRef.__VtrigSched_hd708b578__0.trigger(1U, 
                                                             nullptr, 
                                                             "@( ((3'h4 == tb_mdpc_decoder_demo.dut.state) & (4'h0 == tb_mdpc_decoder_demo.dut.active_var_idx)))", 
                                                             "tb/tb_mdpc_decoder_demo.sv", 
                                                             92);
    }
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "tb/tb_mdpc_decoder_demo.sv", 
                                         93);
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[0U][0U];
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[0U][0U];
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[0U][1U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[0] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[0U][1U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[0] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[0U][2U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[1] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[0U][2U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[1] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[1U][0U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[2] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[1U][0U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[2] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[1U][1U];
    if (VL_UNLIKELY(((1U & (~ (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[3] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[1U][1U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[3] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[1U][2U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[4] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[1U][2U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[4] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[2U][0U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[5] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[2U][0U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[5] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[2U][1U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[6] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[2U][1U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[6] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[2U][2U];
    if (VL_UNLIKELY(((1U & (~ (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[7] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[2U][2U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[7] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[3U][0U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[8] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[3U][0U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[8] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[3U][1U];
    if (VL_UNLIKELY(((1U & (~ (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[9] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[3U][1U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[9] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[3U][2U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[10] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[3U][2U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[10] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[4U][0U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[11] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[4U][0U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[11] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[4U][1U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[12] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[4U][1U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[12] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[4U][2U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[13] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[4U][2U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[13] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[5U][0U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[14] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[5U][0U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[14] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[5U][1U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[15] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[5U][1U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[15] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[5U][2U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[16] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[5U][2U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[16] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[6U][0U];
    if (VL_UNLIKELY(((1U & (~ (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[17] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[6U][0U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[17] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[6U][1U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[18] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[6U][1U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[18] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[6U][2U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[19] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[6U][2U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[19] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[7U][0U];
    if (VL_UNLIKELY(((1U & (~ (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[20] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[7U][0U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[20] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[7U][1U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[21] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[7U][1U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[21] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[7U][2U];
    if (VL_UNLIKELY(((1U & (~ (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[22] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[7U][2U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[22] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[8U][0U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[23] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[8U][0U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[23] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[8U][1U];
    if (VL_UNLIKELY(((1U & (~ (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[24] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[8U][1U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[24] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[8U][2U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[25] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[8U][2U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[25] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[9U][0U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[26] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[9U][0U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[26] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[9U][1U];
    if (VL_UNLIKELY(((1U & (~ (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[27] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[9U][1U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[27] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[9U][2U];
    if (VL_UNLIKELY(((1U & (~ (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[28] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[9U][2U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[28] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[10U][0U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[29] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[10U][0U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[29] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[10U][1U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[30] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[10U][1U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[30] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[10U][2U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[31] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[10U][2U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[31] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[11U][0U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[32] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[11U][0U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[32] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[11U][1U];
    if (VL_UNLIKELY(((1U & (~ (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[33] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[11U][1U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[33] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[11U][2U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[34] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[11U][2U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[34] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[12U][0U];
    if (VL_UNLIKELY(((1U & (~ (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[35] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[12U][0U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[35] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[12U][1U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[36] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[12U][1U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[36] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[12U][2U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[37] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[12U][2U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[37] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[13U][0U];
    if (VL_UNLIKELY(((1U & (~ (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[38] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[13U][0U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[38] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[13U][1U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[39] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[13U][1U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[39] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[13U][2U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[40] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[13U][2U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[40] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[14U][0U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[41] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[14U][0U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[41] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[14U][1U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[42] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[14U][1U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[42] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[14U][2U];
    if (VL_UNLIKELY(((1U & (~ (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[43] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[14U][2U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[43] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[15U][0U];
    if (VL_UNLIKELY(((1U & (~ (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[44] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[15U][0U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[44] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[15U][1U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[45] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[45] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    if (VL_UNLIKELY(((1U & (~ (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[46] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[15U][1U];
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    __Vfunc_msg_sign__10__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[15U][2U];
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__10__msg) 
                 >> 4U));
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[46] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_5__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:98: Assertion failed in %m: CASE1 c2v sign[47] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 98, "", false);
    }
    __Vfunc_msg_mag__11__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[15U][2U];
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__11__msg));
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_6__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:99: Assertion failed in %m: CASE1 c2v mag[47] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk2", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 99, "", false);
    }
    while ((1U & (~ ((5U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state)) 
                     & (0U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__iter_count)))))) {
        Vtb_mdpc_decoder_demo___024root____VbeforeTrig_hdfc022cc__0(vlSelf, 
                                                                    "@( ((3'h5 == tb_mdpc_decoder_demo.dut.state) & (3'h0 == tb_mdpc_decoder_demo.iter_count)))");
        co_await vlSelfRef.__VtrigSched_hdfc022cc__0.trigger(1U, 
                                                             nullptr, 
                                                             "@( ((3'h5 == tb_mdpc_decoder_demo.dut.state) & (3'h0 == tb_mdpc_decoder_demo.iter_count)))", 
                                                             "tb/tb_mdpc_decoder_demo.sv", 
                                                             104);
    }
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "tb/tb_mdpc_decoder_demo.sv", 
                                         105);
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[0U][0U];
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[0U][0U];
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[0U][1U];
    if (VL_UNLIKELY(((1U & (~ (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[0] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[0U][1U];
    if (VL_UNLIKELY(((7U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[0] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    if (VL_UNLIKELY(((1U & (~ (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[1] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[0U][2U];
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    if (VL_UNLIKELY(((7U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[1] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    if (VL_UNLIKELY(((1U & (~ (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[2] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[0U][2U];
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[1U][0U];
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[1U][0U];
    if (VL_UNLIKELY(((7U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[2] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[1U][1U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[3] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[1U][1U];
    if (VL_UNLIKELY(((0x0bU != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[3] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[1U][2U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[4] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[1U][2U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[4] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[2U][0U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[5] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[2U][0U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[5] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[2U][1U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[6] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[2U][1U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[6] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[2U][2U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[7] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[2U][2U];
    if (VL_UNLIKELY(((0x0bU != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[7] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[3U][0U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[8] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[3U][0U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[8] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[3U][1U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[9] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[3U][1U];
    if (VL_UNLIKELY(((0x0bU != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[9] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[3U][2U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[10] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[3U][2U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[10] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[4U][0U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[11] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[4U][0U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[11] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[4U][1U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[12] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[4U][1U];
    if (VL_UNLIKELY(((0x0bU != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[12] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[4U][2U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[13] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[4U][2U];
    if (VL_UNLIKELY(((0x0bU != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[13] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[5U][0U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[14] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[5U][0U];
    if (VL_UNLIKELY(((0x0bU != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[14] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[5U][1U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[15] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[5U][1U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[15] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[5U][2U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[16] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[5U][2U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[16] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[6U][0U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[17] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[6U][0U];
    if (VL_UNLIKELY(((0x0bU != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[17] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[6U][1U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[18] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[6U][1U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[18] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[6U][2U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[19] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[6U][2U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[19] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[7U][0U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[20] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[7U][0U];
    if (VL_UNLIKELY(((0x0bU != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[20] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[7U][1U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[21] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[7U][1U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[21] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[7U][2U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[22] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[7U][2U];
    if (VL_UNLIKELY(((0x0bU != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[22] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[8U][0U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[23] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[8U][0U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[23] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[8U][1U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[24] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[8U][1U];
    if (VL_UNLIKELY(((0x0bU != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[24] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[8U][2U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[25] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[8U][2U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[25] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[9U][0U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[26] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[9U][0U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[26] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[9U][1U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[27] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[9U][1U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[27] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[9U][2U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[28] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[9U][2U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[28] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[10U][0U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[29] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[10U][0U];
    if (VL_UNLIKELY(((7U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[29] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[10U][1U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[30] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[10U][1U];
    if (VL_UNLIKELY(((0x0bU != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[30] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[10U][2U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[31] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[10U][2U];
    if (VL_UNLIKELY(((0x0bU != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[31] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[11U][0U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[32] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[11U][0U];
    if (VL_UNLIKELY(((0x0bU != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[32] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[11U][1U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[33] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[11U][1U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[33] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[11U][2U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[34] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[11U][2U];
    if (VL_UNLIKELY(((7U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[34] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[12U][0U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[35] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[12U][0U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[35] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[12U][1U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[36] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[12U][1U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[36] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[12U][2U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[37] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[12U][2U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[37] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[13U][0U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[38] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[13U][0U];
    if (VL_UNLIKELY(((0x0bU != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[38] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[13U][1U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[39] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[13U][1U];
    if (VL_UNLIKELY(((0x0bU != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[39] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[13U][2U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[40] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[13U][2U];
    if (VL_UNLIKELY(((0x0bU != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[40] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[14U][0U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[41] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[14U][0U];
    if (VL_UNLIKELY(((0x0bU != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[41] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[42] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    if (VL_UNLIKELY(((7U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[42] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[14U][1U];
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[14U][1U];
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[14U][2U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[43] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[14U][2U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[43] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[15U][0U];
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[44] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[15U][0U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[44] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[45] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[15U][1U];
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[15U][1U];
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[45] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[46] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    if (VL_UNLIKELY(((0x0bU != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[46] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    __Vfunc_msg_sign__12__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[15U][2U];
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign 
        = (1U & ((IData)(__Vfunc_msg_sign__12__msg) 
                 >> 4U));
    if (VL_UNLIKELY((tb_mdpc_decoder_demo__DOT____VlemCall_7__msg_sign))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:110: Assertion failed in %m: CASE1 u sign[47] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 110, "", false);
    }
    __Vfunc_msg_mag__13__msg = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[15U][2U];
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag = 0;
    tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag 
        = (0x0000000fU & (IData)(__Vfunc_msg_mag__13__msg));
    if (VL_UNLIKELY(((9U != (IData)(tb_mdpc_decoder_demo__DOT____VlemCall_8__msg_mag))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:111: Assertion failed in %m: CASE1 u mag[47] mismatch\n",3, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1.unnamedblk3", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 111, "", false);
    }
    while ((1U & (~ (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__done)))) {
        Vtb_mdpc_decoder_demo___024root____VbeforeTrig_h0d62a7d4__0(vlSelf, 
                                                                    "@( tb_mdpc_decoder_demo.done)");
        co_await vlSelfRef.__VtrigSched_h0d62a7d4__0.trigger(1U, 
                                                             nullptr, 
                                                             "@( tb_mdpc_decoder_demo.done)", 
                                                             "tb/tb_mdpc_decoder_demo.sv", 
                                                             116);
    }
    Vtb_mdpc_decoder_demo___024root____VbeforeTrig_h5ea129b9__0(vlSelf, 
                                                                "@(posedge tb_mdpc_decoder_demo.clk)");
    co_await vlSelfRef.__VtrigSched_h5ea129b9__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_mdpc_decoder_demo.clk)", 
                                                         "tb/tb_mdpc_decoder_demo.sv", 
                                                         117);
    if (VL_UNLIKELY((vlSelfRef.tb_mdpc_decoder_demo__DOT__success))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:118: Assertion failed in %m: CASE1 success mismatch: got %0d exp 0\n",4, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',1,(IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__success));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 118, "", false);
    }
    if (VL_UNLIKELY(((4U != (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__iter_count))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:119: Assertion failed in %m: CASE1 iterations mismatch: got %0d exp 4\n",4, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',3,(IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__iter_count));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 119, "", false);
    }
    if (VL_UNLIKELY(((1U != (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_out))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:120: Assertion failed in %m: CASE1 x_out mismatch: got %h exp 0001\n",4, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.unnamedblk1", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',16,(IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_out));
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 120, "", false);
    }
    __Vtask_tb_mdpc_decoder_demo__DOT__check_hist__14__expected_hist[0U] 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__unnamedblk1__DOT__case1_hist[0U];
    __Vtask_tb_mdpc_decoder_demo__DOT__check_hist__14__expected_hist[1U] 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__unnamedblk1__DOT__case1_hist[1U];
    __Vtask_tb_mdpc_decoder_demo__DOT__check_hist__14__expected_hist[2U] 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__unnamedblk1__DOT__case1_hist[2U];
    __Vtask_tb_mdpc_decoder_demo__DOT__check_hist__14__expected_hist[3U] 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__unnamedblk1__DOT__case1_hist[3U];
    if (VL_UNLIKELY(((vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist[0U] 
                      != __Vtask_tb_mdpc_decoder_demo__DOT__check_hist__14__expected_hist[0U])))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:57: Assertion failed in %m: syndrome_hist[0] mismatch: got %0d exp %0d\n",5, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.check_hist", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',8,vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist[0U]
                     , '~',32,__Vtask_tb_mdpc_decoder_demo__DOT__check_hist__14__expected_hist[0U]);
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 57, "", false);
    }
    if (VL_UNLIKELY(((vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist[1U] 
                      != __Vtask_tb_mdpc_decoder_demo__DOT__check_hist__14__expected_hist[1U])))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:57: Assertion failed in %m: syndrome_hist[1] mismatch: got %0d exp %0d\n",5, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.check_hist", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',8,vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist[1U]
                     , '~',32,__Vtask_tb_mdpc_decoder_demo__DOT__check_hist__14__expected_hist[1U]);
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 57, "", false);
    }
    if (VL_UNLIKELY(((vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist[2U] 
                      != __Vtask_tb_mdpc_decoder_demo__DOT__check_hist__14__expected_hist[2U])))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:57: Assertion failed in %m: syndrome_hist[2] mismatch: got %0d exp %0d\n",5, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.check_hist", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',8,vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist[2U]
                     , '~',32,__Vtask_tb_mdpc_decoder_demo__DOT__check_hist__14__expected_hist[2U]);
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 57, "", false);
    }
    if (VL_UNLIKELY(((vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist[3U] 
                      != __Vtask_tb_mdpc_decoder_demo__DOT__check_hist__14__expected_hist[3U])))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_mdpc_decoder_demo.sv:57: Assertion failed in %m: syndrome_hist[3] mismatch: got %0d exp %0d\n",5, 'M',vlSymsp->name(),"tb_mdpc_decoder_demo.check_hist", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',8,vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist[3U]
                     , '~',32,__Vtask_tb_mdpc_decoder_demo__DOT__check_hist__14__expected_hist[3U]);
        VL_STOP_MT("tb/tb_mdpc_decoder_demo.sv", 57, "", false);
    }
    VL_WRITEF_NX("tb_mdpc_decoder_demo PASS\n",0);
    VL_FINISH_MT("tb/tb_mdpc_decoder_demo.sv", 124, "");
    co_return;
}

VlCoroutine Vtb_mdpc_decoder_demo___024root___eval_initial__TOP__Vtiming__1(Vtb_mdpc_decoder_demo___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_decoder_demo___024root___eval_initial__TOP__Vtiming__1\n"); );
    Vtb_mdpc_decoder_demo__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    while (VL_LIKELY(!vlSymsp->_vm_contextp__->gotFinish())) {
        co_await vlSelfRef.__VdlySched.delay(0x0000000000001388ULL, 
                                             nullptr, 
                                             "tb/tb_mdpc_decoder_demo.sv", 
                                             31);
        vlSelfRef.tb_mdpc_decoder_demo__DOT__clk = 
            (1U & (~ (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__clk)));
    }
    co_return;
}

void Vtb_mdpc_decoder_demo___024root___eval_triggers_vec__act(Vtb_mdpc_decoder_demo___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_decoder_demo___024root___eval_triggers_vec__act\n"); );
    Vtb_mdpc_decoder_demo__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __Vtrigprevexpr_h95049e09__0;
    __Vtrigprevexpr_h95049e09__0 = 0;
    CData/*0:0*/ __Vtrigprevexpr_h4f3ec4ef__0;
    __Vtrigprevexpr_h4f3ec4ef__0 = 0;
    CData/*0:0*/ __Vtrigprevexpr_h87f7365b__0;
    __Vtrigprevexpr_h87f7365b__0 = 0;
    // Body
    __Vtrigprevexpr_h95049e09__0 = (((3U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state)) 
                                     & (0U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx))) 
                                    & (0U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__scan_slot)));
    __Vtrigprevexpr_h4f3ec4ef__0 = ((4U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state)) 
                                    & (0U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx)));
    __Vtrigprevexpr_h87f7365b__0 = ((5U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state)) 
                                    & (0U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__iter_count)));
    vlSelfRef.__VactTriggered[0U] = (QData)((IData)(
                                                    (((((IData)(__Vtrigprevexpr_h87f7365b__0) 
                                                        != (IData)(vlSelfRef.__Vtrigprevexpr_h87f7365b__1)) 
                                                       << 6U) 
                                                      | ((((IData)(__Vtrigprevexpr_h4f3ec4ef__0) 
                                                           != (IData)(vlSelfRef.__Vtrigprevexpr_h4f3ec4ef__1)) 
                                                          << 5U) 
                                                         | (vlSelfRef.__VdlySched.awaitingCurrentTime() 
                                                            << 4U))) 
                                                     | (((((IData)(__Vtrigprevexpr_h95049e09__0) 
                                                           != (IData)(vlSelfRef.__Vtrigprevexpr_h95049e09__1)) 
                                                          << 3U) 
                                                         | (((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__done) 
                                                             != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_mdpc_decoder_demo__DOT__done__0)) 
                                                            << 2U)) 
                                                        | ((((~ (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__rst_n)) 
                                                             & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_mdpc_decoder_demo__DOT__rst_n__0)) 
                                                            << 1U) 
                                                           | ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__clk) 
                                                              & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_mdpc_decoder_demo__DOT__clk__0))))))));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_mdpc_decoder_demo__DOT__clk__0 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__clk;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_mdpc_decoder_demo__DOT__rst_n__0 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__rst_n;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_mdpc_decoder_demo__DOT__done__0 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__done;
    vlSelfRef.__Vtrigprevexpr_h95049e09__1 = __Vtrigprevexpr_h95049e09__0;
    vlSelfRef.__Vtrigprevexpr_h4f3ec4ef__1 = __Vtrigprevexpr_h4f3ec4ef__0;
    vlSelfRef.__Vtrigprevexpr_h87f7365b__1 = __Vtrigprevexpr_h87f7365b__0;
}

bool Vtb_mdpc_decoder_demo___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_decoder_demo___024root___trigger_anySet__act\n"); );
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

void Vtb_mdpc_decoder_demo___024root___nba_sequent__TOP__0(Vtb_mdpc_decoder_demo___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_mdpc_decoder_demo___024root___nba_sequent__TOP__0\n"); );
    Vtb_mdpc_decoder_demo__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = 0;
    CData/*0:0*/ __Vfunc_gamma_from_bit__72__bit_value;
    __Vfunc_gamma_from_bit__72__bit_value = 0;
    IData/*31:0*/ __Vfunc_msg_from_signed__73__value;
    __Vfunc_msg_from_signed__73__value = 0;
    CData/*3:0*/ __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
    __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int = 0;
    CData/*4:0*/ __Vfunc_msg_from_signed__73__msg;
    __Vfunc_msg_from_signed__73__msg = 0;
    IData/*31:0*/ __Vfunc_msg_from_signed__73__abs_value;
    __Vfunc_msg_from_signed__73__abs_value = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__74__Vfuncout;
    __Vfunc_mag_from_int__74__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_mag_from_int__74__value;
    __Vfunc_mag_from_int__74__value = 0;
    IData/*31:0*/ __Vfunc_mag_from_int__74__clamped_value;
    __Vfunc_mag_from_int__74__clamped_value = 0;
    CData/*3:0*/ __Vfunc_mag_from_int__74__result;
    __Vfunc_mag_from_int__74__result = 0;
    IData/*31:0*/ __Vfunc_clamp_int__75__Vfuncout;
    __Vfunc_clamp_int__75__Vfuncout = 0;
    IData/*31:0*/ __Vfunc_clamp_int__75__value;
    __Vfunc_clamp_int__75__value = 0;
    CData/*4:0*/ __Vfunc_msg_pack__76__Vfuncout;
    __Vfunc_msg_pack__76__Vfuncout = 0;
    CData/*0:0*/ __Vfunc_msg_pack__76__sign;
    __Vfunc_msg_pack__76__sign = 0;
    CData/*3:0*/ __Vfunc_msg_pack__76__mag;
    __Vfunc_msg_pack__76__mag = 0;
    CData/*2:0*/ __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__state;
    __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__state = 0;
    CData/*3:0*/ __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx;
    __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx = 0;
    CData/*1:0*/ __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__scan_slot;
    __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__scan_slot = 0;
    CData/*7:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist__v0;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist__v0 = 0;
    CData/*1:0*/ __VdlyDim0__tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist__v0;
    __VdlyDim0__tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist__v0;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist__v1;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist__v1 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist__v2;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist__v2 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist__v5;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist__v5 = 0;
    CData/*1:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v0;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v0;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v0 = 0;
    CData/*1:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v1;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v1 = 0;
    CData/*1:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v2;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v2 = 0;
    CData/*1:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v3;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v3 = 0;
    CData/*1:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v4;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v4 = 0;
    CData/*0:0*/ __VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v4;
    __VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v4 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v4;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v4 = 0;
    CData/*1:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v5;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v5 = 0;
    CData/*0:0*/ __VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v5;
    __VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v5 = 0;
    CData/*1:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v6;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v6 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v6;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v6 = 0;
    CData/*1:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v7;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v7 = 0;
    CData/*1:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v8;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v8 = 0;
    CData/*1:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v9;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v9 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v0;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v0;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v0 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v1;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v1 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v1;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v1 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v2;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v2 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v2;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v2 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v3;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v3 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v3;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v3 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v4;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v4 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v4;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v4 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v5;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v5 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v5;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v5 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v6;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v6 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v6;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v6 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v7;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v7 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v7;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v7 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v8;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v8 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v8;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v8 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v9;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v9 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v9;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v9 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v10;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v10 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v10;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v10 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v11;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v11 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v11;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v11 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v12;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v12 = 0;
    CData/*0:0*/ __VdlyDim2__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v12;
    __VdlyDim2__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v12 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v12;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v12 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v13;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v13 = 0;
    CData/*0:0*/ __VdlyDim2__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v13;
    __VdlyDim2__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v13 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v13;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v13 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v14;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v14 = 0;
    CData/*0:0*/ __VdlyDim2__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v14;
    __VdlyDim2__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v14 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v14;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v14 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v15;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v15 = 0;
    CData/*0:0*/ __VdlyDim2__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v15;
    __VdlyDim2__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v15 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v15;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v15 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v16;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v16 = 0;
    CData/*0:0*/ __VdlyDim2__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v16;
    __VdlyDim2__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v16 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v16;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v16 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v17;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v17 = 0;
    CData/*0:0*/ __VdlyDim2__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v17;
    __VdlyDim2__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v17 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v17;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v17 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v18;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v18 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v18;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v18 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v19;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v19 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v19;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v19 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v20;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v20 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v20;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v20 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v21;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v21 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v21;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v21 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v22;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v22 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v22;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v22 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v23;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v23 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v23;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v23 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v24;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v24 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v24;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v24 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v25;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v25 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v25;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v25 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v26;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v26 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v26;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v26 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v27;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v27 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v27;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v27 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v28;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v28 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v28;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v28 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v29;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v29 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v29;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v29 = 0;
    SData/*14:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v0;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v0;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v0 = 0;
    SData/*14:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v1;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v1 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v1;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v1 = 0;
    SData/*14:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v2;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v2 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v2;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v2 = 0;
    SData/*14:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v3;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v3 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v3;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v3 = 0;
    SData/*14:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v4;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v4 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v4;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v4 = 0;
    SData/*14:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v5;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v5 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v5;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v5 = 0;
    SData/*14:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v6;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v6 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v6;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v6 = 0;
    SData/*14:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v7;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v7 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v7;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v7 = 0;
    SData/*14:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v8;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v8 = 0;
    CData/*2:0*/ __VdlyDim0__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v8;
    __VdlyDim0__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v8 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v8;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v8 = 0;
    SData/*14:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v9;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v9 = 0;
    CData/*2:0*/ __VdlyDim0__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v9;
    __VdlyDim0__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v9 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v9;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v9 = 0;
    SData/*14:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v10;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v10 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v10;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v10 = 0;
    SData/*14:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v11;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v11 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v11;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v11 = 0;
    SData/*14:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v12;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v12 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v12;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v12 = 0;
    SData/*14:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v13;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v13 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v13;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v13 = 0;
    SData/*14:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v14;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v14 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v14;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v14 = 0;
    SData/*14:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v15;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v15 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v15;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v15 = 0;
    SData/*14:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v16;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v16 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v16;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v16 = 0;
    SData/*14:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v17;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v17 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v17;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v17 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v0;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v0 = 0;
    CData/*0:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v48;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v48 = 0;
    CData/*1:0*/ __VdlyDim0__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v48;
    __VdlyDim0__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v48 = 0;
    CData/*3:0*/ __VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v48;
    __VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v48 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v48;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v48 = 0;
    CData/*0:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v49;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v49 = 0;
    CData/*1:0*/ __VdlyDim0__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v49;
    __VdlyDim0__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v49 = 0;
    CData/*3:0*/ __VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v49;
    __VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v49 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v49;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v49 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v50;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v50 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v0;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v0;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v0 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v1;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v1 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v1;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v1 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v2;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v2 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v2;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v2 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v3;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v3 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v3;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v3 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v4;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v4 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v4;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v4 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v5;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v5 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v5;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v5 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v6;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v6 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v6;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v6 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v7;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v7 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v7;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v7 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v8;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v8 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v8;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v8 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v9;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v9 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v9;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v9 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v10;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v10 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v10;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v10 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v11;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v11 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v11;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v11 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v12;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v12 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v12;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v12 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v13;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v13 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v13;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v13 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v14;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v14 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v14;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v14 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v15;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v15 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v15;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v15 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v16;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v16 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v16;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v16 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v17;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v17 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v17;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v17 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v18;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v18 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v18;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v18 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v19;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v19 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v19;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v19 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v20;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v20 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v20;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v20 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v21;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v21 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v21;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v21 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v22;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v22 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v22;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v22 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v23;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v23 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v23;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v23 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v24;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v24 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v24;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v24 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v25;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v25 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v25;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v25 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v26;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v26 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v26;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v26 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v27;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v27 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v27;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v27 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v28;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v28 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v28;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v28 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v29;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v29 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v29;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v29 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v30;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v30 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v30;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v30 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v31;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v31 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v31;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v31 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v32;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v32 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v32;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v32 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v33;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v33 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v33;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v33 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v34;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v34 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v34;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v34 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v35;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v35 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v35;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v35 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v36;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v36 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v36;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v36 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v37;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v37 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v37;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v37 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v38;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v38 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v38;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v38 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v39;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v39 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v39;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v39 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v40;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v40 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v40;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v40 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v41;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v41 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v41;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v41 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v42;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v42 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v42;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v42 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v43;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v43 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v43;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v43 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v44;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v44 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v44;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v44 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v45;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v45 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v45;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v45 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v46;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v46 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v46;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v46 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v47;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v47 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v47;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v47 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v48;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v48 = 0;
    CData/*1:0*/ __VdlyDim0__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v48;
    __VdlyDim0__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v48 = 0;
    CData/*3:0*/ __VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v48;
    __VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v48 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v48;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v48 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v49;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v49 = 0;
    CData/*1:0*/ __VdlyDim0__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v49;
    __VdlyDim0__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v49 = 0;
    CData/*3:0*/ __VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v49;
    __VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v49 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v49;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v49 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v50;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v50 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v50;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v50 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v51;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v51 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v51;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v51 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v52;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v52 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v52;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v52 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v53;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v53 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v53;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v53 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v54;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v54 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v54;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v54 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v55;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v55 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v55;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v55 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v56;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v56 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v56;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v56 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v57;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v57 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v57;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v57 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v58;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v58 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v58;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v58 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v59;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v59 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v59;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v59 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v60;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v60 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v60;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v60 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v61;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v61 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v61;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v61 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v62;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v62 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v62;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v62 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v63;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v63 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v63;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v63 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v64;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v64 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v64;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v64 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v65;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v65 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v65;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v65 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v66;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v66 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v66;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v66 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v67;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v67 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v67;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v67 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v68;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v68 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v68;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v68 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v69;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v69 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v69;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v69 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v70;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v70 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v70;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v70 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v71;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v71 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v71;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v71 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v72;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v72 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v72;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v72 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v73;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v73 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v73;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v73 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v74;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v74 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v74;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v74 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v75;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v75 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v75;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v75 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v76;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v76 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v76;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v76 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v77;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v77 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v77;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v77 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v78;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v78 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v78;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v78 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v79;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v79 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v79;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v79 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v80;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v80 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v80;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v80 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v81;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v81 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v81;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v81 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v82;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v82 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v82;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v82 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v83;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v83 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v83;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v83 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v84;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v84 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v84;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v84 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v85;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v85 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v85;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v85 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v86;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v86 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v86;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v86 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v87;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v87 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v87;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v87 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v88;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v88 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v88;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v88 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v89;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v89 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v89;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v89 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v90;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v90 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v90;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v90 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v91;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v91 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v91;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v91 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v92;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v92 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v92;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v92 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v93;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v93 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v93;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v93 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v94;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v94 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v94;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v94 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v95;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v95 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v95;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v95 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v96;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v96 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v96;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v96 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v97;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v97 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v97;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v97 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v0;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v0;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v0 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v1;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v1 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v1;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v1 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v2;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v2 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v2;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v2 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v3;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v3 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v3;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v3 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v4;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v4 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v4;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v4 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v5;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v5 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v5;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v5 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v6;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v6 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v6;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v6 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v7;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v7 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v7;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v7 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v8;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v8 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v8;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v8 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v9;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v9 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v9;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v9 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v10;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v10 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v10;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v10 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v11;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v11 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v11;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v11 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v12;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v12 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v12;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v12 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v13;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v13 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v13;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v13 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v14;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v14 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v14;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v14 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v15;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v15 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v15;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v15 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v16;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v16 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v16;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v16 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v17;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v17 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v17;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v17 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v18;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v18 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v18;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v18 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v19;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v19 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v19;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v19 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v20;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v20 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v20;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v20 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v21;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v21 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v21;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v21 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v22;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v22 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v22;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v22 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v23;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v23 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v23;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v23 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v24;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v24 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v24;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v24 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v25;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v25 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v25;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v25 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v26;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v26 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v26;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v26 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v27;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v27 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v27;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v27 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v28;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v28 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v28;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v28 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v29;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v29 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v29;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v29 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v30;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v30 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v30;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v30 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v31;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v31 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v31;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v31 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v32;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v32 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v32;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v32 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v33;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v33 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v33;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v33 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v34;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v34 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v34;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v34 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v35;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v35 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v35;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v35 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v36;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v36 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v36;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v36 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v37;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v37 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v37;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v37 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v38;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v38 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v38;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v38 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v39;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v39 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v39;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v39 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v40;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v40 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v40;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v40 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v41;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v41 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v41;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v41 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v42;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v42 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v42;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v42 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v43;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v43 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v43;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v43 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v44;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v44 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v44;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v44 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v45;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v45 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v45;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v45 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v46;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v46 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v46;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v46 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v47;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v47 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v47;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v47 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v48;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v48 = 0;
    CData/*3:0*/ __VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v48;
    __VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v48 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v48;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v48 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v49;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v49 = 0;
    CData/*3:0*/ __VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v49;
    __VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v49 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v49;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v49 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v50;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v50 = 0;
    CData/*3:0*/ __VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v50;
    __VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v50 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v50;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v50 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v51;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v51 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v51;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v51 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v52;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v52 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v52;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v52 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v53;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v53 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v53;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v53 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v54;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v54 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v54;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v54 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v55;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v55 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v55;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v55 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v56;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v56 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v56;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v56 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v57;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v57 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v57;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v57 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v58;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v58 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v58;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v58 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v59;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v59 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v59;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v59 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v60;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v60 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v60;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v60 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v61;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v61 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v61;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v61 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v62;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v62 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v62;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v62 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v63;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v63 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v63;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v63 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v64;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v64 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v64;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v64 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v65;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v65 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v65;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v65 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v66;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v66 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v66;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v66 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v67;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v67 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v67;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v67 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v68;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v68 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v68;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v68 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v69;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v69 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v69;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v69 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v70;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v70 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v70;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v70 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v71;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v71 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v71;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v71 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v72;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v72 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v72;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v72 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v73;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v73 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v73;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v73 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v74;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v74 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v74;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v74 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v75;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v75 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v75;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v75 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v76;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v76 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v76;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v76 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v77;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v77 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v77;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v77 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v78;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v78 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v78;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v78 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v79;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v79 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v79;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v79 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v80;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v80 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v80;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v80 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v81;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v81 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v81;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v81 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v82;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v82 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v82;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v82 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v83;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v83 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v83;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v83 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v84;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v84 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v84;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v84 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v85;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v85 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v85;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v85 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v86;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v86 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v86;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v86 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v87;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v87 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v87;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v87 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v88;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v88 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v88;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v88 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v89;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v89 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v89;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v89 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v90;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v90 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v90;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v90 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v91;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v91 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v91;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v91 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v92;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v92 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v92;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v92 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v93;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v93 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v93;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v93 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v94;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v94 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v94;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v94 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v95;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v95 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v95;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v95 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v96;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v96 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v96;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v96 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v97;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v97 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v97;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v97 = 0;
    CData/*4:0*/ __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v98;
    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v98 = 0;
    CData/*0:0*/ __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v98;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v98 = 0;
    // Body
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v0 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v48 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v49 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v50 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist__v0 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist__v1 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist__v2 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist__v5 = 0U;
    __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__state 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state;
    __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__scan_slot 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__scan_slot;
    __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx 
        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v0 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v1 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v2 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v3 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v4 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v5 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v6 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v7 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v8 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v9 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v10 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v11 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v12 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v13 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v14 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v15 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v16 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v17 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v0 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v4 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v6 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v0 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v1 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v2 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v3 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v4 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v5 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v6 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v7 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v8 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v9 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v10 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v11 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v12 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v13 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v14 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v15 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v16 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v17 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v18 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v19 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v20 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v21 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v22 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v23 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v24 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v25 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v26 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v27 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v28 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v29 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v0 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v1 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v2 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v3 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v4 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v5 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v6 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v7 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v8 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v9 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v10 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v11 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v12 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v13 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v14 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v15 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v16 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v17 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v18 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v19 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v20 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v21 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v22 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v23 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v24 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v25 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v26 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v27 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v28 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v29 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v30 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v31 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v32 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v33 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v34 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v35 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v36 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v37 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v38 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v39 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v40 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v41 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v42 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v43 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v44 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v45 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v46 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v47 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v48 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v49 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v50 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v51 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v52 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v53 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v54 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v55 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v56 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v57 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v58 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v59 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v60 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v61 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v62 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v63 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v64 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v65 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v66 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v67 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v68 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v69 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v70 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v71 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v72 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v73 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v74 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v75 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v76 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v77 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v78 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v79 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v80 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v81 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v82 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v83 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v84 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v85 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v86 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v87 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v88 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v89 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v90 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v91 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v92 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v93 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v94 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v95 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v96 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v97 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v0 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v1 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v2 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v3 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v4 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v5 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v6 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v7 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v8 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v9 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v10 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v11 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v12 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v13 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v14 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v15 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v16 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v17 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v18 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v19 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v20 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v21 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v22 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v23 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v24 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v25 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v26 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v27 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v28 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v29 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v30 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v31 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v32 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v33 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v34 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v35 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v36 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v37 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v38 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v39 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v40 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v41 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v42 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v43 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v44 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v45 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v46 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v47 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v48 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v49 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v50 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v51 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v52 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v53 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v54 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v55 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v56 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v57 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v58 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v59 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v60 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v61 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v62 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v63 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v64 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v65 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v66 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v67 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v68 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v69 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v70 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v71 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v72 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v73 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v74 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v75 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v76 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v77 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v78 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v79 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v80 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v81 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v82 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v83 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v84 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v85 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v86 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v87 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v88 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v89 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v90 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v91 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v92 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v93 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v94 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v95 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v96 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v97 = 0U;
    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v98 = 0U;
    if (vlSelfRef.tb_mdpc_decoder_demo__DOT__rst_n) {
        if ((1U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state))) {
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v0 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_count[0U][0U];
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v0 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v1 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_count[0U][1U];
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v2 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_count[1U][0U];
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v3 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_count[1U][1U];
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_entries[0U][0U][0U];
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v0 = 1U;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_entries[0U][0U][1U];
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v1 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v1 = 1U;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_entries[0U][0U][2U];
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v2 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v2 = 1U;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_entries[0U][1U][0U];
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v3 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v3 = 1U;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_entries[0U][1U][1U];
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v4 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v4 = 1U;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_entries[0U][1U][2U];
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v5 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v5 = 1U;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_entries[1U][0U][0U];
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v6 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v6 = 1U;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_entries[1U][0U][1U];
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v7 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v7 = 1U;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_entries[1U][0U][2U];
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v8 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v8 = 1U;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_entries[1U][1U][0U];
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v9 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v9 = 1U;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_entries[1U][1U][1U];
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v10 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v10 = 1U;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_entries[1U][1U][2U];
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v11 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v11 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v0 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v0 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v1 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v1 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v2 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v2 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v3 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v3 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v4 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v4 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v5 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v5 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v6 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v6 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v7 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v7 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v8 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v8 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v9 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v9 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v10 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v10 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v11 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v11 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v12 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v12 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v13 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v13 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v14 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v14 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v15 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v15 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v16 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v16 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v17 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v17 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v18 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v18 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v19 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v19 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v20 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v20 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v21 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v21 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v22 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v22 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v23 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v23 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v24 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v24 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v25 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v25 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v26 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v26 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v27 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v27 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v28 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v28 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v29 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v29 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v30 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v30 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v31 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v31 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v32 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v32 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v33 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v33 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v34 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v34 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v35 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v35 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v36 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v36 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v37 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v37 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v38 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v38 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v39 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v39 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v40 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v40 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v41 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v41 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v42 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v42 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v43 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v43 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v44 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v44 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v45 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v45 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v46 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v46 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v47 = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v47 = 1U;
        } else {
            if (vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_wr_en0) {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT____Vlvbound_hfe6829d9__0 
                    = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__cnu_a_sign0;
                if ((2U >= (3U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge0) 
                                  >> 0x0000000bU)))) {
                    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v48 
                        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT____Vlvbound_hfe6829d9__0;
                    __VdlyDim0__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v48 
                        = (3U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge0) 
                                 >> 0x0000000bU));
                    __VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v48 
                        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx;
                    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v48 = 1U;
                }
            }
            if (vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_wr_en1) {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT____Vlvbound_h6bd7c583__0 
                    = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__cnu_a_sign1;
                if ((2U >= (3U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge1) 
                                  >> 0x0000000bU)))) {
                    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v49 
                        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT____Vlvbound_h6bd7c583__0;
                    __VdlyDim0__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v49 
                        = (3U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge1) 
                                 >> 0x0000000bU));
                    __VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v49 
                        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx;
                    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v49 = 1U;
                }
            }
            if (vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__i_shift_en) {
                __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v4 
                    = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_count[0U];
                __VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v4 
                    = (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                             >> 3U));
                __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v4 = 1U;
                __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v5 
                    = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_count[1U];
                __VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v5 
                    = (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                             >> 3U));
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_hd74e08e1__0 
                    = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_entries[0U][0U];
                __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v12 
                    = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_hd74e08e1__0;
                __VdlyDim2__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v12 
                    = (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                             >> 3U));
                __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v12 = 1U;
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_hd74e08e1__0 
                    = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_entries[0U][1U];
                __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v13 
                    = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_hd74e08e1__0;
                __VdlyDim2__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v13 
                    = (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                             >> 3U));
                __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v13 = 1U;
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_hd74e08e1__0 
                    = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_entries[0U][2U];
                __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v14 
                    = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_hd74e08e1__0;
                __VdlyDim2__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v14 
                    = (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                             >> 3U));
                __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v14 = 1U;
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_hd74e08e1__0 
                    = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_entries[1U][0U];
                __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v15 
                    = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_hd74e08e1__0;
                __VdlyDim2__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v15 
                    = (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                             >> 3U));
                __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v15 = 1U;
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_hd74e08e1__0 
                    = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_entries[1U][1U];
                __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v16 
                    = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_hd74e08e1__0;
                __VdlyDim2__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v16 
                    = (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                             >> 3U));
                __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v16 = 1U;
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_hd74e08e1__0 
                    = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__shifted_entries[1U][2U];
                __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v17 
                    = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_hd74e08e1__0;
                __VdlyDim2__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v17 
                    = (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                             >> 3U));
                __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v17 = 1U;
            }
            if (((3U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state)) 
                 & (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge0))) {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT____Vlvbound_h72129cb2__0 
                    = ((0x00000010U & ((0x00fffff0U 
                                        & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_row_state_a0) 
                                           >> 8U)) 
                                       ^ (((2U >= (3U 
                                                   & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge0) 
                                                      >> 0x0000000bU))) 
                                           && vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem
                                           [vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx]
                                           [(3U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge0) 
                                                   >> 0x0000000bU))]) 
                                          << 4U))) 
                       | (0x0000000fU & (((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                                          == (0x0000000fU 
                                              & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_row_state_a0) 
                                                 >> 8U)))
                                          ? ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_row_state_a0) 
                                             >> 4U)
                                          : (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_row_state_a0))));
                if ((2U >= (3U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge0) 
                                  >> 0x0000000bU)))) {
                    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v48 
                        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT____Vlvbound_h72129cb2__0;
                    __VdlyDim0__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v48 
                        = (3U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge0) 
                                 >> 0x0000000bU));
                    __VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v48 
                        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx;
                    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v48 = 1U;
                }
            }
            if (((3U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state)) 
                 & (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge1))) {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT____Vlvbound_h88b19d0e__0 
                    = ((0x00000010U & ((0x00fffff0U 
                                        & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_row_state_a1) 
                                           >> 8U)) 
                                       ^ (((2U >= (3U 
                                                   & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge1) 
                                                      >> 0x0000000bU))) 
                                           && vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem
                                           [vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx]
                                           [(3U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge1) 
                                                   >> 0x0000000bU))]) 
                                          << 4U))) 
                       | (0x0000000fU & (((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx) 
                                          == (0x0000000fU 
                                              & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_row_state_a1) 
                                                 >> 8U)))
                                          ? ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_row_state_a1) 
                                             >> 4U)
                                          : (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_row_state_a1))));
                if ((2U >= (3U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge1) 
                                  >> 0x0000000bU)))) {
                    __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v49 
                        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT____Vlvbound_h88b19d0e__0;
                    __VdlyDim0__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v49 
                        = (3U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge1) 
                                 >> 0x0000000bU));
                    __VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v49 
                        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx;
                    __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v49 = 1U;
                }
            }
        }
        if (vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_clear_en) {
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v0 = 0x00ffU;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v0 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v1 = 0x00ffU;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v1 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v2 = 0x00ffU;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v2 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v3 = 0x00ffU;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v3 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v4 = 0x00ffU;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v4 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v5 = 0x00ffU;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v5 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v6 = 0x00ffU;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v6 = 1U;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v7 = 0x00ffU;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v7 = 1U;
        } else {
            if (vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_wr_en0) {
                __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v8 
                    = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane0__DOT__next_state;
                __VdlyDim0__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v8 
                    = (7U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge0) 
                             >> 4U));
                __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v8 = 1U;
            }
            if (vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__m_wr_en1) {
                __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v9 
                    = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_cnu_a_lane1__DOT__next_state;
                __VdlyDim0__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v9 
                    = (7U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__lane_edge1) 
                             >> 4U));
                __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v9 = 1U;
            }
        }
    } else {
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v50 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v10 = 0x00ffU;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v10 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v11 = 0x00ffU;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v11 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v12 = 0x00ffU;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v12 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v13 = 0x00ffU;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v13 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v14 = 0x00ffU;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v14 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v15 = 0x00ffU;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v15 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v16 = 0x00ffU;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v16 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v17 = 0x00ffU;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v17 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v6 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_count[0U][0U];
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v6 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v7 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_count[0U][1U];
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v8 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_count[1U][0U];
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v9 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_count[1U][1U];
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__1 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_entries[0U][0U][0U];
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v18 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__1;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v18 = 1U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__1 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_entries[0U][0U][1U];
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v19 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__1;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v19 = 1U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__1 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_entries[0U][0U][2U];
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v20 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__1;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v20 = 1U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__1 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_entries[0U][1U][0U];
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v21 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__1;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v21 = 1U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__1 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_entries[0U][1U][1U];
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v22 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__1;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v22 = 1U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__1 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_entries[0U][1U][2U];
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v23 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__1;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v23 = 1U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__1 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_entries[1U][0U][0U];
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v24 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__1;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v24 = 1U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__1 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_entries[1U][0U][1U];
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v25 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__1;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v25 = 1U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__1 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_entries[1U][0U][2U];
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v26 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__1;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v26 = 1U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__1 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_entries[1U][1U][0U];
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v27 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__1;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v27 = 1U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__1 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_entries[1U][1U][1U];
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v28 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__1;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v28 = 1U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__1 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__first_col_entries[1U][1U][2U];
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v29 
            = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT____Vlvbound_h7826b9b6__1;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v29 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v50 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v50 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v51 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v51 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v52 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v52 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v53 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v53 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v54 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v54 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v55 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v55 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v56 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v56 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v57 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v57 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v58 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v58 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v59 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v59 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v60 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v60 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v61 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v61 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v62 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v62 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v63 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v63 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v64 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v64 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v65 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v65 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v66 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v66 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v67 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v67 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v68 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v68 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v69 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v69 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v70 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v70 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v71 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v71 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v72 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v72 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v73 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v73 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v74 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v74 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v75 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v75 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v76 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v76 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v77 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v77 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v78 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v78 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v79 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v79 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v80 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v80 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v81 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v81 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v82 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v82 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v83 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v83 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v84 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v84 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v85 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v85 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v86 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v86 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v87 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v87 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v88 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v88 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v89 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v89 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v90 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v90 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v91 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v91 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v92 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v92 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v93 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v93 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v94 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v94 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v95 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v95 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v96 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v96 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v97 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v97 = 1U;
    }
    if (vlSelfRef.tb_mdpc_decoder_demo__DOT__rst_n) {
        if ((1U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state))) {
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel0;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel0: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel1;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel1;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel1: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v0 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel2;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel2: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel3;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel3;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel3: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v1 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v1 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel4;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel4: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel5;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel5;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel5: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v2 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v2 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 1U));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel6;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel6: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel7;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel7;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel7: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v3 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v3 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 1U));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel8;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel8: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel9;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel9;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel9: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v4 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v4 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 1U));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel10;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel10: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel11;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel11;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel11: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v5 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v5 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 2U));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel12;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel12: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel13;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel13;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel13: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v6 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v6 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 2U));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel14;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel14: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel15;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel15;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel15: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v7 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v7 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 2U));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel16;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel16: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel17;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel17;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel17: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v8 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v8 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 3U));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel18;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel18: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel19;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel19;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel19: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v9 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v9 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 3U));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel20;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel20: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel21;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel21;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel21: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v10 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v10 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 3U));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel22;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel22: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel23;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel23;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel23: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v11 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v11 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 4U));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel24;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel24: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel25;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel25;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel25: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v12 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v12 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 4U));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel26;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel26: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel27;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel27;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel27: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v13 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v13 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 4U));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel28;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel28: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel29;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel29;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel29: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v14 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v14 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 5U));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel30;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel30: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel31;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel31;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel31: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v15 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v15 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 5U));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel32;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel32: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel33;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel33;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel33: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v16 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v16 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 5U));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel34;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel34: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel35;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel35;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel35: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v17 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v17 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 6U));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel36;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel36: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel37;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel37;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel37: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v18 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v18 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 6U));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel38;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel38: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel39;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel39;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel39: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v19 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v19 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 6U));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel40;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel40: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel41;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel41;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel41: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v20 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v20 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 7U));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel42;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel42: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel43;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel43;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel43: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v21 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v21 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 7U));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel44;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel44: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel45;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel45;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel45: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v22 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v22 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 7U));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel46;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel46: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel47;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel47;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel47: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v23 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v23 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 8U));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel48;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel48: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel49;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel49;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel49: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v24 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v24 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 8U));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel50;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel50: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel51;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel51;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel51: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v25 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v25 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 8U));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel52;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel52: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel53;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel53;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel53: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v26 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v26 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 9U));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel54;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel54: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel55;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel55;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel55: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v27 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v27 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 9U));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel56;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel56: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel57;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel57;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel57: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v28 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v28 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 9U));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel58;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel58: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel59;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel59;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel59: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v29 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v29 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 0x0aU));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel60;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel60: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel61;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel61;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel61: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v30 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v30 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 0x0aU));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel62;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel62: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel63;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel63;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel63: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v31 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v31 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 0x0aU));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel64;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel64: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel65;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel65;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel65: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v32 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v32 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 0x0bU));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel66;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel66: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel67;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel67;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel67: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v33 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v33 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 0x0bU));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel68;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel68: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel69;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel69;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel69: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v34 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v34 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 0x0bU));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel70;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel70: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel71;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel71;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel71: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v35 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v35 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 0x0cU));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel72;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel72: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel73;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel73;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel73: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v36 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v36 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 0x0cU));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel74;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel74: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel75;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel75;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel75: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v37 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v37 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 0x0cU));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel76;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel76: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel77;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel77;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel77: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v38 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v38 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 0x0dU));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel78;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel78: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel79;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel79;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel79: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v39 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v39 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 0x0dU));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel80;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel80: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel81;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel81;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel81: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v40 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v40 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 0x0dU));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel82;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel82: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel83;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel83;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel83: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v41 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v41 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 0x0eU));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel84;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel84: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel85;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel85;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel85: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v42 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v42 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 0x0eU));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel86;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel86: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel87;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel87;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel87: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v43 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v43 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 0x0eU));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel88;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel88: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel89;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel89;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel89: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v44 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v44 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 0x0fU));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel90;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel90: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel91;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel91;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel91: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v45 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v45 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 0x0fU));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel92;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel92: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel93;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel93;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel93: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v46 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v46 = 1U;
            __Vfunc_gamma_from_bit__72__bit_value = 
                (1U & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in) 
                       >> 0x0fU));
            {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0U;
                if (__Vfunc_gamma_from_bit__72__bit_value) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 0xfffffff7U;
                    goto __Vlabel94;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit = 9U;
                __Vlabel94: ;
            }
            __Vfunc_msg_from_signed__73__value = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_0__gamma_from_bit;
            __Vfunc_msg_from_signed__73__abs_value 
                = (VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value)
                    ? (- __Vfunc_msg_from_signed__73__value)
                    : __Vfunc_msg_from_signed__73__value);
            __Vfunc_mag_from_int__74__value = __Vfunc_msg_from_signed__73__abs_value;
            __Vfunc_clamp_int__75__value = __Vfunc_mag_from_int__74__value;
            {
                __Vfunc_clamp_int__75__Vfuncout = 0U;
                if (VL_GTS_III(32, 0U, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0U;
                    goto __Vlabel95;
                }
                if (VL_LTS_III(32, 0x0000000fU, __Vfunc_clamp_int__75__value)) {
                    __Vfunc_clamp_int__75__Vfuncout = 0x0000000fU;
                    goto __Vlabel95;
                }
                __Vfunc_clamp_int__75__Vfuncout = __Vfunc_clamp_int__75__value;
                __Vlabel95: ;
            }
            __Vfunc_mag_from_int__74__clamped_value 
                = __Vfunc_clamp_int__75__Vfuncout;
            __Vfunc_mag_from_int__74__result = (0x0000000fU 
                                                & __Vfunc_mag_from_int__74__clamped_value);
            __Vfunc_mag_from_int__74__Vfuncout = __Vfunc_mag_from_int__74__result;
            __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int 
                = __Vfunc_mag_from_int__74__Vfuncout;
            __Vfunc_msg_pack__76__mag = __Vfunc_msg_from_signed__73____VlefCall_0__mag_from_int;
            __Vfunc_msg_pack__76__sign = VL_GTS_III(32, 0U, __Vfunc_msg_from_signed__73__value);
            __Vfunc_msg_pack__76__Vfuncout = (((IData)(__Vfunc_msg_pack__76__sign) 
                                               << 4U) 
                                              | (IData)(__Vfunc_msg_pack__76__mag));
            __Vfunc_msg_from_signed__73__msg = __Vfunc_msg_pack__76__Vfuncout;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed 
                = __Vfunc_msg_from_signed__73__msg;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____VlemCall_1__msg_from_signed;
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v47 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hcd83a06e__0;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v47 = 1U;
        } else if ((4U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state))) {
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hd4376c56__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__vnu_u_next[0U];
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v48 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hd4376c56__0;
            __VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v48 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v48 = 1U;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hd4376c56__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__vnu_u_next[1U];
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v49 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hd4376c56__0;
            __VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v49 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v49 = 1U;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hd4376c56__0 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__vnu_u_next[2U];
            __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v50 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT____Vlvbound_hd4376c56__0;
            __VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v50 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v50 = 1U;
        }
    } else {
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v51 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v51 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v52 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v52 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v53 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v53 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v54 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v54 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v55 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v55 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v56 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v56 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v57 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v57 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v58 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v58 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v59 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v59 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v60 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v60 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v61 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v61 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v62 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v62 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v63 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v63 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v64 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v64 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v65 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v65 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v66 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v66 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v67 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v67 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v68 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v68 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v69 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v69 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v70 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v70 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v71 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v71 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v72 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v72 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v73 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v73 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v74 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v74 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v75 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v75 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v76 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v76 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v77 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v77 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v78 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v78 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v79 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v79 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v80 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v80 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v81 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v81 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v82 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v82 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v83 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v83 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v84 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v84 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v85 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v85 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v86 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v86 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v87 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v87 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v88 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v88 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v89 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v89 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v90 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v90 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v91 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v91 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v92 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v92 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v93 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v93 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v94 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v94 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v95 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v95 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v96 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v96 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v97 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v97 = 1U;
        __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v98 = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v98 = 1U;
    }
    if (vlSelfRef.tb_mdpc_decoder_demo__DOT__rst_n) {
        if ((4U & (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state))) {
            if ((2U & (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state))) {
                if ((1U & (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state))) {
                    __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__state = 0U;
                } else {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__done = 1U;
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__x_out 
                        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_c1_ram__DOT__mem;
                }
            } else if ((1U & (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state))) {
                __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist__v0 
                    = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_next;
                __VdlyDim0__tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist__v0 
                    = (3U & (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__iter_count));
                __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist__v0 = 1U;
                if (vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__stop_decode) {
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__done = 1U;
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__success 
                        = (0U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_next));
                    vlSelfRef.tb_mdpc_decoder_demo__DOT__x_out 
                        = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_c1_ram__DOT__mem;
                    __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__state = 6U;
                } else {
                    __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx = 0U;
                    __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__scan_slot = 0U;
                    __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__state = 2U;
                }
                vlSelfRef.tb_mdpc_decoder_demo__DOT__iter_count 
                    = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__next_iter_count;
            } else {
                vlSelfRef.tb_mdpc_decoder_demo__DOT__x_out 
                    = (((~ ((IData)(1U) << (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx))) 
                        & (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__x_out)) 
                       | (0x0000ffffU & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__vnu_x_out) 
                                         << (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx))));
                if ((0x0fU == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx))) {
                    __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx = 0U;
                    __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__state = 5U;
                } else {
                    __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx 
                        = (0x0000000fU & ((IData)(1U) 
                                          + (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx)));
                }
            }
        } else if ((2U & (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state))) {
            if ((1U & (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state))) {
                if (vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__advance_var) {
                    __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__scan_slot = 0U;
                    if ((0x0fU == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx))) {
                        __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx = 0U;
                        __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__state = 4U;
                    } else {
                        __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx 
                            = (0x0000000fU & ((IData)(1U) 
                                              + (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx)));
                    }
                } else {
                    __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__scan_slot 
                        = (3U & ((IData)(1U) + (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__scan_slot)));
                }
            } else if (vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__advance_var) {
                __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__scan_slot = 0U;
                if ((0x0fU == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx))) {
                    __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx = 0U;
                    __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__state = 3U;
                } else {
                    __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx 
                        = (0x0000000fU & ((IData)(1U) 
                                          + (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx)));
                }
            } else {
                __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__scan_slot 
                    = (3U & ((IData)(1U) + (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__scan_slot)));
            }
        } else if ((1U & (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state))) {
            vlSelfRef.tb_mdpc_decoder_demo__DOT__done = 0U;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__success = 0U;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__x_out 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__iter_count = 0U;
            __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx = 0U;
            __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__scan_slot = 0U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist__v1 = 1U;
            __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__state = 2U;
            __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist__v2 = 1U;
        } else {
            vlSelfRef.tb_mdpc_decoder_demo__DOT__done = 0U;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__success = 0U;
            if (vlSelfRef.tb_mdpc_decoder_demo__DOT__start) {
                __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__state = 1U;
            }
        }
        if ((1U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state))) {
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_c0_ram__DOT__mem 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in;
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_c1_ram__DOT__mem 
                = vlSelfRef.tb_mdpc_decoder_demo__DOT__x_in;
        } else if ((4U == (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state))) {
            vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_c1_ram__DOT__mem 
                = (((~ ((IData)(1U) << (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx))) 
                    & (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_c1_ram__DOT__mem)) 
                   | (0x0000ffffU & ((IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__vnu_x_out) 
                                     << (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx))));
        }
    } else {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_c0_ram__DOT__mem = 0U;
        __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__state = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__done = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__success = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__x_out = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__iter_count = 0U;
        __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx = 0U;
        __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__scan_slot = 0U;
        __VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist__v5 = 1U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_c1_ram__DOT__mem = 0U;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v0) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v0;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v1) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v1;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v2) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v2;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v3) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[3U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v3;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v4) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[4U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v4;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v5) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[5U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v5;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v6) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[6U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v6;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v7) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[7U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v7;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v8) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[__VdlyDim0__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v8] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v8;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v9) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[__VdlyDim0__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v9] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v9;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v10) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v10;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v11) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v11;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v12) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v12;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v13) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[3U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v13;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v14) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[4U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v14;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v15) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[5U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v15;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v16) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[6U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v16;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v17) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem[7U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_m_ram__DOT__mem__v17;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v0) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem[0U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v0;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem[0U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v1;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem[1U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v2;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem[1U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v3;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v4) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem[__VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v4][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v4;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem[__VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v5][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v5;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v6) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem[0U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v6;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem[0U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v7;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem[1U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v8;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem[1U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__count_mem__v9;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v0) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[0U][0U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v0;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v1) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[0U][0U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v1;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v2) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[0U][0U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v2;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v3) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[0U][1U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v3;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v4) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[0U][1U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v4;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v5) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[0U][1U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v5;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v6) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[1U][0U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v6;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v7) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[1U][0U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v7;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v8) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[1U][0U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v8;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v9) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[1U][1U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v9;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v10) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[1U][1U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v10;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v11) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[1U][1U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v11;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v12) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[__VdlyDim2__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v12][0U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v12;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v13) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[__VdlyDim2__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v13][0U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v13;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v14) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[__VdlyDim2__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v14][0U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v14;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v15) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[__VdlyDim2__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v15][1U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v15;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v16) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[__VdlyDim2__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v16][1U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v16;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v17) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[__VdlyDim2__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v17][1U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v17;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v18) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[0U][0U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v18;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v19) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[0U][0U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v19;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v20) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[0U][0U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v20;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v21) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[0U][1U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v21;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v22) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[0U][1U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v22;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v23) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[0U][1U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v23;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v24) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[1U][0U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v24;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v25) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[1U][0U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v25;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v26) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[1U][0U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v26;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v27) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[1U][1U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v27;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v28) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[1U][1U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v28;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v29) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem[1U][1U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_i_ram__DOT__mem__v29;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v0) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[0U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[0U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[0U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[1U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[1U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[1U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[2U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[2U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[2U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[3U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[3U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[3U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[4U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[4U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[4U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[5U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[5U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[5U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[6U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[6U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[6U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[7U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[7U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[7U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[8U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[8U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[8U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[9U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[9U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[9U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[10U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[10U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[10U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[11U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[11U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[11U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[12U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[12U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[12U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[13U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[13U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[13U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[14U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[14U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[14U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[15U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[15U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[15U][2U] = 0U;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v48) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[__VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v48][__VdlyDim0__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v48] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v48;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v49) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[__VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v49][__VdlyDim0__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v49] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v49;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem__v50) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[0U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[0U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[0U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[1U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[1U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[1U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[2U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[2U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[2U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[3U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[3U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[3U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[4U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[4U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[4U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[5U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[5U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[5U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[6U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[6U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[6U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[7U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[7U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[7U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[8U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[8U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[8U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[9U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[9U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[9U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[10U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[10U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[10U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[11U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[11U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[11U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[12U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[12U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[12U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[13U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[13U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[13U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[14U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[14U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[14U][2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[15U][0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[15U][1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_s_ram__DOT__mem[15U][2U] = 0U;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v0) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[0U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v0;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v1) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[0U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v1;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v2) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[0U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v2;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v3) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[1U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v3;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v4) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[1U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v4;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v5) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[1U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v5;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v6) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[2U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v6;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v7) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[2U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v7;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v8) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[2U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v8;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v9) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[3U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v9;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v10) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[3U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v10;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v11) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[3U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v11;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v12) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[4U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v12;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v13) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[4U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v13;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v14) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[4U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v14;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v15) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[5U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v15;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v16) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[5U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v16;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v17) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[5U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v17;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v18) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[6U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v18;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v19) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[6U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v19;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v20) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[6U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v20;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v21) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[7U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v21;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v22) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[7U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v22;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v23) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[7U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v23;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v24) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[8U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v24;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v25) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[8U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v25;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v26) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[8U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v26;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v27) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[9U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v27;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v28) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[9U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v28;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v29) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[9U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v29;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v30) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[10U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v30;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v31) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[10U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v31;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v32) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[10U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v32;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v33) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[11U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v33;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v34) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[11U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v34;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v35) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[11U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v35;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v36) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[12U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v36;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v37) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[12U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v37;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v38) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[12U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v38;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v39) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[13U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v39;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v40) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[13U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v40;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v41) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[13U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v41;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v42) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[14U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v42;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v43) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[14U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v43;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v44) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[14U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v44;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v45) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[15U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v45;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v46) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[15U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v46;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v47) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[15U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v47;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v48) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[__VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v48][__VdlyDim0__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v48] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v48;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v49) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[__VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v49][__VdlyDim0__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v49] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v49;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v50) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[0U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v50;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v51) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[0U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v51;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v52) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[0U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v52;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v53) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[1U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v53;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v54) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[1U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v54;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v55) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[1U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v55;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v56) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[2U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v56;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v57) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[2U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v57;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v58) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[2U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v58;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v59) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[3U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v59;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v60) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[3U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v60;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v61) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[3U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v61;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v62) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[4U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v62;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v63) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[4U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v63;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v64) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[4U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v64;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v65) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[5U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v65;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v66) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[5U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v66;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v67) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[5U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v67;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v68) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[6U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v68;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v69) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[6U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v69;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v70) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[6U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v70;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v71) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[7U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v71;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v72) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[7U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v72;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v73) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[7U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v73;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v74) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[8U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v74;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v75) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[8U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v75;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v76) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[8U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v76;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v77) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[9U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v77;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v78) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[9U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v78;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v79) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[9U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v79;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v80) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[10U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v80;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v81) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[10U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v81;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v82) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[10U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v82;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v83) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[11U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v83;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v84) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[11U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v84;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v85) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[11U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v85;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v86) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[12U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v86;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v87) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[12U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v87;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v88) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[12U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v88;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v89) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[13U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v89;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v90) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[13U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v90;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v91) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[13U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v91;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v92) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[14U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v92;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v93) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[14U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v93;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v94) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[14U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v94;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v95) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[15U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v95;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v96) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[15U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v96;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v97) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem[15U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_t_ram__DOT__mem__v97;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v0) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[0U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v0;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v1) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[0U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v1;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v2) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[0U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v2;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v3) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[1U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v3;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v4) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[1U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v4;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v5) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[1U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v5;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v6) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[2U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v6;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v7) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[2U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v7;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v8) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[2U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v8;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v9) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[3U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v9;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v10) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[3U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v10;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v11) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[3U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v11;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v12) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[4U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v12;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v13) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[4U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v13;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v14) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[4U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v14;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v15) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[5U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v15;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v16) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[5U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v16;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v17) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[5U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v17;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v18) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[6U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v18;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v19) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[6U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v19;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v20) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[6U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v20;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v21) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[7U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v21;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v22) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[7U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v22;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v23) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[7U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v23;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v24) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[8U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v24;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v25) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[8U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v25;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v26) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[8U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v26;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v27) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[9U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v27;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v28) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[9U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v28;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v29) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[9U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v29;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v30) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[10U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v30;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v31) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[10U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v31;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v32) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[10U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v32;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v33) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[11U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v33;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v34) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[11U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v34;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v35) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[11U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v35;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v36) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[12U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v36;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v37) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[12U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v37;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v38) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[12U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v38;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v39) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[13U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v39;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v40) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[13U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v40;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v41) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[13U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v41;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v42) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[14U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v42;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v43) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[14U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v43;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v44) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[14U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v44;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v45) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[15U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v45;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v46) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[15U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v46;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v47) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[15U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v47;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v48) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[__VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v48][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v48;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v49) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[__VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v49][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v49;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v50) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[__VdlyDim1__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v50][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v50;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v51) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[0U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v51;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v52) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[0U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v52;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v53) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[0U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v53;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v54) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[1U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v54;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v55) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[1U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v55;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v56) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[1U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v56;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v57) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[2U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v57;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v58) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[2U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v58;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v59) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[2U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v59;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v60) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[3U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v60;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v61) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[3U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v61;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v62) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[3U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v62;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v63) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[4U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v63;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v64) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[4U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v64;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v65) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[4U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v65;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v66) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[5U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v66;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v67) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[5U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v67;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v68) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[5U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v68;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v69) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[6U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v69;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v70) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[6U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v70;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v71) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[6U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v71;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v72) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[7U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v72;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v73) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[7U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v73;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v74) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[7U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v74;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v75) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[8U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v75;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v76) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[8U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v76;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v77) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[8U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v77;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v78) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[9U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v78;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v79) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[9U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v79;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v80) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[9U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v80;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v81) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[10U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v81;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v82) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[10U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v82;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v83) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[10U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v83;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v84) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[11U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v84;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v85) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[11U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v85;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v86) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[11U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v86;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v87) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[12U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v87;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v88) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[12U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v88;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v89) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[12U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v89;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v90) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[13U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v90;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v91) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[13U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v91;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v92) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[13U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v92;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v93) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[14U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v93;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v94) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[14U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v94;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v95) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[14U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v95;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v96) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[15U][0U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v96;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v97) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[15U][1U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v97;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v98) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem[15U][2U] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__u_u_ram__DOT__mem__v98;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist__v0) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist[__VdlyDim0__tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist__v0] 
            = __VdlyVal__tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist__v0;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist__v1) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist[0U] = 0U;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist__v2) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist[1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist[2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist[3U] = 0U;
    }
    if (__VdlySet__tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist__v5) {
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist[0U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist[1U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist[2U] = 0U;
        vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__syndrome_hist[3U] = 0U;
    }
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__scan_slot 
        = __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__scan_slot;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__next_iter_count 
        = (7U & ((IData)(1U) + (IData)(vlSelfRef.tb_mdpc_decoder_demo__DOT__iter_count)));
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__state 
        = __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__state;
    vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx 
        = __Vdly__tb_mdpc_decoder_demo__DOT__dut__DOT__active_var_idx;
    vlSelfRef.__Vfunc_syndrome_vector__17__x_bits = vlSelfRef.tb_mdpc_decoder_demo__DOT__dut__DOT__u_c1_ram__DOT__mem;
    vlSelfRef.__Vfunc_syndrome_vector__17__syndrome = 0U;
    vlSelfRef.__Vfunc_syndrome_vector__17__parity = 0U;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]);
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]);
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]);
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 1U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 1U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 1U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 2U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 2U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 2U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 3U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 3U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 3U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 4U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 4U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 4U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 5U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 5U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 5U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 6U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 6U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 6U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 7U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 7U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]);
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 7U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]);
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 8U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]);
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 8U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 8U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 9U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 9U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 9U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0aU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0aU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0aU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0bU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0bU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0bU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0cU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0cU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0cU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0dU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0dU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0dU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0eU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0eU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0eU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
               ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                  >> 0x0000000fU));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
               ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                  >> 0x0000000fU));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    if ((0U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
               ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                  >> 0x0000000fU));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17__syndrome 
        = ((0xfeU & (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__syndrome)) 
           | (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity));
    vlSelfRef.__Vfunc_syndrome_vector__17__parity = 0U;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]);
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]);
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]);
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 1U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 1U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 1U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 2U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 2U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 2U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 3U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 3U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 3U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 4U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 4U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 4U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 5U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 5U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 5U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 6U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 6U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 6U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 7U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 7U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]);
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 7U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]);
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 8U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]);
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 8U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 8U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 9U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 9U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 9U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0aU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0aU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0aU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0bU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0bU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0bU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0cU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0cU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0cU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0dU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0dU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0dU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0eU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(6U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0eU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][0U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 0x0eU)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][1U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
               ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                  >> 0x0000000fU));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(7U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[1U][2U]));
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
               ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                  >> 0x0000000fU));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    if ((1U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
               ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                  >> 0x0000000fU));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17__syndrome 
        = ((0xfdU & (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__syndrome)) 
           | ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
              << 1U));
    vlSelfRef.__Vfunc_syndrome_vector__17__parity = 0U;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]);
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]);
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]);
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ (IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 1U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(1U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 1U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 1U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 2U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(2U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 2U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 2U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 3U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(3U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 3U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 3U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][1U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 4U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(4U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][2U]));
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 4U)));
    }
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
    if ((2U == vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global)) {
        vlSelfRef.__Vfunc_syndrome_vector__17__parity 
            = (1U & ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__parity) 
                     ^ ((IData)(vlSelfRef.__Vfunc_syndrome_vector__17__x_bits) 
                        >> 4U)));
    }
    __Vfunc_edge_row_global__18__Vfuncout = (7U & ((IData)(5U) 
                                                   + vlSymsp->TOP__mdpc_demo_pkg.H_BASE[0U][0U]));
    vlSelfRef.__Vfunc_syndrome_vector__17____VlefCall_0__edge_row_global 
        = __Vfunc_edge_row_global__18__Vfuncout;
}
