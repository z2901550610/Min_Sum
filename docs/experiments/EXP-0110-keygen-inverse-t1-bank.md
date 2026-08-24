# EXP-0110：KeyGen inverse复用H123 t1 bank

## 目标与假设

KeyGen算术使用独立244x64-bit RAM保存两次inverse。第一次分母输入完整装载后，H123 `t1`原值没有
后续消费者；其bank可依次保存两次inverse，并在下一笔H123事务由固定vector流完整重装。

## 硬件边界

- `trike_keygen_arith_core`把inverse结果写入`t1` bank，并从同一同步读口提供后续乘法操作数。
- 本地H123配置复用算术核内`t1` RAM；统一ASIC通过外部写口复用共享H123 store的`t1` RAM。
- `trike_h123_vector_store`为`t1`增加固定scratch写口，vector重装与scratch写入由公开阶段互斥。
- `t2/r1`、两组持久结果RAM、求逆核内部`f/g/t` scratch及全部固定调度保持原几何。

## 验证与量化结果

- H123 store通过`t1`装载、scratch覆盖及下一事务完整重装单测。
- 小几何三种KeyGen算术store配置匹配golden，固定928拍，无`t1/inverse`角色冲突。
- 官方算术匹配`t0/r2`逐word golden，固定49,162,174拍。
- KeyGen四种共享服务组合及两种秘密候选路径通过PK/SK byte golden，固定53,995,036拍。
- 8-bit窄I/O wrapper通过PK/SK byte golden，固定54,002,607拍。
- 统一层次结构门禁确认没有独立`u_inverse_mem`，共享H123 vector store仍为一个实例。

## 结论

方案保留。官方TRIKE-2 KeyGen减少`244*64=15,616 bit`逻辑工作存储；实际RAMB36/RAMB18、写口mux、
LUT/FF、WNS和`cycles/Fmax`等待Vivado placed/routed复测。
