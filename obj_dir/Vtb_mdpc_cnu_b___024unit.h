// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtb_mdpc_cnu_b.h for the primary calling header

#ifndef VERILATED_VTB_MDPC_CNU_B___024UNIT_H_
#define VERILATED_VTB_MDPC_CNU_B___024UNIT_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"


class Vtb_mdpc_cnu_b__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vtb_mdpc_cnu_b___024unit final {
  public:

    // INTERNAL VARIABLES
    Vtb_mdpc_cnu_b__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    Vtb_mdpc_cnu_b___024unit();
    ~Vtb_mdpc_cnu_b___024unit();
    void ctor(Vtb_mdpc_cnu_b__Syms* symsp, const char* namep);
    void dtor();
    VL_UNCOPYABLE(Vtb_mdpc_cnu_b___024unit);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
