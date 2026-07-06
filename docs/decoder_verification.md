# 解码器验证

## 回归入口

```sh
make test-unit
make test-integration
make test
make test-bike-random BIKE_RANDOM_TRIALS=1
```

`make test-unit` 覆盖：

- message codec
- tile scheduler
- edge address generator
- H matrix RAM
- CNU_A/CNU_B 参考小模块

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
make format-rtl
make check-format-rtl && make lint-rtl
```

维护态 RTL/TB 文件通过 `MAINTAINED_SV` 自动发现。生成目录不参与格式化。
