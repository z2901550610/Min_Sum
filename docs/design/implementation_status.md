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

### 统一KEM ASIC入口

`trike_kem_asic_top`使用公开`i_operation=KeyGen/Encaps/Decaps`形成单发射事务边界。operation在start
接受时锁存，busy期间三个stage start保持全零，完成只采纳已锁存stage的done。三阶段SM3请求经过公开
operation mux连接唯一`trike_sm3_service`；完整层次结构检查恰好一个`sm3_compress`。控制器one-hot和
operation稳定性由SymbiYosys/Z3证明，三阶段外置SM3路径分别保持现有byte golden与固定周期。
Decaps继承decoder H验证状态的一次复位一笔事务约束；同一复位周期内的第二个Decaps命令返回error。

三阶段普通多项式请求经过同一operation mux连接最大几何`trike_poly_mul_core`。服务在命令边界装载公开
`r_bits/words/sparse_weight`，反馈只送入活动stage。完整层次固定包含一个共享流式乘法器和一个KeyGen
求逆内部乘法器。KeyGen、Encaps和Decaps syndrome外置服务reference分别保持53,995,036、2,378,447和
1,086,187拍并通过golden。

KeyGen与Encaps的H1/H2/H3请求连接同一`trike_h123_vectors`。服务保存一份DRNG
Instantiate/Generate状态并复用一个`trike_parity_map_stream`，seed与vector握手由公开operation选择。
两阶段外置H123、SM3和乘法组合reference分别保持53,995,036和2,378,447拍并通过byte golden。

共享H123 byte流同时写入一个`trike_h123_vector_store`。该服务按官方TRIKE-2几何保存三组
244x64-bit的`t1/t2/r1`，并用三个独立同步读口满足KeyGen的`t1/r1`并行读取及Encaps读序列。
KeyGen第一次分母完整装载后，通过固定写口把`t1` bank依次重命名为两次inverse scratch；Encaps阶段
保持三组H123只读角色。operation mux转发活动stage的读写地址；完整层次恰好一个H123 vector store。两阶段全外置组合reference
分别保持53,995,036和2,378,447拍并通过byte golden；具体RAMB映射及读口复制行为等待Vivado确认。

KeyGen秘密support、Encaps H4和Decaps重加密H4连接同一最大几何`trike_drng_weight_sampler`。命令装载
公开`length/weight`与DRNG state，index和最终state只返回活动stage。完整层次恰好一个
`trike_drng_weight_sampler`及其`trike_fixed_weight_sampler`；三阶段外置reference分别保持53,995,036、
2,378,447和257,417拍并通过golden。seed Instantiate控制、KeyGen弱密钥检测和秘密support RAM位于stage
层次。

Encaps与Decaps的H4 support和三块padded dense error连接同一最大几何`trike_error_support_store`。
命令锁存公开`r/t/padded_r_bytes`，两个边界比较和减法把全局index映射到三块dense error，index写入及
后续support/error同步读取只选择活动operation。完整层次
恰好一个H4 store；两阶段外置store reference分别保持2,378,447和257,417拍，并通过CT/SS byte golden及
有效/拒绝成对固定周期验证。Decaps decoder error RAM属于译码后检查生命周期，不接入该服务。

该入口的KeyGen/Encaps采用官方TRIKE-2 `r=15581,w=35,t=263`，Decaps采用四档项目K-sign profile。
两者是显式分离的参数验证域。Decaps H123存储及其他工作RAM位于stage层次，统一入口的Vivado资源、
时序与功耗为`待测`。

### KeyGen

`trike_keygen_core`接收`key_seed || sigma2 || sigma`共96 byte，固定扫描16组秘密support候选，随后执行
H1/H2/H3和多项式算术。三组support保存在一份寄存视图中，供算术核与`h0`序列化读取；同一输入流写入
SK顺序输出RAM，保持同步读取时序边界。PK为`r2 || sigma`共1,980 byte，SK为三组32-bit little-endian
support以及`h0 || t0 || r2 || sigma || sigma2`共6,328 byte。
外层两组244x64-bit持久RAM直接连接算术核的external result store接口：一组保存`t0`，另一组依次保存
两阶段numerator与最终`r2`。最终乘法完整接受两路操作数后，`r2`按固定输出顺序原位覆盖numerator；
算术结果重放、PK与SK序列化从同一RAM读取。共享H123的`t1` bank在原多项式最后一次读取后保存两次
inverse结果。结构门禁要求算术核只展开external support/result store分支，且层次内没有独立inverse RAM。

