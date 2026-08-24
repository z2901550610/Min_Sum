# EXP-0101：统一KEM运行时几何多项式服务

## 目标与假设

KeyGen、Encaps和Decaps由公开operation单发射，三阶段普通多项式乘法不存在并发需求。最大几何、运行时
公开参数的乘法服务可复用一套product/result/sparse-index数据通路，并保持每档固定周期。

## 硬件边界

- `trike_kem_asic_top`按锁存operation选择一组start、几何、operand和result握手信号。
- 服务核固定为`R_BITS=106781`、`WORD_W=64`、`DIGIT_W=16`、`SPARSE_WEIGHT=263`，启用运行时几何。
- KeyGen求逆核保留内部稠密乘法器；独立KeyGen/Encaps/Decaps入口保留本地乘法模式。
- 调度和RAM访问只由operation与公开`r/words/weight`控制。

## 验证与量化结果

- 完整层次结构检查：1个共享流式乘法器加1个KeyGen求逆乘法器，共2个`trike_poly_mul_core`。
- 外置服务reference：KeyGen 53,995,036拍、Encaps 2,378,447拍、Decaps syndrome 1,086,187拍。
- 三条路径逐byte或逐word golden通过，外置服务与本地服务固定周期一致。
- `make check-rtl`、`make formal-fast`、`make test-unit`和结构检查通过。

## 结论

方案保留。RTL层次证明普通多项式服务收敛为单实例；LUT/FF/BRAM、WNS与`cycles/Fmax`等待统一ASIC
Vivado placed/routed报告，不由结构计数估算。
