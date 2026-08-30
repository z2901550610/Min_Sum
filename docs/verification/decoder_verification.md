# 解码器验证

## 回归入口

```sh
make test-unit
make test-integration
make test
make test-bike-random BIKE_RANDOM_TRIALS=1
```

## Testbench形式选择

- 周期精确的握手、地址、RAM事务、固定延迟和小型RTL单元优先使用直接编写的
  self-checking SystemVerilog testbench。
- 大规模输入、密码学golden、确定性随机样本和复杂数据整理使用Python模型或fixture
  生成器，再由SystemVerilog testbench读取对拍。
- 只有Python侧动态驱动或数据编排明显更清晰时才使用cocotb。cocotb直接驱动仿真器中
  的DUT，不负责生成SystemVerilog。
- 常见组合是“Python生成golden/fixture + SystemVerilog检查协议、周期和结果”；不为
  简单定向单测额外引入cocotb层。

`make test-unit` 覆盖：

- message codec
- tile scheduler
- edge address generator
- H matrix RAM
- CNU_A/CNU_B 参考小模块

每项decoder单测同时提供独立`make test-<name>`入口，例如`test-tile-scheduler`、
`test-edge-addr-gen`和`test-k-sign-update`；`test-unit`聚合这些入口与KEM单测。

`make test-integration` 使用 toy 参数运行完整 `decoder_top`。

## 随机 BIKE 用例

随机用例由 `scripts/run_bike_random.py` 生成：

```sh
python3 scripts/run_bike_random.py \
  --param-set bike128 \
  --trials 1 \
  --base-seed 1 \
  --parallel-l 8 \
  --cols-per-tile 256 \
  --timeout-cycles 900000 \
  --verilator ./scripts/verilator_quiet.py
```

脚本为每个 seed 生成：

- 外部 `bike_pkg.sv`
- H first-column fixture
- syndrome position list
- target error position list
- self-checking SystemVerilog testbench

## 检查项

完整顶层测试执行：

1. 写入全部 H 第一列项。
2. 检查 `o_h_loaded` 和 `o_h_error`。
3. 写入 syndrome。
4. 拉高 `i_start` 一个周期。
5. 等待固定轮数完成。
6. 读出 `e_hat`。
7. 计算 `residual = syndrome ^ H * e_hat`。
8. 检查 residual 为 0。
9. 检查 `e_hat` 与目标错误向量一致。

集成 toy testbench 额外检查：

- C2V/V2C tile overlap 被观察到
- guard dummy 周期被观察到
- `o_iter_count == I_MAX`
- 主循环周期数等于 `I_MAX * (ROW_SEG_SIZE + (TILES_TOTAL + 1) * W * Q_TILE)`

## 调度器形式化边界

`make formal-k-sign-overlap-scheduler`在toy公开几何下证明correction扫描坐标有界、按固定词典序推进、
固定drain并在`N0*TILE_COUNT*W*Q_TILE+K_SIGN_OVERLAP_DRAIN_CYCLES`拍完成。
`make formal-tile-scheduler`对单次公开start后的完整316拍toy事务做有界证明，覆盖
clear/C2V/V2C阶段互斥关系、地址与坐标范围、tile重叠间距和固定完成周期。两者均包含完整done cover。

这些proof只覆盖harness固定的toy公开几何和调度器接口；生产K=3/K=4及四档TRIKE的实际固定周期仍由
对应reference/random仿真测量，不把toy形式化外推为全参数或完整decoder证明。

## 日志

Verilator 编译日志：

```text
build/logs/verilator/
```

运行日志：

```text
build/logs/run/
```

默认命令使用 quiet wrapper 输出关键行。需要查看完整 Verilator 输出时：

```sh
VERILATOR_QUIET=0 make test
```

## 格式和 lint

```sh
make format FILES="<本任务修改的 .sv 文件>"
make format-check
make lint
```

`make format`只原地修改显式列出的任务文件；`make format-check`通过
`MAINTAINED_SV`检查全部维护态 RTL/TB/Formal 文件。生成目录不参与格式化。
