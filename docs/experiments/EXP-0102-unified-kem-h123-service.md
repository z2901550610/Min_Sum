# EXP-0102：KeyGen/Encaps共享H1/H2/H3服务

## 目标与假设

KeyGen与Encaps使用相同官方TRIKE-2 H1/H2/H3流程，并由公开operation单发射。一个向量服务可顺序处理
两阶段命令，复用DRNG Instantiate/Generate状态和parity mapper，不增加数据相关仲裁。

## 硬件边界

- KeyGen/Encaps控制器提供H123 start、32-byte seed流、三路vector返回流和done握手。
- `trike_kem_asic_top`实例化一个`r=15581`的`trike_h123_vectors`并按锁存operation选择客户端。
- 服务的压缩请求接入全局`trike_sm3_service`；反馈同时广播，只有公开活动状态消费。
- 独立KeyGen/Encaps入口保留本地H123模式。

## 验证与量化结果

- 完整层次结构检查：1个`trike_h123_vectors`和1个`trike_parity_map_stream`。
- KeyGen外置H123、SM3和乘法服务逐byte PK/SK golden通过，固定53,995,036拍。
- Encaps外置H123、SM3和乘法服务逐byte CT/SS golden通过，固定2,378,447拍。
- `make check-rtl`和统一ASIC结构检查通过。

## 结论

方案保留。H123控制、DRNG状态与parity mapper在RTL层次收敛为单服务；实际LUT/FF/BRAM、WNS与
`cycles/Fmax`等待统一ASIC Vivado placed/routed报告。
