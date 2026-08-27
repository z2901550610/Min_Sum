# TRIKE KEM Hardware Optimization Analysis

> 状态：EXP-0115实施前的调研快照；其中baseline数字用于解释方案来源，不代表成品当前值。
> 日期：2026-08-26。  
> 证据标签：**MEASURED**=本仓库仿真或Vivado记录；**SOURCE**=TRIKE随包C/当前RTL直接推导；
> **PUBLISHED**=公开文献实测；**ESTIMATE**=解析模型；**PROPOSAL**=尚未实现的TRIKE硬件方案。
> 当前实现、周期和验证结论见[EXP-0115](../experiments/EXP-0115-dense-mul-diagonal-comba.md)、
> [实现状态](implementation_status.md)和[TRIKE KEM优化路线图](trike_kem_optimization_roadmap.md)。

## 0. 结论摘要

外部建议的研究框架总体可参考，但需要按当前实现修正四个关键前提：

1. 当前`trike_poly_mul_core`已经有专用的sparse×dense rotate/XOR模式；问题不是“是否建立稀疏乘法器”，
   而是当前每个support-word对需要8拍、结果RAM存在三段RMW，以及Encaps仍顺序执行4次完整weight-`t`扫描。
2. 当前Decaps已经采用SK内保存的`t0/r2`，没有重算KeyGen。因此“保存并复用`t0/r2`”不是候选优化，而是现状。
3. KeyGen确实有不可由BIKE稀疏结构消除的dense×dense路径：两次求逆内部共44次D×D，外层另有3次D×D。
   官方TRIKE-2的KeyGen core中，两次求逆占85.27%，整个算术阶段占91.05%。
4. 统一KEM当前100 MHz内部时序失败的最差路径是共享SM3结果寄存器到Encaps摘要寄存器，98%为routing；
   因而“降低固定周期”和“恢复Fmax”是两个独立P0问题，不能用乘法器周期优化替代时序修复。

建议顺序为：

- **P0-A（吞吐/周期）**：先将D×D的product-RAM低/高两次RMW改成可综合、可验证的对角/Comba累加基线；
- **P0-B（物理时序）**：单独处理统一KEM的SM3跨层长连线和全局控制扇出，不与算术实验混跑；
- **P1**：把Encaps改成固定两次tagged-support pass，并用恒定的双bank读访问保证地址/次数不随秘密tag改变；
- **P1**：建立专用Frobenius permutation核的`L_perm(k)`实测，再决定FPGA上的square/permutation交叉点；
- **P2**：在相同器件、XDC和报告阶段比较addition-chain与constant-time divstep。ExtGCD值得做实验，但不应直接替换。
- **P2**：在稳定的Comba基线之后探索Karatsuba depth；不能移植AVX-512的512-bit base case。

## 1. Current Architecture

### 1.1 参数域必须分开

| 验证域 | 参数集 | `r` | sparse `d/w` | error `t` | 用途 |
|---|---|---:|---:|---:|---|
| 官方KEM | TRIKE-2 | 15,581 | 35 | 263 | KeyGen/Encaps及官方KAT |
| 官方KEM | TRIKE-5 | 35,363 | 55 | 429 | 软件KAT/模型 |
| 官方KEM | TRIKE-7 | 69,691 | 83 | 659 | 软件KAT/模型 |
| 官方KEM | TRIKE-9 | 114,043 | 111 | 877 | 软件KAT/模型 |
| 项目decoder | TRIKE160 | 12,589 | 35 | 263 | 运行时Decaps |
| 项目decoder | TRIKE256 | 30,389 | 55 | 429 | 运行时Decaps |
| 项目decoder | TRIKE384 | 63,773 | 83 | 659 | 运行时Decaps |
| 项目decoder | TRIKE512 | 106,781 | 111 | 877 | 运行时Decaps |

官方TRIKE-2的`r=15581`与项目TRIKE160的`r=12589`不是同一参数；周期和BRAM结论不能混用。

### 1.2 KeyGen数据流

```text
固定16组秘密候选 -> h0/h1/h2 support
H1/H2/H3 DRNG     -> t1/t2/r1 dense banks

h0(S) * r1(D) XOR h1 -> numerator
(t1 XOR r1)^-1        -> inverse bank（复用t1 bank）
numerator * inverse   -> t0 bank
(t0 XOR h0)^-1        -> inverse bank
t0 * t2 XOR h2        -> numerator bank
numerator * inverse   -> r2（原位覆盖numerator bank）
```

`trike_keygen_arith_core`顺序复用一个外层`trike_poly_mul_core`和一个`trike_poly_inv_core`。
求逆核内部还有一条external-dense乘法数据路，因此当前层次并非全KEM只有一个物理多项式乘法器。
`h1/h2`不保存为完整稠密环，而是在结果写边界按support生成word mask并XOR。

### 1.3 Encaps数据流

```text
H4固定重量采样 -> 全局support index（e0 || e1 || e2，共t项）
e0 -> u/v初始累加
e1*r1 -> u；e2*r2 -> u
e1*t1 -> v；e2*t2 -> v
L/K pseudohash与窄流序列化 -> ciphertext/shared secret
```

`trike_encaps_uv_core`已将每个全局index转换为本地位置；非当前分块的index被改为公开dummy值，
每次乘法仍恰好接收`t`个index。因此固定周期成立，但四次乘法重放同一support列表四遍。

