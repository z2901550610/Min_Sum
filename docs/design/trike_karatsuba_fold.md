# 一层 Karatsuba-Comba 与直接循环折叠

生产稠密乘法使用一层整多项式 Karatsuba、单路 Comba 和 64-bit 基础乘法器内部一层
Karatsuba。`trike_poly_mul_core`和`trike_poly_inv_core`共用
`trike_poly_mul_karatsuba_core`；FFT不在当前选型范围内。物理验收仍需同条件Vivado。

## 接口与 RAM 生命周期

`W=ceil(r/WORD_W)`、`H=ceil(W/2)`。系数在GF(2)，bit 0对应常数项，运算为
`A*B mod (x^r-1)`。默认`WORD_W=64`、`BASE_KARATSUBA_DEPTH=1`。

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

## 固定周期和访问数

令`J(a)=length([a,a+2H-1] ∩ [W-1,2W-2])`。r按word对齐时`S=0`，否则
`S=J(0)+3J(H)+J(2H)`。以下均为连续握手的busy拍数，不计idle接受start前的拍：

| 边界 | 周期 |
| --- | --- |
| 独立半bank流式核 | `3H²+32H+5W-3+2*(W mod 2)+2S` |
| 外部操作数核（含恢复、输出） | `3H²+38H+3W-3+2S` |
| 通用乘法核稠密模式（含装载和控制） | `3H²+38H+5W-1+2S` |
| 通用乘法核稀疏模式，weight=d | `4W+2d+8dW` |

生产绑定中，每份操作数计算期读`3H²+4H`次、写`2H`次；通用核另有W次输入写入。
结果RMW次数为`M=10H+S`；累加RAM总读、总写均为`M+W`（输出读取、初始化清零）。
外部等待拍只延长握手，不改变计算访问数。求逆在每次子乘法最终写回边沿推进，
总周期为`3W+2r*置换次数+乘法次数*(外部操作数核周期+1)`。

## 本地验证与复现

先在仓库根目录执行`source scripts/eda-env.sh`。

- `make test-trike-poly-mul-core test-trike-poly-inv-core`：卷积/求逆及固定周期。
- `make test-trike-poly-mul-runtime`：13次公开几何选择、51个事务，覆盖输入/输出停顿、
  padding、大小参数切换、稀疏模式切换、有效访问轨迹和原地操作数恢复。
- `make test-trike-poly-karatsuba-core`：独立半bank绑定13种几何，每种13个事务。
- `make test-trike-poly-kernel-matrix`：由`scripts/run_trike_fold_profiles.py`生成独立golden，
  运行五档项目/参考乘法几何和五档受支持求逆几何；结果与源文件哈希写入build目录。
  这些seed卷积/求逆样本不是官方KAT或DFR证据。
- `make ci-kem-reference`：官方TRIKE-2 KeyGen、Encaps及项目Decaps相关参考门禁。
  完整运行时四档Decaps入口为`make test-trike-decaps-runtime-four-profile-reference`。

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