| 边界 | 固定周期 | golden范围 |
| --- | ---: | --- |
| 秘密support调度 | 4,778,975 | 候选0合格与候选1才合格 |
| KeyGen算术 | 49,162,174 | 官方TRIKE-2 `t0/r2`逐word |
| KeyGen core | 53,995,036 | PK/SK逐byte，两种候选路径 |
| `trike_keygen_synth_top` | 54,002,607 | 8-bit输入、PK、SK流逐byte |

`success`只报告固定候选集合中是否找到合格support，不改变H123、算术或序列化调度。

### Encaps

`trike_encaps_core`顺序装载`r2 || sigma || m`，用H123/H4和共享稀疏乘法器产生`u/v/c2/SS`。
UV核通过外部store接口直接读写外层两组244x64-bit持久`u/v` RAM；同一RAM依次承担四次乘法累加、
结果重放、K输入和密文输出。结构门禁要求统一层次的UV核选择external store分支。
`trike_encaps_synth_top`只暴露8-bit输入、8-bit CT和8-bit SS流。

| 边界 | 固定周期 | golden范围 |
| --- | ---: | --- |
| H123/H4/UV组件 | 44,640 / 207,017 / 2,062,238 | 官方中间量 |
| Encaps core | 2,378,447 | 3,928-byte CT与32-byte SS |
| `trike_encaps_synth_top` | 2,384,421 | 窄I/O完整输出 |

生产KEM稠密路径使用`WORD_W=64, DIGIT_W=16`。TRIKE-2参数下稀疏环乘固定69,366拍，稠密环乘固定
1,014,796拍。稀疏调度逐support index和B word
执行一次地址准备及三组result RAM读改写，周期为
`4*WORDS + 2*S + 8*S*WORDS`。

### Min-Sum Decaps

完整运行时Decaps覆盖TRIKE160/256/384/512四个项目参数，使用`TRIKE_MINSUM_KAT_V1`项目向量。
官方TRIKE-2/5/7/9 KAT具有不同`r`和高档消息长度，不能作为这些译码profile的端到端Decaps golden。

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
| syndrome core | 1,086,187 | 244个word匹配独立模型 |
| message recover | 28,431 | 正常与全零error |
| reencrypt verify | 209,659 | 匹配与首byte扰动 |
| KDF | 19,323 | 接受与拒绝SS逐byte |
| postprocess | 257,417 | 正常与`c2`篡改 |
| residual checker | 1,340,836 | 双行扫描，residual 0与单bit syndrome扰动 |
| pipeline core | 2,785,269 | 正常及`u/v/c2`三种篡改 |
| `trike_decaps_synth_top` | 2,794,995 | 8-bit `SK || CT`输入和SS输出 |
| `trike_decaps_runtime_synth_top`，TRIKE160 | 2,794,347 | 有效及u/v/c2三种篡改 |
| `trike_decaps_runtime_synth_top`，TRIKE256 | 11,331,165 | 有效及c2隐式拒绝 |
| `trike_decaps_runtime_synth_top`，TRIKE384 | 39,750,462 | 有效及c2隐式拒绝 |
| `trike_decaps_runtime_synth_top`，TRIKE512 | 97,579,462 | 有效及c2隐式拒绝 |

四条pipeline路径的RTL residual重量为`0/6233/6314/0`。正常路径输出Encaps SS，三条篡改路径均输出
`K(sigma2,tampered_ct)`。非收敛`u/v`样本只要求双方residual非零与最终隐式拒绝SS一致，不声明
Min-Sum判决与软件模型bit-exact。