### 1.4 Decaps数据流

当前实现从SK直接装载support、`t0`和`r2`。syndrome核使用代数等价式：

```text
h0(S) * u(D)       -> accumulator
t0(D) * (u XOR v)  -> dense product
两者XOR            -> syndrome -> 固定7轮decoder
decoder输出 -> residual/re-encryption检查 -> 常时间共享密钥选择
```

这比随包optimized C的`(h0+t0)*u + t0*v`两个generic D×D调用更适合硬件：当前RTL已把第一项拆成
1次S×D，并把`u XOR v`融合在RAM读边界。Decaps不执行求逆，也不重算`t0/r2`。

## 2. Polynomial Arithmetic Inventory

`S`表示support-index稀疏表示，`D`表示`r`-bit稠密表示。XOR是word流融合，不是独立完整环扫描时特别注明。

| Stage | Expression | Type | Current RTL | Calls per KEM operation |
|---|---|---|---|---:|
| KeyGen | `h0*r1` | S×D | `trike_poly_mul_core` sparse mode | 1 |
| KeyGen | `t1 XOR r1` | D XOR D | denominator load边界 | 1 |
| KeyGen | denominator inverse | D inverse | `trike_poly_inv_core` | 1 |
| KeyGen | `(h0*r1 XOR h1)*inv` | D×D | outer multiplier | 1 |
| KeyGen | `t0 XOR h0` | D XOR S-word mask | inverse input边界 | 1 |
| KeyGen | denominator inverse | D inverse | `trike_poly_inv_core` | 1 |
| KeyGen | `t0*t2 XOR h2` | D×D + fused XOR | outer multiplier | 1 |
| KeyGen | `numerator*inv` | D×D | outer multiplier | 1 |
| Encaps | `e1*r1`, `e2*r2` | S×D | shared sparse multiplier | 2 |
| Encaps | `e1*t1`, `e2*t2` | S×D | shared sparse multiplier | 2 |
| Encaps | add `e0` | sparse accumulation | UV result RAM init | u、v各1遍 |
| Decaps | `h0*u` | S×D | syndrome shared multiplier | 1 |
| Decaps | `t0*(u XOR v)` | D×D | syndrome shared multiplier | 1 |
| Decoder | syndrome/update | decoder专用RAM数据路 | 不在本报告重构 | 固定7轮 |

官方TRIKE-2求逆schedule的非零项重新统计如下：

- 每次inversion：13个`l0` D×D + 9个`l1` D×D = **22次D×D**；
- 每次inversion：上述22次Frobenius map，再加最终map = **23次permutation**；
- KeyGen两次inversion：44次内部D×D、46次permutation；外层另有3次D×D和1次S×D；
- 当前每次D×D产生完整`2W` product并执行一次modular reduction，因此KeyGen共有47次D×D reduction，
  加上S×D的循环折叠语义共48次环乘结果生成。

“XOR门数量”和“cyclic shift次数”不是独立固定标量：它们取决于选定datapath宽度和微架构。
当前S×D每个support-word对形成最多3个word贡献，固定执行3组RMW；TRIKE-2 KeyGen的35项support对应
`35*244=8,540`个support-word对，Encaps四次乘法对应`4*263*244=256,688`个support-word对。

## 3. Current Bottlenecks

| Priority | Bottleneck | Evidence | Consequence |
|---|---|---|---|
| P0 | KeyGen inversion中的D×D | **MEASURED** 两次inversion 46,043,040拍，占KeyGen core 85.27% | 首要固定周期来源 |
| P0 | 统一KEM共享SM3跨层routing | **MEASURED/diagnostic** 内部WNS -3.914 ns，最差路径0级逻辑、98% routing | 100 MHz未闭合；周期下降不等于实际延时下降 |
| P0 | D×D product RAM RMW | **SOURCE** 每个word pair固定17拍；完整`2W` product后再reduction | `O(W²)`系数大，额外2-ring临时存储 |
| P1 | Encaps四次weight-`t` support扫描 | **MEASURED** UV 2,062,238拍，占Encaps core 86.71% | 可用固定tagged pass减少重复扫描 |
| P1 | Frobenius map固定`2r`拍 | **SOURCE** 每次求逆23次，TRIKE-2仅permutation量级约716k拍 | D×D加速后会成为Amdahl瓶颈 |
| P1 | Decaps syndrome乘法 | **MEASURED** TRIKE160为1,086,187拍，占完整Decaps 38.87% | 高档`W²`增长更严重 |
| P2 | Decaps residual/re-encryption | **MEASURED** TRIKE160为1,340,836拍，占47.98% | 需和syndrome分开优化 |
| P2 | 最大几何decoder RAM/routing | **MEASURED** 635 BRAM tile；最差内部路径位于decoder `ram_m`路由 | 统一KEM BRAM与Fmax的系统瓶颈 |

P0中有两个正交目标：算术固定周期与物理Fmax。它们必须用不同commit/实验、相同Vivado条件独立验证。

## 4. BIKE vs TRIKE Hardware Difference

