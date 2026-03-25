// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vtb_mdpc_cnu_a__pch.h"

//============================================================
// Constructors

Vtb_mdpc_cnu_a::Vtb_mdpc_cnu_a(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vtb_mdpc_cnu_a__Syms(contextp(), _vcname__, this)}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vtb_mdpc_cnu_a::Vtb_mdpc_cnu_a(const char* _vcname__)
    : Vtb_mdpc_cnu_a(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vtb_mdpc_cnu_a::~Vtb_mdpc_cnu_a() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vtb_mdpc_cnu_a___024root___eval_debug_assertions(Vtb_mdpc_cnu_a___024root* vlSelf);
#endif  // VL_DEBUG
void Vtb_mdpc_cnu_a___024root___eval_static(Vtb_mdpc_cnu_a___024root* vlSelf);
void Vtb_mdpc_cnu_a___024root___eval_initial(Vtb_mdpc_cnu_a___024root* vlSelf);
void Vtb_mdpc_cnu_a___024root___eval_settle(Vtb_mdpc_cnu_a___024root* vlSelf);
void Vtb_mdpc_cnu_a___024root___eval(Vtb_mdpc_cnu_a___024root* vlSelf);

void Vtb_mdpc_cnu_a::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vtb_mdpc_cnu_a::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vtb_mdpc_cnu_a___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vtb_mdpc_cnu_a___024root___eval_static(&(vlSymsp->TOP));
        Vtb_mdpc_cnu_a___024root___eval_initial(&(vlSymsp->TOP));
        Vtb_mdpc_cnu_a___024root___eval_settle(&(vlSymsp->TOP));
        vlSymsp->__Vm_didInit = true;
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vtb_mdpc_cnu_a___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vtb_mdpc_cnu_a::eventsPending() { return !vlSymsp->TOP.__VdlySched.empty() && !contextp()->gotFinish(); }

uint64_t Vtb_mdpc_cnu_a::nextTimeSlot() { return vlSymsp->TOP.__VdlySched.nextTimeSlot(); }

//============================================================
// Utilities

const char* Vtb_mdpc_cnu_a::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vtb_mdpc_cnu_a___024root___eval_final(Vtb_mdpc_cnu_a___024root* vlSelf);

VL_ATTR_COLD void Vtb_mdpc_cnu_a::final() {
    contextp()->executingFinal(true);
    Vtb_mdpc_cnu_a___024root___eval_final(&(vlSymsp->TOP));
    contextp()->executingFinal(false);
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vtb_mdpc_cnu_a::hierName() const { return vlSymsp->name(); }
const char* Vtb_mdpc_cnu_a::modelName() const { return "Vtb_mdpc_cnu_a"; }
unsigned Vtb_mdpc_cnu_a::threads() const { return 1; }
void Vtb_mdpc_cnu_a::prepareClone() const { contextp()->prepareClone(); }
void Vtb_mdpc_cnu_a::atClone() const {
    contextp()->threadPoolpOnClone();
}
