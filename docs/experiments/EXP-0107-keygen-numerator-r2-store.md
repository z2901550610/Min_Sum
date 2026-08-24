# EXP-0107：KeyGen numerator/r2原位覆盖

## 目标与假设

KeyGen最终乘法在完整装载`numerator=t0*t2+h2`和第二个inverse后才产生`r2`。numerator的最后读取与
`r2`首个结果写入由乘法器的固定LOAD/COMPUTE/OUTPUT状态分隔，可使用同一组244x64-bit同步RAM。

## 硬件边界

- `trike_keygen_arith_core`用一个`u_numerator_r2_mem`保存两阶段分子及最终`r2`。
- 读写角色mux由公开operation和输出状态选择，`r2`写入时原位覆盖第二阶段numerator。
- 断言检查numerator/r2读写互斥，并要求`r2`首写前两路最终乘法操作数已全部接受。
- H123 store、inverse、`t0`及求逆核内部scratch RAM不属于本实验。

## 验证与量化结果

- KeyGen算术官方`t0/r2`逐word golden通过，固定49,162,174拍。
- KeyGen四种共享服务组合及两种秘密候选路径通过PK/SK byte golden，固定53,995,036拍。
- 8-bit窄I/O wrapper通过PK/SK byte golden，固定54,002,607拍。
- 统一Verilator层次只包含`u_numerator_r2_mem`，不包含独立numerator或r2 RAM。
- 静态RTL、结构门禁及固定覆盖安全断言通过。

## 结论

方案保留。KeyGen算术层次的四组逻辑整环RAM收敛为三组，减少一组244x64-bit逻辑存储；实际
RAMB36/RAMB18、地址mux、LUT/FF、WNS和`cycles/Fmax`等待统一ASIC Vivado placed/routed报告。
