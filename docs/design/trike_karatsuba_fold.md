# 一层 Karatsuba-Comba 循环折叠候选

`trike_poly_mul_karatsuba_core`采用一层整多项式Karatsuba、单路Comba和64-bit基础乘法器
内部一层Karatsuba。该候选的循环折叠功能和固定周期已通过局部验证；同条件Vivado、
求逆接口和统一KEM集成仍为`NOT_RUN`。FFT不在当前选型范围内。

## 行为与存储契约

- 运算：`A*B mod (x^r-1)`，系数在GF(2)，bit 0对应常数项。
- `R_BITS>=2`；默认`WORD_W=64`、`BASE_KARATSUBA_DEPTH=1`。
  word宽必须可被基础递归拆分；参数在elaboration时固定。
- `W=ceil(r/WORD_W)`、`H=ceil(W/2)`；A/B各占两个`H`-word bank。
  奇数W的高半末word固定补零，输入末word屏蔽无效高位。
- `i_start`在idle采样；依次接收W个A word和W个B word。busy期间的start不启动新事务。
  计算结束后输出W个结果word，最后一个被接受的边沿置`o_done`并退出busy。
- `o_result_valid && !i_result_ready`期间保持data/last。外部握手停顿增加等待拍；
  计算期没有数据相关等待、提前退出或收敛判断。
- 低有效复位清控制和局部寄存器，RAM不复位；每次事务固定清零整个结果RAM。
- 结果RAM独立于输入bank，直到全部子积完成才开放输出，输入不会被提前覆盖。

逻辑存储为`4H+W`个word。旧的一层实现为`8H+W`，差额是删除的`4H`-word完整乘积RAM。
结果RAM本身仍必须保留；40%左右的逻辑bit节省不等于相同比例的物理BRAM节省。

## 重组与归约

令`h=H*WORD_W`，依次用同一Comba计算`Z0=A0B0`、`Z2=A1B1`、
`Zs=(A0 XOR A1)*(B0 XOR B1)`，按以下公开偏移混入结果：

| 子积 | 偏移（word） |
| --- | --- |
| Z0 | 0、H |
| Z2 | 2H、H |
| Zs | H |

每个完成的Comba word立即折叠。最后一个低半word分为末word低位和地址0的回卷高位；
高半word使用固定的`WORD_W-LAST_BITS`左移与`LAST_BITS`右移，最多贡献两个结果word。
末word始终掩码。超过结果范围的贡献固定写零到地址0，不依据数据省略事务。

重要边界：补齐后的单个Karatsuba重组项可能超过`2r`，但完整乘积次数不超过`2r-2`。
因此可以先对**每个重组项一致截断到低2r位**，再线性折叠，而不能无条件把这些填充项
再次模r回卷。RTL的地址范围检查和末word掩码实现这个截断。

结果访问严格为`READ0 -> WRITE0 -> [READ1 -> WRITE1]`，然后处理另一重组项或下一word。
第二次RMW仅由公开地址/几何决定。即使`W=1`、两片落入同址，后一次读也发生在前一次
写之后，符合`ram_bram`的一拍同步读、read-first语义，不依赖同拍RAW行为或旁路。

## 固定周期与访问数

令`J(a)`为整数区间`[a,a+2H-1]`与`[W-1,2W-2]`的交集长度。
当r按word对齐时`S=0`；否则`S=J(0)+3J(H)+J(2H)`。

连续输入/输出的busy周期（不包含idle接受start前的周期）为：

`T = 3H² + 32H + 5W - 3 + 2*(W mod 2) + 2S`。

每个操作数bank读取`3H²`次；结果RMW次数`M=10H+S`；结果总读数和总写数均为`M+W`
（分别包含输出读取与初始化清零）。外部停顿不改变这些访问总数。

| r | 旧一层周期 | 折叠周期（RTL实测） | 逻辑word容量：旧→折叠 |
| ---: | ---: | ---: | ---: |
| 12589 | 34542 | 34555 | 989→593 |
| 15581 | 50993 | 50999 | 1220→732 |
| 30389 | 182299 | 182312 | 2379→1427 |
| 63773 | 772942 | 772955 | 4989→2993 |
| 106781 | 2135086 | 2135099 | 8349→5009 |

r15581使用官方TRIKE-2派生golden；其余四档使用固定seed的独立GF(2)卷积，不能称为官方KAT。
旧r15581周期在本任务修改前复测，其余旧周期由原TB公式计算。

## 验证与复现

`make test-trike-poly-karatsuba-core test-trike-poly-karatsuba-reference`是已有定向入口。
前者涵盖13种几何、每种13个事务，包括单word、对齐/非对齐、奇偶word、输入脏padding、
连续事务及输入/输出停顿；检查卷积、固定周期、RAM次数、逐拍数据无关地址轨迹和输出稳定。
`make check-rtl`及独立Slang候选top检查通过。没有声称形式证明或完整KEM通过。

