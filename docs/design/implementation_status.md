# RTL实现状态

> 本文只描述当前成品架构、固定周期、验证结论和证据边界。设计动机与实验结论见
> [实验索引](../experiments/index.md)，精确Vivado运行条件见
> [Vivado基线注册表](vivado_baseline_registry.md)，门禁选择见
> [验证矩阵](../verification/validation_matrix.md)。

## Decoder配置

统一TRIKE K-sign译码器的默认构建为`L=32`、`K=4`、`COLS_PER_TILE=1152`，固定执行7轮
Min-Sum。最大公开参数等级确定计数器和存储几何，`i_param_level`只选择公开的`R/W/tile`配置。

| 项目 | 默认值 |
| --- | --- |
| 参数族 | `TRIKE_UNIFIED_PARAMS` |
| 最大等级 | TRIKE-512：`N0=3`、`R=106781`、`W=111` |
| message | 5 bit，其中幅值4 bit |
| `L / K / POS_W` | `32 / 4 / 7` |
| `COLS_PER_TILE` | 1152 |
| `Q_BASE / Q_TILE` | `36 / 39` |
| `TILE_COUNT / TILES_TOTAL` | `93 / 279` |
| 实现器件 | `xc7k355tffg901-2L` |
| 实现目标 | Vivado 2023.2，10 ns，0.100 ns uncertainty |

当前公开参数为：

| 等级 | `R` | `W` | 固定周期 | 100 MHz延时 |
| --- | ---: | ---: | ---: | ---: |
| TRIKE128 | 8243 | 27 | 193,514 | 1.93514 ms |
| TRIKE160 | 12589 | 35 | 337,245 | 3.37245 ms |
| TRIKE256 | 30389 | 55 | 1,252,957 | 12.52957 ms |
| TRIKE384 | 63773 | 83 | 3,866,043 | 38.66043 ms |
| TRIKE512 | 106781 | 111 | 8,538,564 | 85.38564 ms |

TRIKE-512周期由公开配置计算：

```text
ROW_SEG_SIZE = ceil(106781 / 32) = 3337
T_MAIN       = (279 + 1) * 111 * 39 = 1212120
T_TILE       = 111 * 39 = 4329
T_ITER       = 3337 + 1212120 + 8 + 4329 = 1219794
T_DECODE     = 7 * 1219794 + 6 = 8538564
```

## Decoder数据通路

主循环按公开的iteration、tile、diag和lane坐标扫描：

1. `edge_addr_gen`产生两级流水地址，`barrel_rotate`完成lane到bank的请求和返回路由。
2. C2V从全局K-sign记录重建符号，从`ram_m`读取压缩check-state，并写入fill侧`ram_accum/ram_t`。
3. V2C读取active侧`ram_accum/ram_t`，更新另一个iteration pair的`ram_m/ram_sign_delta`，同时维护
   `ram_k_tile`候选。
4. 完成tile的snapshot与后续tile重叠执行correction；位置命中只产生1-bit flip请求。
5. 最后一轮把`base_sign`提交到`ram_k_global`，`o_done`后外部错误向量读口复用该同步读路径。

H第一列、syndrome、候选值和译码收敛只影响有效位或写使能，不改变状态扫描深度。主循环固定执行
`I_MAX=7`，没有提前终止、秘密相关bank数或数据相关存储访问次数。参数等级在首次配置写入时锁定；
syndrome必须完整装载，H必须完成固定合法性检查，之后才接受start。

## Decoder RAM生命周期

| 存储 | 生命周期与角色 | 物理意图 |
| --- | --- | --- |
| `ram_i` | 配置阶段写三组H第一列；运行期为C2V/V2C/correction提供三读视图 | BRAM |
| `ram_syndrome` | 地址`0..R-1`完整装载；C2V期间同步读取 | `L`个bit bank BRAM |
| `ram_m` | 两个iteration pair交替承担C2V读取和V2C写入 | `2*L`个18-bit bank |
| `ram_sign_delta` | 与`ram_m`同pair切换；correction执行固定flip RMW | `2*L`个1-bit bank |
| `ram_accum` | fill/active双buffer在相邻tile间交换 | banked distributed RAM |
| `ram_t` | C2V写fill，V2C读active；公共地址广播，valid/data旋转 | 双buffer BRAM |
| `ram_k_tile` | 工作候选与已完成tile的位置snapshot并行存在 | 45/28-bit bank |
| `ram_k_global` | 全局K-sign原地更新；完成后提供最终decision读口 | 两个18-bit字段/逻辑记录 |

