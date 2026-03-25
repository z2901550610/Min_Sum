// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtb_mdpc_decoder_demo.h for the primary calling header

#ifndef VERILATED_VTB_MDPC_DECODER_DEMO_MDPC_DEMO_PKG_H_
#define VERILATED_VTB_MDPC_DECODER_DEMO_MDPC_DEMO_PKG_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"


class Vtb_mdpc_decoder_demo__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vtb_mdpc_decoder_demo_mdpc_demo_pkg final {
  public:

    // INTERNAL VARIABLES
    Vtb_mdpc_decoder_demo__Syms* vlSymsp;
    const char* vlNamep;

    // PARAMETERS
    static constexpr VlUnpacked<VlUnpacked<IData/*31:0*/, 3>, 2> H_BASE = {{
        {{
            0U, 1U, 3U
        }},
        {{
            0U, 2U, 5U
        }}
    }};

    // CONSTRUCTORS
    Vtb_mdpc_decoder_demo_mdpc_demo_pkg();
    ~Vtb_mdpc_decoder_demo_mdpc_demo_pkg();
    void ctor(Vtb_mdpc_decoder_demo__Syms* symsp, const char* namep);
    void dtor();
    VL_UNCOPYABLE(Vtb_mdpc_decoder_demo_mdpc_demo_pkg);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
