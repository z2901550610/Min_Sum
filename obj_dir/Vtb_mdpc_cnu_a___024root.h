// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtb_mdpc_cnu_a.h for the primary calling header

#ifndef VERILATED_VTB_MDPC_CNU_A___024ROOT_H_
#define VERILATED_VTB_MDPC_CNU_A___024ROOT_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"


class Vtb_mdpc_cnu_a__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vtb_mdpc_cnu_a___024root final {
  public:

    // DESIGN SPECIFIC STATE
    // Anonymous structures to workaround compiler member-count bugs
    struct {
        CData/*4:0*/ tb_mdpc_cnu_a__DOT__u_in;
        CData/*3:0*/ tb_mdpc_cnu_a__DOT__var_idx;
        CData/*0:0*/ tb_mdpc_cnu_a__DOT__sign_bit_out;
        CData/*3:0*/ tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_13__mag_from_int;
        CData/*3:0*/ tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_12__row_state_min2;
        CData/*3:0*/ tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_11__mag_from_int;
        CData/*3:0*/ tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_10__row_state_min1;
        CData/*3:0*/ tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_9__row_state_min1;
        CData/*0:0*/ tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_8__msg_sign;
        CData/*0:0*/ tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_7__row_state_sign_xor;
        CData/*1:0*/ tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_6__row_state_valid_count;
        CData/*0:0*/ tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_5__msg_sign;
        CData/*3:0*/ tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_4__mag_from_int;
        CData/*3:0*/ tb_mdpc_cnu_a__DOT__dut__DOT____VlemCall_3__mag_from_int;
        CData/*3:0*/ __Vfunc_mag_from_int__55__result;
        CData/*3:0*/ __Vfunc_mag_from_int__57__result;
        CData/*4:0*/ __Vfunc_msg_sign__59__msg;
        CData/*3:0*/ __Vfunc_row_state_pack__60__min1;
        CData/*3:0*/ __Vfunc_row_state_pack__60__min2;
        CData/*3:0*/ __Vfunc_row_state_pack__60__min_id;
        CData/*0:0*/ __Vfunc_row_state_pack__60__sign_xor;
        CData/*4:0*/ __Vfunc_msg_sign__63__msg;
        CData/*0:0*/ __Vfunc_row_state_set_sign_xor__64__sign_xor;
        CData/*1:0*/ __Vfunc_row_state_set_valid_count__65__valid_count;
        CData/*3:0*/ __Vfunc_row_state_set_min2__68__min2;
        CData/*3:0*/ __Vfunc_mag_from_int__69__result;
        CData/*3:0*/ __Vfunc_row_state_set_min1__71__min1;
        CData/*3:0*/ __Vfunc_row_state_set_min_id__72__min_id;
        CData/*3:0*/ __Vfunc_mag_from_int__74__result;
        CData/*3:0*/ __Vfunc_row_state_set_min2__76__min2;
        CData/*0:0*/ __VstlFirstIteration;
        CData/*0:0*/ __VstlPhaseResult;
        CData/*0:0*/ __VactPhaseResult;
        CData/*0:0*/ __VinactPhaseResult;
        CData/*0:0*/ __VnbaPhaseResult;
        SData/*14:0*/ tb_mdpc_cnu_a__DOT__row_state_in;
        SData/*14:0*/ tb_mdpc_cnu_a__DOT__dut__DOT__next_state;
        SData/*14:0*/ __Vfunc_row_state_pack__60__Vfuncout;
        SData/*14:0*/ __Vfunc_row_state_valid_count__61__state;
        SData/*14:0*/ __Vfunc_row_state_sign_xor__62__state;
        SData/*14:0*/ __Vfunc_row_state_set_sign_xor__64__Vfuncout;
        SData/*14:0*/ __Vfunc_row_state_set_sign_xor__64__state;
        SData/*14:0*/ __Vfunc_row_state_set_sign_xor__64__next_state;
        SData/*14:0*/ __Vfunc_row_state_set_valid_count__65__Vfuncout;
        SData/*14:0*/ __Vfunc_row_state_set_valid_count__65__state;
        SData/*14:0*/ __Vfunc_row_state_set_valid_count__65__next_state;
        SData/*14:0*/ __Vfunc_row_state_min1__66__state;
        SData/*14:0*/ __Vfunc_row_state_min1__67__state;
        SData/*14:0*/ __Vfunc_row_state_set_min2__68__Vfuncout;
        SData/*14:0*/ __Vfunc_row_state_set_min2__68__state;
        SData/*14:0*/ __Vfunc_row_state_set_min2__68__next_state;
        SData/*14:0*/ __Vfunc_row_state_set_min1__71__Vfuncout;
        SData/*14:0*/ __Vfunc_row_state_set_min1__71__state;
        SData/*14:0*/ __Vfunc_row_state_set_min1__71__next_state;
        SData/*14:0*/ __Vfunc_row_state_set_min_id__72__Vfuncout;
        SData/*14:0*/ __Vfunc_row_state_set_min_id__72__state;
        SData/*14:0*/ __Vfunc_row_state_set_min_id__72__next_state;
        SData/*14:0*/ __Vfunc_row_state_min2__73__state;
        SData/*14:0*/ __Vfunc_row_state_set_min2__76__Vfuncout;
        SData/*14:0*/ __Vfunc_row_state_set_min2__76__state;
        SData/*14:0*/ __Vfunc_row_state_set_min2__76__next_state;
        IData/*31:0*/ __Vfunc_mag_from_int__55__value;
        IData/*31:0*/ __Vfunc_mag_from_int__55__clamped_value;
        IData/*31:0*/ __Vfunc_clamp_int__56__Vfuncout;
    };
    struct {
        IData/*31:0*/ __Vfunc_clamp_int__56__value;
        IData/*31:0*/ __Vfunc_clamp_int__56__lo;
        IData/*31:0*/ __Vfunc_clamp_int__56__hi;
        IData/*31:0*/ __Vfunc_mag_from_int__57__clamped_value;
        IData/*31:0*/ __Vfunc_clamp_int__58__Vfuncout;
        IData/*31:0*/ __Vfunc_clamp_int__58__value;
        IData/*31:0*/ __Vfunc_clamp_int__58__lo;
        IData/*31:0*/ __Vfunc_clamp_int__58__hi;
        IData/*31:0*/ __Vfunc_mag_from_int__69__value;
        IData/*31:0*/ __Vfunc_mag_from_int__69__clamped_value;
        IData/*31:0*/ __Vfunc_clamp_int__70__Vfuncout;
        IData/*31:0*/ __Vfunc_clamp_int__70__value;
        IData/*31:0*/ __Vfunc_clamp_int__70__lo;
        IData/*31:0*/ __Vfunc_clamp_int__70__hi;
        IData/*31:0*/ __Vfunc_mag_from_int__74__value;
        IData/*31:0*/ __Vfunc_mag_from_int__74__clamped_value;
        IData/*31:0*/ __Vfunc_clamp_int__75__Vfuncout;
        IData/*31:0*/ __Vfunc_clamp_int__75__value;
        IData/*31:0*/ __Vfunc_clamp_int__75__lo;
        IData/*31:0*/ __Vfunc_clamp_int__75__hi;
        IData/*31:0*/ __VactIterCount;
        IData/*31:0*/ __VinactIterCount;
        IData/*31:0*/ __Vi;
        VlUnpacked<QData/*63:0*/, 1> __VstlTriggered;
        VlUnpacked<QData/*63:0*/, 1> __VactTriggered;
        VlUnpacked<QData/*63:0*/, 1> __VactTriggeredAcc;
        VlUnpacked<QData/*63:0*/, 1> __VnbaTriggered;
    };
    VlDelayScheduler __VdlySched;

    // INTERNAL VARIABLES
    Vtb_mdpc_cnu_a__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    Vtb_mdpc_cnu_a___024root(Vtb_mdpc_cnu_a__Syms* symsp, const char* namep);
    ~Vtb_mdpc_cnu_a___024root();
    VL_UNCOPYABLE(Vtb_mdpc_cnu_a___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