四档Decaps输入事务前端由`trike_decaps_profile_config`和`trike_decaps_input_loader`组成。profile仅在
start边界锁存，TRIKE160/256/384/512分别固定接受8,386/19,751/40,952/68,168 byte，并按档产生
support、t0、r2、sigma2、u、v和ciphertext的最大几何RAM写命令。每档两组不同payload均通过精确
写次数、连续地址、profile锁存和`input_bytes+1`周期检查。该结果是前端RTL验证，不是完整四档Decaps
功能或Vivado物理证据。

`trike_decaps_input_store`按TRIKE512最大几何承接上述写命令，提供support、t0、r2、u、v和完整
ciphertext的同步读口，并保存32-byte sigma2。四档全部有效地址已逐项读回，包含little-endian word
组装和末word高位清零检查。大RAM不执行复位清零，事务消费者只访问锁存profile给出的活动范围。

syndrome和共享`trike_poly_mul_core`支持可选运行时公开环几何。start边界锁存`r/w/word`后，活动值固定
控制加载、清零、稠密归约、稀疏回卷和输出长度。固定预取器使用一拍同步读的FETCH/DATA状态，按
`h0/t0/u/v`顺序访问最大几何输入RAM；valid等待期间保持数据且不重复读。`r=7/13/23`小几何逐word
golden通过。项目TRIKE160完整`SK || CT`装载、预取和syndrome输出接受8,386 byte、输出197个word，
两套payload均匹配golden并固定为728,602拍。TRIKE syndrome reference为1,086,187拍，独立
稠密/稀疏乘法reference为1,014,796/69,366拍。

support排序器和decoder装载桥支持可选运行时公开几何。start边界锁存`r/w`后，三块support分别固定执行
`w*(w-1)/2`次compare-swap并输出`w`项；syndrome按活动`r`逐bit写入并只产生一次decoder start。
`r/w=7/1、13/3、23/5`下排序器分别固定7/28/61拍，组合装载桥分别固定22/50/94拍；每档两套
payload的坐标、地址、数据、访问次数和周期一致。

`trike_decaps_support_prefetch`使用一个同步RAM读口读取全部`3w`项。首块support原子广播到syndrome H0
装载与完整H排序器，另外两块只送排序器；消费者停顿时保持数据且不重复读取。项目TRIKE160最大RAM
实例从8,386-byte输入开始，固定写入105项升序H和12,589个syndrome bit并产生一次decoder start，
两套payload均匹配golden且固定741,000拍。该边界的decoder完成信号由testbench固定延迟模型提供。

decoder后检查使用最大容量error、support和syndrome RAM，在事务start锁存公开`r/w`。error writer只清零
活动`3*ceil(r/512)*64` byte并扫描`3r`项判决；residual checker用同一support读数处理相邻两行，
K-sign全局记录RAM在译码完成后提供两个不同bank的decision读数。固定预算为
`ceil(r/2)*(3+6w)+1`拍，不因判决值或首个非零residual提前结束。小几何error逐byte匹配，residual为0
与单bit扰动重量1的周期一致。项目TRIKE160运行时residual reference固定1,340,836拍。

## 验证状态

2026-08-24当前源码通过：

- `make ci-fast`：工具锁、记录/filelist检查、Verible/Slang/Verilator、形式proof/cover、单元测试和toy
  集成；toy结果为`residual=0, exact=1, cycles=154`，四档Decaps输入/最大几何存储及运行时decoder
  装载/后检查边界包含在该门禁中。
- `make ci-kem-reference`：官方TRIKE-2/5/7/9 C KAT哈希、四档软件KEM自测，以及完整
  KeyGen/Encaps/Min-Sum Decaps参考链通过；KeyGen两种候选路径保持53,995,036拍。
- `make test-trike-decaps-synth-reference`：TRIKE160正常及`u/v/c2`篡改路径固定2,794,995拍并通过
  逐byte shared-secret golden。
- `make test-trike-decaps-runtime-synth-reference`：最大几何统一入口选择TRIKE160，正常及`u/v/c2`篡改
  均固定2,794,347拍并通过逐byte shared-secret golden。
- 同一目标逐档选择TRIKE256/384/512并运行有效及`c2`篡改路径，分别固定11,331,165、39,750,462和
  97,579,462拍；接受与拒绝SS均逐byte匹配项目golden。