每个逻辑全局记录包含`base_sign`和4个7-bit deviation位置，共29 bit。默认`L=32`映射为两个18-bit
字段：field 0保存`base_sign/dev_pos[1:0]`，field 1保存`dev_pos[3:2]`。读segment编号与同步RAM延迟
对齐后完成字段组合和lane返回路由。TRIKE K-sign配置不实例化完整符号RAM。

## KEM数据通路

公共核的接口、状态布局和逐模块周期见
[TRIKE KEM公共核设计](trike_kem_common_cores.md)。所有复合顶层按公开FSM复用SM3服务；Yosys层次检查
要求每个完整KeyGen、Encaps和Decaps层次恰好包含一个`sm3_compress`。

### KeyGen

`trike_keygen_core`接收`key_seed || sigma2 || sigma`共96 byte，固定扫描16组秘密support候选，随后执行
H1/H2/H3和多项式算术。support同时写入稀疏运算视图和SK顺序输出RAM。PK为`r2 || sigma`共1,980
byte，SK为三组32-bit little-endian support以及`h0 || t0 || r2 || sigma || sigma2`共6,328 byte。

| 边界 | 固定周期 | golden范围 |
| --- | ---: | --- |
| 秘密support调度 | 4,778,975 | 候选0合格与候选1才合格 |
| KeyGen算术 | 93,933,246 | 官方TRIKE-2 `t0/r2`逐word |
| KeyGen core | 98,766,108 | PK/SK逐byte，两种候选路径 |
| `trike_keygen_synth_top` | 98,773,679 | 8-bit输入、PK、SK流逐byte |

`success`只报告固定候选集合中是否找到合格support，不改变H123、算术或序列化调度。

### Encaps

`trike_encaps_core`顺序装载`r2 || sigma || m`，用H123/H4和共享稀疏乘法器产生`u/v/c2/SS`。
`trike_encaps_synth_top`只暴露8-bit输入、8-bit CT和8-bit SS流。

| 边界 | 固定周期 | golden范围 |
| --- | ---: | --- |
| H123/H4/UV组件 | 44,640 / 207,017 / 2,062,238 | 官方中间量 |
| Encaps core | 2,378,447 | 3,928-byte CT与32-byte SS |
| `trike_encaps_synth_top` | 2,384,421 | 窄I/O完整输出 |

稀疏环乘在TRIKE-2参数下固定69,366拍，稠密环乘固定1,967,372拍。稀疏调度逐support index和B word
执行一次地址准备及三组result RAM读改写，周期为
`4*WORDS + 2*S + 8*S*WORDS`。

### Min-Sum Decaps

当前完整Decaps profile为TRIKE160项目参数`r=12589,w=35,t=263,L=32,K=4`。它使用
`TRIKE_MINSUM_KAT_V1`项目向量；官方TRIKE-2 KAT的`r=15581`不能作为该译码profile的端到端
Decaps golden。

流水顺序为：

```text
SK/CT装载 -> h0*u + t0*(u+v) -> H排序与decoder装载
-> 固定7轮Min-Sum -> padded error写出 -> residual全扫描
-> L(e')恢复消息 -> H4重加密比较 -> m'/sigma2选择 -> KDF
```

`decoder_top.o_done`只表示固定轮完成；`trike_decoder_residual_check`独立重算
`syndrome xor H*e'`，其`o_residual_zero`作为隐式拒绝条件之一。decision同步读口依次分配给padded
error writer和residual checker，之后postprocess才读取error RAM。

