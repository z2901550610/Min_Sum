# EXP-0109：KeyGen算术复用stage support视图

## 目标与假设

KeyGen顶层与算术核分别保存三组35项support。秘密采样结束后，算术和SK序列化按公开FSM串行执行，
顶层寄存视图可直接作为算术核只读输入，不需要算术核内的第二份寄存副本。

## 硬件边界

- `trike_keygen_arith_core`支持本地support存储或外部packed只读视图。
- `trike_keygen_core`固定选择外部模式，唯一寄存视图同时服务算术稀疏操作和`h0`稠密序列化。
- 32-bit support顺序输出RAM及其同步fetch状态保留，维持SK输出的时序隔离边界。
- support装载、算术操作数数量、RAM访问次数与PK/SK输出顺序只由公开参数和FSM决定。

## 验证与量化结果

- 小几何算术本地support、本地/外部result及外部support/result三种配置均匹配golden，固定928拍。
- 官方算术本地support reference匹配`t0/r2`逐word golden，固定49,162,174拍。
- KeyGen四种共享服务组合及两种秘密候选路径通过PK/SK byte golden，固定53,995,036拍。
- 8-bit窄I/O wrapper通过PK/SK byte golden，固定54,002,607拍。
- 统一层次结构门禁确认算术核只展开external support store分支。

## 结论

方案保留。官方TRIKE-2统一KeyGen层次减少`3*35*14=1,470 bit`逻辑寄存存储；顺序输出RAM避免把
105项动态选择路径接到SK输出。实际FF/LUT、RAMB、扇出、WNS和`cycles/Fmax`等待Vivado placed/routed复测。
