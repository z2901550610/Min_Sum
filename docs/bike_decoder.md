# BIKE Syndrome 输入 Min-Sum 解码器

## 概述

本 RTL 实现了一个 BIKE/MDPC 风格的 syndrome 输入 min-sum 解码器。校验矩阵由 `N0` 个 circulant block 横向拼接：

- `H = [H0 | H1 | ... | H(N0-1)]`
- 每个 `H*` 由各自的首列支撑集表示
- `h_block_idx` 选择对应的 circulant block

解码器接受初始 syndrome，根据 RAM-I 中的首列元数据访问各 circulant block，并估计错误向量：

- 输入 syndrome 通过 `i_syndrome_we/i_syndrome_addr/i_syndrome_wdata` 写入
- 错误估计读口通过 `i_e_read_col_idx` 选择列，`o_e_rdata` 返回该列硬判决 bit
- 成功条件为 `i_syndrome ^ H*e_hat == 0`

## 文档导航

- [decoder_architecture.md](decoder_architecture.md)：模块划分、RAM 组织、RAM-I 加载路径和访存组织
- [decoder_schedule.md](decoder_schedule.md)：`decoder_ctrl` 状态机和 Fig.8 式列重叠调度
- [decoder_verification.md](decoder_verification.md)：常用回归、随机用例和残差检查语义
- [naming_conventions.md](naming_conventions.md)：RTL 命名规范、索引术语和声明排版规则

## 参数

`rtl/bike_pkg.sv` 是解码器核心的参数包，包含尺寸、位宽、RAM 几何和消息格式常量。

- 默认构建：BIKE-L1 形状参数（`N0=2`, `R=11677`, `W=71`, `T=201`, `C_VAL=7`, `alpha=0.0625`），使用脚本侧的确定性首列支撑集
- `BIKE_TOY_PARAMS` 构建：小型 BIKE 演示参数（`R=8`, `W=3`），用于快速 RTL 测试
- `BIKE_128_PARAMS` 构建：`N0=3`, `R=8117`, `W=27`, `T=201`, `C_VAL=5`, `alpha=0.1875`
- `BIKE_160_PARAMS` 构建：`N0=3`, `R=12739`, `W=35`, `T=263`, `C_VAL=5`, `alpha=0.1875`
- `BIKE_256_PARAMS` 构建：`N0=3`, `R=29501`, `W=55`, `T=429`, `C_VAL=5`, `alpha=0.1875`
- `BIKE_384_PARAMS` 构建：`N0=3`, `R=73421`, `W=83`, `T=659`, `C_VAL=5`, `alpha=0.140625`
- `BIKE_512_PARAMS` 构建：`N0=3`, `R=156011`, `W=111`, `T=877`, `C_VAL=5`, `alpha=0.140625`
- `BIKE_PARALLEL_L` 可选择并行 lane 数；默认 `L=8`
- `BIKE_RAM_LANE_MIN_DEPTH` 设置 RAM-I 和 RAM-T 的 lane depth 下限；默认值为 3
- `BIKE_RAM_LANE_DEPTH` 可显式指定 RAM-I 和 RAM-T 的 lane depth；控制流水要求取值至少为 3

其中 `W` 是每个 circulant block 的列权重，总行重为 `N0 * W`。RAM-I 和 RAM-T 的 lane 内 entry 深度统一为 `RAM_LANE_DEPTH`。RAM-S 每个变量列保存一个 `W` bit v2c sign 向量。

## 解码语义

解码器从全零错误估计开始。

- `ram_c` 存储运行中的错误估计（硬判决位）
- 顶层通过 `i_e_read_col_idx/o_e_rdata` 串行导出最终错误估计
- `CNU_A` 初始化输入使用 `{sign=0, mag=C_VAL}`
- `VNU` 先验值始终为 `+C_VAL`
- `CNU_A` 仅累积每个压缩 c2v 状态中传入的 `u` 符号
- `CNU_B` 计算每条输出边的符号：

```text
row_sign_xor ^ edge_u_sign ^ syndrome[row]
```

RTL 完成 `I_MAX` 次迭代后输出错误估计。验证环境导出 `e_hat` 后计算 `i_syndrome ^ H*e_hat`，残差为零且 `e_hat` 等于测试目标错误向量时用例通过。

## 顶层数据流

`decoder_top` 连接 RAM-I 首列元数据、RAM-M 压缩 c2v 状态、RAM-S v2c sign 存储、RAM-T 列交叠缓冲、RAM-C 错误估计和 syndrome RAM。`decoder_ctrl` 产生固定调度脉冲，使 c2v 侧提前一列重建并累加 LLR，v2c 侧消费上一列的 RAM-T 数据并写回 CNU_A 更新。

RAM-I 保存 `row_idx_global` entry。解码期间，c2v 侧按 `h_block_idx` 和 `entry_pos` 读取首列 entry，`decoder_top` 由 `entry_pos` 与 lane 编号重建 `one_idx`，对 `base_row_idx_global + col_idx_local` 执行环绕修正，得到活跃列的校验行地址。列 metadata 使用 active/fill 双 slot，使 c2v 生产和 v2c 消费保持独立。

## 验证入口

常规 RTL 回归使用小型 BIKE 演示参数：

```sh
make test
```

随机 BIKE 形状用例由脚本生成，并通过顶层 testbench 执行：

```sh
make test-bike-random BIKE_RANDOM_TRIALS=1
```

验证细节和日志位置见 [decoder_verification.md](decoder_verification.md)。
