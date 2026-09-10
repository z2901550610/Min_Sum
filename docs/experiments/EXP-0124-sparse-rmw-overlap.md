# EXP-0124：稀疏乘法重叠读写与同址转发

日期：2026-09-09。基线：`a17f0f1`。状态：本地功能保留，Vivado NOT_RUN。

## 假设与实现

既有SDP结果RAM可在同一拍读、写。保持每个support-word的三组RMW，
把WRITE0与READ1、WRITE1与READ2重叠，内层8拍降为6拍：
`FETCH_B -> PREPARE -> READ0 -> WRITE0/READ1 -> WRITE1/READ2 -> WRITE2`。
总连续握手周期由`4W+2d+8dW`变为`4W+2d+6dW`。

read-first同址读写会返回旧值，因此用一个WORD_W位寄存器保存刚提交的写回值。
WRITE1比较地址1与地址0，WRITE2比较地址2与地址1，相等则选择转发值。
若地址2只与地址0相等，READ2发生在WRITE0之后，RAM已经包含更新；不需要第二级历史转发。
首项读取前已完成前一个support-word的写回，跨word无需额外旁路。

固定三读三写，不按贡献是否为零或地址相等跳过；各为`3dW`次，计入清零/输出后
结果RAM读写各`3dW+W`次。地址仍由原有循环移位规则计算，秘密index可影响地址，
但不影响周期和访问次数；本实验不宣称稀疏地址轨迹与index无关。
保留原结果RAM，不改ram_bram或其他ram_accum；新增一个word寄存器及地址比较/数据选择。

## 实测周期

| 边界 | 基线8拍 | 当前6拍 |
| --- | ---: | ---: |
| TRIKE-2稀疏乘法，W=244、d=35 | 69366 | 52286 |
| KeyGen算术reference | 3095537 | 3078457 |
| KeyGen core基础reference | 7928399 | 7911319 |
| Encaps core基础reference | 2378447 | 1865071 |
| syndrome基础/共享乘法reference | 123123 | 106043 |
| 小几何UV，内部/外部store | 424 | 344 |
| 小几何KeyGen算术，内部/外部stores | 967 | 961 |

每次稀疏乘法减少`2dW`拍。KeyGen和syndrome各一次d=35、W=244，减少17080拍；
Encaps四次d=263、W=244，减少513376拍。TRIKE-2稠密仍为51733拍。
wrapper周期按同样差额更新测试预算：KeyGen 7918890、Encaps 1871045；本轮wrapper未实测。

## 验证及复现

以下已完成，均为本地仿真/静态检查：

- `./eda make check-fast`，任务文件format和`git diff --check`通过。
- `./eda make test-trike-poly-mul-core test-trike-poly-mul-runtime`：75个运行时事务，
  13次几何选择；word对齐/非对齐、单word、多word、padding、背压、大小切换、无效index，
  74次非零同址读写；独立golden、精确周期/访问数及相同index下不同数据的轨迹比较通过。
- `./eda python3 scripts/run_trike_fold_profiles.py --suite multiply --profiles representative --build-dir build/sparse-overlap-profiles`：
  r12589/106781独立seed卷积参考通过，d=3稀疏周期4340/36724；稠密35149/2140109保持不变。
- `./eda make test-trike-poly-reference test-trike-encaps-uv-core test-trike-encaps-uv-core-external-store test-trike-keygen-arith-core test-trike-keygen-arith-core-external-stores test-trike-decaps-syndrome-runtime test-trike-keygen-arith-reference test-trike-decaps-syndrome-reference test-trike-encaps-core-reference-base test-trike-keygen-core-reference-base`：
  算术word golden、Encaps CT/SS和KeyGen PK/SK byte golden通过。

日志：`build/sparse-overlap-unit.log`、`build/sparse-overlap-integration.log`、
`build/sparse-overlap-profiles.log`、`build/sparse-overlap-bindings.log`。
代表几何选择不构成全档验证；未运行的中间几何、完整Decaps、KeyGen替代候选/其他共享配置和wrapper为NOT_RUN。
本模块没有现成受影响的形式证明，本轮未新增生产形式证明（NOT_RUN）。
Vivado和本轮Yosys资源/频率测量均NOT_RUN；不沿用EXP-0123综合数字作为新版本物理证据。
6拍相对8拍节省25%内层周期，实际延时和转发选择路径的时序代价需同条件Vivado确认。
