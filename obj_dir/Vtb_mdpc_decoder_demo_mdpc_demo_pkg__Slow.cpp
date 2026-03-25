// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_mdpc_decoder_demo.h for the primary calling header

#include "Vtb_mdpc_decoder_demo__pch.h"

// Parameter definitions for Vtb_mdpc_decoder_demo_mdpc_demo_pkg
constexpr VlUnpacked<VlUnpacked<IData/*31:0*/, 3>, 2> Vtb_mdpc_decoder_demo_mdpc_demo_pkg::H_BASE;


void Vtb_mdpc_decoder_demo_mdpc_demo_pkg___ctor_var_reset(Vtb_mdpc_decoder_demo_mdpc_demo_pkg* vlSelf);

Vtb_mdpc_decoder_demo_mdpc_demo_pkg::Vtb_mdpc_decoder_demo_mdpc_demo_pkg() = default;
Vtb_mdpc_decoder_demo_mdpc_demo_pkg::~Vtb_mdpc_decoder_demo_mdpc_demo_pkg() = default;

void Vtb_mdpc_decoder_demo_mdpc_demo_pkg::ctor(Vtb_mdpc_decoder_demo__Syms* symsp, const char* namep) {
    vlSymsp = symsp;
    vlNamep = strdup(Verilated::catName(vlSymsp->name(), namep));
    // Reset structure values
    Vtb_mdpc_decoder_demo_mdpc_demo_pkg___ctor_var_reset(this);
}

void Vtb_mdpc_decoder_demo_mdpc_demo_pkg::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

void Vtb_mdpc_decoder_demo_mdpc_demo_pkg::dtor() {
    VL_DO_DANGLING(std::free(const_cast<char*>(vlNamep)), vlNamep);
}
