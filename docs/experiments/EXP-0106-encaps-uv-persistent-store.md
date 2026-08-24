# EXP-0106：Encaps UV累加与持久结果共用RAM

## 目标与假设

Encaps UV核的累加结果就是L、K和密文阶段消费的最终`u/v`。UV计算与后续消费者按公开FSM串行，
两组244x64-bit持久RAM可同时承担乘法累加、结果重放和事务后半段读取。

## 硬件边界

- `trike_encaps_uv_core`支持内部或外部`u/v`同步RAM，乘法与结果输出调度保持一致。
- `trike_encaps_core`固定选择外部模式，把UV读写端口连接到自身持久`u/v` RAM。
- `ST_UV_RUN`独占RAM端口；L、K和密文状态按原有公开地址序列读取。
- H123、H4、共享乘法器及Decaps输入`u/v`存储不属于本实验。

## 验证与量化结果

- UV单元测试的内部、外部store配置均通过，固定424拍。
- 官方组件reference保持UV固定2,062,238拍并匹配逐word golden。
- Encaps三种共享服务组合均保持2,378,447拍，CT/SS逐byte golden通过。
- 8-bit窄I/O wrapper保持2,384,421拍，CT/SS逐byte golden通过。
- 统一Verilator层次恰好一个UV核并选择external store generate分支。

## 结论

方案保留。Encaps层次的四组逻辑`u/v` RAM收敛为两组持久逻辑RAM；实际RAMB36/RAMB18、
地址mux、LUT/FF、WNS和`cycles/Fmax`等待统一ASIC Vivado placed/routed报告。