四档全尺寸fixture可从已检入的卷积helper复现（仓库根目录，先source `scripts/eda-env.sh`）：

```python
from pathlib import Path
import random, sys
sys.path.insert(0, 'scripts')
from trike_fixture_utils import cyclic_multiply, format_word_array, words_from_bytes
for r in [12589, 30389, 63773, 106781]:
    rng = random.Random(20260907 + r)
    w, nb = (r + 63) // 64, (r + 7) // 8
    a, b = rng.getrandbits(r), rng.getrandbits(r)
    p = cyclic_multiply(a, b, r)
    dest = Path(f'build/karatsuba-fold/r{r}/generated/trike_poly_mul_reference_case.svh')
    dest.parent.mkdir(parents=True, exist_ok=True)
    lines = [f'localparam int REF_R_BITS={r};', 'localparam int REF_WORD_W=64;',
             f'localparam int REF_WORDS={w};']
    for name, value in [('REF_DENSE_A', a), ('REF_DENSE_B', b), ('REF_DENSE_RESULT', p)]:
        lines += format_word_array(name, words_from_bytes(value.to_bytes(nb, 'little'), w),
                                   width='REF_WORD_W-1:0')
    dest.write_text('\n'.join(lines) + '\n')
```

对每个r运行下面命令。必须同时覆盖fixture搜索目录和`VERILATOR_MDIR`，使编译和执行使用同一实例：

```sh
for fold_r in 12589 30389 63773 106781; do
  fold_dir="build/karatsuba-fold/r${fold_r}"
  make test-trike-poly-karatsuba-reference \
    TRIKE_POLY_REFERENCE_FIXTURE="$fold_dir/generated/trike_poly_mul_reference_case.svh" \
    VERILATOR_MDIR="$fold_dir/obj" \
    VERILATOR_FLAGS="--binary --sv -Wall -I./$fold_dir -I./tb -I./rtl config/verilator_waivers.vlt --Mdir $fold_dir/obj"
done
```

## 物理和集成边界

同次本地Yosys比较记录在[结构估计](../../reports/qor/20260907-trike-karatsuba-fold.json)。
使用`read_slang --no-synthesis-define`选择generic RAM，再运行`synth_xilinx -family xc7`。
默认SYNTHESIS/XPM分支在本地缺少`xpm_memory_sdpram`定义，不能当成已通过的路径。

| 本地xc7估计 | r15581：前→后 | r106781：前→后 |
| --- | ---: | ---: |
| LUT primitives | 3200→3164 | 3457→3208 |
| FF | 627→520 | 633→520 |
| RAMB36E1 | 6→5 | 19→12 |
| Estimated LC | 2429→2487 | 2645→2546 |
| CARRY4 | 87→106 | 90→106 |

大几何中BRAM估计减少36.8%；小几何Estimated LC反而增加。两者都不能推出布线后Fmax。
复现大几何综合时，在相同的`LOCAL_SYNTH_SOURCES`中加入`-G R_BITS=106781`，
其余源码、前端选项和`xc7`映射条件保持一致；基线与候选使用不同构建目录。

Windows Vivado Tcl Console可用已有统一入口运行r15581默认候选：先配置本机报告目录，
为本次实际运行分配未使用的RUN ID，再执行以下配置。器件、XDC和directive必须与基线一致。

```tcl
set TRIKE_KEM_SYNTH_TOP trike_poly_mul_karatsuba_core
set VIVADO_PART xc7k355tffg901-2L
set VIVADO_XDC constraints/trike_kem_core.xdc
set VIVADO_SYNTH_DIRECTIVE Default
set VIVADO_PLACE_DIRECTIVE Explore
set VIVADO_PHYS_OPT_DIRECTIVE Explore
set VIVADO_ROUTE_DIRECTIVE Explore
source scripts/vivado_trike_kem_cores.tcl
```

基线是`3d2e0ba548de620c2fac317cc571105f6172b12a`的未折叠一层核；在独立源码副本中
使用同一入口/约束复测，不覆盖当前工作区。记录两次实际RTL/XDC/Tcl哈希与每次RUN manifest，
不得把旧EXP-0118缺provenance的报告升级为可比基线。分别看内部setup/hold和顶层I/O路径，
报告LUT、FF、Slice、BRAM Tile、RAMB36/18、DSP、WNS/TNS/WHS。

通过物理比较后再完成已授权的求逆/统一KEM集成：分bank读取必须接入现有`f/g/t`生命周期，
不能无条件复制整套输入RAM；统一服务须支持公开运行时几何和现有稀疏模式。当前候选的
静态stream接口不能直接替代外部RAM乘法接口。集成时重算系统周期并运行对应完整门禁。