| Dimension | BIKE核心结构 | 当前TRIKE结构 | 迁移结论 |
|---|---|---|---|
| KeyGen | `h1 * inv(h0)`；求逆外多为S×D | 2次dense denominator inverse，外层还有3次D×D | 不能删除通用D×D |
| Encaps | `e0 + e1*h` | `e0 + e1*r1 + e2*r2`及`t1/t2`镜像 | rotate/XOR可迁移，但bank/tag调度更复杂 |
| Decaps syndrome | `c0*h0`可利用稀疏秘密 | `h0*u + t0*(u+v)`含真正D×D | 至少保留1条D×D服务 |
| Inversion替换 | ExtGCD可同时移除dense multiplier | ExtGCD后D×D仍服务KeyGen/Decaps | 必须比较额外面积和系统AT |
| 中间存储 | 环数量较少 | `t0,t1,t2,r1,r2,u,v`及两个inversion上下文 | BRAM生命周期和带宽更关键 |

因此，Racing BIKE的**稀疏乘法地址/旋转思想**和**constant-time divstep设计方法**可参考；
“使用ExtGCD后不需要D×D”的系统结论不能迁移。

## 5. Sparse Multiplier Analysis

### 5.1 当前实现

当前RTL不是generic Karatsuba：support index的高位决定起始word，低6位决定bit offset；读取相邻dense word，
拼接/移位后形成最多3个循环目的word贡献，再对result RAM执行3次read-modify-write。

连续握手固定周期为：

```text
L_SD_current(W,S) = 4W + 2S + 8SW
```

TRIKE-2中，`S=35`为69,366拍；`S=t=263`为514,878拍。四次Encaps乘法的公式值2,059,512拍，
与UV component实测2,062,238拍只差固定控制开销，说明该模块确为Encaps主导项。

### 5.2 Racing BIKE可迁移部分

