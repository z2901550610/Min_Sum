# 解码器验证

## 常规回归

常规 RTL 回归使用小型 BIKE 演示参数。集成 testbench 导出 `e_hat`，并要求残差 `i_syndrome ^ H*e_hat` 为零且 `e_hat` 等于目标错误向量：

```sh
make test
```

单位测试入口：

```sh
make test-unit
```

顶层集成测试入口：

```sh
make test-integration
```

## 随机 BIKE 用例

随机 BIKE 形状用例由 `scripts/run_bike_random.py` 生成，并通过顶层 testbench 执行。生成用例打印 `residual_weight` 和 `exact`，残差非零或 `exact=0` 触发 `$fatal`：

```sh
make test-bike-random BIKE_RANDOM_TRIALS=1
```

## 检查语义

验证环境按如下流程判断通过：

1. 写入输入 syndrome。
2. 启动 RAM-I 首列元数据加载或使用 RAM-I 初始镜像。
3. 启动解码并等待 `o_done`。
4. 通过 `i_e_read_col_idx/o_e_rdata` 串行导出 `e_hat`。
5. 计算 `i_syndrome ^ H*e_hat`。
6. 要求 residual 全零。
7. 要求 `e_hat` 等于测试目标错误向量。

集成 testbench 和随机 testbench 都执行 residual 检查和 exact-match 检查。

## 日志位置

默认 `VERILATOR` 使用 `./scripts/verilator_quiet.py`，终端输出保持精简。

- Verilator 编译日志保存在 `build/logs/verilator/`
- 仿真运行日志保存在 `build/logs/run/`
- 需要查看原始 Verilator 输出时使用 `VERILATOR_QUIET=0 make ...`

## 生成文件

RAM-I 初始化 hex 和随机用例 testbench 位于 generated 目录。许多测试依赖这些文件，调试失败时优先检查生成脚本输入、参数集和日志，不直接删除 generated 文件。
