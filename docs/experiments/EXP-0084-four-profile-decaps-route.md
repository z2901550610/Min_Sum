# EXP-0084：四档统一Decaps物理复测

- 状态：`physical-pass`
- 基线/对照：`EXP-0083` / `RUN-20260810-01-trike-decaps`
- 配置键：`trike_decaps_synth_top | 四档统一最大几何 | L=32 | K=4 | C=256`
- 运行清单：[RUN-20260811-01-trike-decaps](../../reports/vivado/manifests/RUN-20260811-01-trike-decaps.toml)

## 目标与证据边界

在删除非提交TRIKE-1档后，用相同器件、Vivado版本、XDC、并行度、存储几何、10 ns时钟和Fully Routed
阶段复测统一Decaps。`trike_decaps_synth_top`内pipeline仍绑定`PROFILE_DEFAULT`，因此该报告验证的是四档
RTL对应的TRIKE-9最大物理包络，不是wrapper端四档KEM运行时profile切换。

报告头没有记录Git revision或compile define；本次结果由用户关联到EXP-0083后的四档Windows工程。
原始报告位于`D:/trike_reports`，归档目标为`D:/trike_reports/RUN-20260811-01-trike-decaps/`。

## 同条件物理结果

| 指标 | 五档参考 | 四档复测 | 变化 |
| --- | ---: | ---: | ---: |
| LUT | 63,228 | 63,386 | +158（+0.25%） |
| FF | 60,542 | 60,521 | -21（-0.03%） |
| Slice | 25,653 | 25,759 | +106（+0.41%） |
| Block RAM Tile | 635 | 635 | 0 |
| RAMB36 / RAMB18 | 575 / 120 | 575 / 120 | 0 / 0 |
| DSP | 4 | 4 | 0 |
| setup WNS / TNS | +0.033 ns / 0 | +0.033 ns / 0 | 0 / 0 |
| hold WHS / THS | +0.050 ns / 0 | +0.051 ns / 0 | +0.001 ns / 0 |

LUT、FF和Slice的微小正负变化处于重新实现的物理波动范围。最大RAM几何未改变，profile ID与控制表收缩
没有形成可声明的物理面积收益。

主要层次资源如下：

| 层次 | LUT | FF | RAMB36 | RAMB18 | DSP |
| --- | ---: | ---: | ---: | ---: | ---: |
| `u_pipeline` | 62,419 | 59,623 | 551 | 119 | 4 |
| `u_decoder` | 24,593 | 11,263 | 480 | 115 | 0 |
| `u_postprocess` | 30,157 | 44,967 | 16 | 0 | 4 |
| `u_adapter` | 4,716 | 2,035 | 0 | 0 | 0 |
| `support_sorter` | 4,641 | 1,940 | 0 | 0 | 0 |
| `u_syndrome` | 2,664 | 892 | 35 | 3 | 0 |
| `u_residual` | 156 | 71 | 4 | 1 | 0 |

## 时序与方法学检查

- 100 MHz下全部用户时序约束满足：setup WNS/TNS为`+0.033 ns/0`，hold WHS/THS为
  `+0.051 ns/0`，pulse-width裕量为`+4.232 ns`。
- 全局setup最差路径是`o_shared_secret_data_reg[0]`到输出端口的IOB/OBUF路径，不是片内同步数据通路；
  wrapper没有package pin约束，因此该结果不是板级I/O签核。
- `async_default` recovery WNS为`+0.275 ns`。30,127扇出的同步复位根网络以及9,118扇出的decoder复位
  网络保持正裕量；最差recovery路径96.63%为布线延迟。
- `check_timing`没有无时钟寄存器、无约束内部端点或缺失output delay；一项无input delay端口已有false-path。
- methodology有49项`DPIR-1`异步驱动检查和4项`SYNTH-10`宽乘法告警，与签核边界一起保留。

两份用户提供的`post_route_internal_setup_paths.rpt`内容完全相同，只计作一个artifact。该命令的前20条
路径全部落在`**async_default**` recovery检查，不能给出同步register-to-register数据路径WNS。后续若要
定位下一项优化，应在Vivado Tcl Console生成数据pin限定报告：

```tcl
report_timing \
  -from [all_registers -clock [get_clocks core_clk] -output_pins] \
  -to [all_registers -clock [get_clocks core_clk] -data_pins] \
  -delay_type max -max_paths 20 -sort_by slack \
  -file D:/trike_reports/post_route_internal_data_setup_paths.rpt
```

## 结论

`retained`。四档统一最大几何在100 MHz下Fully Routed通过，成为当前统一Decaps物理基线。删除
TRIKE-1档的功能收益是提交范围与公开控制一致；物理结果判定为中性。同步数据关键路径报告仍需补充，
它影响后续优化定位，不影响本次已约束100 MHz实现通过的结论。