- 四档统一K=4 seed-1 decoder：337,245/1,252,957/3,866,043/8,538,564拍，全部residual 0且exact 1。

2026-08-10发布门禁记录还包含：

- 默认K=4、`L=32`四档随机译码：固定周期与预算一致，`residual=0`、`exact=1`。

严格Verilator告警门使用[精确waiver文件](../../config/verilator_waivers.vlt)。waiver只覆盖已知的生成
fixture未用参数、testbench同步观察复位与DUT异步复位、以及显式未消费的测试输出；RTL规则保持启用。

## Vivado证据边界

16-bit digit poly-inv的Routed参考报告为2,138 LUT、833 FF、704 Slice、4 RAMB36和0 DSP。顶层
setup WNS/TNS为`-2.636 ns/-152.573 ns`，69个失败端点；最差路径从结果RAMB36直达输出端口。
同步register-output-pin到register-data-pin查询的内部setup WNS为`+0.447 ns`，最差为乘法状态高扇出
控制到置换bit计数器CE，数据路径8.832 ns且92.8%为布线；hold WHS/THS为`+0.018 ns/0`。
该报告未嵌入revision、`DIGIT_W`或XDC文件名，只作为16-bit候选的不可比物理参考。

16-bit digit KeyGen的Routed参考报告为46,441 LUT、54,731 FF、22,042 Slice、22 Block RAM Tile、
21 RAMB36、2 RAMB18和5 DSP。setup WNS/TNS为`+0.025 ns/0`，hold WHS/THS为`+0.049 ns/0`。
整体最差路径为`o_pk_valid`虚拟输出边界；报告中最差内部setup为`+0.040 ns`，位于秘密采样FSM到
reseed counter的fanout-1321控制网，数据路径9.864 ns且97.3%为布线，不属于稠密乘法部分积。
该报告同样未嵌入revision、`DIGIT_W`或XDC文件名，只作为不可比参考。固定profile Decaps和运行时统一
Decaps仍为`待测`。以下8-bit digit结果只作为历史物理参考。

2026-08-11的固定profile最大几何Decaps物理包络报告Fully Routed并满足100 MHz：63,386 LUT、60,521 FF、
25,759 Slice、635 Block RAM Tile、575 RAMB36、120 RAMB18、4 DSP，setup WNS/TNS为
`+0.033 ns/0`，hold WHS/THS为`+0.051 ns/0`。该结果见
[EXP-0084](../experiments/EXP-0084-four-profile-decaps-route.md)，对应`trike_decaps_synth_top`，不包含
运行时输入与流水线入口。
数据pin限定的同步register-to-register报告给出内部setup WNS `+0.635 ns`；最差路径位于decoder
`ram_m`读地址控制，96.98%的数据路径延迟来自布线。

2026-08-13的TRIKE-2窄I/O KeyGen报告Fully Routed并满足100 MHz：46,464 LUT、54,718 FF、
22,392 Slice、22 Block RAM Tile、21 RAMB36、2 RAMB18和5 DSP，setup WNS/TNS为`+0.025 ns/0`，
hold WHS/THS为`+0.001 ns/0`。同步数据路径WNS为`+0.600 ns`，最差路径位于弱密钥距离判定；该结果见
[EXP-0085](../experiments/EXP-0085-current-keygen-route.md)。

同日的TRIKE-2窄I/O Encaps报告Fully Routed并满足100 MHz：47,349 LUT、61,308 FF、24,349 Slice、
16.5 Block RAM Tile、15 RAMB36、3 RAMB18和4 DSP，setup WNS/TNS为`+0.025 ns/0`，hold WHS/THS为
`+0.014 ns/0`。同步数据路径WNS为`+0.441 ns`，最差路径位于共享SM3状态到L摘要寄存器；该结果见
[EXP-0086](../experiments/EXP-0086-current-encaps-route.md)。

