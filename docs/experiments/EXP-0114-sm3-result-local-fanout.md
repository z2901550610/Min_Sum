# EXP-0114：SM3结果寄存器局部扇出

## 目标与假设

统一KEM唯一SM3服务向KeyGen、Encaps、Decaps、H123和采样客户端分发256-bit chaining state。
结果寄存器的受控复制可形成局部数据树，降低跨芯片布线延迟，同时保持单SM3核与原固定周期。

## 硬件边界

- `sm3_compress.o_state`保持原寄存时刻、位序和`busy/done`协议。
- 每位声明`max_fanout=8`综合意图，允许Vivado复制结果寄存器并按负载区域放置。
- 不新增压缩轮、response pipeline、owner仲裁或客户端调度状态。
- 固定调度、RAM访问次数以及KeyGen/Encaps/Decaps周期边界保持不变。

## 验证与结论

- SM3标准digest与116拍busy检查通过；`make check-rtl`和统一KEM单SM3结构检查通过。
- 物理判据是同配置Fully Routed内部top path不再由单个`o_state_reg`跨区域广播主导；同时记录FF、
  Slice、复制后单网fanout和internal WNS。
- 该属性只表达综合意图，Vivado是否复制以及时序收益均等待GUI复测，不用RTL属性推断物理结果。
