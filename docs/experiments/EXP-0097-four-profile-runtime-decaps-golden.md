# EXP-0097：四档运行时Decaps端到端golden

- 日期：2026-08-18
- 状态：`retained`
- 基线：EXP-0096
- 配置：`trike_decaps_runtime_synth_top`，L=32，K=4，C=256，8-bit I/O

## 目标与边界

为四个项目Min-Sum profile生成完整`SK || CT`、接受SS和隐式拒绝SS，并在统一最大几何RTL上测量
公开profile固定周期。输入连续供给，SS持续ready；每次复位执行一项事务。

## 改动边界

生成器从共享四档decoder参数取得`r/w/t/C/alpha`，按档使用weak-key阈值。大输入通过逐byte hex fixture
加载，避免仿真器超大数值常量限制。RTL数据通路、RAM几何和调度不变。

## 验证

| Profile | `r/w/t` | 输入byte | RTL固定周期 | 100 MHz延时 |
| --- | --- | ---: | ---: | ---: |
| TRIKE160 | 12589/35/263 | 8,386 | 4,743,324 | 47.43324 ms |
| TRIKE256 | 30389/55/429 | 19,751 | 19,970,378 | 199.70378 ms |
| TRIKE384 | 63773/83/659 | 40,952 | 71,565,719 | 715.65719 ms |
| TRIKE512 | 106781/111/877 | 68,168 | 177,759,567 | 1.77759567 s |

四档seed-1软件golden均为candidate 0、有效路径`residual=0`且精确恢复；u/v/c2首bit篡改均输出对应
隐式拒绝SS。RTL逐档有效与c2篡改路径逐byte匹配且周期相等；TRIKE160另通过u/v两条非收敛路径。

## 结论

四档运行时Decaps端到端golden与公开固定周期边界保留。u/v高档RTL深测、运行时顶层Vivado资源与时序
不属于本实验的完成证据。
