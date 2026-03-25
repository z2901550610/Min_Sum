// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtb_mdpc_vnu.h for the primary calling header

#ifndef VERILATED_VTB_MDPC_VNU___024ROOT_H_
#define VERILATED_VTB_MDPC_VNU___024ROOT_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"


class Vtb_mdpc_vnu__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vtb_mdpc_vnu___024root final {
  public:

    // DESIGN SPECIFIC STATE
    CData/*7:0*/ tb_mdpc_vnu__DOT__gamma_in;
    CData/*7:0*/ tb_mdpc_vnu__DOT__app_out;
    CData/*0:0*/ tb_mdpc_vnu__DOT__x_out;
    CData/*0:0*/ __Vfunc_msg_to_signed__60____VlefCall_1__msg_sign;
    CData/*3:0*/ __Vfunc_msg_to_signed__60____VlefCall_0__msg_mag;
    CData/*3:0*/ __Vfunc_msg_mag__61__Vfuncout;
    CData/*4:0*/ __Vfunc_msg_mag__61__msg;
    CData/*0:0*/ __Vfunc_msg_sign__62__Vfuncout;
    CData/*4:0*/ __Vfunc_msg_sign__62__msg;
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __VstlPhaseResult;
    CData/*0:0*/ __VactPhaseResult;
    CData/*0:0*/ __VinactPhaseResult;
    CData/*0:0*/ __VnbaPhaseResult;
    IData/*31:0*/ tb_mdpc_vnu__DOT____VlemCall_17__msg_to_signed;
    IData/*31:0*/ tb_mdpc_vnu__DOT____VlemCall_16__msg_to_signed;
    IData/*31:0*/ tb_mdpc_vnu__DOT____VlemCall_15__msg_to_signed;
    IData/*31:0*/ tb_mdpc_vnu__DOT____VlemCall_14__msg_to_signed;
    IData/*31:0*/ tb_mdpc_vnu__DOT____VlemCall_13__msg_to_signed;
    IData/*31:0*/ tb_mdpc_vnu__DOT____VlemCall_12__msg_to_signed;
    IData/*31:0*/ tb_mdpc_vnu__DOT____VlemCall_8__msg_to_signed;
    IData/*31:0*/ tb_mdpc_vnu__DOT____VlemCall_7__msg_to_signed;
    IData/*31:0*/ tb_mdpc_vnu__DOT____VlemCall_6__msg_to_signed;
    IData/*31:0*/ tb_mdpc_vnu__DOT____VlemCall_5__msg_to_signed;
    IData/*31:0*/ tb_mdpc_vnu__DOT____VlemCall_4__msg_to_signed;
    IData/*31:0*/ tb_mdpc_vnu__DOT____VlemCall_3__msg_to_signed;
    IData/*31:0*/ tb_mdpc_vnu__DOT__dut__DOT____VlemCall_2__alpha_scale;
    IData/*31:0*/ tb_mdpc_vnu__DOT__dut__DOT____VlemCall_1__alpha_scale;
    IData/*31:0*/ tb_mdpc_vnu__DOT__dut__DOT____VlemCall_0__msg_to_signed;
    IData/*31:0*/ __Vfunc_msg_to_signed__60__mag_value;
    IData/*31:0*/ __Vfunc_alpha_scale__63__abs_value;
    IData/*31:0*/ __Vfunc_alpha_scale__63__scaled_abs;
    IData/*31:0*/ __Vfunc_alpha_scale__65__abs_value;
    IData/*31:0*/ __Vfunc_alpha_scale__65__scaled_abs;
    IData/*31:0*/ __Vfunc_clamp_int__68__Vfuncout;
    IData/*31:0*/ __VactIterCount;
    IData/*31:0*/ __VinactIterCount;
    IData/*31:0*/ __Vi;
    VlUnpacked<CData/*4:0*/, 3> tb_mdpc_vnu__DOT__c2v_in;
    VlUnpacked<CData/*4:0*/, 3> tb_mdpc_vnu__DOT__u_next_out;
    VlUnpacked<IData/*31:0*/, 3> tb_mdpc_vnu__DOT__dut__DOT__signed_c2v;
    VlUnpacked<QData/*63:0*/, 1> __VstlTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VactTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VactTriggeredAcc;
    VlUnpacked<QData/*63:0*/, 1> __VnbaTriggered;
    VlDelayScheduler __VdlySched;

    // INTERNAL VARIABLES
    Vtb_mdpc_vnu__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    Vtb_mdpc_vnu___024root(Vtb_mdpc_vnu__Syms* symsp, const char* namep);
    ~Vtb_mdpc_vnu___024root();
    VL_UNCOPYABLE(Vtb_mdpc_vnu___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
