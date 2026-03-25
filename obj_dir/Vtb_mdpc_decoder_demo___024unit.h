// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtb_mdpc_decoder_demo.h for the primary calling header

#ifndef VERILATED_VTB_MDPC_DECODER_DEMO___024UNIT_H_
#define VERILATED_VTB_MDPC_DECODER_DEMO___024UNIT_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"


class Vtb_mdpc_decoder_demo__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vtb_mdpc_decoder_demo___024unit final {
  public:

    // INTERNAL VARIABLES
    Vtb_mdpc_decoder_demo__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    Vtb_mdpc_decoder_demo___024unit();
    ~Vtb_mdpc_decoder_demo___024unit();
    void ctor(Vtb_mdpc_decoder_demo__Syms* symsp, const char* namep);
    void dtor();
    VL_UNCOPYABLE(Vtb_mdpc_decoder_demo___024unit);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
