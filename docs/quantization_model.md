# QC-MDPC Min-Sum C Model

`scripts/min_sum_model.c` 是面向量化研究的固定迭代 QC-MDPC syndrome min-sum 模型。模型使用 C11，实现 BIKE profile、定重错误生成、消息饱和、RTL 对应舍入、逐轮统计和 CSV 汇总。

模型复现译码算法和定点数值规则，不复现 tile、bank、pipeline 和 cycle schedule。RTL 时序与固定周期预算继续由现有 testbench 验证。

## 构建

```bash
make model-min-sum
```

生成文件：

```text
build/model/min_sum_model
```

Linux 服务器也可以直接构建：

```bash
cc -O3 -std=c11 -Wall -Wextra -Wpedantic \
  -pthread scripts/min_sum_model.c -o min_sum_model
```

## 基本运行

运行一个 BIKE-128 case：

```bash
build/model/min_sum_model --profile bike128 --seed 1 --trials 1
```

输出逐轮消息统计：

```bash
build/model/min_sum_model \
  --profile bike128 \
  --seed 1 \
  --trials 1 \
  --stats
```

保存多次 trial 的汇总：

```bash
build/model/min_sum_model \
  --profile bike128 \
  --seed 1 \
  --trials 100 \
  --threads 16 \
  --csv build/model/bike128.csv
```

`--threads` 按 trial 并行。每个 worker 拥有独立 H、错误向量和消息缓冲区，最终结果按 trial 编号输出。同一 seed 区间在单线程和多线程运行中产生相同的译码结果。

使用 Linux 在线 CPU 数量：

```bash
build/model/min_sum_model \
  --profile bike128 \
  --seed 1 \
  --trials 1000 \
  --threads 0
```

启动信息中的 `worker_memory_mib` 和 `total_worker_memory_mib` 给出主要缓冲区估算。总内存需求近似为：

```text
threads * worker_memory_mib
```

BIKE-256 和高线程数需要先确认服务器内存容量。`--stats` 输出逐轮直方图，只允许配合 `--threads 1` 使用。

## 量化参数

消息位宽包含 1 bit 符号和其余 magnitude bit。4-bit 消息对应 3-bit magnitude：

```bash
build/model/min_sum_model \
  --profile bike128 \
  --msg-bits 4 \
  --c-val 5 \
  --alpha-shift-0 3 \
  --alpha-shift-1 4 \
  --trials 10
```

缩放因子定义为：

```text
alpha = 2^(-alpha_shift_0) + 2^(-alpha_shift_1)
```

模型使用 6-bit 小数缩放和 round-half-away-from-zero。V2C 更新结果以配置的消息幅度上限饱和。主循环固定执行 `--iterations` 指定的轮数。

## 模型数据流

每轮执行：

1. 由全部 V2C 消息计算每个 check 的 `min1`、`min2`、`min_id` 和 `sign_xor`。
2. 根据 syndrome 和 extrinsic sign 重建全部 C2V 消息。
3. 累加每个 variable 的 C2V 总和。
4. 计算 posterior 和下一轮 V2C 消息。
5. 在指定迭代预算结束后计算 error estimate 和 residual syndrome。

随机 case 由 SplitMix64 生成。同一可执行文件、配置和 seed 产生相同的 H 支撑集及错误位置，适合在服务器上复现实验。

## 第一组实验

先分别搜索 5-bit、4-bit 和 3-bit 均匀量化参数。每种位宽都需要搜索合法的 `C` 和 `alpha`：

```text
msg_bits = 5, 4, 3
C        = 1 .. 2^(msg_bits-1)-1
shift    = 1 .. 6
```

使用相同的 seed 区间比较候选配置，并记录：

- `syndrome_success`
- `exact`
- `decision_weight`
- `residual_weight`
- 每轮 V2C/C2V magnitude histogram
- saturation rate
- `min1 == min2` 比例

这些统计用于选择非均匀 reconstruction level 和 quantization threshold。

## C/RTL 共享 fixture

共享 fixture 包含 H 第一列支撑集、错误位置、syndrome 位置和全部定点参数。自动对拍命令：

```bash
make check-model-rtl
```

脚本使用同一个 fixture 运行 C 模型和 Verilator，并比较完整 error estimate 中所有非零列位置。对拍允许 case 译码失败，因为验证目标是两个实现产生完全相同的判决。

BIKE-128 完整参数对拍：

```bash
make check-model-rtl-bike128
```

保留中间 fixture、生成 testbench 和判决文件：

```bash
python3 scripts/check_model_rtl.py \
  --seed 2 \
  --r 8 \
  --w 3 \
  --errors 1 \
  --keep-dir build/model/diff_case
```

C 模型也可以单独读取 fixture：

```bash
build/model/min_sum_model \
  --fixture-in build/model/diff_case/case.fixture \
  --decision-out build/model/diff_case/c.decision
```

## 参数扫描

`scripts/run_quantization_sweep.py` 逐个枚举消息位宽、`C` 和两个 alpha shift。每个候选配置内部使用 C 模型的多线程 trial：

```bash
python3 scripts/run_quantization_sweep.py \
  --profile bike128 \
  --msg-bits 3,4,5 \
  --seed 1 \
  --trials 1000 \
  --threads 32 \
  --output build/model/bike128_sweep.csv
```

shift pair 只枚举 `shift_0 <= shift_1`，避免交换顺序造成重复配置。扫描结果包含成功数、精确恢复数、平均 residual weight 和运行时间。大规模实验可以先用 20～100 个 trial 粗筛，再对候选配置使用相同 seed 区间扩大 trial 数。

## Linux 服务器一键实验

脚本自动完成构建、3/4/5-bit 全参数粗筛、候选参数验证、压力测试和结果汇总：

```bash
scripts/run_quantization_campaign.sh \
  --profile bike128 \
  --mode quick \
  --threads 32
```

使用全部在线 CPU：

```bash
scripts/run_quantization_campaign.sh --threads 0
```

三种实验规模：

| Mode | 粗筛 trials/配置 | 目标重量 trials | 每个压力点 trials |
| --- | ---: | ---: | ---: |
| `smoke` | 2 | 20 | 20 |
| `quick` | 20 | 1000 | 500 |
| `full` | 100 | 10000 | 5000 |

正式服务器实验：

```bash
mkdir -p results

nohup scripts/run_quantization_campaign.sh \
  --profile bike128 \
  --mode full \
  --threads 32 \
  --out-dir results/bike128_full \
  > results/bike128_full.log 2>&1 &
```

查看进度：

```bash
tail -f results/bike128_full.log
```

主要结果：

```text
results/bike128_full/coarse_sweep.csv
results/bike128_full/candidate_results.csv
results/bike128_full/summary.md
```

也可以通过环境变量一键启动：

```bash
MODE=full PROFILE=bike128 THREADS=32 \
  scripts/run_quantization_campaign.sh
```