| 边界 | 固定周期 | 当前验证 |
| --- | ---: | --- |
| syndrome core | 2,038,763 | 244个word匹配独立模型 |
| message recover | 28,431 | 正常与全零error |
| reencrypt verify | 209,659 | 匹配与首byte扰动 |
| KDF | 19,323 | 接受与拒绝SS逐byte |
| postprocess | 257,417 | 正常与`c2`篡改 |
| residual checker | 2,668,869 | residual 0与单bit syndrome扰动 |
| pipeline core | 4,734,246 | 正常及`u/v/c2`三种篡改 |
| `trike_decaps_synth_top` | 4,743,972 | 8-bit `SK || CT`输入和SS输出 |

四条pipeline路径的RTL residual重量为`0/6233/6314/0`。正常路径输出Encaps SS，三条篡改路径均输出
`K(sigma2,tampered_ct)`。非收敛`u/v`样本只要求双方residual非零与最终隐式拒绝SS一致，不声明
Min-Sum判决与软件模型bit-exact。

## 验证状态

2026-08-10当前源码通过：

- `make ci-fast`：工具锁、记录/filelist检查、Verible/Slang/Verilator、形式proof/cover、单元测试和toy
  集成；toy结果为`residual=0, exact=1, cycles=154`。
- `make ci-kem-reference`：官方TRIKE-2/5/7/9 C KAT哈希、五档软件KEM自测，以及完整
  KeyGen/Encaps/Min-Sum Decaps参考链。
- 默认K=4、`L=32`五档随机译码：固定周期与预算一致，`residual=0`、`exact=1`。

严格Verilator告警门使用[精确waiver文件](../../config/verilator_waivers.vlt)。waiver只覆盖已知的生成
fixture未用参数、testbench同步观察复位与DUT异步复位、以及显式未消费的测试输出；RTL规则保持启用。

## Vivado证据边界

当前参数与当前源码没有完整的同条件routed decoder基线。KeyGen、Encaps和Decaps经历过会影响路径或
周期的RTL修改，其资源、WNS和Fmax以下一次带manifest的实现为准。历史报告只用于定位，不用于计算当前
增减或宣称物理收益。

每次新运行使用`RUN-YYYYMMDD-NN-<top>`标识，在
`reports/vivado/manifests/`提交运行manifest，原始`.rpt/.dcp`保存在
`D:/trike_reports/<run-id>/`。只有器件、Vivado、XDC、参数、`L/K`、存储几何、时钟和报告阶段一致的
Fully Routed结果才可更新[Vivado基线注册表](vivado_baseline_registry.md)。wrapper没有package pin约束，
因此核心100 MHz通过不等于板级I/O签核。

实现入口与产物说明见[项目工作流](../project_workflow.md)。完整Decaps的下一项物理工作是运行
`trike_decaps_synth_top`，记录LUT/FF/Slice/BRAM/DSP、setup WNS/TNS、hold WHS/THS、未约束路径和
关键routed path，再用`cycles/Fmax`评价体系级延时。

## 当前限制

- 官方TRIKE-2的`r=15581`与项目Min-Sum profile的`r=12589`是两个验证域；官方端到端Decaps KAT需要
  单独建立`r=15581`译码profile及DFR证据。
- 当前Min-Sum端到端向量证明功能闭环、固定周期和隐式拒绝，不构成有限样本之外的DFR/FLS结论。
- 完整Decaps、当前KeyGen和当前Encaps需要同条件Vivado复测；板级接口还需要真实pin与I/O delay约束。

## 实现判据

1. 固定调度只依赖公开参数；秘密数据、收敛和失败路径不改变访问次数或状态深度。
2. 功能验证分别报告golden、固定周期、residual和隐式拒绝；其中一项不能代替另一项。
3. 物理比较必须保持器件、Vivado、XDC、参数、并行度、存储几何和报告阶段一致。
4. 资源同时报告LUT、FF、Slice、Block RAM Tile、RAMB36、RAMB18和DSP。
5. 时序以routed setup/hold和真实约束为准；逻辑bit数、实例数或综合结构不等同于物理收益。
