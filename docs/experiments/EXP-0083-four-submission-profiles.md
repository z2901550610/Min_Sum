# EXP-0083：统一架构删除非提交TRIKE-1档

- 状态：`functional-pass`
- 基线/对照：`EXP-0082` / `RUN-20260810-01-trike-decaps`
- 配置键：`TRIKE_UNIFIED_PARAMS | TRIKE-2/5/7/9 | L=32 | K=4 | maximum geometry`

## 目标与假设

统一硬件只保留实际提交的TRIKE-2、TRIKE-5、TRIKE-7和TRIKE-9四档。删除实验性的TRIKE-1档、对应
profile ID、软件入口和默认回归项；最大档TRIKE-9不变，因此RAM深度、数据通路宽度和最大固定周期不变。

## 改动边界

- 数据路径/RAM生命周期：全局K-sign、message、syndrome和tile RAM仍按TRIKE-9最大几何实现。
- 公开控制与固定周期影响：profile ID由3 bit五档压缩为2 bit四档；保留档位各自的`r/w/tile/C/alpha`
  和固定周期公式不变。
- 接口边界：`decoder_top.i_param_level`覆盖四个公开运行时档位；`trike_decaps_synth_top`
  中的pipeline仍使用`PROFILE_DEFAULT`，其统一编译结果是最大档物理包络，不是四档KEM流输入长度
  和profile选择已经联调。
- Vivado入口：`scripts/vivado_trike_kem_cores.tcl`对Decaps显式使用`TRIKE_UNIFIED_PARAMS`，
  与最大物理包络的报告口径一致；固定TRIKE160 RTL golden仍使用`TRIKE_160_PARAMS`单独验证。
- 不在本实验范围：官方TRIKE-2的`r=15581` KAT与项目Min-Sum `r=12589`的参数差异、DFR外推方法、
  KeyGen/Encaps/Decaps密码数据通路。

## 验证

| 层 | 配置 | 结果 |
| --- | --- | --- |
| RTL/软件静态检查 | `make ci-fast`；固定TRIKE160与统一最大几何Decaps lint | `PASS` |
| Decoder随机回归 | TRIKE-2/5/7/9，K=4，L=32，seed 1 | `PASS`，337245/1252957/3866043/8538564拍，均`residual=0, exact=1` |
| KEM软件 | trike160/256/384/512 | `PASS`，正常解封装与篡改隐式拒绝逐档通过 |
| 完整参考门禁 | `make ci-kem-reference` | `PASS`，官方TRIKE-2/5/7/9 KAT与RTL KEM分层golden通过 |
| Vivado | 四档统一最大几何 | `pending` |

## 结论

`pending`。四档RTL和软件功能门禁通过；最大物理几何不变，但profile mux和控制宽度发生变化，必须用新的
Fully Routed报告确认LUT/FF/Slice、BRAM和WNS后再更新当前物理基线。
