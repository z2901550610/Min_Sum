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
- [RUN-20260826-01](../../reports/vivado/manifests/RUN-20260826-01-trike-kem-asic-sm3-fanout.toml)的
  Routed报告为113,478 LUT、107,758 FF、41,224 Slice、655 Block RAM Tile和5 DSP；整体setup
  WNS/TNS为`-4.733/-17427.521 ns`，hold WHS为`+0.049 ns`。
- 同步内部setup WNS为`-4.017 ns`。最差20条路径全部从Decaps support sorter的one-hot状态位出发，
  该网fanout 2,033，最差数据路径14.043 ns中13.741 ns为布线；共享SM3输出不在该top-20列表中。
- async recovery WNS为`-3.550 ns`，最差reset分发网fanout 9,206，12.938 ns为布线。100 MHz仍未收敛。
- 两份methodology附件字节相同；`post_route_high_fanout.rpt`、DRC和`run_provenance.txt`未提供。
  FF/Slice增长形态与寄存器复制相符，但不能在缺少高扇出报告和严格source association时确认复制数量或
  计算相对RUN-20260825-04的严格物理增减。
- 状态保持`pending`。补齐high-fanout、DRC以及Windows revision/dirty状态后，判断该属性为
  `retained`或`rejected`；新的独立时序方向是support sorter控制广播和decoder reset分发。
