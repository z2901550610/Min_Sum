// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table implementation internals

#include "Vtb_mdpc_decoder_demo__pch.h"

Vtb_mdpc_decoder_demo__Syms::Vtb_mdpc_decoder_demo__Syms(VerilatedContext* contextp, const char* namep, Vtb_mdpc_decoder_demo* modelp)
    : VerilatedSyms{contextp}
    // Setup internal state of the Syms class
    , __Vm_modelp{modelp}
    // Setup top module instance
    , TOP{this, namep}
{
    // Check resources
    Verilated::stackCheck(2258);
    // Setup sub module instances
    TOP__mdpc_demo_pkg.ctor(this, "mdpc_demo_pkg");
    // Configure time unit / time precision
    _vm_contextp__->timeunit(-9);
    _vm_contextp__->timeprecision(-12);
    // Setup each module's pointers to their submodules
    TOP.__PVT__mdpc_demo_pkg = &TOP__mdpc_demo_pkg;
    // Setup each module's pointer back to symbol table (for public functions)
    TOP.__Vconfigure(true);
    TOP__mdpc_demo_pkg.__Vconfigure(true);
    // Setup scopes
}

Vtb_mdpc_decoder_demo__Syms::~Vtb_mdpc_decoder_demo__Syms() {
    // Tear down scopes
    // Tear down sub module instances
    TOP__mdpc_demo_pkg.dtor();
}
