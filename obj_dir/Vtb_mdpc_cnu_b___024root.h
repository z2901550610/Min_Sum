// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtb_mdpc_cnu_b.h for the primary calling header

#ifndef VERILATED_VTB_MDPC_CNU_B___024ROOT_H_
#define VERILATED_VTB_MDPC_CNU_B___024ROOT_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"


class Vtb_mdpc_cnu_b__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vtb_mdpc_cnu_b___024root final {
  public:

    // DESIGN SPECIFIC STATE
    CData/*0:0*/ tb_mdpc_cnu_b__DOT____VlemCall_9__msg_sign;
    CData/*3:0*/ tb_mdpc_cnu_b__DOT____VlemCall_7__msg_mag;
    CData/*0:0*/ tb_mdpc_cnu_b__DOT____VlemCall_5__msg_sign;
    CData/*3:0*/ tb_mdpc_cnu_b__DOT____VlemCall_3__msg_mag;
    CData/*0:0*/ tb_mdpc_cnu_b__DOT__u_sign_in;
    CData/*3:0*/ tb_mdpc_cnu_b__DOT__var_idx;
    CData/*4:0*/ tb_mdpc_cnu_b__DOT__dut__DOT__next_msg;
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __VstlPhaseResult;
    CData/*0:0*/ __VactPhaseResult;
    CData/*0:0*/ __VinactPhaseResult;
    CData/*0:0*/ __VnbaPhaseResult;
    SData/*14:0*/ tb_mdpc_cnu_b__DOT__row_state_in;
    IData/*31:0*/ __VactIterCount;
    IData/*31:0*/ __VinactIterCount;
    IData/*31:0*/ __Vi;
    VlUnpacked<QData/*63:0*/, 1> __VstlTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VactTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VactTriggeredAcc;
    VlUnpacked<QData/*63:0*/, 1> __VnbaTriggered;
    VlDelayScheduler __VdlySched;

    // INTERNAL VARIABLES
    Vtb_mdpc_cnu_b__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    Vtb_mdpc_cnu_b___024root(Vtb_mdpc_cnu_b__Syms* symsp, const char* namep);
    ~Vtb_mdpc_cnu_b___024root();
    VL_UNCOPYABLE(Vtb_mdpc_cnu_b___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