[Racing BIKE](https://eprint.iacr.org/2021/1344.pdf)公开的rotate-XOR multiplier每个support固定扫描
`ceil(r/b)`个dense word，采用双结果memory ping-pong实现同拍读写，模型为
`(ceil(r/b)+4)*S+1`。其Artix-7、`r=12323`实测显示：general sparse multiplier在`b=32/64/128`
分别为27,691/13,988/7,172拍，代价为319/549/1,136 LUT和2/4/8 BRAM。该数据只能作为架构趋势，
不能和当前Kintex-7报告直接相减。

可直接参考：固定support循环、相邻word旋转、双buffer/forwarding解决RMW。需重新设计：非64对齐尾部、
XPM read latency、当前单结果bank接口，以及tagged多源读取。

### 5.3 Encaps tagged-support

建议的安全版本不是按tag只访问一个bank，而是每个公开迭代同时读取所有候选dense bank，再用tag做数据mask：

```text
u pass: 每个support、每个word固定读 r1 和 r2；e0使用固定dummy数据路径
v pass: 每个support、每个word固定读 t1 和 t2；e0使用固定dummy数据路径
```

这样从4遍weight-`t`降为2遍，同时每个bank的读取次数与地址序列不依赖秘密tag。单纯“tag选bank”虽然周期固定，
但会使每个bank的访问次数暴露`|e0|/|e1|/|e2|`，不满足本工程的强memory-access不变量。

| Scheme | Passes | Dense-bank reads/cycle | Accumulator | Expected effect |
|---|---:|---:|---:|---|
| 当前共享核 | 4 | 1 | 1，u/v顺序 | baseline |
| A：一个tagged核 | 2 | 2 | 1，u/v顺序 | **PROPOSAL** 首选；中等LUT/route增长 |
| B：两个tagged核 | 1个wall-time窗口内各1遍 | 4合计 | 2，并行u/v | **PROPOSAL** 最低周期、高routing/BRAM端口压力 |

以TRIKE-2为例，若先实现保守的“每support-word对2拍”内核，纯UV算术解析值约260,744拍，
相对当前2,059,512拍是约7.9倍的**ESTIMATE上界**；它未计双bank路由、尾部、清零、RAW forwarding和Fmax，
不能作为预期实测speedup。

### 5.4 `b=32/64/128`权衡

| `b` | TRIKE-2 words | 优点 | 主要代价 |
|---:|---:|---|---|
| 32 | 487 | shift/XOR窄，路由和单级时序容易 | 扫描约为64-bit的2倍；地址/控制占比高 |
| 64 | 244 | 与现有RAM/接口一致；最小改造基线 | 当前RMW调度低效，需要forwarding或双buffer |
| 128 | 122 | 理论扫描减半 | 每bank常需宽化/双bank，shift网络和fanout显著增大，Fmax风险最高 |

优先验证64-bit，再并列综合32/128；不应仅按cycles选128-bit。

## 6. Dense Multiplier Analysis

### 6.1 当前微架构

当前D×D是`WORD_W=64, DIGIT_W=16`的digit-serial schoolbook：

- A/B以64-bit word保存；
- 一个16×64 carry-less datapath生成128-bit partial product；
- 每个word pair依次更新完整`2W` product RAM的low/high word；
- product完成后单独扫描并按`x^r=1`折叠到`W`-word result RAM；
- external模式由inverter直接读取f/t bank并写回结果store。

公式：

```text
L_DD_current       = 11W + W^2 * (1 + 4*64/16) = 11W + 17W^2
L_DD_external      =  7W + W^2 * (1 + 4*64/16) =  7W + 17W^2
```

TRIKE-2分别为1,014,796和1,013,820拍。问题不在schoolbook复杂度本身，而在每个word pair的17拍状态开销
与product RAM反复RMW。

### 6.2 候选比较

| Candidate | Partial products | Intermediate storage | Strength | Risk / condition |
|---|---|---|---|---|
| 当前digit-schoolbook | `W²`组、每组4 digits | `2W` product + `W` result | 面积小、已验证 | 17拍/word pair |
| diagonal/Comba + 16×64 base | 仍为`W²`量级 | 128-bit diagonal寄存器 + `W`结果 | 先消除product RMW，改动可控 | carry-less对角边界、尾部fold需形式化 |
| 64×64 pipelined Comba | `W²` | 小型pipeline/结果bank | 可能达到高pair吞吐 | LUT和critical path明显增加 |
| recursive Karatsuba + Comba | 约`3^k`子问题 | recursion buffer/bank | 大`r`可降低partial products | bank置换、重组XOR、Fmax和BRAM复杂 |
| fully combinational大块 | 很少cycle | 大量FF/LUT | 极端throughput | 对十万bit不可扩展，不建议 |

[Zoni等人的可扩展大二元多项式乘法器](https://re.public.polimi.it/retrieve/e0c31c0f-8c3b-4599-e053-1705fe0aef77/IEEEAccess_FPGA_Mul.pdf)
把可配置递归Karatsuba与serial/parallel Comba结合，并明确将内部datapath带宽与外部接口带宽解耦；论文也指出
Comba并不减少schoolbook的partial-product数量，但会最小化中间结果存储和优化memory write pattern。
这支持“先做Comba内存调度基线，再加Karatsuba”的顺序。

### 6.3 不直接迁移optimized C

随包`gf2x.c`在VPCLMUL路径以512-bit为Karatsuba base，并用CPU SIMD寄存器完成base multiply；scalar fallback
则回落到更小schoolbook。512-bit阈值是指令集、寄存器宽度和cache共同决定的，不是FPGA结论。

FPGA搜索空间：

```text
base datapath b ∈ {32, 64, 128, 256}
Karatsuba depth k ∈ {0, 1, 2, 3}
Comba lanes p ∈ {1, 2, 4}
result strategy ∈ {2r product, direct cyclic fold}
```

512-bit只作为资源允许时的附加点，不作为默认base。

### 6.4 Modular reduction

直接cyclic fold可把`2W` product bank缩成`W` result bank，但不能简单“边乘边覆盖输入”：inverter后续对角仍可能读取
旧f/t word。可行的两步路线是：

1. 先用对角寄存器顺序生成product word，保持单独`W`结果bank并在写入时fold；
2. 再研究结果原位写回，增加明确的读后写生命周期证明和RAW bypass。

对于`r mod 64 != 0`，一个高word会折叠到两个目的word；相邻cycle可能命中同址，必须定义XPM同步读延迟、
`read_first`语义和forwarding。若没有这三项，理论上少一次扫描可能在RTL中变成错误RMW。

## 7. Squaring Analysis

当前RTL的`k`-squaring并未照搬CPU的重复CLMUL square。`trike_poly_inv_core`把
`a(x) -> a(x)^(2^k)`实现为固定`2r`拍的bit permutation，地址由公开schedule决定。

| Scheme | Access pattern | Model | Assessment |
|---|---|---|---|
| A repeated single-square | 每次扫描全环，规则性好 | `k * L_sq1` | 小`k`可能有利；大`k`线性恶化 |
| B direct k-permutation | 每系数一次源/目的映射 | 当前约`2r` | 当前功能基线；random-write/bank conflict是关键 |
| C hybrid | 按公开`k`选A/B | `min(k*L_sq1,L_perm(k))` | 应由综合/route实测选择阈值 |

随包C在VPCLMUL可用时设置`K_SQR_THRESHOLD=64`，否则为0；其small-`k`路径使用CPU carry-less square，
large-`k`路径使用coefficient permutation。该阈值不能迁移。

建议先实现两个独立、固定调度的实验核：

- `direct-perm-stream`：目标从`2r`压到接近`r + O(W)`，用bank conflict表或固定多pass解决写冲突；
- `single-square-stream`：每次固定顺序读写，测量`L_sq1`、BRAM复制和Fmax。

然后对当前schedule实际出现的所有`k`计算交叉点，而不是只测试`k=64`。若D×D降到`2W²`量级，
TRIKE-2的46次permutation会从次要开销上升为明显Amdahl限制。

## 8. Inversion Analysis

### 8.1 当前addition-chain

当前是固定schedule的Frobenius/addition-chain，不是数据相关的普通Fermat循环。TRIKE-2每次：

```text
L_inv = 22 * L_DD_external + 23 * (2r) + fixed control
      = 23,021,520 cycles (MEASURED)
```

优势是控制完全公开，且可复用D×D；代价是D×D慢时被乘22倍。当前inverter自身Routed参考为2,138 LUT、
833 FF、4 RAMB36、0 DSP，内部同步WNS +0.447 ns；报告顶层I/O路径失败，且provenance不完整，
所以只能作为诊断参考。

### 8.2 Bernstein–Yang / Racing BIKE divstep

Racing BIKE的constant-time ExtGCD固定执行`2r-1` divsteps，以`b`控制memory width、`s`控制每轮展开divstep数。
在Artix-7 XC7A200T、100 MHz、`r=12323`下，论文实测：

| `b` | Configuration | LUT | FF | BRAM | Slices | Cycles |
|---:|---|---:|---:|---:|---:|---:|
| 32 | light `s=1` | 580 | 117 | 2 | 196 | 9,637,363 |
| 32 | best-AT `s=23` | 3,359 | 643 | 2 | 995 | 434,255 |
| 32 | high-speed `s=32` | 5,038 | 943 | 2 | 1,473 | 316,504 |
| 64 | light `s=1` | 1,020 | 183 | 4 | 377 | 4,880,299 |
| 64 | best-AT `s=31` | 7,801 | 1,457 | 4 | 2,269 | 172,522 |
| 64 | high-speed `s=64` | 18,610 | 3,563 | 4 | 5,457 | 91,678 |
| 128 | high-speed `s=128` | 75,269 | 14,028 | 8 | 21,435 | 47,386 |

这些是不同`r`、器件和完整接口下的**PUBLISHED**数据，不是TRIKE预测。它证明divstep具有很宽的面积/周期
设计空间，也显示高`b,s`的LUT代价极快增长。

### 8.3 新er EEA/FLT变体

[2025年的constant-time inversion综述与软件实验](https://eprint.iacr.org/2025/166.pdf)报告x86上
Bernstein–Yang相对FLT方法有1.76–3.76倍优势，同时明确这些是软件结果；它还研究CEA/TYT/SAC等减少
多项式乘法数的addition-chain变体，并指出只按block multiplication数量判断时，FLT硬件可能更有利。
因此“combined/multi-divstep EEA”应标为**潜在研究方向**，不能写成已有TRIKE FPGA结论。

### 8.4 Break-even模型

令`N_mul(r)`为当前schedule中的D×D次数，`N_perm=N_mul+1`：

```text
L_chain = N_mul * L_DD + Σ L_perm(k_i) + L_ctrl
L_div   = F(r,b,s,d,u)                 （固定2r-1 divsteps的实现模型）

chain更快的D×D交叉点：
L_DD* = (L_div - ΣL_perm - L_ctrl) / N_mul
```

若右侧为负，说明仅permutation floor已慢于该divstep点，必须先优化permutation才有比较意义。
TRIKE-2当前`L_DD≈1.014M`，远高于任何有竞争力的交叉点；但D×D是系统必需资源，divstep增加的f/g/v/w
bank和LUT不能按BIKE“删除dense multiplier”抵消。最终选择应比较：

```text
system_latency = cycles / routed_Fmax
system_AT      = incremental_area * system_latency
```

而不是只比较inverter standalone cycles。

## 9. Memory Architecture

### 9.1 当前生命周期

| Storage | Lifetime / reuse | Assessment |
|---|---|---|
| h0/h1/h2 support | KeyGen采样后跨算术/序列化 | 只保存index主表示；dense word按需合成 |
| t1/t2/r1 | H123后进入KeyGen算术 | t1生命周期结束后bank保存两次inverse |
| t0 | 第一次外层D×D后跨r2计算及SK输出 | 必须保留 |
| numerator/r2 | 两阶段numerator，最终原位变r2 | 已做生命周期复用 |
| outer multiplier | A、B、result、`2W` product | product是首要可压缩临时存储 |
| inverter | f、g、t、`2W` product | 外部乘法结果store避免额外完整复制 |
| u/v | Encaps输出及Decaps输入 | 两个ring bank |
| syndrome/decoder RAM | syndrome后固定7轮 | 统一KEM BRAM主要来源 |

SK格式同时包含h support和稠密h0，这是协议序列化需求；Decaps输入store会接收该dense h0字段，但当前syndrome
计算使用support列表。片上算术不长期同时维护h0/h1/h2三份dense副本。

### 9.2 单个64-bit SDP ring bank的RAMB36几何估算

按RAMB36 `512 x 72`模式，仅计容量且不含复制、端口或尾部开销：

| Parameter | `W=ceil(r/64)` | RAMB36 tiles / ring (**ESTIMATE**) |
|---|---:|---:|
| official TRIKE-2 | 244 | 1 |
| official TRIKE-5 | 553 | 2 |
| official TRIKE-7 | 1,089 | 3 |
| official TRIKE-9 | 1,782 | 4 |
| project TRIKE160 | 197 | 1 |
| project TRIKE256 | 475 | 1 |
| project TRIKE384 | 997 | 2 |
| project TRIKE512 | 1,669 | 4 |

因此删除一个`2W` product store的理论收益是2个ring-equivalent，但实际RAMB36/RAMB18映射、端口复制和最大几何
统一配置必须由Vivado确认。当前统一KEM 655 Block RAM Tile主要受最大几何Decaps/decoder影响，
局部乘法RAM优化不会按比例降低总BRAM。

## 10. Cycle Model

### 10.1 当前公式与官方TRIKE模型

| Set | `W` | D×D current | S×D (`S=d`) | S×D (`S=t`) | One inv arithmetic model | KeyGen arithmetic model |
|---|---:|---:|---:|---:|---:|---:|
| TRIKE-2 | 244 | 1,014,796 | 69,366 | 514,878 | 23,020,766 | 49,155,286 |
| TRIKE-5 | 553 | 5,204,836 | 245,642 | 1,900,966 | 100,264,376 | 216,388,902 |
| TRIKE-7 | 1,089 | 20,172,636 | 727,618 | 5,746,882 | 426,600,284 | 914,446,094 |
| TRIKE-9 | 1,782 | 54,003,510 | 1,589,766 | 12,511,394 | 1,464,288,722 | 3,092,177,740 |

后两列是按当前cycle公式和schedule次数得到的**ESTIMATE**，未加入所有FSM边界。TRIKE-2实际one-inv为
23,021,520，KeyGen arithmetic为49,162,174，说明模型足以定位主导项但不替代仿真测量。

### 10.2 已测固定周期剖面

| Operation | Total cycles | Dominant component | Cycles | Share |
|---|---:|---|---:|---:|
| official TRIKE-2 KeyGen core | 53,995,036 | arithmetic | 49,162,174 | 91.05% |
| official TRIKE-2 KeyGen core | 53,995,036 | two inversions | 46,043,040 | 85.27% |
| official TRIKE-2 Encaps core | 2,378,447 | UV sparse component | 2,062,238 | 86.71% |
| project TRIKE160 Decaps | 2,794,347 | residual/re-encryption | 1,340,836 | 47.98% |
| project TRIKE160 Decaps | 2,794,347 | syndrome | 1,086,187 | 38.87% |
| project TRIKE160 Decaps | 2,794,347 | decoder | 337,245 | 12.07% |

项目运行时Decaps已测总周期：TRIKE160/256/384/512分别为2,794,347、11,331,165、39,750,462、
97,579,462。16-bit digit相对旧8-bit digit分别减少18.18%、24.16%、28.58%、31.35%，证明高档D×D优化
具有越来越高的系统价值。

### 10.3 候选D×D解析包络

用`L_DD≈aW+I_pair*W²`描述去除product-RMW后的word-pair吞吐，先探索`I_pair={1,2,4}`。
这不是声称64×64组合乘法可以无代价II=1，而是用于限制实验目标。任何speedup必须同时报告routed Fmax：

```text
latency_ns = fixed_cycles / routed_Fmax
```

若周期降低4倍但Fmax下降超过4倍，系统延时并未改善。

## 11. Resource Model

### 11.1 当前可用物理证据

| Boundary | LUT | FF | Slice | BRAM Tile | DSP | Timing status | Evidence limit |
|---|---:|---:|---:|---:|---:|---|---|
| poly-inv digit16 | 2,138 | 833 | 704 | 4 | 0 | internal WNS +0.447 ns | overall I/O WNS -2.636；provenance不完整 |
| KeyGen digit16 | 46,441 | 54,731 | 22,042 | 22 | 5 | overall +0.025；internal +0.040 ns | 独立TRIKE-2诊断 |
| Encaps | 47,349 | 61,308 | 24,349 | 16.5 | 4 | overall +0.025；internal +0.441 ns | source revision未嵌入报告 |
| max-geometry Decaps | 63,386 | 60,521 | 25,759 | 635 | 4 | overall +0.033；internal +0.635 ns | 固定profile物理包络 |
| unified KEM GUI | 113,484 | 106,282 | 40,061 | 655 | 5 | overall -4.794；internal -3.914 ns | GUI来源/defines/XDC未完整记录，不可严格比较 |

统一报告中仅确认共享sampler的`u_index_mem`映射为1 RAMB36；没有可信的dense multiplier/square/inverter
完整层次资源分解，故本报告不编造该表。后续需要对各实验top执行同一Vivado Tcl flow并保存hierarchical utilization。

### 11.2 方向性资源模型

| Change | LUT/FF | BRAM | Routing/Fmax |
|---|---|---|---|
| diagonal/Comba，保留16×64 base | 小到中增量 | product `2W`可望降为result `W` | 通常优于反复RAM控制；需route验证 |
| 64×64多lane | 中到高增量 | 可减少临时bank | XOR树/广播可能降Fmax |
| Karatsuba depth增加 | XOR/控制和buffer上升 | recursion staging可能上升 | bank置换和fanout是主要风险 |
| tagged sparse单核 | 读mux/mask中增量 | 可能需要bank复制或独立端口 | 双bank并读增加route |
| dual tagged sparse | 近似复制accumulator/datapath | 端口/结果bank翻倍 | 高风险 |
| direct permutation | 地址生成/冲突控制增加 | 1–多bank，取决于冲突方案 | random access可能成为critical path |
| divstep | 随`s,b`快速增长 | f/g/v/w约4个状态bank | 高`s`组合链风险 |

## 12. Optimization Candidates

| Optimization | Expected speedup | Area impact | Difficulty | Risk | Priority |
|---|---|---|---|---|---|
| D×D diagonal/Comba去product RMW | High（KeyGen/高档Decaps主导） | Low–Medium，BRAM可能下降 | Medium | cyclic fold/RAW correctness | P0 |
| 统一SM3输出局部寄存/分发树 | 不降cycles；可恢复实际Fmax | Low–Medium FF | Medium | cycle/handshake保持 | P0 |
| Encaps固定双读tagged two-pass | High（UV占86.71%） | Medium | Medium–High | secret bank access、routing | P1 |
| 专用direct permutation | Medium，D×D加速后High | Low–Medium | Medium | bank conflict | P1 |
| on-the-fly cyclic reduction | Medium | BRAM下降 | High | 非64对齐、覆盖输入 | P1 |
| Karatsuba+Comba depth 1/2 | Medium–High，高`r`更有利 | Medium–High | High | Fmax/BRAM重组 | P2 |
| constant-time divstep inverter | High inversion-cycle potential | Medium–High额外LUT/BRAM | High | TRIKE系统AT未证实 | P2 |
| dual parallel tagged UV engines | High Encaps latency potential | High | High | 4-bank读和route | P3 |
| 复制通用D×D提高并行度 | Low for current serial dependency chain | High | Medium | inversion数据依赖限制收益 | P3 |
| 普通XOR微优化 | Low | Low | Low | 转移注意力 | 不建议先做 |

## 13. Recommended Architecture

建议的下一版不是立即建立“大而全Karatsuba核”，而是形成三个边界清楚、可独立替换的算术服务：

```text
Polynomial service fabric
├── Sparse service
│   ├── support index RAM
│   ├── fixed multi-bank reader
│   ├── 64-bit rotate/concatenate
│   └── result forwarding / ping-pong accumulator
├── Dense service
│   ├── banked operand interface
│   ├── diagonal/Comba base engine
│   ├── optional Karatsuba front end
│   └── direct cyclic fold to separate W-word result
└── Frobenius service
    ├── direct k-permutation
    └── optional repeated single-square mode

KeyGen inversion FSM复用Dense + Frobenius service
Decaps syndrome复用Sparse + Dense service
Encaps使用tagged Sparse service；是否双实例由route结果决定
```

默认保留addition-chain inverter。Divstep作为并列实验top，只有在同条件下同时改善`cycles/Fmax`和系统AT，
且没有破坏统一KEM资源/路由时才替换。D×D的外层核与inverter内部核是否进一步合并也应后置：当前inversion
串行依赖强，物理共享可能省面积，但服务接口、bank arbitration和长路由可能降低Fmax。

## 14. Experimental Plan

所有点先在TRIKE-2完成byte-golden与固定周期，再选择TRIKE-9几何做扩展性检查；保留点才进入KeyGen/Decaps集成。

### 14.1 Dense multiplier matrix

| Axis | Values | First gate | Physical outputs |
|---|---|---|---|
| base width | 32, 64, 128, 256 | random+official polynomial golden | LUT/FF/BRAM/DSP、WNS、cycles |
| Comba lanes / pair II | 1, 2, 4 | reduction及尾部formal | routed Fmax、AT |
| Karatsuba depth | 0, 1, 2, 3 | 先固定最优Comba base | hierarchical utilization |
| reduction | full-2r, folded-W | 等价、RAW、last-word assertions | product/result RAM mapping |

淘汰规则：任何点若内部WNS恶化且`cycles/Fmax`不改善，或需要未受控的额外ring复制，停止扩展其Karatsuba depth。

EXP-0117把“64x64 base递归深度”和“整多项式word-array递归深度”拆成两个独立轴。前者的Yosys诊断选择
depth 1：独立base Estimated LC从2,195降至1,766，depth 2/3增至2,690/3,312；该选择不改变`W^2`
word-pair数量或周期。后者才通过`3^k`个half-size Comba子问题降低主周期，必须同时测量banked operand、
cross-term读取、product重组和额外scratch RAM。

EXP-0118完成word-array depth 1：TRIKE-2使用四个half operand bank依次形成`Z0/Z2/Z1`，官方golden
固定50,993拍，相对D64 Comba的61,977拍减少17.72%。Yosys诊断为2,363 Estimated LC和6 RAMB36；
该点只进入depth-2与Vivado候选矩阵，不作为成品资源或Fmax结论。

EXP-0119完成word-array depth 2：九个quarter-size子积按固定phase地址表重组，TRIKE-2官方golden
固定44,216拍，相对D64 Comba减少28.66%；强制block诊断为3,104 Estimated LC和10 RAMB36。
TRIKE-9的固定周期公式给出1,646,057拍，且depth 1/2静态block容量均为19个RAMB36；该扩展性结论仍需
大参数golden和Vivado映射确认。

### 14.2 Sparse multiplier matrix

| Axis | Values | Required checks |
|---|---|---|
| `b` | 32, 64, 128 | 所有rotation offset、`r mod b`尾部、support边界 |
| accumulator | single+forward, ping-pong | XPM read-first/latency、同址连续更新 |
| Encaps topology | 4-pass baseline, 2-pass tagged, dual tagged | 每bank固定访问计数和固定地址轨迹 |
| profiles | TRIKE-2, TRIKE-9 | cycle scaling、route和BRAM宽化 |

### 14.3 Inversion and square matrix

| Family | Points | Decision metric |
|---|---|---|
| addition-chain | current D×D；new D×D；new permutation | measured `N_mul`, `N_perm`, cycles/Fmax |
| divstep | `b=32/64/128`, `s=1/4/8/16/32`，再局部搜索 | incremental area、cycles/Fmax、AT |
| square | repeated single；direct perm；hybrid | 对实际schedule每个`k`测`L_square(k)` |

### 14.4 每个实验的验证层

1. 静态：filelist、Verible、fatal-warning Verilator、Slang；
2. 单元：与Reference C逐word/逐byte golden，覆盖非64对齐；
3. formal：counter/address边界、fixed done、RAM同址forwarding、公开参数访问计数；
4. 集成：KeyGen/Encaps/Decaps最小相关测试及固定周期；
5. 物理：相同part、Vivado版本、XDC、clock、uncertainty、参数、报告阶段；
6. 记录：raw reports + RUN manifest + experiments ledger；不以Yosys memory统计替代XPM/RAMB证据。

## 15. Optimization Roadmap

### Phase 1：建立可比较的瓶颈基线

- 重跑当前TRIKE-2 poly-mul、poly-inv、KeyGen、Encaps和统一KEM的同源Vivado Tcl基线；
- 保存模块层次utilization、内部同步timing、BRAM映射及精确cycle manifest；
- 单独修复统一SM3跨层routing，不改变算术微架构。

退出条件：同一revision/defines/XDC/part/Vivado/stage可复现；否则所有物理差值仍标`incomparable`。

### Phase 2：低风险高收益算术调度

- 建立64-bit diagonal/Comba D×D，先保留独立W-word result bank；
- 建立64-bit sparse accumulator forwarding或ping-pong版本；
- 建立direct permutation实验核；
- 每项一个commit、一个独立实验，先单元/formal后KEM集成。

退出条件：byte-golden、固定周期、K=3/K=4相关路径无回归，并有comparable routed `cycles/Fmax`改善。

### Phase 3：结构级探索

- 在获胜Comba base上扫描Karatsuba depth；
- 实现Encaps constant-access tagged two-pass，之后才评估双UV实例；
- addition-chain与divstep并列综合/route；
- 依据实际`square(k)`数据选择hybrid阈值。

退出条件：系统级KeyGen/Encaps/Decaps延时与面积共同可解释；不得只凭standalone模块speedup保留方案。

### Phase 4：统一KEM收敛

- 重新审查外层D×D与inverter D×D的物理共享；
- 复核所有polynomial bank生命周期、端口和constant-access属性；
- 对保留架构运行完整reference、random、formal和comparable Fully Routed gate。

## 16. Security and Evidence Boundaries

- 所有循环上界由公开`r/d/t`和公开参数档决定，不允许按weight分布、denominator内容、decoder收敛或mismatch位置提前结束。
- support index本身是秘密。固定总周期不自动等于固定memory trace；tagged Encaps必须保证每个候选bank的访问次数和地址
  序列固定，或在威胁模型中明确降级。
- Karatsuba recursion depth、square阈值和divstep的`b/s`只能由公开参数选择。
- decoder成功、重加密匹配和候选合格只允许mask选择结果，不允许改变调度深度。
- 软件benchmark、不同FPGA论文、Yosys结构结果、Vivado routed结果和本仓库仿真周期是不同证据层，不能互相替代。
- 统一KEM GUI报告缺少完整source/defines/XDC provenance；113,484 LUT、655 BRAM和WNS仅用于定位问题，不计算跨run增减。

## 17. Source Map

### A. Published / experimentally validated

- [Racing BIKE: Improved Polynomial Multiplication and Inversion in Hardware](https://eprint.iacr.org/2021/1344.pdf)：
  constant-time sparse rotate/XOR、`b/s`可调divstep、Artix-7资源/周期数据。
- [Flexible and Scalable FPGA-Oriented Design of Multipliers for Large Binary Polynomials](https://re.public.polimi.it/retrieve/e0c31c0f-8c3b-4599-e053-1705fe0aef77/IEEEAccess_FPGA_Mul.pdf)：
  recursive Karatsuba + Comba、内部/外部带宽解耦、BRAM-aware可扩展结构。
- [Polynomial Inversion Algorithms in Constant Time for Post-Quantum Cryptography](https://eprint.iacr.org/2025/166.pdf)：
  BY/FLT/CEA/TYT/SAC比较；硬件迁移部分仅作研究线索。

### B. Derived from TRIKE source / current RTL

- `rtl/trike_poly_mul_core.sv`：当前D×D/S×D微架构和精确busy-cycle公式；
- `rtl/trike_poly_inv_core.sv`、`rtl/trike_inv_schedule_pkg.sv`：固定Frobenius/addition-chain schedule；
- `rtl/trike_keygen_arith_core.sv`：KeyGen四个外层乘法操作与两个inversion；
- `rtl/trike_encaps_uv_core.sv`：四次固定weight-`t` sparse pass；
- `rtl/trike_decaps_syndrome_core.sv`：`h0*u + t0*(u+v)`；
- 随包`Optimized_Implementation/TRIKE-2/src/gf2x.c`：VPCLMUL 512-bit base、`K_SQR_THRESHOLD`和fast inversion；
- 随包`KEM_AlgorithmInstance.c`：软件KeyGen/Encaps/syndrome调用关系及SK保存`t0/r2`。

### C. Proposed TRIKE hardware optimizations

- Encaps constant-access tagged two-pass；
- diagonal/Comba direct-fold D×D基线；
- FPGA实测驱动的square/permutation hybrid阈值；
- addition-chain/divstep的TRIKE系统break-even与同条件AT实验。

这些C类项目均未实现、未综合、未route；本报告中的周期仅为透明公式或上界，不是承诺结果。
