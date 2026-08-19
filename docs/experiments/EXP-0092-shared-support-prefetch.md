# EXP-0092：Decaps共享support固定预取

- 日期：2026-08-17
- 状态：`retained`
- 配置：最大输入RAM，三块support，运行时公开`r/w`

## 目标与边界

用一个同步读口把最大输入存储的全部`3w`项连接到H0 syndrome装载和decoder support排序。该实验覆盖
输入装载、syndrome生成与decoder装载边界，不包含decoder运算、error writer、residual或postprocess。

## 实现

`trike_decaps_support_prefetch`逐项执行FETCH/DATA。首块`w`项只有在syndrome H0和完整H排序器同时ready
时才原子发送，另外两块只发送给排序器；valid等待期间保持RAM输出，不重复读取。

syndrome operand预取支持外部H0模式，t0/u/v使用各自RAM读口。`trike_decaps_input_decoder_load_core`
在完整`SK || CT`装载后同时启动support预取、运行时syndrome和运行时decoder装载桥。

## 验证与结论

小几何`w=1/3/5`每项只读一次，理想ready周期分别为7/19/31拍，两套payload成对相等。项目TRIKE160
最大RAM实例接受8,386 byte，输出105项块内升序H、写入12,589个syndrome bit并产生一次decoder start；
两套payload逐项golden通过且固定1,361,944拍。`make check-rtl`通过。

共享support预取边界保留；完整decoder连接、较大三档长回归和Vivado资源/时序为`待测`。
