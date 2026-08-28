# 复位与时钟契约

生产 RTL 的完整规则以`docs/vivado_systemverilog_guidelines.md`为准。

- 时序逻辑使用单一、明确的时钟边沿；时钟不进入组合门控逻辑。需要降频或暂停
  工作时使用同步 clock-enable。
- 异步外部复位在`reset_sync`边界完成异步置位、同步释放；同步模块不得把未同步
  的释放沿传播到内部状态。
- 同一时钟域内的 valid/ready、地址和数据必须按接口契约同周期对齐。跨域信号需
  专用 CDC 结构与独立约束/验证。
- Testbench 与 formal harness 必须明确起始复位和 start/done 采样边界；不能以
  未初始化状态恰好收敛作为通过依据。
- 复位 recovery/removal、同步数据 setup/hold、总体 I/O timing 和功能固定周期是
  四种不同证据，报告时不得互相替代。

`workflow-smoke`的低有效同步复位只属于独立工具 PoC，不定义生产顶层复位接口。
