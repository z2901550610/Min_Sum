# EXP-0111：统一KEM ASIC首轮物理实现

## 目标与配置

- 顶层：`trike_kem_asic_top`，公开operation单发射KeyGen/Encaps/Decaps。
- Vivado 2023.2，`xc7k355tffg901-2L`，100 MHz；源码revision、compile define和XDC文件名未嵌入报告。
- 证据仅包含Fully Placed utilization和Routed timing summary，无层次资源报告。

## 结果

- 119,969 LUT、122,997 FF、45,900 Slice、654 Block RAM Tile、6 DSP。
- Slice占用82.48%，Block RAM Tile占用91.47%。
- setup WNS/TNS为`-23.964 ns/-154517.797 ns`，63,128个失败端点；hold WHS为`+0.049 ns`。
- 最差同步路径从`active_operation_q[0]`到共享H4 error RAM地址，33.157 ns、189级逻辑，其中165级CARRY4。
- `async_default` recovery WNS为`-9.274 ns`；methodology摘要含56项DPIR-1和1项ULMTCS-1。

## 结论

该版本不构成100 MHz基线。共享H4 store的变量`/`和`%`地址映射形成深除法链，进入EXP-0112消除；
统一顶层复位边界同步后复测资源、同步数据路径和异步恢复路径。
