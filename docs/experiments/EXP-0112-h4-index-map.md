# EXP-0112：H4运行时索引无除法映射

## 目标与假设

H4全局索引只落在公开的三段`[0,r)`、`[r,2r)`、`[2r,3r)`。使用两次比较和减法可得到
block与local index，无需综合变量除法器。

## 硬件边界

- `trike_error_support_store`按`index >= 2r`、`index >= r`选择三段。
- dense byte地址为选中的`0/padded/2*padded + (local >> 3)`，bit位置为`local[2:0]`。
- 固定清零窗口、support写入以及每个位置一次读和一次写的状态调度保持不变。
- `trike_kem_asic_top`使用异步置位、同步释放的内部复位边界。

## 验证与结论

- `make check-rtl`、filelist与record检查通过；Yosys目标层次的`$div/$mod`单元数为0。
- 官方TRIKE-2 store byte golden保持6,478拍；运行时`r=7/13/521`成对case功能与固定周期通过。
- Encaps三种服务组合保持2,378,447拍，Decaps postprocess三种组合保持257,417拍并通过byte golden。
- 统一层次门禁保持一个H4 store、一个SM3、一个采样链和一个H123 store。
- [RUN-20260825-02](../../reports/vivado/manifests/RUN-20260825-02-trike-kem-asic.toml)为Fully Routed诊断：
  136,358 LUT、132,627 FF、47,130 Slice、646 Block RAM Tile和5 DSP。
- 整体setup WNS为`-3.936 ns`，由输入边界到Decaps BRAM DI的布线路径决定；同步内部
  register-to-register WNS为`-3.529 ns`，最差路径是KeyGen秘密采样FSM到fanout约1322的状态控制网，
  仅1级LUT且98.0%数据路径延迟来自布线。
- H4变量除法关键路径未出现，async recovery WNS为`+0.148 ns`。该运行未提供source revision、
  compile defines和`run_provenance.txt`，因此不对RUN-20260825-01计算严格的资源或WNS增减。
- 无除法映射方案保留；统一KEM顶层100 MHz时序未收敛，下一个物理实验针对控制网高扇出布线。