单发射统一KEM ASIC的2026-08-25 Fully Routed诊断报告为136,358 LUT、132,627 FF、47,130 Slice、
646 Block RAM Tile、561 RAMB36、170 RAMB18和5 DSP。整体setup WNS/TNS为`-3.936 ns/-10583.756 ns`，
同步内部register-to-register WNS为`-3.529 ns`。内部最差路径位于KeyGen秘密采样FSM到
fanout约1322的状态控制网，仅1级LUT，98.0%数据路径延迟来自布线；Decaps support sorter存在
同类次级路径。整体最差路径位于输入边界到Decaps BRAM DI，与内部核时序分开评估。
async recovery WNS为`+0.148 ns`，hold WHS为`+0.049 ns`。该运行未记录source revision、compile defines和
XDC文件名，因此只作当前routed诊断，不与其他运行计算严格增减。详见
[EXP-0112](../experiments/EXP-0112-h4-index-map.md)。

每次新运行使用`RUN-YYYYMMDD-NN-<top>`标识，在
`reports/vivado/manifests/`提交运行manifest，原始`.rpt/.dcp`保存在
`D:/trike_reports/<run-id>/`。只有器件、Vivado、XDC、参数、`L/K`、存储几何、时钟和报告阶段一致的
Fully Routed结果才可更新[Vivado基线注册表](vivado_baseline_registry.md)。wrapper没有package pin约束，
因此核心100 MHz通过不等于板级I/O签核。

实现入口与产物说明见[项目工作流](../project_workflow.md)。固定profile Decaps最大档物理包络复测使用
`TRIKE_UNIFIED_PARAMS`、`BIKE_PARALLEL_L=32`、`BIKE_K_SIGN_K=4`、`BIKE_MSG_BITS=5`和
`BIKE_COLS_PER_TILE=256`，重置synthesis/implementation后重新运行`trike_decaps_synth_top`。新报告需
记录LUT/FF/Slice/BRAM/DSP、setup WNS/TNS、hold WHS/THS、未约束路径和关键routed path，再用
`cycles/Fmax`评价体系级延时。同步数据路径报告必须把起点限制为register output pin、终点限制为register
data pin，避免async recovery路径占满top-N列表。

运行时统一入口使用`make vivado-impl-trike-decaps-runtime`，综合定义保持
`TRIKE_UNIFIED_PARAMS/L32/K4/C256`。该目标生成完整post-route报告与checkpoint；形成物理结论前必须分配
新run ID并提交匹配manifest。

## 当前限制

- 官方TRIKE-2的`r=15581`与项目Min-Sum profile的`r=12589`是两个验证域；官方端到端Decaps KAT需要
  单独建立`r=15581`译码profile及DFR证据。
- `trike_kem_asic_top`包含公开operation单发射、全局SM3、H1/H2/H3向量、固定重量采样、H4结果存储和
  普通多项式乘法共享；KeyGen算术、序列化及其他跨阶段scratch RAM生命周期分配是独立资源收敛边界。
- `trike_decaps_runtime_synth_top`通过2-bit公开profile连接最大几何输入存储、运行时syndrome、统一decoder、
  decoder后检查和postprocess。四档具备有效与`c2`隐式拒绝完整KEM golden；u/v非收敛RTL深测覆盖TRIKE160，
  其余三档由软件golden和分层运行时RTL测试覆盖。
- 运行时综合入口没有Vivado placed/routed结果；EXP-0084的资源与时序只适用于固定profile
  `trike_decaps_synth_top`最大物理包络。
- 当前Min-Sum端到端向量证明功能闭环、固定周期和隐式拒绝，不构成有限样本之外的DFR/FLS结论。
- KeyGen、Encaps和完整Decaps的板级接口还需要真实pin与I/O delay约束。

## 实现判据

1. 固定调度只依赖公开参数；秘密数据、收敛和失败路径不改变访问次数或状态深度。
2. 功能验证分别报告golden、固定周期、residual和隐式拒绝；其中一项不能代替另一项。
3. 物理比较必须保持器件、Vivado、XDC、参数、并行度、存储几何和报告阶段一致。
4. 资源同时报告LUT、FF、Slice、Block RAM Tile、RAMB36、RAMB18和DSP。
5. 时序以routed setup/hold和真实约束为准；逻辑bit数、实例数或综合结构不等同于物理收益。
