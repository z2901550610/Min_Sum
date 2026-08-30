# EXP-0122：TRIKE Bernstein-Yang divstep架构锚点

- 日期：2026-08-28
- 状态：`pending`
- 参数域：官方TRIKE-2，`r=15581`、`b=64`；局部RTL以`s=1/8`验证

## 目标与结构

建立二元多项式Bernstein-Yang求逆的独立正确性与并行更新边界，不接入KeyGen或当前addition-chain核。
黄金模型以`f=x^r+1`、bit-reversed输入和`delta=1`初始化，固定执行`2r-1`个divstep；
`f/g`低次方向右移，`v/w`高次方向左移，状态均保留`r+1`位。

RTL分成两级：`s=1`原语作为分支语义锚点；可参数化control generator一次生成`s`组
`swap/alpha`，word update接收广播控制并更新局部`f/g/v/w`窗口。该分离允许后续独立改变BRAM扫描调度。

## 验证与结果

- Python对`r=13`全部4095个可逆输入穷举，并对一个确定性`r=15581`输入与Euclid golden对拍通过。
- `s=1,b=64`定向/随机1059例通过；W2/W8组合形式化证明通过，swap、alpha无swap和alpha=0均有cover。
- `s=8,b=64` control与word-update定向/随机2049例通过；未实例化全长多项式RAM。
- 按Racing BIKE式(3)、`b=64,d=2,u=8`的未集成周期投影：`s=1/2/4/8/16`
  分别为7,760,079 / 3,880,411 / 1,948,492 / 982,534 / 501,378拍。
- 上述周期是公开调度模型，不是本RTL实测；`s=1`在论文中另有专用存储调度，不能直接用该点做物理比较。

## 结论

算法位序、`r+1`状态宽度、固定`2r-1`边界和`s=8`广播更新接口已形成局部锚点。
下一结构变量是`b=64,s=8`四多项式BRAM扫描器：验证首末word padding、相邻word携带、固定访问次数、
全尺寸inverse golden和实测周期；形成独立求逆top后再运行Vivado，不接入完整KEM。

## 收口判据

扫描器完成后，以同一器件、Vivado版本、XDC、时钟、接口和Fully Routed阶段，与EXP-0120独立求逆top
比较固定周期、`cycles/Fmax`、LUT/Slice、RAMB36/RAMB18和内部同步WNS。进入面积、延时或存储的
Pareto前沿则保留为候选；若所有维度均被addition-chain点支配，则归档本路线。缺少完整provenance、
全尺寸golden、固定访问计数或routed报告时保持`pending`，不接入KeyGen。
