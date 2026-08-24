# EXP-0108：KeyGen算术与序列化共用结果RAM

## 目标与假设

KeyGen算术核内部的`t0`与`numerator/r2`在固定结果重放后复制到外层输出RAM。算术、结果重放和
PK/SK序列化严格串行，外层两组244x64-bit持久RAM可直接承担全部工作与输出生命周期。

## 硬件边界

- `trike_keygen_arith_core`支持本地或外部`t0`、`numerator/r2`同步store。
- `trike_keygen_core`固定选择外部模式，把算术读写端口连接到持久`t0/r2`输出RAM。
- 算术结果重放维持相同valid/ready周期，并向同一RAM执行固定最终写回。
- H123、inverse、求逆核scratch及support输出RAM不属于本实验。

## 验证与量化结果

- 小几何算术本地/外部store配置均通过逐word golden，固定928拍。
- 官方算术本地store reference保持49,162,174拍并匹配`t0/r2`逐word golden。
- KeyGen四种共享服务组合及两种秘密候选路径使用外部store，固定53,995,036拍并通过PK/SK byte golden。
- 8-bit窄I/O wrapper固定54,002,607拍并通过PK/SK byte golden。
- 统一层次算术核只展开external result store分支，外层恰好包含两组持久结果RAM。

## 结论

方案保留。KeyGen算术与输出层的四组逻辑结果RAM收敛为两组，减少31,232 bit逻辑存储；实际
RAMB36/RAMB18、地址mux、LUT/FF、WNS和`cycles/Fmax`等待统一ASIC Vivado placed/routed报告。
