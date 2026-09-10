# 一层 Karatsuba-Comba 与直接循环折叠

生产稠密乘法使用一层整多项式 Karatsuba、单路 Comba 和 64-bit 基础乘法器内部两层
Karatsuba。`trike_poly_mul_core`和`trike_poly_inv_core`共用
`trike_poly_mul_karatsuba_core`；FFT不在当前选型范围内。物理验收仍需同条件Vivado。

## 接口与 RAM 生命周期

`W=ceil(r/WORD_W)`、`H=ceil(W/2)`。系数在GF(2)，bit 0对应常数项，运算为
`A*B mod (x^r-1)`。默认`WORD_W=64`、`BASE_KARATSUBA_DEPTH=2`（非64-bit默认仍为1）。

- 通用乘法核接收W个A word和W个B word，再计算、输出W个结果。稀疏模式接收公开数量的
  support index替代A流；两种模式共用B和结果RAM。数据存储为`3W`个word及index RAM。
- 求逆核保持`f/g/t`三份scratch。置换固定执行`2r`拍；乘法期间`f`或`t`作为A，`g`作为B，
  独立W-word累加RAM保存结果。数据容量为`4W`个word，乘法器没有输入复制RAM。
- 外部操作数绑定需要两份独立、可写的RAM，均为一拍同步读、read-first。乘法期间调用方
  让出读写所有权，不能并行观察或修改操作数。结果输出之前，两份输入均已恢复。
- 独立流式实验绑定使用A/B高低半bank，容量`4H+W`。它与生产绑定使用同一折叠/Comba核，
  不代表求逆或统一KEM的物理容量。
- 复位清控制，不清RAM；新事务固定清整个活动结果区，流式装载覆盖活动输入区。
  busy期间忽略start；输出背压保持valid/data/last，最后一个结果被接受后结束事务。

统一服务在idle接受start时锁存公开的r、word数及稀疏weight，后续输入端变化不影响当前事务。
奇数W的虚拟高半末word使用固定地址0的dummy读并强制数据为零；末word屏蔽padding。

## 原地交叉项扫描

外部RAM绑定依次完成：

1. Comba计算低积`Z0=A0B0`、高积`Z2=A1B1`，直接折叠到结果RAM。
2. 固定H次`READ_LOW -> READ_HIGH -> WRITE_LOW`，并行对A/B写入`low XOR high`。
   高半区不改写，只增加两个word寄存器暂存低半读取值。
3. 用低半区的临时和计算`Zs=(A0 XOR A1)*(B0 XOR B1)`。
4. 再执行相同H次扫描。由于`(low XOR high) XOR high = low`，原操作数恢复。
5. 才开始结果输出或覆盖求逆的目标`f/t`。

每次扫描3H拍，两次共6H拍，不增加RAM读端口或复制操作数。
写回、虚拟高半处理及恢复扫描均只由公开几何和阶段决定，不因数据为零跳过。

## 重组和循环归约

| 子积 | 混入偏移（word） |
| --- | --- |
| Z0 | 0、H |
| Z2 | 2H、H |
| Zs | H |

每个完成的Comba word立即混入W-word结果RAM。低半末word的高位回卷到地址0；
高半word按`WORD_W-LAST_BITS`和`LAST_BITS`移位，最多贡献两个结果word。
补齐的单个重组项可能超过2r位，但完整乘积次数不超过`2r-2`：对每项一致截断至低2r位
再线性归约，不能反复回卷填充项。超出范围的贡献固定写零到地址0，末word始终掩码。

结果访问为`READ0 -> WRITE0 -> [READ1 -> WRITE1]`。第二组访问只取决于公开几何；
即使两片落入同址，后一次读取也在前一次写入之后，不依赖同拍RAW或旁路。

## Comba与折叠重叠

单路Comba生产下一条对角线时，折叠器顺序处理上一word。完成但尚未接收的
对角线保留在原有low/high累加寄存器中；折叠器接收时才推进对角线并传递高字。
两者仅交换一个word及其公开索引，无FIFO RAM、无新增操作数端口，并删除独立carry暂存寄存器。
折叠器忙时生产者固定等待，生产者尚未完成时折叠器固定等待；等待只取决于公开对角线长度。
最后carry word折叠完成后才切换相位、执行原地XOR/恢复或输出。结果RAM仍保持原顺序RMW，
因此不引入新的同拍同址读取，也不改变每事务的有效读写次数。

## 稀疏读写重叠

稀疏路径每个support-word固定执行FETCH_B、PREPARE、READ0、WRITE0/READ1、
WRITE1/READ2、WRITE2，共6拍。三组结果读写均保留，读写次数分别为3dW；
计入清零和输出后各为3dW+W。相邻访问同址时使用上一拍写回值转发，避开read-first旧值。
新增一个WORD_W位转发寄存器，不新增RAM；地址相等比较只选择数据，不改变调度。
详见[EXP-0124](../experiments/EXP-0124-sparse-rmw-overlap.md)。

## 固定周期和访问数

令`J(a)=length([a,a+2H-1] ∩ [W-1,2W-2])`。r按word对齐时`S=0`，否则
`S=J(0)+3J(H)+J(2H)`。令`ell(j)=min(j+1,2H-1-j)`，偏移集合`O0={0,H}`、`O1={2H,H}`、`O2={H}`。
对实际对角线k，`m(p,k)`为该word的RMW次数：每个偏移贡献一次，非word对齐且
`W-1 <= k+offset <= 2W-2`时再贡献一次。计算与折叠隐藏的拍数为
`Delta=sum(p=0..2,k=0..2H-3) min(2*m(p,k)+1,ell(k+1)+1)`；H=1时空和为0。
以下均为连续握手的busy拍数，不计idle接受start前的拍：

