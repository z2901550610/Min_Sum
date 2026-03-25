// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_mdpc_decoder_demo.h for the primary calling header

#include "Vtb_mdpc_decoder_demo__pch.h"

void Vtb_mdpc_decoder_demo___024root___ctor_var_reset(Vtb_mdpc_decoder_demo___024root* vlSelf);

Vtb_mdpc_decoder_demo___024root::Vtb_mdpc_decoder_demo___024root(Vtb_mdpc_decoder_demo__Syms* symsp, const char* namep)
    : __VdlySched{*symsp->_vm_contextp__}
 {
    vlSymsp = symsp;
    vlNamep = strdup(namep);
    // Reset structure values
    Vtb_mdpc_decoder_demo___024root___ctor_var_reset(this);
}

void Vtb_mdpc_decoder_demo___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vtb_mdpc_decoder_demo___024root::~Vtb_mdpc_decoder_demo___024root() {
    VL_DO_DANGLING(std::free(const_cast<char*>(vlNamep)), vlNamep);
}