| 边界 | 周期 |
| --- | --- |
| 独立半bank流式核 | `3H²+32H+5W-3+2*(W mod 2)+2S-Delta` |
| 外部操作数核（含恢复、输出） | `3H²+38H+3W-3+2S-Delta` |
| 通用乘法核稠密模式（含装载和控制） | `3H²+38H+5W-1+2S-Delta` |
| 通用乘法核稀疏模式，weight=d | `4W+2d+6dW` |

生产绑定中，每份操作数计算期读`3H²+4H`次、写`2H`次；通用核另有W次输入写入。
结果RMW次数为`M=10H+S`；累加RAM总读、总写均为`M+W`（输出读取、初始化清零）。
外部等待拍只延长握手，不改变计算访问数。求逆在每次子乘法最终写回边沿推进，
总周期为`3W+2r*置换次数+乘法次数*(外部操作数核周期+1)`。

## 本地验证与复现

以下是按验证边界选择的复现入口，不要求逐项执行；命令加`./eda`前缀。

- `make test-trike-poly-mul-core test-trike-poly-inv-core`：卷积/求逆及固定周期。
- `make test-trike-poly-mul-runtime`：13次公开几何选择、75个事务，覆盖输入/输出停顿、
  padding、大小参数切换、稀疏模式切换、有效访问轨迹和原地操作数恢复。
- `make test-trike-poly-karatsuba-core`：独立半bank绑定13种几何，每种13个事务。
- `make test-trike-fold-profiles`：由`scripts/run_trike_fold_profiles.py`生成独立golden，
  默认运行乘法/求逆代表几何，`VALIDATION_PROFILE_SET=all`显式选择全部几何；结果与源文件哈希写入build目录。
  这些seed卷积/求逆样本不是官方KAT或DFR证据。
- `make ci-kem-reference`：官方TRIKE-2 KeyGen、Encaps及项目Decaps相关参考门禁。
  运行时Decaps入口为`./eda make test-trike-decaps-runtime-profiles-reference`，默认最小/最大代表档；显式全四档加`VALIDATION_PROFILE_SET=all`。

2026-09-10将64-bit基础核默认递归深度从1改为2，外层仍为一层；未增加流水寄存器，
RAM绑定、固定访问与周期公式不变。基础核、运行时、独立折叠核及官方乘法/求逆参考测试通过，
当时通用稠密乘法和求逆为51,733与1,432,796拍（下述重叠改动之前）。同条件r15581本地Yosys/ABC9估计：
通用乘法LUT primitive总数4,438→4,162，FF=1,162、RAMB36=3、RAMB18=1不变；
求逆综合wrapper LUT 3,822→3,547，FF=878、RAMB36=4不变。
这不是Vivado时序或加速证据，历史depth-1记录保留。
命令、源文件哈希和日志见[基础核集成证据](../../reports/qor/20260910-trike-base-depth2.json)。

2026-09-10进一步启用Comba/折叠重叠。r15581的`Delta=4294`，通用乘法47,439拍，
求逆1,359,798拍；KeyGen算术/core为2,919,579/7,752,441拍，Encaps core为527,684拍。
小几何固定轨迹、运行时、官方乘法/求逆与调用方测试通过，最小/最大乘法几何
r12589/r106781分别31,677/2,110,141拍。相对上述depth-2串行调度，同条件本地估计：
通用乘法LUT 4,162→4,102、FF 1,162→1,101；求逆wrapper LUT 3,547→3,478、FF 878→817；
各自BRAM不变。未建立Vivado时序或整乘法器形式证明。
详细条件与测试日志见[重叠集成证据](../../reports/qor/20260910-trike-comba-overlap.json)。

准确的已完成结果与比较记录见[EXP-0123](../experiments/EXP-0123-trike-k1-cyclic-fold.md)。
仿真检查固定周期及测试覆盖下的轨迹，未建立整个乘法器的形式证明。

## Vivado 物理验收

本机没有Vivado，`NOT_RUN`。Yosys的generic RAM估计不能替代XPM和布局布线结果。
直接使用Windows Tcl Console或batch入口，对同一边界的基线/当前源码分别运行：

```tcl
set TRIKE_KEM_SYNTH_TOP trike_poly_inv_synth_top
set VIVADO_PART xc7k355tffg901-2L
set VIVADO_XDC constraints/trike_kem_core.xdc
set VIVADO_SYNTH_DIRECTIVE Default
set VIVADO_PLACE_DIRECTIVE Explore
set VIVADO_PHYS_OPT_DIRECTIVE Explore
set VIVADO_ROUTE_DIRECTIVE Explore
# 先设置本机 VIVADO_REPORT_ROOT 和唯一的 VIVADO_RUN_ID
source scripts/vivado_trike_kem_cores.tcl
```

集成前源码为`7c7b75d327ebada3beda2ce1cf1cae02b60c30ca`。在独立源码副本中复测，保持器件、
Vivado、XDC、公开参数、defines和directive一致，记录源文件哈希及每次RUN manifest。
求逆、KeyGen、统一KEM分别比较LUT/FF/Slice/BRAM/DSP、内部setup/hold与I/O路径，
最终比较实际周期和可实现时钟。当前功能集成不更新历史物理基线。
